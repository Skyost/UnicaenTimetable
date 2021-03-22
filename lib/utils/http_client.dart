import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:unicaen_timetable/model/user.dart';

/// The app http client.
class UnicaenTimetableHttpClient {
  /// The app user agent.
  final String userAgent;

  /// Creates a new app http client.
  const UnicaenTimetableHttpClient({
    this.userAgent = 'Unicaen Timetable',
  });

  /// Connects to the specified url (using the specified credentials).
  Future<Response?> connect(Uri url, [User? user]) async {
    try {
      Map<String, String> headers = HashMap();
      headers[HttpHeaders.userAgentHeader] = userAgent + ' (' + (Platform.isAndroid ? 'Android' : 'iOS') + ')';
      if (user != null) {
        headers[HttpHeaders.authorizationHeader] = 'Basic ' + base64Encode(utf8.encode('${user.username}:${user.password}'));
      }

      return get(url, headers: headers);
    } catch (ex, stacktrace) {
      print(ex);
      print(stacktrace);
      return null;
    }
  }
}
