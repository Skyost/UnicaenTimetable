import 'dart:io';
import 'dart:ui';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings/entries/application/sidebar_days.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/week_view/common.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/utils/widgets.dart';

/// The page that allows to show a day's lessons.
class DayViewPage extends Page {
  /// The share button key.
  final GlobalKey _shareButtonKey = GlobalKey();

  /// The week day.
  final int weekDay;

  /// Creates a new day view page instance.
  DayViewPage({
    @required this.weekDay,
  }) : super(icon: null);

  @override
  IconData get icon {
    switch (weekDay) {
      case DateTime.monday:
        return const IconData(0xf03a4, fontFamily: 'MaterialCommunityIcons');
      case DateTime.tuesday:
        return const IconData(0xf03a7, fontFamily: 'MaterialCommunityIcons');
      case DateTime.wednesday:
        return const IconData(0xf03aa, fontFamily: 'MaterialCommunityIcons');
      case DateTime.thursday:
        return const IconData(0xf03ad, fontFamily: 'MaterialCommunityIcons');
      case DateTime.friday:
        return const IconData(0xf03b1, fontFamily: 'MaterialCommunityIcons');
      case DateTime.saturday:
        return const IconData(0xf03b3, fontFamily: 'MaterialCommunityIcons');
      default:
        return const IconData(0xf03b6, fontFamily: 'MaterialCommunityIcons');
    }
  }

  @override
  State<StatefulWidget> createState() => _DayViewPageState();

  @override
  String buildTitle(BuildContext context) => DateFormat.EEEE(EzLocalization.of(context).locale.languageCode).format(resolveDate(context)).capitalize();

  @override
  bool isSamePage(Page other) => super.isSamePage(other) && other is DayViewPage && weekDay == other.weekDay;

  @override
  List<Widget> buildActions(BuildContext context) {
    SidebarDaysSettingsEntry sidebarDays = context.get<SettingsModel>().sidebarDaysEntry;
    return [
      if (sidebarDays.value.isNotEmpty)
        IconButton(
          icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () => previousDay(context, sidebarDays: sidebarDays),
        ),
      if (sidebarDays.value.isNotEmpty)
        IconButton(
          icon: Icon(Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_forward_ios),
          onPressed: () => nextDay(context, sidebarDays: sidebarDays),
        ),
      WeekPickerButton(),
      IconButton(
        key: _shareButtonKey,
        icon: const Icon(Icons.share),
        onPressed: () async {
          RenderBox renderBox = _shareButtonKey.currentContext.findRenderObject();
          Offset position = renderBox.localToGlobal(Offset.zero);

          StringBuffer builder = StringBuffer();
          DateTime date = resolveDate(context, listen: false);
          LessonModel lessonModel = context.get<LessonModel>();
          List<Lesson> lessons = await lessonModel.getLessonsForDate(date)
            ..sort();
          builder.write(DateFormat.yMd(EzLocalization.of(context).locale.languageCode).format(date) + ' :\n\n');
          lessons.forEach((lesson) => builder.write(lesson.toString(context) + '\n'));
          String content = builder.toString();
          await Share.share(
            content.substring(0, content.lastIndexOf('\n')),
            sharePositionOrigin: Rect.fromLTWH(position.dx, position.dy, 24, 40),
          );
        },
      ),
    ];
  }

  /// Goes to the previous day.
  void previousDay(BuildContext context, {SidebarDaysSettingsEntry sidebarDays}) {
    sidebarDays ??= context.get<SettingsModel>().sidebarDaysEntry;
    int previousDay = sidebarDays.previousDay(weekDay);
    if (previousDay >= weekDay) {
      ValueNotifier<DateTime> monday = context.get<ValueNotifier<DateTime>>();
      monday.value = monday.value.subtract(const Duration(days: 7));
    }
    context.get<ValueNotifier<Page>>().value = DayViewPage(weekDay: previousDay);
  }

  /// Goes to the next day.
  void nextDay(BuildContext context, {SidebarDaysSettingsEntry sidebarDays}) {
    sidebarDays ??= context.get<SettingsModel>().sidebarDaysEntry;
    int nextDay = sidebarDays.nextDay(weekDay);
    if (nextDay <= weekDay) {
      ValueNotifier<DateTime> monday = context.get<ValueNotifier<DateTime>>();
      monday.value = monday.value.add(const Duration(days: 7));
    }
    context.get<ValueNotifier<Page>>().value = DayViewPage(weekDay: nextDay);
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
    List<FlutterWeekViewEvent> events = context.watch<List<FlutterWeekViewEvent>>();
    if (events == null) {
      return const CenteredCircularProgressIndicator();
    }

    DateTime date = widget.resolveDate(context);
    UnicaenTimetableTheme theme = context.watch<SettingsModel>().resolveTheme(context);
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
        style: theme.createDayViewStyle(date),
        dayBarStyle: theme.createDayBarStyle(date, formatDate),
        hoursColumnStyle: theme.createHoursColumnStyle(),
      ),
    );
  }

  @override
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, LessonModel lessonModel, SettingsModel settingsModel) async {
    DateTime date = widget.resolveDate(context);
    return (await lessonModel.getLessonsForDate(date)).map((lesson) => createEvent(lesson, lessonModel, settingsModel)).toList();
  }
}
