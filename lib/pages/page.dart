import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/open_today_automatically.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The date provider
final dateProvider = NotifierProvider<DateNotifier, DateTime>(DateNotifier.new);

/// The date notifier.
class DateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    DateTime date = DateTime.now().yearMonthDay;
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      date = date.add(const Duration(days: 7));
    }
    return date.atMonday;
  }

  /// Changes the date.
  void changeDate(DateTime date) => state = date.atMonday;
}

/// The page provider
final pageProvider = AsyncNotifierProvider<PageNotifier, Page>(PageNotifier.new);

/// The page notifier.
class PageNotifier extends AsyncNotifier<Page> {
  @override
  FutureOr<Page> build() async {
    bool openTodayAutomatically = await ref.read(openTodayAutomaticallyEntryProvider.future);
    int weekDay = DateTime.now().weekday;
    bool inWeekEnd = weekDay == DateTime.saturday || weekDay == DateTime.sunday;
    return openTodayAutomatically ? DayViewPage(day: inWeekEnd ? DateTime.monday : weekDay) : HomePage();
  }

  @override
  bool updateShouldNotify(AsyncValue<Page> previous, AsyncValue<Page> next) {
    if (previous.hasValue && next.hasValue) {
      return !previous.value!.isSamePage(next.value!);
    }
    return super.updateShouldNotify(previous, next);
  }

  /// Changes the page.
  void changePage(Page page) => state = AsyncData(page);
}

/// A page with a title and an icon, can be added to a drawer.
sealed class Page {
  /// Returns whether the [page] is the same page than the current one.
  bool isSamePage(Page page);
}

/// The home page.
class HomePage extends Page {
  @override
  bool isSamePage(Page page) => page is HomePage;
}

/// The page that allows to show a day's lessons.
class DayViewPage extends Page {
  /// The day to display.
  final int day;

  /// Creates a new day view page instance.
  DayViewPage({
    required this.day,
  });

  @override
  bool isSamePage(Page page) => page is DayViewPage && page.day == day;
}

/// The page that allows to show a week's lessons.
class WeekViewPage extends Page {
  @override
  bool isSamePage(Page page) => page is WeekViewPage;
}

/// The page that allows to configure the app.
class SettingsPage extends Page {
  @override
  bool isSamePage(Page page) => page is SettingsPage;
}

/// A page that allows the user to contact me in case of any bug occurred / improvements needed.
class BugsImprovementsPage extends Page {
  @override
  bool isSamePage(Page page) => page is BugsImprovementsPage;
}

/// The about page that shows info about the app.
class AboutPage extends Page {
  @override
  bool isSamePage(Page page) => page is AboutPage;
}
