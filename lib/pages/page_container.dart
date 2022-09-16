import 'dart:io';

import 'package:flutter/material.dart' hide DrawerHeader, Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/about.dart';
import 'package:unicaen_timetable/pages/bugs_improvements.dart';
import 'package:unicaen_timetable/pages/day_view.dart';
import 'package:unicaen_timetable/pages/home.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/settings.dart';
import 'package:unicaen_timetable/pages/week_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/drawer/header.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';
import 'package:unicaen_timetable/widgets/drawer/section_title.dart';
import 'package:unicaen_timetable/widgets/synchronize_floating_button.dart';

final currentDateProvider = ChangeNotifierProvider((ref) {
  DateTime date = DateTime.now().yearMonthDay;
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    date = date.add(const Duration(days: 7));
  }

  return ValueNotifier<DateTime>(date.atMonday);
});

final currentPageProvider = ChangeNotifierProvider((ref) {
  SettingsModel settingsModel = ref.read(settingsModelProvider);
  bool openToday = settingsModel.getEntryByKey('application.open_today_automatically')!.value;
  int weekDay = DateTime.now().weekday;
  bool inWeekEnd = weekDay == DateTime.saturday || weekDay == DateTime.sunday;
  return ValueNotifier<String>(openToday ? DayViewPage.buildPageId(inWeekEnd ? DateTime.monday : weekDay) : HomePage.id);
});

/// The app scaffold, containing the drawer and the shown page.
class PageContainer extends ConsumerStatefulWidget {
  /// Creates a new page container instance.
  const PageContainer({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  ConsumerState createState() => _PageContainerState();
}

/// The app scaffold state.
class _PageContainerState extends ConsumerState<PageContainer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // TODO: Show message to tell that settings have been reset
    WidgetsBinding.instance.addObserver(this);
    goToDateIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      goToDateIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    Page page = Page.createFromId(ref.watch(currentPageProvider).value);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) => AppBar(
            title: Text(page.buildTitle(context)),
            actions: page.buildActions(context, ref),
          ),
        ),
      ),
      body: page,
      drawer: Drawer(child: createDrawer(context)),
      floatingActionButton: const SynchronizeFloatingButton(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget createDrawer(BuildContext context) {
    SettingsModel settingsModel = ref.watch(settingsModelProvider);
    return Container(
      color: settingsModel.resolveTheme(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(),
          const DrawerSectionTitle(titleKey: 'home'),
          const PageListTitle(page: HomePage()),
          const Divider(),
          const DrawerSectionTitle(titleKey: 'timetable'),
          const PageListTitle(page: WeekViewPage()),
          for (int day in settingsModel.sidebarDaysEntry.value) //
            PageListTitle(page: Page.createFromId(DayViewPage.buildPageId(day))),
          const Divider(),
          const DrawerSectionTitle(titleKey: 'others'),
          const PageListTitle(page: SettingsPage()),
          const PageListTitle(page: BugsImprovementsPage()),
          const PageListTitle(page: AboutPage()),
        ],
      ),
    );
  }

  /// Goes to the date (if found in the app channel).
  void goToDateIfNeeded() {
    if (!Platform.isAndroid) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? rawDate = await UnicaenTimetableRoot.channel.invokeMethod<String>('activity.extract_date');
      if (rawDate != null) {
        DateTime date = DateFormat('yyyy-MM-dd').parse(rawDate);
        ref.read(currentDateProvider).value = date;
      }
    });
  }

  /// Synchronize the app (if found in the app channel).
  void syncIfNeeded() {
    if (!Platform.isAndroid) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool? shouldSync = await UnicaenTimetableRoot.channel.invokeMethod<bool>('activity.extract_should_sync');
      if (shouldSync != null && shouldSync && mounted) {
        LessonRepository lessonRepository = ref.read(lessonRepositoryProvider);
        await lessonRepository.downloadLessonsFromWidget(context, ref);
      }
    });
  }
}





