import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/week_view/common.dart';
import 'package:unicaen_timetable/utils/widgets.dart';

/// A widget that allows to show a week's lessons.
class WeekViewPage extends StaticTitlePage {
  /// Creates a new week view page instance.
  WeekViewPage()
      : super(
          titleKey: 'week_view.title',
          icon: Icons.view_array,
        );

  @override
  State<StatefulWidget> createState() => _WeekViewPageState();

  @override
  List<Widget> buildActions(BuildContext context) => [WeekPickerButton()];

  /// Resolves the page dates from a given context.
  List<DateTime> resolveDates(BuildContext context) {
    DateTime monday = Provider.of<ValueNotifier<DateTime>>(context).value;
    return [
      monday,
      monday.add(const Duration(days: 1)),
      monday.add(const Duration(days: 2)),
      monday.add(const Duration(days: 3)),
      monday.add(const Duration(days: 4)),
      monday.add(const Duration(days: 5)),
    ];
  }
}

/// The week view page state.
class _WeekViewPageState extends FlutterWeekViewState<WeekViewPage> {
  @override
  Widget buildChild(BuildContext context) {
    List<FlutterWeekViewEvent> events = Provider.of<List<FlutterWeekViewEvent>>(context);
    if (events == null) {
      return const CenteredCircularProgressIndicator();
    }

    UnicaenTimetableTheme theme = Provider.of<SettingsModel>(context).theme;
    return WeekView(
      dates: widget.resolveDates(context),
      events: events,
      initialHour: 7,
      dateFormatter: formatDate,
      dayViewWidth: calculateDayViewWidth(context),
      dayViewBuilder: (context, weekView, date, controller) => buildDayView(context, weekView, date, controller, theme),
      dayBarTextStyle: TextStyle(color: theme.dayBarTextColor ?? theme.textColor),
      dayBarBackgroundColor: theme.dayBarBackgroundColor,
      hoursColumnTextStyle: TextStyle(color: theme.hoursColumnTextColor ?? theme.textColor),
      hoursColumnBackgroundColor: theme.hoursColumnBackgroundColor,
    );
  }

  @override
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, LessonModel lessonModel, SettingsModel settingsModel) async {
    List<DateTime> dates = widget.resolveDates(context);
    return (await lessonModel.selectLessons(dates.first, dates.last)).map((lesson) => createEvent(lesson, lessonModel, settingsModel)).toList();
  }

  /// Calculates a day view width.
  double calculateDayViewWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width > 450) {
      return width / 3;
    }

    if (width > 300) {
      return width / 2;
    }

    return width - 60;
  }

  /// Builds a day view.
  DayView buildDayView(BuildContext context, WeekView weekView, DateTime date, DayViewController controller, UnicaenTimetableTheme theme) => DayView(
        date: date,
        events: weekView.events,
        hoursColumnWidth: 0,
        controller: controller,
        eventsColumnBackgroundPainter: theme.createEventsColumnBackgroundPainter(date),
        inScrollableWidget: false,
        dayBarHeight: 0,
        userZoomable: false,
        scrollToCurrentTime: false,
      );
}
