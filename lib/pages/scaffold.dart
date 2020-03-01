import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/pages/about.dart';
import 'package:unicaen_timetable/pages/home/home.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/settings.dart';
import 'package:unicaen_timetable/pages/week_view/day_view.dart';
import 'package:unicaen_timetable/pages/week_view/week_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';

class AppScaffold extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppScaffoldState();
}

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
    Page page = Provider.of<ValueNotifier<Page>>(context).value;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
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

  Widget createDrawer(BuildContext context) => Container(
        color: Provider.of<SettingsModel>(context).theme.scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            createDrawerHeader(context),
            const _DrawerSectionTitle(titleKey: 'home'),
            const _PageListTitle(page: HomePage()),
            const Divider(),
            const _DrawerSectionTitle(titleKey: 'timetable'),
            _PageListTitle(page: WeekViewPage()),
            _PageListTitle(page: DayViewPage(weekDay: DateTime.monday)),
            _PageListTitle(page: DayViewPage(weekDay: DateTime.tuesday)),
            _PageListTitle(page: DayViewPage(weekDay: DateTime.wednesday)),
            _PageListTitle(page: DayViewPage(weekDay: DateTime.thursday)),
            _PageListTitle(page: DayViewPage(weekDay: DateTime.friday)),
            const Divider(),
            const _DrawerSectionTitle(titleKey: 'others'),
            const _PageListTitle(page: SettingsPage()),
            const _PageListTitle(page: AboutPage()),
          ],
        ),
      );

  Widget createDrawerHeader(BuildContext context) => FutureProvider<User>(
        create: (_) => Provider.of<UserRepository>(context).get(),
        child: _DrawerHeader(),
      );

  void goToDateIfNeeded() => WidgetsBinding.instance.addPostFrameCallback((_) async {
    String rawDate = await UnicaenTimetableApp.CHANNEL.invokeMethod('activity.extract_date');
    if (rawDate != null) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(rawDate);
      Provider.of<ValueNotifier<DateTime>>(context, listen: false).value = date;
    }
  });
}

class SynchronizeFloatingButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SynchronizeFloatingButtonState();

  static Future<void> onPressed(BuildContext context) async {
    Utils.showSnackBar(
      context: context,
      icon: Icons.sync,
      textKey: 'synchronizing',
      color: Theme.of(context).primaryColor,
    );

    User user = await Provider.of<UserRepository>(context, listen: false).get();

    LessonModel lessonModel = Provider.of<LessonModel>(context, listen: false);
    dynamic result = await lessonModel.synchronizeFromZimbra(settingsModel: Provider.of<SettingsModel>(context, listen: false), user: user);

    if (result is bool && result) {
      Utils.showSnackBar(
        context: context,
        icon: Icons.check,
        textKey: 'success',
        color: Colors.green[700],
      );
    } else {
      LoginResult loginResult = result is bool ? LoginResult.GENERIC_ERROR : User.getLoginResultFromResponse(result);
      switch (loginResult) {
        case LoginResult.NOT_FOUND:
          unawaited(showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(EzLocalization.of(context).get('calendar_not_found.title')),
              content: SingleChildScrollView(
                child: Text(EzLocalization.of(context).get('calendar_not_found.message')),
              ),
              actions: [
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                )
              ],
            ),
          ));
          break;
        case LoginResult.UNAUTHORIZED:
          print((result as Response).headers);
          Utils.showSnackBar(
            context: context,
            icon: Icons.error_outline,
            textKey: 'unauthorized',
            color: Colors.amber[800],
            onVisible: () => LoginDialog.show(context),
          );
          break;
        default:
          Utils.showSnackBar(
            context: context,
            icon: Icons.error_outline,
            textKey: 'error',
            color: Colors.red[800],
          );
          break;
      }
    }
  }
}

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
      tooltip: EzLocalization.of(context).get('scaffold.floating_button_tooltip'),
      child: Icon(Icons.sync),
    );

    double paddingBottom = Provider.of<SettingsModel>(context).adMobEntry.calculatePaddingBottom(context);
    if(paddingBottom == 0 || Provider.of<ValueNotifier<Page>>(context).value is! HomePage) {
      return button;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: button,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void syncIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool shouldSync = await UnicaenTimetableApp.CHANNEL.invokeMethod('activity.extract_should_sync');
      if (shouldSync) {
        await SynchronizeFloatingButton.onPressed(context);
      }
    });
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    if (user == null) {
      return const SizedBox.shrink();
    }

    AppTheme theme = Provider.of<SettingsModel>(context).theme;
    return UserAccountsDrawerHeader(
      accountName: Text(user.usernameWithoutAt),
      accountEmail: Text(user.username.contains('@') ? user.username : (user.username + '@etu.unicaen.fr')),
      currentAccountPicture: SvgPicture.asset('assets/icon.svg'),
      decoration: BoxDecoration(color: theme.actionBarColor),
    );
  }
}

class _DrawerSectionTitle extends StatelessWidget {
  final String titleKey;

  const _DrawerSectionTitle({
    @required this.titleKey,
  });

  @override
  Widget build(BuildContext context) {
    AppTheme theme = Provider.of<SettingsModel>(context).theme;
    return ListTile(
      title: Text(
        EzLocalization.of(context).get('scaffold.drawer.${titleKey}'),
        style: TextStyle(color: theme.listHeaderTextColor),
      ),
      enabled: false,
    );
  }
}

class _PageListTitle extends StatelessWidget {
  final Page page;

  const _PageListTitle({
    @required this.page,
  });

  @override
  Widget build(BuildContext context) {
    AppTheme theme = Provider.of<SettingsModel>(context).theme;
    ValueNotifier<Page> currentPage = Provider.of<ValueNotifier<Page>>(context);
    bool isCurrentPage = page == currentPage.value;
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
