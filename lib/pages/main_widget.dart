import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
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

class AppMainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppMainWidgetState();
}

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
          builder: (_) => AlertDialog(
            title: Text(EzLocalization.of(context).get('dialogs.unauthorized.title')),
            content: SingleChildScrollView(
              child: Text(EzLocalization.of(context).get('dialogs.unauthorized.message')),
            ),
            actions: [
              FlatButton(
                onPressed: () async {
                  await Navigator.pop(context);
                  unawaited(LoginDialog.show(context));
                },
                child: Text(EzLocalization.of(context).get('dialogs.unauthorized.button_login').toUpperCase()),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel.toUpperCase()),
              ),
            ],
          ),
        );
      }

      RateMyApp rateMyApp = RateMyApp();
      await rateMyApp.init();
      if (rateMyApp.shouldOpenDialog) {
        EzLocalization ezLocalization = EzLocalization.of(context);
        unawaited(rateMyApp.showRateDialog(
          context,
          title: ezLocalization.get('dialogs.rate.title'),
          message: ezLocalization.get('dialogs.rate.message'),
          rateButton: ezLocalization.get('dialogs.rate.button_rate').toUpperCase(),
          laterButton: ezLocalization.get('dialogs.rate.button_later').toUpperCase(),
          noButton: ezLocalization.get('dialogs.rate.button_no').toUpperCase(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settingsModel = Provider.of<SettingsModel>(context);
    bool openToday = settingsModel.getEntryByKey('application.open_today_automatically').value;
    int weekDay = DateTime.now().weekday;
    bool inWeekEnd = weekDay == DateTime.saturday || weekDay == DateTime.sunday;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ValueNotifier<Page>>(create: (_) => ValueNotifier<Page>(openToday ? DayViewPage(weekDay: inWeekEnd ? DateTime.monday : weekDay) : const HomePage())),
        ChangeNotifierProvider<ValueNotifier<DateTime>>(create: (_) => ValueNotifier<DateTime>(_mondayOfCurrentWeek)),
      ],
      child: AppScaffold(),
    );
  }

  DateTime get _mondayOfCurrentWeek {
    DateTime date = DateTime.now().yearMonthDay;
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      date = date.add(const Duration(days: 7));
    }

    return date.atMonday;
  }
}
