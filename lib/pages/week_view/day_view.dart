import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/week_view/common.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/utils/widgets.dart';

/// The page that allows to show a day's lessons.
class DayViewPage extends Page {
  /// The week day.
  final int weekDay;

  /// Creates a new day view page instance.
  const DayViewPage({
    @required this.weekDay,
  }) : super(icon: null);

  @override
  IconData get icon {
    switch (weekDay) {
      case DateTime.monday:
        return Icons.looks_one;
      case DateTime.tuesday:
        return Icons.looks_two;
      case DateTime.wednesday:
        return Icons.looks_3;
      case DateTime.thursday:
        return Icons.looks_4;
      default:
        return Icons.looks_5;
    }
  }

  @override
  State<StatefulWidget> createState() => _DayViewPageState();

  @override
  String buildTitle(BuildContext context) => DateFormat.EEEE(EzLocalization.of(context).locale.languageCode).format(resolveDate(context)).capitalize();

  @override
  bool operator ==(Object other) => super == other && other is DayViewPage && weekDay == other.weekDay;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
        onPressed: () => previousDay(context),
      ),
      IconButton(
        icon: Icon(Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_forward_ios),
        onPressed: () => nextDay(context),
      ),
      WeekPickerButton(),
      IconButton(
        icon: Icon(Icons.share),
        onPressed: () async {
          StringBuffer builder = StringBuffer();
          DateTime date = resolveDate(context, listen: false);
          LessonModel lessonModel = Provider.of<LessonModel>(context, listen: false);
          List<Lesson> lessons = await lessonModel.getLessonsForDate(date)
            ..sort();
          builder.write(DateFormat.yMd(EzLocalization.of(context).locale.languageCode).format(date) + ' :\n\n');
          lessons.forEach((lesson) => builder.write(lesson.toString(context) + '\n'));
          String content = builder.toString();
          await Share.share(content.substring(0, content.lastIndexOf('\n')));
        },
      ),
    ];
  }

  /// Goes to the previous day.
  void previousDay(BuildContext context) {
    int weekDay = this.weekDay;
    if (weekDay == DateTime.monday) {
      weekDay = DateTime.friday;
      ValueNotifier<DateTime> date = Provider.of<ValueNotifier<DateTime>>(context, listen: false);
      date.value = date.value.subtract(const Duration(days: 7));
    } else {
      weekDay--;
    }

    Provider.of<ValueNotifier<Page>>(context, listen: false).value = DayViewPage(weekDay: weekDay);
  }

  /// Goes to the next day.
  void nextDay(BuildContext context) {
    int weekDay = this.weekDay;
    if (weekDay == DateTime.friday) {
      weekDay = DateTime.monday;
      ValueNotifier<DateTime> date = Provider.of<ValueNotifier<DateTime>>(context, listen: false);
      date.value = date.value.add(const Duration(days: 7));
    } else {
      weekDay++;
    }

    Provider.of<ValueNotifier<Page>>(context, listen: false).value = DayViewPage(weekDay: weekDay);
  }

  /// Resolves the date from the given context.
  DateTime resolveDate(BuildContext context, {bool listen = true}) {
    DateTime monday = Provider.of<ValueNotifier<DateTime>>(context, listen: listen).value;
    return monday.add(Duration(days: weekDay - 1));
  }
}

/// The day view page state.
class _DayViewPageState extends FlutterWeekViewState<DayViewPage> {
  @override
  Widget buildChild(BuildContext context) {
    List<FlutterWeekViewEvent> events = Provider.of<List<FlutterWeekViewEvent>>(context);
    if (events == null) {
      return const CenteredCircularProgressIndicator();
    }

    DateTime date = widget.resolveDate(context);
    UnicaenTimetableTheme theme = Provider.of<SettingsModel>(context).theme;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity > 0) {
          widget.previousDay(context);
        }

        if (details.primaryVelocity < 0) {
          widget.nextDay(context);
        }
      },
      child: DayView(
        date: date,
        events: events,
        initialTime: const HourMinute(hour: 7),
        style: theme.createDayViewStyle(date).copyWith(
              dayBarTextStyle: TextStyle(
                color: theme.dayBarTextColor ?? theme.textColor,
                fontWeight: FontWeight.bold,
              ),
              dayBarBackgroundColor: theme.dayBarBackgroundColor,
              hoursColumnTextStyle: TextStyle(color: theme.hoursColumnTextColor ?? theme.textColor),
              hoursColumnBackgroundColor: theme.hoursColumnBackgroundColor,
              dateFormatter: formatDate,
            ),
      ),
    );
  }

  @override
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, LessonModel lessonModel, SettingsModel settingsModel) async {
    DateTime date = widget.resolveDate(context);
    return (await lessonModel.getLessonsForDate(date)).map((lesson) => createEvent(lesson, lessonModel, settingsModel)).toList();
  }
}
