import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:unicaen_timetable/model/lessons/authentication/result.dart';
import 'package:unicaen_timetable/model/lessons/authentication/state.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/utils/calendar_url.dart';
import 'package:unicaen_timetable/utils/http_client.dart';
import 'package:unicaen_timetable/utils/utils.dart';

part 'user.g.dart';

/// Represents an user with an username and a password.
@HiveType(typeId: 0)
class User extends HiveObject {
  /// The username.
  @HiveField(0)
  String username;

  /// The password.
  @HiveField(1)
  String password;

  /// Creates a new username instance.
  User({
    required this.username,
    required this.password,
  });

  /// Returns the username without the @.
  String get usernameWithoutAt => username.split('@').first;

  /// Tries to login this user.
  Future<RequestResultState> login(CalendarUrl calendarUrl) async {
    UnicaenTimetableHttpClient client = const UnicaenTimetableHttpClient();
    Response? response = await client.connect(calendarUrl, this);
    if (response?.statusCode == 401 || response?.statusCode == 404) {
      username = username.endsWith('@etu.unicaen.fr') ? usernameWithoutAt : ('$username@etu.unicaen.fr');
      if (isInBox) {
        save();
      }
      response = await client.connect(calendarUrl, this);
    }

    return RequestResultState.fromResponse(response);
  }

  /// Tries to synchronize this user from Zimbra.
  Future<RequestResult<Map<DateTime, List<Lesson>>>> downloadLessons(CalendarUrl calendarUrl) async {
    UnicaenTimetableHttpClient client = const UnicaenTimetableHttpClient();
    Response? response = await client.connect(calendarUrl, this);
    RequestResultState state = RequestResultState.fromResponse(response);
    Map<DateTime, List<Lesson>> result = {};

    if (state == RequestResultState.success) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response!.bodyBytes));
      if (body.isNotEmpty) {
        List<dynamic> appt = body['appt'];
        for (dynamic jsonData in appt) {
          if (!jsonData.containsKey('inv')) {
            continue;
          }

          Lesson lesson = Lesson.fromJson(jsonData['inv'].first);
          DateTime start = lesson.start.yearMonthDay;
          if (result.containsKey(start)) {
            List<Lesson> lessons = result[start]!;
            lessons.add(lesson);
            result[start] = lessons;
          } else {
            result[start] = [lesson];
          }
        }
      }
    }
    return RequestResult(
      state: state,
      object: result,
    );
  }
}
