
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// Represents a lesson with a name, a description, a location, a start and an end.
class Lesson with Comparable<Lesson> {
  /// The lesson name.
  String name;

  /// The lesson description.
  String? description;

  /// The lesson location.
  String location;

  /// The lesson start.
  DateTime start;

  /// The lesson end.
  DateTime end;

  /// Creates a new lesson instance.
  Lesson({
    required this.name,
    this.description,
    required this.location,
    required this.start,
    required this.end,
  });

  /// Creates a new lesson instance from a Zimbra JSON map.
  factory Lesson.fromJson(Map<String, dynamic> inv) {
    Map<String, dynamic> comp = inv['comp']!.first;

    String name = comp['name']!;
    String location = comp['loc']!;
    String? description;
    if (comp.containsKey('desc')) {
      description = comp['desc'].first['_content'];
    }
    DateTime start = DateTime.fromMillisecondsSinceEpoch(comp['s']!.first['u']!);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(comp['e']!.first['u']!);

    return Lesson(name: name, location: location, description: description, start: start, end: end);
  }

  /// Creates a new lesson instance from a test JSON calendar.
  factory Lesson.fromTestJson(DateTime date, Map<String, dynamic> json) {
    List<dynamic> startParts = json['start']!.split(':').map(int.parse).toList();
    List<dynamic> endParts = json['end']!.split(':').map(int.parse).toList();

    String name = json['name']!;
    String? description = json['description'];
    String location = json['location']!;
    DateTime start = date.add(Duration(hours: startParts.first, minutes: startParts.last));
    DateTime end = date.add(Duration(hours: endParts.first, minutes: endParts.last));

    return Lesson(name: name, location: location, description: description, start: start, end: end);
  }

  @override
  String toString([BuildContext? context]) {
    String hour;
    if (context == null) {
      hour = '${start.hour.withLeadingZero}:${start.minute.withLeadingZero}-${end.hour.withLeadingZero}:${end.minute.withLeadingZero}';
    } else {
      String? locale = EzLocalization.of(context)?.locale.languageCode;
      DateFormat formatter = DateFormat.Hm(locale);
      hour = '${formatter.format(start)}-${formatter.format(end)}';
    }

    return '$hour $name ($location)';
  }

  @override
  int compareTo(Lesson other) => start.compareTo(other.start);
}
