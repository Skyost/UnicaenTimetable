import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eventide/eventide.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/color_resolver.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/storage.dart';
import 'package:unicaen_timetable/model/settings/device_calendar.dart';
import 'package:unicaen_timetable/model/user/calendar.dart';
import 'package:unicaen_timetable/utils/date_time_range.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The lesson repository provider.
final lessonRepositoryProvider = AsyncNotifierProvider<LessonRepository, DateTime?>(LessonRepository.new);

/// The lesson model.
class LessonRepository extends AsyncNotifier<DateTime?> {
  @override
  FutureOr<DateTime?> build() async {
    int? lastUpdate = await UnicaenTimetableRoot.channel.invokeMethod<int>('sync.get');
    if (lastUpdate == 0) {
      lastUpdate = null;
    }
    return lastUpdate == null ? null : DateTime.fromMillisecondsSinceEpoch(lastUpdate * 1000);
  }

  /// Synchronizes the app with Zimbra.
  Future<RequestResult> refreshLessons() async {
    try {
      Calendar? calendar = await ref.read(calendarProvider.future);
      if (calendar == null) {
        return const RequestError(httpCode: HttpStatus.unauthorized);
      }

      RequestResult result = await calendar.downloadLessons();
      if (result is! RequestSuccess) {
        return result;
      }

      List<Lesson> lessons = result.object;
      await ref.read(localStorageProvider).replaceLessons(lessons);

      Directory directory = await getApplicationSupportDirectory();
      File lessonsFile = File('${directory.path}/lessons.json');
      if (!lessonsFile.existsSync()) {
        lessonsFile.createSync(recursive: true);
      }
      Map<DateTime, List<Lesson>> groupedLessons = _groupLessonsByDay(lessons, minimumDateTime: DateTime.now().yearMonthDay);
      lessonsFile.writeAsStringSync(
        jsonEncode({
          for (MapEntry<DateTime, List<Lesson>> entry in groupedLessons.entries)
            '${entry.key.year}-${entry.key.month.withLeadingZero}-${entry.key.day.withLeadingZero}': [
              for (Lesson lesson in entry.value) lesson.toJson(),
            ],
        }),
        flush: true,
      );

      int? lastUpdate = await UnicaenTimetableRoot.channel.invokeMethod<int>('sync.refresh');
      if (lastUpdate != null) {
        state = AsyncData(DateTime.fromMillisecondsSinceEpoch(lastUpdate * 1000));
      }
      _refreshPlatformCalendar(lessons);

      return result;
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return const RequestError();
  }

  /// Refreshes the platform data.
  Future<void> _refreshPlatformCalendar(List<Lesson> lessons) async {
    bool syncWithDevice = await ref.read(syncWithDeviceCalendarSettingsEntryProvider.future);
    if (syncWithDevice) {
      ETCalendar? calendar = await ref.read(unicaenDeviceCalendarProvider.notifier).createCalendarOnDeviceIfNotExist();
      Iterable<ETEvent> events = await calendar.retrieveEvents();
      Eventide eventide = Eventide();
      for (ETEvent event in events) {
        await eventide.deleteEvent(eventId: event.id);
      }
      for (Lesson lesson in lessons) {
        await eventide.createEvent(
          calendarId: calendar.id,
          title: lesson.name,
          description: lesson.description,
          startDate: lesson.dateTime.start,
          endDate: lesson.dateTime.end,
        );
      }
    }
  }

  /// Groups the given [lessons] by day.
  Map<DateTime, List<Lesson>> _groupLessonsByDay(List<Lesson> lessons, {DateTime? minimumDateTime}) {
    Map<DateTime, List<Lesson>> groupedLessons = {};
    for (Lesson lesson in lessons) {
      DateTime currentDay = lesson.dateTime.start.yearMonthDay;
      DateTime endDay = lesson.dateTime.end.yearMonthDay;

      while (currentDay.isBefore(endDay) || currentDay.isAtSameMomentAs(endDay)) {
        DateTime lessonStart = currentDay.isAtSameMomentAs(lesson.dateTime.start.yearMonthDay) ? lesson.dateTime.start : DateTime(currentDay.year, currentDay.month, currentDay.day, 0, 0);
        DateTime lessonEnd = currentDay.isAtSameMomentAs(lesson.dateTime.end.yearMonthDay) ? lesson.dateTime.end : DateTime(currentDay.year, currentDay.month, currentDay.day, 23, 59, 59);
        if (minimumDateTime == null || currentDay.isAtSameMomentAs(minimumDateTime) || currentDay.isAfter(minimumDateTime)) {
          groupedLessons
              .putIfAbsent(
                currentDay,
                () => [],
              )
              .add(
                lesson.copyWith(
                  dateTime: DateTimeRange(
                    start: lessonStart,
                    end: lessonEnd,
                  ),
                ),
              );
          groupedLessons[currentDay] = List.of(groupedLessons[currentDay]!)..sort();
        }
        currentDay = currentDay.add(const Duration(days: 1));
      }
    }

    return groupedLessons;
  }
}

/// The lesson repository provider.
final lessonsProvider = AsyncNotifierProvider.autoDispose.family<LessonsNotifier, List<LessonWithColor>, DateTimeRange?>(LessonsNotifier.new);

/// The remaining lessons provider.
final remainingLessonsProvider = FutureProvider<List<LessonWithColor>>((ref) async {
  DateTime now = DateTime.now();
  List<LessonWithColor> lessons = await ref.watch(lessonsProvider(DateTimeRange.oneDay(DateTime.now().yearMonthDay)).future);
  return [
    for (LessonWithColor lesson in lessons)
      if (!now.isAfter(lesson.dateTime.end)) lesson,
  ];
});

/// The lesson model.
class LessonsNotifier extends AsyncNotifier<List<LessonWithColor>> {
  /// The date time range.
  final DateTimeRange? arg;

  /// Creates a new lessons notifier.
  LessonsNotifier(this.arg);

  @override
  FutureOr<List<LessonWithColor>> build() async {
    LocalStorage storage = ref.watch(localStorageProvider);
    ColorResolver colorResolver = await ref.watch(lessonColorResolverProvider.future);
    List<Lesson> lessons = arg == null ? (await storage.selectAllLessons()) : (await storage.selectLessons(arg!));
    return [
      for (Lesson lesson in lessons)
        LessonWithColor.fromLesson(
          lesson: lesson,
          color: colorResolver.resolveColor(lesson),
        ),
    ];
  }
}

/// A lesson that holds a color.
class LessonWithColor extends Lesson {
  /// The color.
  final Color? color;

  /// Creates a new lesson with color.
  const LessonWithColor({
    required super.name,
    super.description,
    required super.location,
    required super.dateTime,
    this.color,
  });

  /// Creates a new lesson with color.
  LessonWithColor.fromLesson({
    required Lesson lesson,
    Color? color,
  }) : this(
         name: lesson.name,
         description: lesson.description,
         location: lesson.location,
         dateTime: lesson.dateTime,
         color: color,
       );
}
