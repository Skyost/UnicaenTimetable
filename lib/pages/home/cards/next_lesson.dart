import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/pages/home/cards/card_content.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A card that allows to show the next lesson.
class NextLessonCard extends ConsumerWidget {
  /// Creates a new next lesson card instance.
  const NextLessonCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String subtitle = translations.common.other.pleaseWait;
    AsyncValue<List<Lesson>> remainingLessons = ref.watch(remainingLessonsProvider);
    if (remainingLessons.hasValue) {
      DateTime now = DateTime.now();
      Lesson? lesson = remainingLessons.value!.firstWhereOrNull((lesson) => now.isBefore(lesson.dateTime.start));
      subtitle = lesson?.toString(context) ?? translations.home.nextLesson.nothing;
    }
    return MaterialCardContent(
      color: Colors.purple,
      icon: Icons.arrow_forward,
      title: translations.home.nextLesson.title,
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
