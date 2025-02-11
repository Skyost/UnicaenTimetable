import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/settings/calendar.dart';
import 'package:unicaen_timetable/model/user/user.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The calendar provider.
final calendarProvider = FutureProvider<Calendar?>((ref) async {
  User? user = await ref.watch(userProvider.future);
  return await ref.watch(userCalendarProvider(user).future);
});

/// The user calendar provider.
final userCalendarProvider = FutureProvider.family<Calendar?, User?>((ref, arg) async {
  switch (arg) {
    case CredentialsUser(:final username, :final password):
      return ZimbraCalendar(
        server: await ref.watch(serverSettingsEntryProvider.future),
        calendar: await ref.watch(calendarNameSettingsEntryProvider.future),
        additionalParameters: await ref.watch(additionalParametersSettingsEntryProvider.future),
        interval: await ref.watch(intervalSettingsEntryProvider.future),
        username: username,
        password: password,
      );
    case TestUser():
      return TestCalendar();
    default:
      return null;
  }
});

/// Represents a remote calendar.
mixin Calendar {
  /// Tries to get the calendar.
  /// Returns the HTTP response code.
  Future<int> get();

  /// Tries to synchronize this calendar from Zimbra.
  Future<RequestResult> downloadLessons();
}

/// Allows to request a calendar from Zimbra.
class ZimbraCalendar with Calendar {
  /// The app user agent.
  final String userAgent;

  /// The server.
  final String server;

  /// The calendar.
  final String calendar;

  /// Contains some additional parameters.
  final String additionalParameters;

  /// The interval.
  final int? interval;

  /// The username.
  final String username;

  /// The password.
  final String password;

  /// Creates a new Zimbra calendar instance.
  const ZimbraCalendar({
    this.userAgent = 'Unicaen Timetable',
    required this.server,
    required this.calendar,
    required this.additionalParameters,
    required this.interval,
    required this.username,
    required this.password,
  });

  @override
  Future<int> get() async {
    http.Response? response = await _request();
    return response?.statusCode ?? HttpStatus.networkConnectTimeoutError;
  }

  @override
  Future<RequestResult> downloadLessons() async {
    http.Response? response = await _request();
    if (response?.statusCode != HttpStatus.ok) {
      return RequestError(
        httpCode: response?.statusCode,
      );
    }
    Map<String, dynamic> body = jsonDecode(utf8.decode(response!.bodyBytes));
    List<Lesson> result = [];
    if (body.isNotEmpty) {
      List<dynamic> appt = body['appt'];
      for (dynamic jsonData in appt) {
        if (!jsonData.containsKey('inv')) {
          continue;
        }
        result.add(Lesson.fromZimbra(jsonData['inv'].first));
      }
    }
    return RequestSuccess(object: result);
  }

  /// Connects to the calendar URL (using the specified credentials).
  Future<http.Response?> _request() async {
    try {
      Future<http.Response> buildUrlAndGet(String username) async {
        Map<String, String> headers = {
          HttpHeaders.userAgentHeader: '$userAgent (${Platform.isAndroid ? 'Android' : 'iOS'})',
          HttpHeaders.authorizationHeader: 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        };
        return await http.get(_buildUrl(username), headers: headers);
      }

      http.Response response = await buildUrlAndGet(username);
      if (response.statusCode == 401 || response.statusCode == 404) {
        response = await buildUrlAndGet(username.endsWith('@etu.unicaen.fr') ? username.split('@').first : '$username@etu.unicaen.fr');
      }
      return response;
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
      return null;
    }
  }

  /// Returns the URL.
  Uri _buildUrl(String username) {
    String url = '$server/home/$username/${Uri.encodeFull(calendar)}?auth=ba&fmt=json';
    if (additionalParameters.isNotEmpty) {
      url += '&$additionalParameters';
    }

    if (interval != null && interval! > 0) {
      DateTime now = DateTime.now().atMonday.yearMonthDay;
      DateTime min = now.subtract(Duration(days: interval! * 7));
      DateTime max = now.add(Duration(days: interval! * 7)).add(const Duration(days: DateTime.friday));

      url += '&start=${min.year}/${min.month.withLeadingZero}/${min.day.withLeadingZero}';
      url += '&end=${max.year}/${max.month.withLeadingZero}/${max.day.withLeadingZero}';
    }

    return Uri.parse(url);
  }
}

/// Allows to test the application using debug data.
class TestCalendar with Calendar {
  @override
  Future<int> get() => Future.value(HttpStatus.ok);

  @override
  Future<RequestResult> downloadLessons() async {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.add(const Duration(days: 7));
    }

    DateTime monday = now.yearMonthDay.atMonday;
    List<Lesson> result = [];
    Map<String, dynamic> calendar = jsonDecode(await rootBundle.loadString('assets/test_data.json'))['calendar'];
    List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    for (int i = 0; i < days.length; i++) {
      DateTime date = monday.add(Duration(days: i));
      result.addAll(_decodeDay(date, calendar, days[i]));
    }
    return RequestSuccess(
      object: result,
    );
  }

  /// Decodes the specified day from the test calendar.
  List<Lesson> _decodeDay(DateTime date, Map<String, dynamic> calendar, String day) {
    List<Lesson> result = [];
    List<dynamic> lessons = calendar[day];
    for (dynamic lesson in lessons) {
      result.add(Lesson.fromTest(date, lesson));
    }
    return result;
  }
}

/// Represents an request result.
sealed class RequestResult {
  /// Creates a new result instance.
  const RequestResult();
}

/// Returned when the request has succeeded.
class RequestSuccess extends RequestResult {
  /// The returned object.
  final List<Lesson> object;

  /// Creates a new result success instance.
  const RequestSuccess({
    required this.object,
  });
}

/// Returned when an error occurred.
class RequestError extends RequestResult {
  /// The HTTP code.
  final int? httpCode;

  /// Creates a new result error instance.
  const RequestError({
    this.httpCode,
  });
}
