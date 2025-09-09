import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/utils/date_time_range.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// Represents a lesson with a name, a description, a location, a start and an end.
class Lesson implements Comparable<Lesson> {
  /// The lesson name.
  final String name;

  /// The lesson description.
  final String? description;

  /// The lesson location.
  final String location;

  /// The lesson start and end.
  final DateTimeRange dateTime;

  /// Creates a new lesson instance.
  const Lesson({
    required this.name,
    this.description,
    required this.location,
    required this.dateTime,
  });

  /// Creates a new [Lesson] from a JSON map.
  Lesson.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      description = json['description'],
      location = json['location'],
      dateTime = DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(json['start']),
        end: DateTime.fromMillisecondsSinceEpoch(json['end']),
      );

  /// Creates a new lesson instance from a Zimbra JSON map.
  factory Lesson.fromZimbra(Map<String, dynamic> inv) {
    Map<String, dynamic> comp = inv['comp']!.first;

    String name = comp['name']!;
    String location = comp['loc']!;
    String? description;
    if (comp.containsKey('desc')) {
      description = comp['desc'].first['_content'];
    }
    DateTime start = DateTime.fromMillisecondsSinceEpoch(comp['s']!.first['u']!);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(comp['e']!.first['u']!);

    return Lesson(
      name: name,
      location: location,
      description: description,
      dateTime: DateTimeRange(
        start: start,
        end: end,
      ),
    );
  }

  /// Creates a new lesson instance from a test JSON calendar.
  factory Lesson.fromTest(DateTime date, Map<String, dynamic> json) {
    List<dynamic> startParts = json['start']!.split(':').map(int.parse).toList();
    List<dynamic> endParts = json['end']!.split(':').map(int.parse).toList();

    String name = json['name']!;
    String? description = json['description'];
    String location = json['location']!;
    DateTime start = date.add(Duration(hours: startParts.first, minutes: startParts.last));
    DateTime end = date.add(Duration(hours: endParts.first, minutes: endParts.last));

    return Lesson(
      name: name,
      location: location,
      description: description,
      dateTime: DateTimeRange(
        start: start,
        end: end,
      ),
    );
  }

  @override
  String toString([BuildContext? context]) {
    String hour;
    if (context == null) {
      hour = '${dateTime.start.hour.withLeadingZero}:${dateTime.start.minute.withLeadingZero}-${dateTime.end.hour.withLeadingZero}:${dateTime.end.minute.withLeadingZero}';
    } else {
      String? locale = TranslationProvider.of(context).flutterLocale.languageCode;
      DateFormat formatter = DateFormat.Hm(locale);
      hour = '${formatter.format(dateTime.start)}-${formatter.format(dateTime.end)}';
    }
    return '$hour $name ($location)';
  }

  /// Copies this instance with the given parameters.
  Lesson copyWith({
    String? name,
    String? description,
    String? location,
    DateTimeRange? dateTime,
  }) => Lesson(
    name: name ?? this.name,
    description: description ?? this.description,
    location: location ?? this.location,
    dateTime: dateTime ?? this.dateTime,
  );

  @override
  int compareTo(Lesson other) => dateTime.start.compareTo(other.dateTime.start);

  /// Converts this lesson to a JSON object.
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'location': location,
    'start': dateTime.start.millisecondsSinceEpoch ~/ 1000,
    'end': dateTime.end.millisecondsSinceEpoch ~/ 1000,
  };
}
