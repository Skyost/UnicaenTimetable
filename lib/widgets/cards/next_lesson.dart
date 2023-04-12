import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/pages/day_view.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/cards/card.dart';

/// A card that allows to show the next lesson of today.
class NextLessonCard extends RemainingLessonsCard {
  /// The card id.
  static const String id = 'next_lesson';

  /// Creates a new next lesson card instance.
  NextLessonCard({
    super.key,
    super.onRemove,
  }) : super(
          cardId: id,
        );

  @override
  IconData buildIcon(BuildContext context, WidgetRef ref) => Icons.arrow_forward;

  @override
  Color buildColor(BuildContext context, WidgetRef ref) => Colors.purple;

  @override
  String buildSubtitle(BuildContext context, List<Lesson> data) {
    DateTime now = DateTime.now();
    Lesson? lesson = data.firstWhereOrNull((lesson) => now.isBefore(lesson.start));
    return lesson?.toString(context) ?? context.getString('home.next_lesson.nothing');
  }

  @override
  void onTap(BuildContext context, WidgetRef ref) {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.atMonday;
    }

    ref.read(currentPageProvider).value = DayViewPage.buildPageId(now.weekday);
  }
}
