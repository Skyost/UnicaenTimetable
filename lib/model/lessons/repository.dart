import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eventide/eventide.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/color_resolver.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/storage.dart';
import 'package:unicaen_timetable/model/settings/device_calendar.dart';
import 'package:unicaen_timetable/model/user/calendar.dart';
import 'package:unicaen_timetable/utils/date_time_range.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The lesson repository provider.
final lessonRepositoryProvider = AsyncNotifierProvider.autoDispose<LessonRepository, DateTime?>(LessonRepository.new);

/// The lesson model.
class LessonRepository extends AutoDisposeAsyncNotifier<DateTime?> {
  @override
  FutureOr<DateTime?> build() async {
    int? lastUpdate = await UnicaenTimetableRoot.channel.invokeMethod<int>('sync.get');
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

      // TODO: Add the widget data.
      int? lastUpdate = await UnicaenTimetableRoot.channel.invokeMethod<int>('sync.refresh');
      if (lastUpdate != null) {
        state = AsyncData(DateTime.fromMillisecondsSinceEpoch(lastUpdate * 1000));
      }
      _refreshPlatform(lessons);

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
  Future<void> _refreshPlatform(List<Lesson> lessons) async {
    bool syncWithDevice = await ref.read(syncWithDeviceCalendarSettingsEntryProvider.future);
    if (syncWithDevice) {
      ETCalendar? calendar = await ref.read(unicaenDeviceCalendarProvider.future);
      calendar ??= await ref.read(unicaenDeviceCalendarProvider.notifier).createCalendarOnDevice();
      Eventide eventide = Eventide();
      for (Lesson lesson in lessons) {
        await eventide.createEvent(
          calendarId: calendar.id,
          title: lesson.name,
          startDate: lesson.dateTime.start,
          endDate: lesson.dateTime.end,
        );
      }
    }
    await HomeWidget.saveWidgetData('lessons', jsonEncode(_toMap(lessons)));
    await HomeWidget.updateWidget(
      name: 'TodayWidget',
      androidName: 'TodayWidget',
      iOSName: 'TodayWidget',
    );
  }

  /// Converts the [lessons] list to a map.
  Map<String, List<Map>> _toMap(List<Lesson> lessons) {
    Map<String, List<Map>> result = {};
    for (Lesson lesson in lessons) {
      DateTime start = lesson.dateTime.start.yearMonthDay;
      String key = '${start.year}-${start.month.withLeadingZero}-${start.day.withLeadingZero}';
      while (start.isBefore(lesson.dateTime.end)) {
        List<Map>? dayLessons = result[key];
        if (dayLessons == null) {
          result[key] = [lesson.toJson()];
        } else {
          dayLessons.add(lesson.toJson());
        }
        start = start.add(const Duration(days: 1));
      }
    }
    return result;
  }
}

/// The lesson repository provider.
final lessonsProvider = AsyncNotifierProvider.autoDispose.family<LessonsNotifier, List<Lesson>, DateTimeRange?>(LessonsNotifier.new);

/// The remaining lessons provider.
final remainingLessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  DateTime now = DateTime.now();
  List<Lesson> lessons = await ref.watch(lessonsProvider(DateTimeRange.oneDay(DateTime.now().yearMonthDay)).future);
  return [
    for (Lesson lesson in lessons)
      if (!now.isAfter(lesson.dateTime.end)) lesson,
  ];
});

/// The lesson model.
class LessonsNotifier extends AutoDisposeFamilyAsyncNotifier<List<Lesson>, DateTimeRange?> {
  @override
  FutureOr<List<Lesson>> build(DateTimeRange? arg) async {
    LocalStorage storage = ref.watch(localStorageProvider);
    ColorResolver colorResolver = await ref.watch(lessonColorResolverProvider.future);
    List<Lesson> lessons = arg == null ? (await storage.selectAllLessons()) : (await storage.selectLessons(arg));
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
