import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/pages/home/home.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/scaffold.dart';
import 'package:unicaen_timetable/pages/week_view/day_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The app main widget that creates the Scaffold with a page and a date.
class AppMainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppMainWidgetState();
}

/// The app main widget state.
class _AppMainWidgetState extends State<AppMainWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserRepository userRepository = Provider.of<UserRepository>(context, listen: false);
      SettingsModel settingsModel = Provider.of<SettingsModel>(context, listen: false);

      User user = await userRepository.getUser();
      if (user == null) {
        unawaited(Navigator.of(context).pushReplacementNamed('/intro'));
        return;
      }

      LoginResult loginResult = await user.login(settingsModel);
      if (loginResult == LoginResult.UNAUTHORIZED) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.getString('dialogs.unauthorized.title')),
            content: SingleChildScrollView(
              child: Text(context.getString('dialogs.unauthorized.message')),
            ),
            actions: [
              FlatButton(
                onPressed: () async {
                  await Navigator.pop(context);
                  unawaited(LoginDialog.show(context));
                },
                child: Text(context.getString('dialogs.unauthorized.button_login').toUpperCase()),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel.toUpperCase()),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settingsModel = Provider.of<SettingsModel>(context);
    bool openToday = settingsModel.getEntryByKey('application.open_today_automatically').value;
    int weekDay = DateTime.now().weekday;
    bool inWeekEnd = weekDay == DateTime.saturday || weekDay == DateTime.sunday;
    return RateMyAppBuilder(
      onInitialized: (context, rateMyApp) {
        if (rateMyApp.shouldOpenDialog) {
          unawaited(rateMyApp.showRateDialog(
            context,
            title: context.getString('dialogs.rate.title'),
            message: context.getString('dialogs.rate.message'),
            rateButton: context.getString('dialogs.rate.button_rate').toUpperCase(),
            laterButton: context.getString('dialogs.rate.button_later').toUpperCase(),
            noButton: context.getString('dialogs.rate.button_no').toUpperCase(),
          ));
        }
      },
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ValueNotifier<Page>>(create: (_) => ValueNotifier<Page>(openToday ? DayViewPage(weekDay: inWeekEnd ? DateTime.monday : weekDay) : const HomePage())),
          ChangeNotifierProvider<ValueNotifier<DateTime>>(create: (_) => ValueNotifier<DateTime>(_mondayOfCurrentWeek)),
        ],
        child: AppScaffold(),
      ),
    );
  }

  /// Returns monday of the current week.
  DateTime get _mondayOfCurrentWeek {
    DateTime date = DateTime.now().yearMonthDay;
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      date = date.add(const Duration(days: 7));
    }

    return date.atMonday;
  }
}
