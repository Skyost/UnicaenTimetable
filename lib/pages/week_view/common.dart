import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/input.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A widget that shows a FlutterWeekView widget.
abstract class FlutterWeekViewState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    SettingsModel settingsModel = Provider.of<SettingsModel>(context);
    LessonModel lessonModel = Provider.of<LessonModel>(context);

    Future<List<FlutterWeekViewEvent>> events = createEvents(context, lessonModel, settingsModel);
    return FutureProvider<List<FlutterWeekViewEvent>>.value(
      value: events,
      child: Builder(
        builder: (context) => buildChild(context),
      ),
    );
  }

  /// Creates an event.
  FlutterWeekViewEvent createEvent(Lesson lesson, LessonModel lessonModel, SettingsModel settingsModel) {
    Pair<Color, Color> colors = computeColors(lessonModel, settingsModel, lesson);
    return FlutterWeekViewEvent(
      title: lesson.name,
      description: lesson.description,
      start: lesson.start,
      end: lesson.end,
      backgroundColor: colors.first,
      onLongPress: () => onEventLongPress(context, lesson, lessonModel, colors.first),
      onTap: () => onEventTap(context, lesson, lessonModel),
      textStyle: TextStyle(color: colors.second),
    );
  }

  /// Computes lesson colors.
  Pair<Color, Color> computeColors(LessonModel lessonModel, SettingsModel settingsModel, Lesson lesson) {
    Color backgroundColor = lessonModel.getLessonColor(lesson);
    backgroundColor ??= settingsModel.getEntryByKey('application.color_lessons_automatically').value ? Utils.randomColor(150, lesson.name.splitEqually(3)) : const Color(0xCC2196F3).withAlpha(150);
    Color textColor = backgroundColor.isDark ? Colors.white : Colors.black;
    return Pair<Color, Color>(backgroundColor, textColor);
  }

  /// Triggered when the user long press on an event.
  Future<void> onEventLongPress(BuildContext context, Lesson lesson, LessonModel lessonModel, Color initialValue) async {
    Color color = await ColorInputDialog.getValue(
      context,
      titleKey: 'dialogs.lesson_color.title',
      initialValue: initialValue,
    );

    if (color != null) {
      await lessonModel.setLessonColor(lesson, color);
    }
  }

  /// Triggered when the user taps on an event.
  void onEventTap(BuildContext context, Lesson lesson, LessonModel lessonModel) {
    List<Widget> actions = [
      FlatButton(
        child: Text(EzLocalization.of(context).get('dialogs.lesson_info.reset_color').toUpperCase()),
        onPressed: () {
          lessonModel.resetLessonColor(lesson);
          Navigator.of(context).pop();
        },
      ),
      FlatButton(
        child: Text(MaterialLocalizations.of(context).closeButtonLabel.toUpperCase()),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];

    if (Platform.isAndroid) {
      actions.insert(
        0,
        FlatButton(
          child: Text(EzLocalization.of(context).get('dialogs.lesson_info.set_alarm').toUpperCase()),
          onPressed: () => UnicaenTimetableApp.CHANNEL.invokeMethod('activity.set_alarm', {
            'title': lesson.name,
            'hour': lesson.start.hour,
            'minute': lesson.start.minute,
          }),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lesson.name),
        content: SingleChildScrollView(
          child: Text(lesson.start.hour.withLeadingZero + ':' + lesson.start.minute.withLeadingZero + ' — ' + lesson.end.hour.withLeadingZero + ':' + lesson.end.minute.withLeadingZero + '\n\n' + lesson.description),
        ),
        actions: [
          Wrap(
            direction: Axis.vertical,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: actions,
          ),
        ],
      ),
    );
  }

  /// Formats a date.
  String formatDate(int year, int month, int day) => DateFormat.yMMMMEEEEd(EzLocalization.of(context).locale.languageCode).format(DateTime(year, month, day));

  /// Builds the widget child.
  Widget buildChild(BuildContext context);

  /// Creates the events.
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, LessonModel lessonModel, SettingsModel settingsModel);
}

/// A button that allows to show the week picker.
class WeekPickerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<DateTime> date = Provider.of<ValueNotifier<DateTime>>(context);
    return IconButton(
      icon: Icon(Icons.date_range),
      onPressed: () async {
        DateTime selectedDate = await AvailableWeekInputDialog.getValue(
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
