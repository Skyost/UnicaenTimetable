import 'package:flutter/material.dart' hide DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/days_to_display.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/date_time_range.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';
import 'package:unicaen_timetable/widgets/flutter_week_view.dart';

/// The week view page list tile.
class WeekViewPageListTile extends StatelessWidget {
  /// Creates a new week view page list tile.
  const WeekViewPageListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PageListTitle(
        page: WeekViewPage(),
        title: translations.weekView.title,
        icon: const Icon(Icons.view_array),
      );
}

/// The about week view app bar.
class WeekViewPageAppBar extends StatelessWidget {
  /// Creates a new week view page app bar.
  const WeekViewPageAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(translations.weekView.title),
        actions: [
          const WeekPickerButton(),
        ],
      );
}

/// The week view page widget.
class WeekViewPageWidget extends ConsumerStatefulWidget {
  /// Creates a new week view page instance.
  const WeekViewPageWidget({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WeekViewPageWidgetState();
}

/// The week view page widget state.
class _WeekViewPageWidgetState extends FlutterWeekViewWidgetState {
  @override
  Widget buildChild(List<FlutterWeekViewEventWithLesson> events) {
    DateTime monday = ref.watch(dateProvider);
    List<int> daysToDisplay = ref.watch(daysToDisplayEntryProvider).valueOrNull ?? defaultDaysToDisplay;
    List<DateTime> dates = [
      for (int day in daysToDisplay) monday.add(Duration(days: day - 1)),
    ];
    DateTime today = DateTime.now().yearMonthDay;
    DateTime initialTime = (dates.contains(today) ? today : monday).copyWith(hour: 7, minute: 0);
    return WeekView<FlutterWeekViewEventWithLesson>(
      dates: dates,
      events: events,
      initialTime: initialTime,
      style: WeekViewStyle(dayViewWidth: calculateDayViewWidth(context)),
      dayBarStyleBuilder: (date) => createDayBarStyle(date, (year, month, day) => formatDate(context, year, month, day)),
      hourColumnStyle: createHoursColumnStyle(),
      dayViewStyleBuilder: createDayViewStyle,
      eventWidgetBuilder: createEventWidget,
    );
  }

  @override
  AsyncValue<List<LessonWithColor>> queryLessons() {
    DateTime monday = ref.watch(dateProvider);
    DateTime nextWeek = monday.add(const Duration(days: 7));
    return ref.watch(lessonsProvider(DateTimeRange(start: monday, end: nextWeek)));
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
