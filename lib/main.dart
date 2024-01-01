import 'package:background_fetch/background_fetch.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show MobileAds;
import 'package:rate_my_app/rate_my_app.dart';
import 'package:unicaen_timetable/intro/scaffold.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/repository.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/widgets/ensure_logged_in.dart';

/// Hello world !
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const ProviderScope(child: UnicaenTimetableRoot()));
  BackgroundFetch.registerHeadlessTask(headlessSyncTask);
}

/// The headless synchronization task.
void headlessSyncTask(String taskId) async {
  UserRepository userRepository = UserRepository();
  await userRepository.initialize();

  if (userRepository.user != null) {
    LessonRepository lessonRepository = LessonRepository();
    SettingsModel settingsModel = SettingsModel();

    await settingsModel.initialize();
    await lessonRepository.initialize();
    await lessonRepository.downloadLessons(
      calendarUrl: settingsModel.calendarUrl,
      user: userRepository.user!,
    );
  }

  BackgroundFetch.finish(taskId);
}

/// The app first widget.
class UnicaenTimetableRoot extends ConsumerStatefulWidget {
  /// The communication channel.
  static const MethodChannel channel = MethodChannel('fr.skyost.timetable');

  /// Creates a new Unicaen timetable app instance.
  const UnicaenTimetableRoot({
    super.key,
  });

  @override
  ConsumerState createState() => _UnicaenTimetableRootState();
}

/// The app first widget state.
class _UnicaenTimetableRootState extends ConsumerState<UnicaenTimetableRoot> {
  @override
  void initState() {
    super.initState();
    initializeBackgroundTasks();
  }

  @override
  Widget build(BuildContext context) => EzLocalizationBuilder(
        delegate: const EzLocalizationDelegate(supportedLocales: [Locale('en'), Locale('fr')]),
        builder: (context, ezLocalization) => _UnicaenTimetableApp(ezLocalization: ezLocalization),
      );

  /// Initializes the background tasks.
  Future<void> initializeBackgroundTasks() async {
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: const Duration(days: 1).inMinutes,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        LessonRepository lessonRepository = ref.read(lessonRepositoryProvider);
        await lessonRepository.initialize();

        UserRepository userRepository = ref.read(userRepositoryProvider);
        await userRepository.initialize();

        SettingsModel settingsModel = ref.read(settingsModelProvider);
        await settingsModel.initialize();

        await lessonRepository.downloadLessons(calendarUrl: settingsModel.calendarUrl, user: userRepository.user);
        BackgroundFetch.finish(taskId);
      },
    );
  }
}

/// The app material widget.
class _UnicaenTimetableApp extends ConsumerWidget {
  /// The EzLocalization instance.
  final EzLocalizationDelegate ezLocalization;

  /// Creates a new Unicaen timetable app.
  const _UnicaenTimetableApp({
    required this.ezLocalization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SettingsModel settingsModel = ref.watch(settingsModelProvider);
    return MaterialApp(
      onGenerateTitle: (context) => EzLocalization.of(context)?.get('app_name') ?? 'Unicaen Timetable',
      theme: UnicaenTimetableTheme.light.themeData,
      darkTheme: UnicaenTimetableTheme.dark.themeData,
      themeMode: settingsModel.isInitialized ? settingsModel.themeEntry.value : ThemeMode.light,
      routes: {
        '/': (_) => EnsureLoggedInWidget(
              child: RateMyAppBuilder(
                onInitialized: (context, rateMyApp) {
                  if (rateMyApp.shouldOpenDialog) {
                    rateMyApp.showRateDialog(
                      context,
                      title: context.getString('dialogs.rate.title'),
                      message: context.getString('dialogs.rate.message'),
                      rateButton: context.getString('dialogs.rate.button_rate').toUpperCase(),
                      laterButton: context.getString('dialogs.rate.button_later').toUpperCase(),
                      noButton: context.getString('dialogs.rate.button_no').toUpperCase(),
                      ignoreNativeDialog: false,
                    );
                  }
                },
                builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: ref.watch(settingsModelProvider).resolveTheme(context).actionBarColor),
                  child: const PageContainer(),
                ),
              ),
            ),
        '/intro': (_) => const IntroScaffold(),
      },
      initialRoute: '/',
      localizationsDelegates: ezLocalization.localizationDelegates,
      supportedLocales: ezLocalization.supportedLocales,
      localeResolutionCallback: ezLocalization.localeResolutionCallback,
    );
  }
}
