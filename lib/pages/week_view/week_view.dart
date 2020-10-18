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
  const WeekViewPage()
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
    DateTime monday = context.watch<ValueNotifier<DateTime>>().value;
    return [
      monday,
      monday.add(const Duration(days: 1)),
      monday.add(const Duration(days: 2)),
      monday.add(const Duration(days: 3)),
      monday.add(const Duration(days: 4)),
      monday.add(const Duration(days: 5)),
      monday.add(const Duration(days: 6)),
    ];
  }
}

/// The week view page state.
class _WeekViewPageState extends FlutterWeekViewState<WeekViewPage> {
  @override
  Widget buildChild(BuildContext context) {
    List<FlutterWeekViewEvent> events = context.watch<List<FlutterWeekViewEvent>>();
    if (events == null) {
      return const CenteredCircularProgressIndicator();
    }

    UnicaenTimetableTheme theme = context.watch<SettingsModel>().resolveTheme(context);
    return WeekView(
      dates: widget.resolveDates(context),
      events: events,
      initialTime: const HourMinute(hour: 7).atDate(DateTime.now()),
      style: WeekViewStyle(dayViewWidth: calculateDayViewWidth(context)),
      dayBarStyleBuilder: (date) => theme.createDayBarStyle(date, formatDate),
      hoursColumnStyle: theme.createHoursColumnStyle(),
      dayViewStyleBuilder: theme.createDayViewStyle,
    );
  }

  @override
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, LessonModel lessonModel, SettingsModel settingsModel) async {
    List<DateTime> dates = widget.resolveDates(context);
    return (await lessonModel.selectLessons(dates.first, dates.last..add(const Duration(days: 1)))).map((lesson) => createEvent(lesson, lessonModel, settingsModel)).toList();
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
}
