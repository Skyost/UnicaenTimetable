import 'package:background_fetch/background_fetch.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/intro/scaffold.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/pages/main_widget.dart';
import 'package:unicaen_timetable/utils/utils.dart';

void main() async {
  await Hive.initFlutter();
  runApp(UnicaenTimetableApp());
  unawaited(BackgroundFetch.registerHeadlessTask(headlessSyncTask));
}

void headlessSyncTask(String taskId) async {
  await Hive.initFlutter();

  UserRepository userRepository = UserRepository();
  await userRepository.initialize();

  User user = await userRepository.get();
  if (user != null) {
    LessonModel lessonModel = LessonModel();
    SettingsModel settingsModel = SettingsModel();

    await settingsModel.initialize();
    await lessonModel.initialize();
    await lessonModel.synchronizeFromZimbra(
      settingsModel: settingsModel,
      user: user,
    );
  }

  await Hive.close();
  BackgroundFetch.finish(taskId);
}

class UnicaenTimetableApp extends StatefulWidget {
  static const MethodChannel CHANNEL = MethodChannel('fr.skyost.timetable');

  @override
  State<StatefulWidget> createState() => _UnicaenTimetableAppState();
}

class _UnicaenTimetableAppState extends State<UnicaenTimetableApp> {
  final EzLocalizationDelegate ezLocalization = const EzLocalizationDelegate(supportedLocales: [Locale('en'), Locale('fr')]);

  LessonModel lessonModel;
  UserRepository userRepository;
  SettingsModel settingsModel;

  @override
  void initState() {
    super.initState();
    lessonModel = LessonModel();
    userRepository = UserRepository();
    settingsModel = SettingsModel();

    lessonModel.initialize();
    userRepository.initialize();
    settingsModel.initialize();

    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: const Duration(days: 1).inMinutes,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        await lessonModel.synchronizeFromZimbra(settingsModel: settingsModel, user: await userRepository.get());
        BackgroundFetch.finish(taskId);
      },
    );
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<LessonModel>.value(value: lessonModel),
          ChangeNotifierProvider<UserRepository>.value(value: userRepository),
          ChangeNotifierProvider<SettingsModel>.value(value: settingsModel),
          ChangeNotifierProvider<HomeCardsModel>(create: (_) => HomeCardsModel()..initialize(), lazy: false),
        ],
        child: Consumer<SettingsModel>(
          builder: (context, settingsModel, child) => MaterialApp(
            onGenerateTitle: (context) => EzLocalization.of(context)?.get('app_name') ?? 'Unicaen Timetable',
            theme: settingsModel.theme?.themeData ?? ThemeData(primaryColor: Colors.indigo),
            routes: {
              '/': (context) {
                if (!Provider.of<LessonModel>(context).isInitialized || !Provider.of<UserRepository>(context).isInitialized || !settingsModel.isInitialized) {
                  return const Scaffold(
                    body: CenteredCircularProgressIndicator(color: Colors.white),
                    backgroundColor: Colors.indigo,
                  );
                }

                return AppMainWidget();
              },
              '/intro': (_) => IntroScaffold(),
            },
            initialRoute: '/',
            localizationsDelegates: ezLocalization.localizationDelegates,
            supportedLocales: ezLocalization.supportedLocales,
            localeResolutionCallback: ezLocalization.localeResolutionCallback,
          ),
        ),
      );

  @override
  void dispose() {
    lessonModel.dispose();
    userRepository.dispose();
    settingsModel.dispose();
    Hive.close();
    super.dispose();
  }
}