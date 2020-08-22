import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/admob.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/pages/about.dart';
import 'package:unicaen_timetable/pages/bugs_improvements.dart';
import 'package:unicaen_timetable/pages/home/home.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/settings.dart';
import 'package:unicaen_timetable/pages/week_view/day_view.dart';
import 'package:unicaen_timetable/pages/week_view/week_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The app scaffold, containing the drawer and the shown page.
class AppScaffold extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppScaffoldState();
}

/// The app scaffold state.
class _AppScaffoldState extends State<AppScaffold> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

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
    Page page = context.watch<ValueNotifier<Page>>().value;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Builder(
          builder: (context) => AppBar(
            title: Text(page.buildTitle(context)),
            actions: page.buildActions(context),
          ),
        ),
      ),
      body: page,
      drawer: Drawer(child: createDrawer(context)),
      floatingActionButton: SynchronizeFloatingButton(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget createDrawer(BuildContext context) {
    SettingsModel settingsModel = context.watch<SettingsModel>();
    UserRepository userRepository = context.watch<UserRepository>();
    return Container(
      color: settingsModel.theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          createDrawerHeader(context, userRepository),
          const _DrawerSectionTitle(titleKey: 'home'),
          const _PageListTitle(page: HomePage()),
          const Divider(),
          const _DrawerSectionTitle(titleKey: 'timetable'),
          const _PageListTitle(page: WeekViewPage()),
          const _PageListTitle(page: DayViewPage(weekDay: DateTime.monday)),
          const _PageListTitle(page: DayViewPage(weekDay: DateTime.tuesday)),
          const _PageListTitle(page: DayViewPage(weekDay: DateTime.wednesday)),
          const _PageListTitle(page: DayViewPage(weekDay: DateTime.thursday)),
          const _PageListTitle(page: DayViewPage(weekDay: DateTime.friday)),
          const Divider(),
          const _DrawerSectionTitle(titleKey: 'others'),
          const _PageListTitle(page: SettingsPage()),
          const _PageListTitle(page: BugsImprovementsPage()),
          const _PageListTitle(page: AboutPage()),
        ],
      ),
    );
  }

  /// Creates the drawer header widget.
  Widget createDrawerHeader(BuildContext context, UserRepository userRepository) => FutureProvider<User>(
        create: (_) => userRepository.getUser(),
        child: _DrawerHeader(),
      );

  /// Goes to the date (if found in the app channel).
  void goToDateIfNeeded() {
    if(!Platform.isAndroid) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String rawDate = await UnicaenTimetableApp.CHANNEL.invokeMethod('activity.extract_date');
      if (rawDate != null) {
        DateTime date = DateFormat('yyyy-MM-dd').parse(rawDate);
        context.get<ValueNotifier<DateTime>>().value = date;
      }
    });
  }
}

/// The floating button that allows to synchronize the app.
class SynchronizeFloatingButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SynchronizeFloatingButtonState();

  /// Triggered when the floating button has been pressed.
  static Future<void> onPressed(BuildContext context) async {
    Utils.showSnackBar(
      context: context,
      icon: Icons.sync,
      textKey: 'synchronizing',
      color: Theme.of(context).primaryColor,
    );

    User user = await context.get<UserRepository>().getUser();

    LessonModel lessonModel = context.get<LessonModel>();
    dynamic result = await lessonModel.synchronizeFromZimbra(settingsModel: context.get<SettingsModel>(), user: user);

    if (result is bool && result) {
      Utils.showSnackBar(
        context: context,
        icon: Icons.check,
        textKey: 'success',
        color: Colors.green[700],
      );
      return;
    }

    LoginResult loginResult = result is bool ? LoginResult.GENERIC_ERROR : LoginResult.fromResponse(result);
    if (loginResult == LoginResult.NOT_FOUND) {
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.getString('calendar_not_found.title')),
          content: SingleChildScrollView(
            child: Text(context.getString('calendar_not_found.message')),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            )
          ],
        ),
      ));
    } else if (loginResult == LoginResult.UNAUTHORIZED) {
      Utils.showSnackBar(
        context: context,
        icon: Icons.error_outline,
        textKey: 'unauthorized',
        color: Colors.amber[800],
        onVisible: () => LoginDialog.show(context),
      );
    } else {
      Utils.showSnackBar(
        context: context,
        icon: Icons.error_outline,
        textKey: 'error',
        color: Colors.red[800],
      );
    }
  }
}

