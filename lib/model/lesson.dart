import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pedantic/pedantic.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/utils/utils.dart';

part 'lesson.g.dart';

/// Represents a lesson with a name, a description, a location, a start and an end.
@HiveType(typeId: 1)
class Lesson extends HiveObject with Comparable<Lesson> {
  /// The lesson name.
  @HiveField(0)
  String name;

  /// The lesson description.
  @HiveField(1)
  String description;

  /// The lesson location.
  @HiveField(2)
  String location;

  /// The lesson start.
  @HiveField(3)
  DateTime start;

  /// The lesson end.
  @HiveField(4)
  DateTime end;

  /// Creates a new lesson instance.
  Lesson({
    this.name,
    this.description,
    this.location,
    this.start,
    this.end,
  });

  /// Creates a new lesson instance from a Zimbra JSON map.
  Lesson.fromJson(Map<String, dynamic> inv) {
    Map<String, dynamic> comp = inv['comp'].first;
    name = comp['name'];
    location = comp['loc'];

    if (comp.containsKey('desc')) {
      description = comp['desc'].first['_content'];
    }

    start = DateTime.fromMillisecondsSinceEpoch(comp['s'].first['u']);
    end = DateTime.fromMillisecondsSinceEpoch(comp['e'].first['u']);
  }

  /// Creates a new lesson instance from a test JSON calendar.
  Lesson.fromTestJson(DateTime date, Map<String, dynamic> json) {
    List<dynamic> startParts = json['start'].split(':').map(int.parse).toList();
    List<dynamic> endParts = json['end'].split(':').map(int.parse).toList();

    name = json['name'];
    description = json['description'];
    location = json['location'];
    start = date.add(Duration(hours: startParts.first, minutes: startParts.last));
    end = date.add(Duration(hours: endParts.first, minutes: endParts.last));
  }

  @override
  String toString([BuildContext context]) {
    String hour;
    if (context == null) {
      hour = start.hour.withLeadingZero + ':' + start.minute.withLeadingZero + '-' + end.hour.withLeadingZero + ':' + end.minute.withLeadingZero;
    } else {
      String locale = EzLocalization.of(context).locale.languageCode;
      DateFormat formatter = DateFormat.Hm(locale);
      hour = formatter.format(start) + '-' + formatter.format(end);
    }

    return hour + ' ' + name + ' (' + location + ')';
  }

  @override
  int compareTo(Lesson other) => start.compareTo(other.start);
}

/// The lesson model.
class LessonModel extends UnicaenTimetableModel {
  /// The lessons Hive box name.
  static const String _LESSONS_HIVE_BOX = 'lessons';

  /// The lessons colors Hive box name.
  static const String _LESSONS_COLORS_HIVE_BOX = 'lessons_colors';

  /// The lessons Hive box.
  LazyBox<List> _lessonsBox;

  /// The lessons colors Hive box.
  Box<int> _lessonsColorsBox;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    Hive.registerAdapter(LessonAdapter());
    _lessonsBox = await Hive.openLazyBox<List>(_LESSONS_HIVE_BOX);
    _lessonsColorsBox = await Hive.openBox(_LESSONS_COLORS_HIVE_BOX);

    markInitialized();
  }

  /// Returns the lessons of a date.
  Future<List<Lesson>> getLessonsForDate(DateTime date) async {
    List result = await _lessonsBox.get(date.yearMonthDay.toString(), defaultValue: []);
    return List<Lesson>.from(result);
  }

  /// Selects the lessons available between two dates.
  Future<List<Lesson>> selectLessons([DateTime min, DateTime max]) async {
    List<Lesson> result = [];
    DateTime date = min;
    while (date.isBefore(max)) {
      result.addAll(await getLessonsForDate(date));
      date = date.add(const Duration(days: 1));
    }
    return result;
  }

  /// Returns the remaining today's lessons.
  Future<List<Lesson>> get remainingLessons async {
    DateTime now = DateTime.now();
    List<Lesson> result = await getLessonsForDate(now);
    for (Lesson lesson in List<Lesson>.of(result, growable: false)) {
      if (now.isAfter(lesson.end)) {
        result.remove(lesson);
      }
    }

    return result..sort();
  }

  /// Clears all lessons.
  Future<void> clearLessons() async {
    await _lessonsBox.clear();
    notifyListeners();
  }

  /// Returns all weeks handled.
  Future<List<DateTime>> get availableWeeks async {
    Set<DateTime> result = HashSet();
    for (String date in _lessonsBox.keys) {
      DateTime monday = DateTime.parse(date).atMonday;
      if (!result.contains(monday)) {
        result.add(monday);
      }
    }
    return result.toList()..sort();
  }

  /// Synchronizes the app with Zimbra.
  Future<dynamic> synchronizeFromZimbra({
    @required SettingsModel settingsModel,
    @required User user,
  }) async {
    try {
      dynamic result = await user.synchronizeFromZimbra(
        lessonsBox: _lessonsBox,
        settingsModel: settingsModel,
      );

      if(result != null) {
        return result;
      }

      if (Platform.isAndroid) {
        Map<String, List<_JsonLesson>> jsonContent = HashMap();
        for(String boxKey in _lessonsBox.keys) {
          DateTime date = DateTime.parse(boxKey);
          String key = date.millisecondsSinceEpoch.toString();
          jsonContent[key] = (await _lessonsBox.get(boxKey)).map((lesson) => _JsonLesson.fromLesson(lesson)).toList();
        }

        Directory directory = await getApplicationDocumentsDirectory();
        File('${directory.path}/android_lessons.json').writeAsStringSync(jsonEncode(jsonContent), flush: true);
        unawaited(UnicaenTimetableApp.CHANNEL.invokeMethod('sync.finished'));
      }

      notifyListeners();
      return true;
    } catch (ex, stacktrace) {
      print(ex);
      print(stacktrace);
    }
    return false;
  }

  /// Returns the last modification time.
  DateTime get lastModificationTime => File(_lessonsBox.path).lastModifiedSync();

  /// Returns the color of a lesson (depends on the name).
  Color getLessonColor(Lesson lesson) {
    int value = _lessonsColorsBox.get(lesson.name);
    return value == null ? null : Color(value);
  }

  /// Sets the lesson color according to its name.
  Future<void> setLessonColor(Lesson lesson, Color color) async {
    await _lessonsColorsBox.put(lesson.name, color.value);
    notifyListeners();
  }

  /// Resets the lesson color according to its name.
  Future<void> resetLessonColor(Lesson lesson) async {
    await _lessonsColorsBox.delete(lesson.name);
    notifyListeners();
  }
}

/// Represents a JSON lesson.
class _JsonLesson {
  /// The lesson name.
  final String name;

  /// The lesson start timestamp.
  final int start;

  /// The lesson end timestamp.
  final int end;

  /// The lesson location.
  final String location;

  /// Creates a new JSON lesson instance from a lesson.
  _JsonLesson.fromLesson(Lesson lesson)
      : name = lesson.name,
        start = lesson.start.millisecondsSinceEpoch,
        end = lesson.end.millisecondsSinceEpoch,
        location = lesson.location;

  /// Converts this lesson to a JSON map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'start': start,
        'end': end,
        'location': location,
      };
}
