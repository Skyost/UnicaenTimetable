import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/pages/home/cards/card_content.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A card that allows to show the current lesson.
class CurrentLessonCard extends ConsumerWidget {
  /// Creates a new current lesson card instance.
  const CurrentLessonCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String subtitle = translations.common.other.pleaseWait;
    AsyncValue<List<Lesson>> remainingLessons = ref.watch(remainingLessonsProvider);
    if (remainingLessons.hasValue) {
      DateTime now = DateTime.now();
      Lesson? lesson = remainingLessons.value!.firstWhereOrNull((lesson) => lesson.dateTime.start.isBefore(now));
      subtitle = lesson?.toString(context) ?? translations.home.currentLesson.nothing;
    }
    return MaterialCardContent(
      color: Colors.pink.shade700,
      icon: Icons.business_center,
      title: translations.home.currentLesson.title,
      subtitle: subtitle,
      onTap: () {
        DateTime now = DateTime.now();
        if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
          now = now.atMonday;
        }

        ref.read(pageProvider.notifier).changePage(DayViewPage(day: now.weekday));
      },
    );
  }
}
