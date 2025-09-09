import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/firebase_options.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/intro/scaffold.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/theme.dart';
import 'package:unicaen_timetable/pages/scaffold.dart';
import 'package:unicaen_timetable/widgets/ensure_logged_in.dart';

/// Hello world !
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  await LocaleSettings.useDeviceLocale();
  runApp(
    ProviderScope(
      child: TranslationProvider(
        child: const UnicaenTimetableRoot(),
      ),
    ),
  );
  BackgroundFetch.registerHeadlessTask(headlessSyncTask);
}

/// The headless synchronization task.
@pragma('vm:entry-point')
Future<void> headlessSyncTask(String taskId) async {
  ProviderContainer providerContainer = ProviderContainer();
  await providerContainer.read(lessonRepositoryProvider.notifier).refreshLessons();
  providerContainer.dispose();
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
  Widget build(BuildContext context) => const _UnicaenTimetableApp();

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
        await ref.read(lessonRepositoryProvider.notifier).refreshLessons();
        BackgroundFetch.finish(taskId);
      },
    );
  }
}

/// The app material widget.
class _UnicaenTimetableApp extends ConsumerWidget {
  /// Creates a new Unicaen timetable app.
  const _UnicaenTimetableApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ThemeMode> theme = ref.watch(themeSettingsEntryProvider);
    ColorScheme light = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
    );
    ColorScheme dark = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      onGenerateTitle: (context) => translations.common.appName,
      theme: ThemeData(
        colorScheme: light,
        appBarTheme: AppBarTheme(
          foregroundColor: light.onPrimary,
          backgroundColor: light.primary,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: light.surface,
          ),
          shape: const RoundedRectangleBorder(),
        ),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: dark,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: dark.surface,
          ),
          shape: const RoundedRectangleBorder(),
        ),
        brightness: Brightness.dark,
      ),
      themeMode: theme.valueOrNull,
      routes: {
        '/': (_) => const EnsureLoggedInWidget(
          child: AppScaffold(),
        ),
        '/intro': (_) => const IntroScaffold(),
      },
      initialRoute: '/',
      locale: TranslationProvider.of(context).flutterLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocaleUtils.supportedLocales,
    );
  }
}
