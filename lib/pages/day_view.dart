import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/entries/application/sidebar_days.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/flutter_week_view.dart';

/// The page that allows to show a day's lessons.
class DayViewPage extends FlutterWeekViewWidget {
  /// The share button key.
  final GlobalKey _shareButtonKey = GlobalKey();

  /// The week day.
  final int weekDay;

  /// Creates a new day view page instance.
  DayViewPage({
    super.key,
    required this.weekDay,
    required String pageId,
    super.icon,
  }) : super(
          pageId: pageId,
        );

  /// Builds a day view page id.
  static String buildPageId(int weekDay) => 'day_view_$weekDay';

  @override
  String buildTitle(BuildContext context) {
    DateTime monday = DateTime.now().atMonday;
    DateTime date = monday.add(Duration(days: weekDay - 1));
    return DateFormat.EEEE(EzLocalization.of(context)?.locale.languageCode).format(date).capitalize();
  }

  @override
  Widget buildChild(BuildContext context, WidgetRef ref, List<FlutterWeekViewEvent> events) {
    DateTime date = resolveDate(ref);
    UnicaenTimetableTheme theme = ref.watch(settingsModelProvider).resolveTheme(context);
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) {
          return;
        }

        if (details.primaryVelocity! > 0) {
          previousDay(ref);
        }

        if (details.primaryVelocity! < 0) {
          nextDay(ref);
        }
      },
      child: DayView(
        date: date,
        events: events,
        initialTime: const HourMinute(hour: 7),
        style: theme.createDayViewStyle(date),
        dayBarStyle: theme.createDayBarStyle(date, (year, month, day) => formatDate(context, year, month, day)),
        hoursColumnStyle: theme.createHoursColumnStyle(),
      ),
    );
  }

  @override
  Future<List<FlutterWeekViewEvent>> createEvents(BuildContext context, WidgetRef ref) async {
    SettingsModel settingsModel = ref.watch(settingsModelProvider);
    LessonRepository lessonRepository = ref.watch(lessonRepositoryProvider);
    DateTime date = resolveDate(ref);
    return (await lessonRepository.getLessonsForDate(date)).map((lesson) => createEvent(context, lesson, lessonRepository, settingsModel)).toList();
  }

  /// Goes to the previous day.
  void previousDay(WidgetRef ref) {
    SidebarDaysSettingsEntry sidebarDays = ref.read(settingsModelProvider).sidebarDaysEntry;
    int previousDay = sidebarDays.previousDay(weekDay);
    if (previousDay >= weekDay) {
      ValueNotifier<DateTime> monday = ref.read(currentDateProvider);
      monday.value = monday.value.subtract(const Duration(days: 7));
    }
    ref.read(currentPageProvider).value = buildPageId(previousDay);
  }

  /// Goes to the next day.
  void nextDay(WidgetRef ref) {
    SidebarDaysSettingsEntry sidebarDays = ref.read(settingsModelProvider).sidebarDaysEntry;
    int nextDay = sidebarDays.nextDay(weekDay);
    if (nextDay <= weekDay) {
      ValueNotifier<DateTime> monday = ref.read(currentDateProvider);
      monday.value = monday.value.add(const Duration(days: 7));
    }
    ref.read(currentPageProvider).value = buildPageId(nextDay);
  }

  /// Resolves the date from the given ref.
  DateTime resolveDate(WidgetRef ref, {bool listen = true}) {
    DateTime monday = (listen ? ref.watch(currentDateProvider) : ref.read(currentDateProvider)).value;
    return monday.add(Duration(days: weekDay - 1));
  }

  @override
  List<Widget> buildActions(BuildContext context, WidgetRef ref) {
    SidebarDaysSettingsEntry sidebarDays = ref.read(settingsModelProvider).sidebarDaysEntry;
    return [
      if (sidebarDays.value.isNotEmpty)
        IconButton(
          icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () => previousDay(ref),
        ),
      if (sidebarDays.value.isNotEmpty)
        IconButton(
          icon: Icon(Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_forward_ios),
          onPressed: () => nextDay(ref),
        ),
      const WeekPickerButton(),
      IconButton(
        key: _shareButtonKey,
        icon: const Icon(Icons.share),
        onPressed: () async {
          RenderObject? renderObject = _shareButtonKey.currentContext?.findRenderObject();
          Offset? position;

          if (renderObject is RenderBox) {
            position = renderObject.localToGlobal(Offset.zero);
          }

          StringBuffer builder = StringBuffer();
          DateTime date = resolveDate(ref, listen: false);
          LessonRepository lessonRepository = ref.read(lessonRepositoryProvider);
          List<Lesson> lessons = await lessonRepository.getLessonsForDate(date)
            ..sort();
          builder.write('${DateFormat.yMd(EzLocalization.of(context)?.locale.languageCode).format(date)} :\n\n');
          for (Lesson lesson in lessons) {
            builder.write('$lesson\n');
          }
          String content = builder.toString();
          await Share.share(
            content.substring(0, content.lastIndexOf('\n')),
            sharePositionOrigin: position == null ? null : Rect.fromLTWH(position.dx, position.dy, 24, 40),
          );
        },
      ),
    ];
  }

  @override
  bool isSamePage(Page other) => super.isSamePage(other) && other is DayViewPage && weekDay == other.weekDay;
}

