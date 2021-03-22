import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/input.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A widget that shows a FlutterWeekView widget.
abstract class FlutterWeekViewState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    SettingsModel settingsModel = context.watch<SettingsModel>();
    LessonModel lessonModel = context.watch<LessonModel>();

    Future<List<FlutterWeekViewEvent>> events = createEvents(context, lessonModel, settingsModel);
    return FutureProvider<List<FlutterWeekViewEvent>>.value(
      initialData: [],
      value: events,
      child: Builder(
        builder: (context) => buildChild(context),
      ),
    );
  }

  /// Creates an event.
  FlutterWeekViewEvent createEvent(Lesson lesson, LessonModel lessonModel, SettingsModel settingsModel) {
    Pair<Color, Color> colors = lesson.computeColors(lessonModel: lessonModel, settingsModel: settingsModel);
    return FlutterWeekViewEvent(
      title: lesson.name,
      description: lesson.description ?? '',
      start: lesson.start,
      end: lesson.end,
      backgroundColor: colors.first,
      onLongPress: () => onEventLongPress(context, lesson, lessonModel, colors.first),
      onTap: () => onEventTap(context, lesson, lessonModel),
      textStyle: TextStyle(color: colors.second),
    );
  }

  /// Triggered when the user long press on an event.
  Future<void> onEventLongPress(BuildContext context, Lesson lesson, LessonModel lessonModel, Color initialValue) async {
    Color? color = await ColorInputDialog.getValue(
      context,
      lesson: lesson,
      titleKey: 'dialogs.lesson_color.title',
      initialValue: initialValue,
    );

    if (color != null) {
      await lessonModel.setLessonColor(lesson, color);
    }
  }

  /// Triggered when the user taps on an event.
  Future<void> onEventTap(BuildContext context, Lesson lesson, LessonModel lessonModel) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(lesson.name),
          content: SingleChildScrollView(
            child: Text(lesson.start.hour.withLeadingZero + ':' + lesson.start.minute.withLeadingZero + ' — ' + lesson.end.hour.withLeadingZero + ':' + lesson.end.minute.withLeadingZero + '\n\n' + (lesson.description ?? '')),
          ),
          actions: [
            if (Platform.isAndroid)
              TextButton(
                onPressed: () => UnicaenTimetableApp.CHANNEL.invokeMethod('activity.set_alarm', {
                  'title': lesson.name,
                  'hour': lesson.start.hour,
                  'minute': lesson.start.minute,
                }),
                child: Text(context.getString('dialogs.lesson_info.set_alarm').toUpperCase()),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel.toUpperCase()),
            ),
          ],
        ),
      );

  /// Formats a date.
  String formatDate(int year, int month, int day) => DateFormat.yMMMMEEEEd(EzLocalization.of(context)?.locale.languageCode).format(DateTime(year, month, day)).capitalize();

  /// Builds the widget child.
  Widget buildChild(BuildContext context);

  /// Creates the events.
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, LessonModel lessonModel, SettingsModel settingsModel);
}

/// A button that allows to show the week picker.
class WeekPickerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<DateTime> date = context.watch<ValueNotifier<DateTime>>();
    return IconButton(
      icon: const Icon(Icons.date_range),
      onPressed: () async {
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
}
