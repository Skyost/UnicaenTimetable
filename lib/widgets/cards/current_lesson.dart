import 'package:collection/collection.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/pages/day_view.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/cards/card.dart';

/// A card that allows to show the current lesson.
class CurrentLessonCard extends RemainingLessonsCard {
  /// The card id.
  static const String id = 'current_lesson';

  /// Creates a new current lesson card instance.
  CurrentLessonCard({
    super.onRemove,
  }) : super(
          cardId: id,
        );

  @override
  IconData buildIcon(BuildContext context, WidgetRef ref) => Icons.business_center;

  @override
  Color buildColor(BuildContext context, WidgetRef ref) => Colors.pink[700]!;

  @override
  String buildSubtitle(BuildContext context, List<Lesson> data) {
    DateTime now = DateTime.now();
    Lesson? lesson = data.firstWhereOrNull((lesson) => lesson.start.isBefore(now));
    return lesson?.toString(context) ?? context.getString('home.current_lesson.nothing');
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
