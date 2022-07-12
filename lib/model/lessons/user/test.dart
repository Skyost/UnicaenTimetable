import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:unicaen_timetable/model/lessons/authentication/result.dart';
import 'package:unicaen_timetable/model/lessons/authentication/state.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/utils/calendar_url.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The test user (for Apple Store review).
class TestUser extends User {
  /// Creates a new test user instance.
  TestUser(User? user)
      : super(
          username: user?.username ?? '',
          password: user?.password ?? '',
        );

  @override
  Future<RequestResultState> login(CalendarUrl calendarUrl) async {
    Map<String, dynamic> testData = jsonDecode(await rootBundle.loadString('assets/test_data.json'));
    return username == testData['username'] && password == testData['password'] ? RequestResultState.success : RequestResultState.unauthorized;
  }

  @override
  Future<RequestResult<Map<DateTime, List<Lesson>>>> downloadLessons(CalendarUrl calendarUrl) async {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.add(const Duration(days: 7));
    }

    DateTime monday = now.yearMonthDay.atMonday;
    Map<DateTime, List<Lesson>> result = {};
    Map<String, dynamic> calendar = jsonDecode(await rootBundle.loadString('assets/test_data.json'))['calendar'];
    List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    for (int i = 0; i < days.length; i++) {
      DateTime date = monday.add(Duration(days: i));
      result[date] = _decodeDay(date, calendar, days[i]);
    }
    return RequestResult(
      state: RequestResultState.success,
      object: result,
    );
  }

  /// Decodes the specified day from the test calendar.
  List<Lesson> _decodeDay(DateTime date, Map<String, dynamic> calendar, String day) {
    List<Lesson> result = [];
    List<dynamic> lessons = calendar[day];
    for (dynamic lesson in lessons) {
      result.add(Lesson.fromTestJson(date, lesson));
    }
    return result;
  }
}
