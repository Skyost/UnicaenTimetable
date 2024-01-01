import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';

/// A widget that shows a FlutterWeekView widget.
abstract class FlutterWeekViewWidget extends Page {
  /// Creates a new FlutterWeekView widget instance.
  const FlutterWeekViewWidget({
    super.key,
    required super.pageId,
    super.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<List<FlutterWeekViewEvent>>(
        initialData: const [],
        future: createEvents(context, ref),
        builder: (context, snapshot) => buildChild(context, ref, snapshot.data ?? []),
      );

  /// Creates an event.
  FlutterWeekViewEvent createEvent(BuildContext context, Lesson lesson, LessonRepository lessonRepository, SettingsModel settingsModel) {
    Pair<Color, Color> colors = computeColors(lesson, lessonRepository: lessonRepository, settingsModel: settingsModel);
    return FlutterWeekViewEvent(
      title: lesson.name,
      description: lesson.description ?? '',
      start: lesson.start,
      end: lesson.end,
      backgroundColor: colors.first,
      onLongPress: () => onEventLongPress(context, lesson, lessonRepository, colors.first),
      onTap: () => onEventTap(context, lesson, lessonRepository),
      textStyle: TextStyle(color: colors.second),
    );
  }

  /// Triggered when the user long press on an event.
  Future<void> onEventLongPress(BuildContext context, Lesson lesson, LessonRepository lessonRepository, Color initialValue) async {
    Color? color = await ColorInputDialog.getValue(
      context,
      lesson: lesson,
      titleKey: 'dialogs.lesson_color.title',
      initialValue: initialValue,
    );

    if (color != null) {
      await lessonRepository.setLessonColor(lesson, color);
    }
  }

  /// Triggered when the user taps on an event.
  Future<void> onEventTap(BuildContext context, Lesson lesson, LessonRepository lessonRepository) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(lesson.name),
          content: SingleChildScrollView(
            child: Text(
                '${lesson.start.hour.withLeadingZero}:${lesson.start.minute.withLeadingZero} — ${lesson.end.hour.withLeadingZero}:${lesson.end.minute.withLeadingZero}\n\n${lesson.description ?? ''}'),
          ),
          actions: [
            if (Platform.isAndroid)
              TextButton(
                onPressed: () => UnicaenTimetableRoot.channel.invokeMethod('activity.set_alarm', {
                  'title': lesson.name,
                  'hour': lesson.start.hour,
                  'minute': lesson.start.minute,
                }),
                child: Text(context.getString('dialogs.lesson_info.set_alarm').toUpperCase()),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel.toUpperCase()),
            ),
          ],
        ),
      );

  /// Formats a date.
  String formatDate(BuildContext context, int year, int month, int day) {
    String? languageCode = EzLocalization.of(context)?.locale.languageCode;
    return DateFormat.yMMMMEEEEd(languageCode).format(DateTime(year, month, day)).capitalize();
  }

  /// Computes lesson foreground and background colors.
  static Pair<Color, Color> computeColors(Lesson lesson, {LessonRepository? lessonRepository, SettingsModel? settingsModel}) {
    Color? backgroundColor = lessonRepository?.getLessonColor(lesson);
    backgroundColor ??= settingsModel?.getEntryByKey('application.color_lessons_automatically')?.value ? Utils.randomColor(150, lesson.name.splitEqually(3)) : const Color(0xCC2196F3).withAlpha(150);
    Color textColor = backgroundColor.isDark ? Colors.white : Colors.black;
    return Pair<Color, Color>(backgroundColor, textColor);
  }

  /// Builds the widget child.
  Widget buildChild(BuildContext context, WidgetRef ref, List<FlutterWeekViewEvent> events);

  /// Creates the events.
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, WidgetRef ref);
}

/// A button that allows to show the week picker.
class WeekPickerButton extends ConsumerWidget {
  /// Creates a new week picker button instance.
  const WeekPickerButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        icon: const Icon(Icons.date_range),
        onPressed: () async {
          ValueNotifier<DateTime> date = ref.read(currentDateProvider);
          DateTime? selectedDate = await AvailableWeekInputDialog.getValue(
            context,
            titleKey: 'dialogs.week_picker.title',
            initialValue: date.value,
          );

          if (selectedDate != null) {
            date.value = selectedDate;
          }
        },
      );
}
