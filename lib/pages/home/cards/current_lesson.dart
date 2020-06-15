import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/card.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/week_view/day_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A card that allows to show the current lesson.
class CurrentLessonCard extends RemainingLessonsCard {
  /// The card id.
  static const String ID = 'current_lesson';

  /// Creates a new current lesson card instance.
  const CurrentLessonCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => Icons.business_center;

  @override
  Color buildColor(BuildContext context) => Colors.pink[700];

  @override
  String buildSubtitle(BuildContext context) {
    List<Lesson> remainingLessons = Provider.of<List<Lesson>>(context);
    if(remainingLessons == null) {
      return context.getString('home.loading');
    }

    DateTime now = DateTime.now();
    Lesson lesson = remainingLessons.firstWhere((lesson) => lesson.start.isBefore(now), orElse: () => null);
    return lesson?.toString(context) ?? context.getString('home.current_lesson.nothing');
  }

  @override
  void onTap(BuildContext context) {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.atMonday;
    }

    Provider.of<ValueNotifier<Page>>(context, listen: false).value = DayViewPage(weekDay: now.weekday);
  }
}