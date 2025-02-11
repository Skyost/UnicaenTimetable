import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/color_resolver.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/storage.dart';
import 'package:unicaen_timetable/model/user/calendar.dart';
import 'package:unicaen_timetable/utils/date_time_range.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The lesson repository provider.
final lessonRepositoryProvider = AsyncNotifierProvider.autoDispose<LessonRepository, DateTime?>(LessonRepository.new);

/// The lesson model.
class LessonRepository extends AutoDisposeAsyncNotifier<DateTime?> {
  @override
  FutureOr<DateTime?> build() async {
    File file = await _getFile(create: false);
    return file.existsSync() ? file.lastModifiedSync() : null;
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

      DateTime now = DateTime.now();
      File file = await _getFile();
      file.writeAsStringSync(
        jsonEncode(
          {
            'lastModification': now.millisecondsSinceEpoch,
          },
        ),
      );
      state = AsyncData(now);
      if (Platform.isAndroid) {
        UnicaenTimetableRoot.channel.invokeMethod('sync.finished');
      }

      return result;
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return const RequestError();
  }

  /// Returns the lessons color file.
  Future<File> _getFile({bool create = true}) async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    File file = File('${appDocumentsDir.path}/repository.json');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
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
