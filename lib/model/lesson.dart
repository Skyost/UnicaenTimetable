import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pedantic/pedantic.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/app_model.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/utils/utils.dart';

part 'lesson.g.dart';

@HiveType(typeId: 1)
class Lesson extends HiveObject with Comparable<Lesson> {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  String location;

  @HiveField(3)
  DateTime start;

  @HiveField(4)
  DateTime end;

  Lesson({
    this.name,
    this.description,
    this.location,
    this.start,
    this.end,
  });

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
  String toString() {
    return start.hour.withLeadingZero + ':' + start.minute.withLeadingZero + '-' + end.hour.withLeadingZero + ':' + end.minute.withLeadingZero + ' ' + name + ' (' + location + ')';
  }

  @override
  int compareTo(Lesson other) => start.compareTo(other.start);
}

class LessonModel extends AppModel {
  static const String _LESSONS_HIVE_BOX = 'lessons';
  static const String _LESSONS_COLORS_HIVE_BOX = 'lessons_colors';

  LazyBox<List> _lessonsBox;
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

  Future<List<Lesson>> getLessonsForDate(DateTime date) async {
    List result = await _lessonsBox.get(date.yearMonthDay.toString(), defaultValue: []);
    return List<Lesson>.from(result);
  }

  Future<List<Lesson>> selectLessons([DateTime min, DateTime max]) async {
    List<Lesson> result = [];
    DateTime date = min;
    while (date.isBefore(max)) {
      result.addAll(await getLessonsForDate(date));
      date = date.add(const Duration(days: 1));
    }
    return result;
  }

  Future<List<Lesson>> get remainingLessons async {
    DateTime now = DateTime.now();
    List<Lesson> result = await getLessonsForDate(now);
    for (Lesson lesson in List.of(result)) {
      if (!now.isAfter(lesson.end)) {
        continue;
      }
      result.remove(lesson);
    }

    return result..sort();
  }

  Future<void> clearLessons() async {
    await _lessonsBox.clear();
    notifyListeners();
  }

  Color getLessonColor(Lesson lesson) {
    int value = _lessonsColorsBox.get(lesson.name);
    return value == null ? null : Color(value);
  }

  Future<void> setLessonColor(Lesson lesson, Color color) async {
    await _lessonsColorsBox.put(lesson.name, color.value);
    notifyListeners();
  }

  Future<void> resetLessonColor(Lesson lesson) async {
    await _lessonsColorsBox.delete(lesson.name);
    notifyListeners();
  }

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

  Future<dynamic> synchronizeFromZimbra({
    @required SettingsModel settingsModel,
    @required User user,
  }) async {
    try {
      Map<String, List<_JsonLesson>> jsonContent = HashMap();
      if (await user.isTestUser) {
        await _lessonsBox.clear();

        DateTime now = DateTime.now();
        if(now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
          now = now.add(const Duration(days: 7));
        }
        DateTime monday = now.yearMonthDay.atMonday;

        Map<String, dynamic> calendar = jsonDecode(await rootBundle.loadString('assets/test_data.json'))['calendar'];
        List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
        for (int i = 0; i < days.length; i++) {
          DateTime date = monday.add(Duration(days: i));
          List<Lesson> lessons = _decodeDay(date, calendar, days[i]);

          await _lessonsBox.put(date.toString(), lessons);
          jsonContent[date.millisecondsSinceEpoch.toString()] = lessons.map((lesson) => _JsonLesson.fromLesson(lesson)).toList();
        }
      } else {
        Response response = await user.requestCalendar(settingsModel);
        if (response.statusCode != 200) {
          return response;
        }

        Map<String, dynamic> body = jsonDecode(response.body);
        await _lessonsBox.clear();

        if (body.isNotEmpty) {
          List<dynamic> appt = body['appt'];
          for (dynamic jsonData in appt) {
            if (!jsonData.containsKey('inv')) {
              continue;
            }

            Lesson lesson = Lesson.fromJson(jsonData['inv'].first);
            DateTime start = lesson.start.yearMonthDay;
            await _lessonsBox.put(start.toString(), (await getLessonsForDate(start))..add(lesson));

            String key = start.millisecondsSinceEpoch.toString();
            List<_JsonLesson> jsonLessons = jsonContent[key] ?? [];
            jsonLessons.add(_JsonLesson.fromLesson(lesson));
            jsonContent[key] = jsonLessons;
          }
        }
      }

      if (Platform.isAndroid) {
        Directory directory = await getApplicationDocumentsDirectory();
        File('${directory.path}/android_lessons.json').writeAsStringSync(jsonEncode(jsonContent));
        unawaited(UnicaenTimetableApp.CHANNEL.invokeMethod('sync.finished'));
      }

      notifyListeners();
      return true;
    } catch (ex, stacktrace) {
      print(ex);
      print(stacktrace);
      return false;
    }
  }

  List<Lesson> _decodeDay(DateTime date, Map<String, dynamic> calendar, String day) {
    List<Lesson> result = [];
    List<dynamic> lessons = calendar[day];
    for (dynamic lesson in lessons) {
      result.add(Lesson.fromTestJson(date, lesson));
    }
    return result;
  }

  DateTime get lastModificationTime => File(_lessonsBox.path).lastModifiedSync();
}

class _JsonLesson {
  final String name;
  final int start;
  final int end;
  final String location;

  _JsonLesson.fromLesson(Lesson lesson)
      : name = lesson.name,
        start = lesson.start.millisecondsSinceEpoch,
        end = lesson.end.millisecondsSinceEpoch,
        location = lesson.location;

  Map<String, dynamic> toJson() => {
        'name': name,
        'start': start,
        'end': end,
        'location': location,
      };
}
