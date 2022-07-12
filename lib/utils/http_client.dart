import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/utils/calendar_url.dart';

/// The app http client.
class UnicaenTimetableHttpClient {
  /// The app user agent.
  final String userAgent;

  /// Creates a new app http client.
  const UnicaenTimetableHttpClient({
    this.userAgent = 'Unicaen Timetable',
  });

  /// Connects to the calendar URL (using the specified credentials).
  Future<Response?> connect(CalendarUrl calendarUrl, User user) async {
    try {
      Map<String, String> headers = HashMap();
      headers[HttpHeaders.userAgentHeader] = '$userAgent (${Platform.isAndroid ? 'Android' : 'iOS'})';
      headers[HttpHeaders.authorizationHeader] = 'Basic ${base64Encode(utf8.encode('${user.username}:${user.password}'))}';

      return get(calendarUrl.build(user)!, headers: headers);
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
      return null;
    }
  }
}
