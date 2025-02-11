import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/utils/date_time_range.dart';
import 'package:unicaen_timetable/utils/sqlite.dart';
import 'package:unicaen_timetable/utils/utils.dart';

part 'storage.g.dart';

/// Represents a [Lesson].
@DataClassName('_DriftLesson')
class Lessons extends Table {
  /// Maps to [Lesson.name].
  TextColumn get name => text()();

  /// Maps to [Lesson.description].
  TextColumn get description => text().nullable()();

  /// Maps to [Lesson.location].
  TextColumn get location => text()();

  /// Maps to [Lesson.start].
  DateTimeColumn get start => dateTime()();

  /// Maps to [Lesson.end].
  DateTimeColumn get end => dateTime()();
}

/// The local storage provider.
final localStorageProvider = Provider.autoDispose<LocalStorage>((ref) {
  LocalStorage storage = LocalStorage(ref);
  ref.onDispose(storage.close);
  ref.cacheFor(const Duration(seconds: 1));
  return storage;
});

/// Stores lessons using Drift.
@DriftDatabase(tables: [Lessons])
class LocalStorage extends _$LocalStorage {
  /// The database file name.
  static const _kDbFileName = 'lessons';

  /// The Riverpod's ref instance.
  final Ref ref;

  /// Creates a new Drift storage instance.
  LocalStorage(
    this.ref,
  ) : super(
          SqliteUtils.openConnection(_kDbFileName),
        );

  @override
  int get schemaVersion => 1;

  /// Selects all lessons.
  Future<List<Lesson>> selectAllLessons() async {
    List<_DriftLesson> list = await (select(lessons)
          ..orderBy(
            [
              (table) => OrderingTerm(
                    expression: table.start,
                  )
            ],
          ))
        .get();
    return [
      for (_DriftLesson driftLesson in list) driftLesson.asLesson,
    ];
  }

  /// Returns the lessons of a date.
  Future<List<Lesson>> getLessonsForDate(DateTime date) => selectLessons(DateTimeRange.oneDay(date.yearMonthDay));

  /// Selects the lessons available between two dates.
  /// This function tolerates overlaps.
  Future<List<Lesson>> selectLessons(DateTimeRange range) async {
    List<_DriftLesson> list = await (select(lessons)
          ..where((lesson) => (lesson.end.isSmallerThanValue(range.start) | lesson.start.isBiggerThanValue(range.end)).not())
          ..orderBy(
            [
              (table) => OrderingTerm(
                    expression: table.start,
                  )
            ],
          ))
        .get();
    List<Lesson> result = [];
    for (_DriftLesson driftLesson in list) {
      Lesson lesson = driftLesson.asLesson;
      if (DateTimeRange.intersection(range, lesson.dateTime) != null) {
        result.add(lesson);
      }
    }
    return result;
  }

  /// Replaces the current lessons by the [newLessons].
  Future<void> replaceLessons(List<Lesson> newLessons) async {
    await batch((batch) {
      batch.deleteAll(lessons);
      batch.insertAll(lessons, newLessons.map((totp) => totp.asDriftLesson));
    });
    ref.notifyListeners();
  }

  /// Returns all weeks handled.
  Future<List<DateTime>> getAvailableWeeks() async {
    Set<DateTime> result = {};
    List<Lesson> lessons = await selectAllLessons();
    for (Lesson lesson in lessons) {
      DateTime monday = lesson.dateTime.start.atMonday;
      while (monday.isBefore(lesson.dateTime.end)) {
        result.add(monday);
        monday = monday.add(const Duration(days: 7));
      }
    }
    return result.toList()..sort();
  }
}

/// Contains some useful methods from the generated [Secret] class.
extension _UnicaenTimetable on _DriftLesson {
  /// Converts this instance to a [Totp].
  Lesson get asLesson => Lesson(
        name: name,
        description: description,
        location: location,
        dateTime: DateTimeRange(
          start: start,
          end: end,
        ),
      );
}

/// Contains some useful methods to use [Totp] with Drift.
extension _Drift on Lesson {
  /// Converts this instance to a Drift generated [_DriftLesson].
  _DriftLesson get asDriftLesson => _DriftLesson(
        name: name,
        description: description,
        location: location,
        start: dateTime.start,
        end: dateTime.end,
      );
}