/// The synchronize floating button state.
class _SynchronizeFloatingButtonState extends State<SynchronizeFloatingButton> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    syncIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      syncIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = FloatingActionButton(
      onPressed: () => SynchronizeFloatingButton.onPressed(context),
      tooltip: context.getString('scaffold.floating_button_tooltip'),
      child: const Icon(Icons.sync),
    );

    if (context.watch<ValueNotifier<Page>>().value is! HomePage) {
      return button;
    }

    AdMobSettingsEntry adMobSettingsEntry = context.watch<SettingsModel>().adMobEntry;
    return FutureBuilder<Size>(
      initialData: Size.zero,
      future: adMobSettingsEntry.calculateSize(context),
      builder: (context, sizeSnapshot) => Padding(
        padding: EdgeInsets.only(bottom: sizeSnapshot.data.height),
        child: button,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Synchronize the app (if found in the app channel).
  void syncIfNeeded() {
    if(!Platform.isAndroid) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool shouldSync = await UnicaenTimetableApp.CHANNEL.invokeMethod('activity.extract_should_sync');
      if (shouldSync) {
        await SynchronizeFloatingButton.onPressed(context);
      }
    });
  }
}

/// The drawer header.
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = context.watch<User>();
    if (user == null) {
      return const SizedBox.shrink();
    }

    UnicaenTimetableTheme theme = context.watch<SettingsModel>().theme;
    return UserAccountsDrawerHeader(
      accountName: Text(user.usernameWithoutAt),
      accountEmail: Text(user.username.contains('@') ? user.username : (user.username + '@etu.unicaen.fr')),
      currentAccountPicture: SvgPicture.asset('assets/icon.svg'),
      decoration: BoxDecoration(color: theme.actionBarColor),
    );
  }
}

/// A drawer section title.
class _DrawerSectionTitle extends StatelessWidget {
  /// The title string key.
  final String titleKey;

  /// Creates a new drawer section title instance.
  const _DrawerSectionTitle({
    @required this.titleKey,
  });

  @override
  Widget build(BuildContext context) {
    UnicaenTimetableTheme theme = context.watch<SettingsModel>().theme;
    return ListTile(
      title: Text(
        context.getString('scaffold.drawer.${titleKey}'),
        style: TextStyle(color: theme.listHeaderTextColor),
      ),
      enabled: false,
    );
  }
}

/// Allows to show a page in the drawer (with its icon and its title).
class _PageListTitle extends StatelessWidget {
  /// The page.
  final Page page;

  /// Creates a new page list title instance.
  const _PageListTitle({
    @required this.page,
  });

  @override
  Widget build(BuildContext context) {
    UnicaenTimetableTheme theme = context.watch<SettingsModel>().theme;
    ValueNotifier<Page> currentPage = context.watch<ValueNotifier<Page>>();
    bool isCurrentPage = page.isSamePage(currentPage.value);
    return Material(
      color: isCurrentPage ? Colors.black12 : theme.scaffoldBackgroundColor,
      child: ListTile(
        leading: Icon(
          page.icon,
          color: isCurrentPage ? theme.selectedListTileTextColor : theme.textColor,
        ),
        title: Text(
          page.buildTitle(context),
          style: TextStyle(color: isCurrentPage ? theme.selectedListTileTextColor : theme.textColor),
        ),
        onTap: () {
          Navigator.pop(context);
          if (isCurrentPage) {
            return;
          }

          currentPage.value = page;
        },
      ),
    );
  }
}
