import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// Allows to build the URL of the Zimbra calendar.
class CalendarUrl {
  /// The server.
  final String? server;

  /// The calendar.
  final String? calendar;

  /// Contains some additional parameters.
  final String? additionalParameters;

  /// The interval.
  final int? interval;

  const CalendarUrl({
    this.server,
    this.calendar,
    this.additionalParameters,
    this.interval,
  });

  /// Returns the URL.
  Uri? build(User user) {
    if (server == null || calendar == null) {
      return null;
    }

    String url = '$server/home/${user.username}/${Uri.encodeFull(calendar!)}?auth=ba&fmt=json';
    if (additionalParameters != null && additionalParameters!.isNotEmpty) {
      url += '&$additionalParameters';
    }

    if (interval != null && interval! > 0) {
      DateTime now = DateTime.now().atMonday.yearMonthDay;
      DateTime min = now.subtract(Duration(days: interval! * 7));
      DateTime max = now.add(Duration(days: interval! * 7)).add(const Duration(days: DateTime.friday));

      url += '&start=${min.year}/${min.month.withLeadingZero}/${min.day.withLeadingZero}';
      url += '&end=${max.year}/${max.month.withLeadingZero}/${max.day.withLeadingZero}';
    }

    return Uri.tryParse(url);
  }
}
