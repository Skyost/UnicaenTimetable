import 'dart:io';

import 'package:flutter/material.dart' hide Page, DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/days_to_display.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/date_time_range.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';
import 'package:unicaen_timetable/widgets/flutter_week_view.dart';

/// The day view page list tile.
class DayViewPageListTile extends StatelessWidget {
  /// The week day.
  final int day;

  /// Creates a new day view page list tile.
  const DayViewPageListTile({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    DateTime monday = DateTime.now().atMonday;
    DateTime date = monday.add(Duration(days: day - 1));
    return PageListTitle(
      page: DayViewPage(day: day),
      title: DateFormat.EEEE(TranslationProvider.of(context).locale.languageCode).format(date).capitalize(),
      icon: _DayViewPageListTileIcon(
        day: day,
      ),
    );
  }
}

/// A day view page list tile icon, with a number.
class _DayViewPageListTileIcon extends StatelessWidget {
  /// The week day.
  final int day;

  /// Creates a new day view page list tile icon.
  const _DayViewPageListTileIcon({
    required this.day,
  });

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Icon(Icons.square_rounded),
      Positioned.fill(
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}

/// The about week view app bar.
class DayViewPageAppBar extends ConsumerWidget {
  /// The share button key.
  final GlobalKey _shareButtonKey = GlobalKey();

  /// The week day.
  final int day;

  /// Creates a new week view page app bar.
  DayViewPageAppBar({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> sidebarDays = ref.watch(daysToDisplayEntryProvider).valueOrNull ?? [];
    DateTime monday = DateTime.now().atMonday;
    DateTime date = monday.add(Duration(days: day - 1));
    return AppBar(
      title: Text(DateFormat.EEEE(TranslationProvider.of(context).locale.languageCode).format(date).capitalize()),
      actions: [
        if (sidebarDays.isNotEmpty)
          IconButton(
            icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
            onPressed: () => DayViewPageWidget._previousDay(ref, day),
          ),
        if (sidebarDays.isNotEmpty)
          IconButton(
            icon: Icon(Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_forward_ios),
            onPressed: () => DayViewPageWidget._nextDay(ref, day),
          ),
        const WeekPickerButton(),
        IconButton(
          key: _shareButtonKey,
          icon: const Icon(Icons.share),
          onPressed: () async {
            String? languageCode = TranslationProvider.of(context).locale.languageCode;
            RenderObject? renderObject = _shareButtonKey.currentContext?.findRenderObject();
            Offset? position;

            if (renderObject is RenderBox) {
              position = renderObject.localToGlobal(Offset.zero);
            }

            StringBuffer builder = StringBuffer();
            DateTime monday = ref.watch(dateProvider);
            DateTime day = monday.add(Duration(days: this.day));
            List<Lesson> lessons = await ref.read(lessonsProvider(DateTimeRange.oneDay(day)).future);
            builder.write('${DateFormat.yMd(languageCode).format(date)} :\n\n');
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
      ],
    );
  }
}

/// The day view page widget.
class DayViewPageWidget extends ConsumerStatefulWidget {
  /// The week day.
  final int day;

  /// Creates a new day view page instance.
  const DayViewPageWidget({
    super.key,
    required this.day,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DayViewPageWidgetState();

  /// Goes to the previous day.
  static Future<void> _previousDay(WidgetRef ref, int currentWeekDay) async {
    List<int> sidebarDays = await ref.read(daysToDisplayEntryProvider.future);
    int previousDay = sidebarDays.previousDay(currentWeekDay);
    if (previousDay >= currentWeekDay) {
      DateTime monday = ref.read(dateProvider);
      monday = monday.subtract(const Duration(days: 7));
      ref.read(dateProvider.notifier).changeDate(monday);
    }
    ref.read(pageProvider.notifier).changePage(DayViewPage(day: previousDay));
  }

  /// Goes to the next day.
  static Future<void> _nextDay(WidgetRef ref, int currentWeekDay) async {
    List<int> sidebarDays = await ref.read(daysToDisplayEntryProvider.future);
    int nextDay = sidebarDays.nextDay(currentWeekDay);
    if (nextDay <= currentWeekDay) {
      DateTime monday = ref.read(dateProvider);
      monday = monday.add(const Duration(days: 7));
      ref.read(dateProvider.notifier).changeDate(monday);
    }
    ref.read(pageProvider.notifier).changePage(DayViewPage(day: nextDay));
  }
}

/// The day view page widget state.
class _DayViewPageWidgetState extends FlutterWeekViewWidgetState<DayViewPageWidget> {
  @override
  Widget buildChild(List<FlutterWeekViewEvent> events) {
    DateTime monday = ref.watch(dateProvider);
    DateTime date = monday.add(Duration(days: widget.day - 1));
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) {
          return;
        }

        if (details.primaryVelocity! > 0) {
          DayViewPageWidget._previousDay(ref, widget.day);
        }

        if (details.primaryVelocity! < 0) {
          DayViewPageWidget._nextDay(ref, widget.day);
        }
      },
      child: DayView(
        date: date,
        events: events,
        initialTime: const HourMinute(hour: 7),
        style: createDayViewStyle(date),
        dayBarStyle: createDayBarStyle(date, (year, month, day) => formatDate(context, year, month, day)),
        hoursColumnStyle: createHoursColumnStyle(),
      ),
    );
  }

  @override
  AsyncValue<List<Lesson>> queryLessons() {
    DateTime monday = ref.watch(dateProvider);
    DateTime day = monday.add(Duration(days: widget.day - 1));
    return ref.watch(lessonsProvider(DateTimeRange.oneDay(day)));
  }
}
