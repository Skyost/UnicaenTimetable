import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/widgets/flutter_week_view.dart';

/// A widget that allows to show a week's lessons.
class WeekViewPage extends FlutterWeekViewWidget {
  /// The page identifier.
  static const String id = 'week_view';

  /// Creates a new week view page instance.
  const WeekViewPage({
    super.key,
  }) : super(
          pageId: id,
          icon: Icons.view_array,
        );

  @override
  List<Widget> buildActions(BuildContext context, WidgetRef ref) => [const WeekPickerButton()];

  @override
  Widget buildChild(BuildContext context, WidgetRef ref, List<FlutterWeekViewEvent> events) {
    UnicaenTimetableTheme theme = ref.watch(settingsModelProvider).resolveTheme(context);
    return WeekView(
      dates: resolveDates(ref),
      events: events,
      initialTime: const HourMinute(hour: 7).atDate(DateTime.now()),
      style: WeekViewStyle(dayViewWidth: calculateDayViewWidth(context)),
      dayBarStyleBuilder: (date) => theme.createDayBarStyle(date, (year, month, day) => formatDate(context, year, month, day)),
      hoursColumnStyle: theme.createHoursColumnStyle(),
      dayViewStyleBuilder: theme.createDayViewStyle,
    );
  }

  /// Resolves the page dates from a given context.
  List<DateTime> resolveDates(WidgetRef ref) {
    DateTime monday = ref.watch(currentDateProvider).value;
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

  @override
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, WidgetRef ref) async {
    SettingsModel settingsModel = ref.watch(settingsModelProvider);
    LessonRepository lessonRepository = ref.watch(lessonRepositoryProvider);
    List<DateTime> dates = resolveDates(ref);
    return (await lessonRepository.selectLessons(dates.first, dates.last..add(const Duration(days: 1)))).map((lesson) => createEvent(context, lesson, lessonRepository, settingsModel)).toList();
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