/// Monday day view page.
class MondayPage extends DayViewPage {
  /// The page identifier.
  static const String id = 'day_view_1';

  /// Creates a new monday page instance.
  MondayPage({
    super.key,
  }) : super(
          weekDay: DateTime.monday,
          pageId: id,
          icon: const IconData(0xf03a4, fontFamily: 'MaterialCommunityIcons'),
        );
}

/// Tuesday day view page.
class TuesdayPage extends DayViewPage {
  /// The page identifier.
  static const String id = 'day_view_2';

  /// Creates a new tuesday page instance.
  TuesdayPage({
    super.key,
  }) : super(
          weekDay: DateTime.tuesday,
          pageId: id,
          icon: const IconData(0xf03a7, fontFamily: 'MaterialCommunityIcons'),
        );
}

/// Wednesday day view page.
class WednesdayPage extends DayViewPage {
  /// The page identifier.
  static const String id = 'day_view_3';

  /// Creates a new wednesday page instance.
  WednesdayPage({
    super.key,
  }) : super(
          weekDay: DateTime.wednesday,
          pageId: id,
          icon: const IconData(0xf03aa, fontFamily: 'MaterialCommunityIcons'),
        );
}

/// Thursday day view page.
class ThursdayPage extends DayViewPage {
  /// The page identifier.
  static const String id = 'day_view_4';

  /// Creates a new thursday page instance.
  ThursdayPage({
    super.key,
  }) : super(
          weekDay: DateTime.thursday,
          pageId: id,
          icon: const IconData(0xf03ad, fontFamily: 'MaterialCommunityIcons'),
        );
}

/// Friday day view page.
class FridayPage extends DayViewPage {
  /// The page identifier.
  static const String id = 'day_view_5';

  /// Creates a new friday page instance.
  FridayPage({
    super.key,
  }) : super(
          weekDay: DateTime.friday,
          pageId: id,
          icon: const IconData(0xf03b1, fontFamily: 'MaterialCommunityIcons'),
        );
}

/// Saturday day view page.
class SaturdayPage extends DayViewPage {
  /// The page identifier.
  static const String id = 'day_view_6';

  /// Creates a new saturday page instance.
  SaturdayPage({
    super.key,
  }) : super(
          weekDay: DateTime.saturday,
          pageId: id,
          icon: const IconData(0xf03b3, fontFamily: 'MaterialCommunityIcons'),
        );
}

/// Sunday day view page.
class SundayPage extends DayViewPage {
  /// The page identifier.
  static const String id = 'day_view_7';

  /// Creates a new sunday page instance.
  SundayPage({
    super.key,
  }) : super(
          weekDay: DateTime.sunday,
          pageId: id,
          icon: const IconData(0xf03b6, fontFamily: 'MaterialCommunityIcons'),
        );
}
