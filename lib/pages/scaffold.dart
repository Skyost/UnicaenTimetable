import 'package:flutter/material.dart' hide DrawerHeader, Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/settings/sidebar_days.dart';
import 'package:unicaen_timetable/pages/about.dart';
import 'package:unicaen_timetable/pages/bugs_improvements.dart';
import 'package:unicaen_timetable/pages/day_view.dart';
import 'package:unicaen_timetable/pages/home/page.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/settings/page.dart';
import 'package:unicaen_timetable/pages/week_view.dart';
import 'package:unicaen_timetable/utils/lesson_download.dart';
import 'package:unicaen_timetable/utils/widgets.dart';
import 'package:unicaen_timetable/widgets/drawer/header.dart';
import 'package:unicaen_timetable/widgets/drawer/section_title.dart';

/// The app scaffold, containing the drawer and the shown page.
class AppScaffold extends ConsumerStatefulWidget {
  /// Creates a new page container instance.
  const AppScaffold({
    super.key,
  });

  @override
  ConsumerState createState() => _PageContainerState();
}

/// The app scaffold state.
class _PageContainerState extends ConsumerState<AppScaffold> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      RateMyApp rateMyApp = RateMyApp();
      await rateMyApp.init();
      if (rateMyApp.shouldOpenDialog && mounted) {
        rateMyApp.showRateDialog(
          context,
          ignoreNativeDialog: false,
        );
      }
    });
    WidgetsBinding.instance.addObserver(this);
    goToDateIfNeeded();
    syncIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      goToDateIfNeeded();
      syncIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _AppBar(),
        ),
        body: _Page(),
        drawer: _Drawer(),
        floatingActionButton: _FloatingButton(),
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Goes to the date (if found in the app channel).
  void goToDateIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? rawDate = await UnicaenTimetableRoot.channel.invokeMethod<String>('activity.getRequestedDateString');
      if (rawDate != null) {
        DateTime date = DateFormat('yyyy-MM-dd').parse(rawDate);
        ref.read(dateProvider.notifier).changeDate(date);
        ref.read(pageProvider.notifier).changePage(DayViewPage(day: date.weekday));
      }
    });
  }

  /// Synchronize the app (if found in the app channel).
  void syncIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool? shouldSync = await UnicaenTimetableRoot.channel.invokeMethod<bool>('activity.shouldRefreshTimeTable');
      if (shouldSync == true && mounted) {
        await downloadLessons(ref);
      }
    });
  }
}

/// The app bar.
class _AppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Page? page = ref.watch(pageProvider).valueOrNull;
    return switch (page) {
      HomePage() => const HomePageAppBar(),
      DayViewPage(:final day) => DayViewPageAppBar(day: day),
      WeekViewPage() => const WeekViewPageAppBar(),
      SettingsPage() => const SettingsPageAppBar(),
      BugsImprovementsPage() => const BugsImprovementsPageAppBar(),
      AboutPage() => const AboutPageAppBar(),
      _ => AppBar(
          title: Text(translations.common.appName),
        ),
    };
  }
}

/// The page.
class _Page extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Page? page = ref.watch(pageProvider).valueOrNull;
    return switch (page) {
      HomePage() => const HomePageWidget(),
      DayViewPage(:final day) => DayViewPageWidget(day: day),
      WeekViewPage() => const WeekViewPageWidget(),
      SettingsPage() => const SettingsPageWidget(),
      BugsImprovementsPage() => const BugsImprovementsPageWidget(),
      AboutPage() => const AboutPageWidget(),
      _ => const CenteredCircularProgressIndicator(),
    };
  }
}

/// The drawer.
class _Drawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> sidebarDays = ref.watch(sidebarDaysEntryProvider).valueOrNull ?? [];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(),
          DrawerSectionTitle(title: translations.scaffold.drawer.home),
          const HomePageListTile(),
          DrawerSectionTitle(title: translations.scaffold.drawer.timetable),
          const WeekViewPageListTile(),
          for (int day in sidebarDays) //
            DayViewPageListTile(day: day),
          DrawerSectionTitle(title: translations.scaffold.drawer.others),
          const SettingsPageListTile(),
          const BugsImprovementsPageListTile(),
          const AboutPageListTile(),
        ],
      ),
    );
  }
}

/// The floating button that allows to synchronize the app.
class _FloatingButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => FloatingActionButton(
        onPressed: () async => await downloadLessons(ref),
        tooltip: translations.scaffold.floatingButtonTooltip,
        elevation: 1,
        child: const Icon(Icons.sync),
      );
}
