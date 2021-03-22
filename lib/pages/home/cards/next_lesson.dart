import 'package:collection/collection.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/card.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/week_view/day_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A card that allows to show the next lesson of today.
class NextLessonCard extends RemainingLessonsCard {
  /// The card id.
  static const String ID = 'next_lesson';

  /// Creates a new next lesson card instance.
  const NextLessonCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => Icons.arrow_forward;

  @override
  Color buildColor(BuildContext context) => Colors.purple;

  @override
  String buildSubtitle(BuildContext context) {
    List<Lesson>? remainingLessons = context.watch<List<Lesson>?>();
    if (remainingLessons == null) {
      return context.getString('home.loading');
    }

    DateTime now = DateTime.now();
    Lesson? lesson = remainingLessons.firstWhereOrNull((lesson) => now.isBefore(lesson.start));
    return lesson?.toString(context) ?? context.getString('home.next_lesson.nothing');
  }

  @override
  void onTap(BuildContext context) {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.atMonday;
    }

    context.read<ValueNotifier<Page>>().value = DayViewPage(weekDay: now.weekday);
  }
}
