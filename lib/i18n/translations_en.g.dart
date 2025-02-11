///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final translations = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final TranslationsAboutEn about = TranslationsAboutEn.internal(_root);
	late final TranslationsBugsImprovementsEn bugsImprovements = TranslationsBugsImprovementsEn.internal(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsDialogsEn dialogs = TranslationsDialogsEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsIntroEn intro = TranslationsIntroEn.internal(_root);
	late final TranslationsScaffoldEn scaffold = TranslationsScaffoldEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsWeekViewEn weekView = TranslationsWeekViewEn.internal(_root);
}

// Path: about
class TranslationsAboutEn {
	TranslationsAboutEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'About';
	late final TranslationsAboutParagraphsEn paragraphs = TranslationsAboutParagraphsEn.internal(_root);
}

// Path: bugsImprovements
class TranslationsBugsImprovementsEn {
	TranslationsBugsImprovementsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Bugs / Improvements';
	late final TranslationsBugsImprovementsMessageEn message = TranslationsBugsImprovementsMessageEn.internal(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get appName => 'Unicaen Timetable';
	late final TranslationsCommonOtherEn other = TranslationsCommonOtherEn.internal(_root);
}

// Path: dialogs
class TranslationsDialogsEn {
	TranslationsDialogsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsDialogsLessonInfoEn lessonInfo = TranslationsDialogsLessonInfoEn.internal(_root);
	late final TranslationsDialogsLessonColorEn lessonColor = TranslationsDialogsLessonColorEn.internal(_root);
	late final TranslationsDialogsWeekPickerEn weekPicker = TranslationsDialogsWeekPickerEn.internal(_root);
	late final TranslationsDialogsLoginEn login = TranslationsDialogsLoginEn.internal(_root);
	late final TranslationsDialogsCalendarNotFoundEn calendarNotFound = TranslationsDialogsCalendarNotFoundEn.internal(_root);
	late final TranslationsDialogsUnauthorizedEn unauthorized = TranslationsDialogsUnauthorizedEn.internal(_root);
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Home';
	String get noCard => 'It feels a bit empty here. Feel free to add some widgets using the upper-right button.';
	String get loading => 'Loading…';
	late final TranslationsHomeSynchronizationStatusEn synchronizationStatus = TranslationsHomeSynchronizationStatusEn.internal(_root);
	late final TranslationsHomeCurrentLessonEn currentLesson = TranslationsHomeCurrentLessonEn.internal(_root);
	late final TranslationsHomeNextLessonEn nextLesson = TranslationsHomeNextLessonEn.internal(_root);
	late final TranslationsHomeCurrentThemeEn currentTheme = TranslationsHomeCurrentThemeEn.internal(_root);
	late final TranslationsHomeInfoEn info = TranslationsHomeInfoEn.internal(_root);
}

// Path: intro
class TranslationsIntroEn {
	TranslationsIntroEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsIntroButtonsEn buttons = TranslationsIntroButtonsEn.internal(_root);
	late final TranslationsIntroSlidesEn slides = TranslationsIntroSlidesEn.internal(_root);
}

// Path: scaffold
class TranslationsScaffoldEn {
	TranslationsScaffoldEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsScaffoldSettingsResetEn settingsReset = TranslationsScaffoldSettingsResetEn.internal(_root);
	String get floatingButtonTooltip => 'Synchronize';
	late final TranslationsScaffoldWaitEn wait = TranslationsScaffoldWaitEn.internal(_root);
	late final TranslationsScaffoldDrawerEn drawer = TranslationsScaffoldDrawerEn.internal(_root);
	late final TranslationsScaffoldSnackBarEn snackBar = TranslationsScaffoldSnackBarEn.internal(_root);
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	late final TranslationsSettingsApplicationEn application = TranslationsSettingsApplicationEn.internal(_root);
	late final TranslationsSettingsAccountEn account = TranslationsSettingsAccountEn.internal(_root);
	late final TranslationsSettingsCalendarEn calendar = TranslationsSettingsCalendarEn.internal(_root);
}

// Path: weekView
class TranslationsWeekViewEn {
	TranslationsWeekViewEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Week view';
}

// Path: about.paragraphs
class TranslationsAboutParagraphsEn {
	TranslationsAboutParagraphsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get first => 'This app has been created by Skyost and is available under the therms of the GNU GPL v3 license. It\'s using Flutter and has been written in Dart by using some technologies. You can view all of this using the links below.';
	String get second => 'Disclaimer. This application has not been developed by any official member of the University. Consequently, do not send any request to the University if you have a problem with this application. Furthermore, this application needs your student number with your password to work. Your credentials will not be send to any third party, except to the University server in order to download your timetable. If you do not trust this application, you can still check the source code with the "Github" link below.';
}

// Path: bugsImprovements.message
class TranslationsBugsImprovementsMessageEn {
	TranslationsBugsImprovementsMessageEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get github => 'You have some options to report me a bug or to suggest me an improvement. For example, you can use the Github issue tracker which is available <a href="https://github.com/Skyost/UnicaenTimetable/issues/">here</a>.';
	String get website => 'You can also send me an email via the form which is available <a href="https://skyost.eu/#contact">here</a>.';
}

// Path: common.other
class TranslationsCommonOtherEn {
	TranslationsCommonOtherEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get fieldEmpty => 'This field cannot be empty.';
	String get pleaseWait => 'Please wait…';
}

// Path: dialogs.lessonInfo
class TranslationsDialogsLessonInfoEn {
	TranslationsDialogsLessonInfoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get resetColor => 'Default color';
	String get setAlarm => 'Set alarm';
}

// Path: dialogs.lessonColor
class TranslationsDialogsLessonColorEn {
	TranslationsDialogsLessonColorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Lesson color';
}

// Path: dialogs.weekPicker
class TranslationsDialogsWeekPickerEn {
	TranslationsDialogsWeekPickerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Pick the week to display';
	String get empty => 'There is no lesson. Please check that your timetable is available on Zimbra.';
}

// Path: dialogs.login
class TranslationsDialogsLoginEn {
	TranslationsDialogsLoginEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Login';
	String get username => 'Étupass :';
	String get usernameHint => 'Before the @etu.unicaen.fr';
	String get password => 'Password :';
	String get passwordHint => 'Your password';
	String get login => 'Login';
	late final TranslationsDialogsLoginMoreSettingsEn moreSettings = TranslationsDialogsLoginMoreSettingsEn.internal(_root);
	late final TranslationsDialogsLoginErrorsEn errors = TranslationsDialogsLoginErrorsEn.internal(_root);
}

// Path: dialogs.calendarNotFound
class TranslationsDialogsCalendarNotFoundEn {
	TranslationsDialogsCalendarNotFoundEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Calendar not found';
	String get message => 'If you just came back from holidays (or if you are in holidays), this is normal, please try again once your timetable will be available on Zimbra.\nOtherwise, it probably means that you\'ve entered a wrong username.\nYou may also have entered a bad calendar name in the app settings or the servers are in maintenance.\nAnyway, this error is common. Please try again later.';
}

// Path: dialogs.unauthorized
class TranslationsDialogsUnauthorizedEn {
	TranslationsDialogsUnauthorizedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Wrong credentials';
	String get message => 'Your username or your password may have been entered incorrectly.';
	String get buttonLogin => 'Change account';
}

// Path: home.synchronizationStatus
class TranslationsHomeSynchronizationStatusEn {
	TranslationsHomeSynchronizationStatusEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Synchronization status';
	String get title => 'Last synchronization :';
	String get bad => 'You may have to synchronize the app.';
	String get good => 'The app is up-to-date.';
	String get never => 'Never';
}

// Path: home.currentLesson
class TranslationsHomeCurrentLessonEn {
	TranslationsHomeCurrentLessonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Current lesson';
	String get title => 'Now :';
	String get nothing => 'No lesson.';
}

// Path: home.nextLesson
class TranslationsHomeNextLessonEn {
	TranslationsHomeNextLessonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Next lesson';
	String get title => 'Next lesson :';
	String get nothing => 'Nothing today.';
}

// Path: home.currentTheme
class TranslationsHomeCurrentThemeEn {
	TranslationsHomeCurrentThemeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Current theme';
	String get title => 'Current theme :';
	String get light => 'Light mode';
	String get dark => 'Dark mode';
	String get auto => 'picked by system';
}

// Path: home.info
class TranslationsHomeInfoEn {
	TranslationsHomeInfoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Device & app info';
	String get title => 'Info :';
}

// Path: intro.buttons
class TranslationsIntroButtonsEn {
	TranslationsIntroButtonsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get next => 'Next';
	String get finish => 'Finish';
}

// Path: intro.slides
class TranslationsIntroSlidesEn {
	TranslationsIntroSlidesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsIntroSlidesMainEn main = TranslationsIntroSlidesMainEn.internal(_root);
	late final TranslationsIntroSlidesLoginEn login = TranslationsIntroSlidesLoginEn.internal(_root);
	late final TranslationsIntroSlidesFinishedEn finished = TranslationsIntroSlidesFinishedEn.internal(_root);
}

// Path: scaffold.settingsReset
class TranslationsScaffoldSettingsResetEn {
	TranslationsScaffoldSettingsResetEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get message => 'The app settings have been reset due to an update. We really apologize for this trouble.';
	String get ios => 'If you\'re on iOS, you may also have to reconnect yourself.';
	String get end => 'Thanks for using this app 💘';
}

// Path: scaffold.wait
class TranslationsScaffoldWaitEn {
	TranslationsScaffoldWaitEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get settingsRepository => 'Initializing settings…';
	String get lessonRepository => 'Initializing the lessons repository…';
	String get userRepository => 'Initializing the user repository…';
	String get hasUser => 'Waiting for the user…';
}

// Path: scaffold.drawer
class TranslationsScaffoldDrawerEn {
	TranslationsScaffoldDrawerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get home => 'Home';
	String get timetable => 'Timetable';
	String get others => 'Others';
}

// Path: scaffold.snackBar
class TranslationsScaffoldSnackBarEn {
	TranslationsScaffoldSnackBarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get synchronizing => 'Synchronizing…';
	String get success => 'Success.';
	String get unauthorized => 'Wrong username / password.';
	String get genericError => 'Error. Please try again later.';
	String get widgetAlreadyPresent => 'The selected widget is already present on the application home screen.';
}

// Path: settings.application
class TranslationsSettingsApplicationEn {
	TranslationsSettingsApplicationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Application';
	String get sidebarDays => 'Days to show in the sidebar';
	String get colorLessonsAutomatically => 'Automatically color lessons';
	String get openTodayAutomatically => 'Open today\'s page at launch';
	String get enableAds => 'Enable ads';
	late final TranslationsSettingsApplicationBrightnessEn brightness = TranslationsSettingsApplicationBrightnessEn.internal(_root);
}

// Path: settings.account
class TranslationsSettingsAccountEn {
	TranslationsSettingsAccountEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Account';
	String get kSwitch => 'Switch account';
}

// Path: settings.calendar
class TranslationsSettingsCalendarEn {
	TranslationsSettingsCalendarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Calendar';
	String get server => 'Server address';
	String get name => 'Name';
	String get additionalParameters => 'Additional parameters';
	String get interval => 'Number of weeks to download';
}

// Path: dialogs.login.moreSettings
class TranslationsDialogsLoginMoreSettingsEn {
	TranslationsDialogsLoginMoreSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get button => 'More settings';
	String get server => 'Server address';
	String get calendarName => 'Calendar name';
	String get additionalParameters => 'Additional parameters';
}

// Path: dialogs.login.errors
class TranslationsDialogsLoginErrorsEn {
	TranslationsDialogsLoginErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get notFound => 'Calendar not found : it can be caused by holidays, an unavailable timetable on Zimbra or a bad username. Another reason may be a maintenance so please try again later.';
	String get unauthorized => 'Bad username / bad password.';
	String get genericError => 'An error occurred. Please try again later.';
}

// Path: intro.slides.main
class TranslationsIntroSlidesMainEn {
	TranslationsIntroSlidesMainEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Your timetable on your smartphone !';
	String get message => 'This app allows the students of the University of Caen Normandy to have their timetable directly on their smartphone.';
}

// Path: intro.slides.login
class TranslationsIntroSlidesLoginEn {
	TranslationsIntroSlidesLoginEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'We need an access to your Unicaen account…';
	String get message => 'Don\'t worry ! This credentials will only be used to download your timetable on the Unicaen servers, nothing else.';
}

// Path: intro.slides.finished
class TranslationsIntroSlidesFinishedEn {
	TranslationsIntroSlidesFinishedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Everything is set !';
	String get message => 'You\'re ready. Please tap on the button below to start.';
}

// Path: settings.application.brightness
class TranslationsSettingsApplicationBrightnessEn {
	TranslationsSettingsApplicationBrightnessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Theme';
	Map<String, String> get values => {
		'light': 'Bright',
		'dark': 'Dark',
		'system': 'Let the system choose',
	};
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'about.title': return 'About';
			case 'about.paragraphs.first': return 'This app has been created by Skyost and is available under the therms of the GNU GPL v3 license. It\'s using Flutter and has been written in Dart by using some technologies. You can view all of this using the links below.';
			case 'about.paragraphs.second': return 'Disclaimer. This application has not been developed by any official member of the University. Consequently, do not send any request to the University if you have a problem with this application. Furthermore, this application needs your student number with your password to work. Your credentials will not be send to any third party, except to the University server in order to download your timetable. If you do not trust this application, you can still check the source code with the "Github" link below.';
			case 'bugsImprovements.title': return 'Bugs / Improvements';
			case 'bugsImprovements.message.github': return 'You have some options to report me a bug or to suggest me an improvement. For example, you can use the Github issue tracker which is available <a href="https://github.com/Skyost/UnicaenTimetable/issues/">here</a>.';
			case 'bugsImprovements.message.website': return 'You can also send me an email via the form which is available <a href="https://skyost.eu/#contact">here</a>.';
			case 'common.appName': return 'Unicaen Timetable';
			case 'common.other.fieldEmpty': return 'This field cannot be empty.';
			case 'common.other.pleaseWait': return 'Please wait…';
			case 'dialogs.lessonInfo.resetColor': return 'Default color';
			case 'dialogs.lessonInfo.setAlarm': return 'Set alarm';
			case 'dialogs.lessonColor.title': return 'Lesson color';
			case 'dialogs.weekPicker.title': return 'Pick the week to display';
			case 'dialogs.weekPicker.empty': return 'There is no lesson. Please check that your timetable is available on Zimbra.';
			case 'dialogs.login.title': return 'Login';
			case 'dialogs.login.username': return 'Étupass :';
			case 'dialogs.login.usernameHint': return 'Before the @etu.unicaen.fr';
			case 'dialogs.login.password': return 'Password :';
			case 'dialogs.login.passwordHint': return 'Your password';
			case 'dialogs.login.login': return 'Login';
			case 'dialogs.login.moreSettings.button': return 'More settings';
			case 'dialogs.login.moreSettings.server': return 'Server address';
			case 'dialogs.login.moreSettings.calendarName': return 'Calendar name';
			case 'dialogs.login.moreSettings.additionalParameters': return 'Additional parameters';
			case 'dialogs.login.errors.notFound': return 'Calendar not found : it can be caused by holidays, an unavailable timetable on Zimbra or a bad username. Another reason may be a maintenance so please try again later.';
			case 'dialogs.login.errors.unauthorized': return 'Bad username / bad password.';
			case 'dialogs.login.errors.genericError': return 'An error occurred. Please try again later.';
			case 'dialogs.calendarNotFound.title': return 'Calendar not found';
			case 'dialogs.calendarNotFound.message': return 'If you just came back from holidays (or if you are in holidays), this is normal, please try again once your timetable will be available on Zimbra.\nOtherwise, it probably means that you\'ve entered a wrong username.\nYou may also have entered a bad calendar name in the app settings or the servers are in maintenance.\nAnyway, this error is common. Please try again later.';
			case 'dialogs.unauthorized.title': return 'Wrong credentials';
			case 'dialogs.unauthorized.message': return 'Your username or your password may have been entered incorrectly.';
			case 'dialogs.unauthorized.buttonLogin': return 'Change account';
			case 'home.title': return 'Home';
			case 'home.noCard': return 'It feels a bit empty here. Feel free to add some widgets using the upper-right button.';
			case 'home.loading': return 'Loading…';
			case 'home.synchronizationStatus.name': return 'Synchronization status';
			case 'home.synchronizationStatus.title': return 'Last synchronization :';
			case 'home.synchronizationStatus.bad': return 'You may have to synchronize the app.';
			case 'home.synchronizationStatus.good': return 'The app is up-to-date.';
			case 'home.synchronizationStatus.never': return 'Never';
			case 'home.currentLesson.name': return 'Current lesson';
			case 'home.currentLesson.title': return 'Now :';
			case 'home.currentLesson.nothing': return 'No lesson.';
			case 'home.nextLesson.name': return 'Next lesson';
			case 'home.nextLesson.title': return 'Next lesson :';
			case 'home.nextLesson.nothing': return 'Nothing today.';
			case 'home.currentTheme.name': return 'Current theme';
			case 'home.currentTheme.title': return 'Current theme :';
			case 'home.currentTheme.light': return 'Light mode';
			case 'home.currentTheme.dark': return 'Dark mode';
			case 'home.currentTheme.auto': return 'picked by system';
			case 'home.info.name': return 'Device & app info';
			case 'home.info.title': return 'Info :';
			case 'intro.buttons.next': return 'Next';
			case 'intro.buttons.finish': return 'Finish';
			case 'intro.slides.main.title': return 'Your timetable on your smartphone !';
			case 'intro.slides.main.message': return 'This app allows the students of the University of Caen Normandy to have their timetable directly on their smartphone.';
			case 'intro.slides.login.title': return 'We need an access to your Unicaen account…';
			case 'intro.slides.login.message': return 'Don\'t worry ! This credentials will only be used to download your timetable on the Unicaen servers, nothing else.';
			case 'intro.slides.finished.title': return 'Everything is set !';
			case 'intro.slides.finished.message': return 'You\'re ready. Please tap on the button below to start.';
			case 'scaffold.settingsReset.message': return 'The app settings have been reset due to an update. We really apologize for this trouble.';
			case 'scaffold.settingsReset.ios': return 'If you\'re on iOS, you may also have to reconnect yourself.';
			case 'scaffold.settingsReset.end': return 'Thanks for using this app 💘';
			case 'scaffold.floatingButtonTooltip': return 'Synchronize';
			case 'scaffold.wait.settingsRepository': return 'Initializing settings…';
			case 'scaffold.wait.lessonRepository': return 'Initializing the lessons repository…';
			case 'scaffold.wait.userRepository': return 'Initializing the user repository…';
			case 'scaffold.wait.hasUser': return 'Waiting for the user…';
			case 'scaffold.drawer.home': return 'Home';
			case 'scaffold.drawer.timetable': return 'Timetable';
			case 'scaffold.drawer.others': return 'Others';
			case 'scaffold.snackBar.synchronizing': return 'Synchronizing…';
			case 'scaffold.snackBar.success': return 'Success.';
			case 'scaffold.snackBar.unauthorized': return 'Wrong username / password.';
			case 'scaffold.snackBar.genericError': return 'Error. Please try again later.';
			case 'scaffold.snackBar.widgetAlreadyPresent': return 'The selected widget is already present on the application home screen.';
			case 'settings.title': return 'Settings';
			case 'settings.application.title': return 'Application';
			case 'settings.application.sidebarDays': return 'Days to show in the sidebar';
			case 'settings.application.colorLessonsAutomatically': return 'Automatically color lessons';
			case 'settings.application.openTodayAutomatically': return 'Open today\'s page at launch';
			case 'settings.application.enableAds': return 'Enable ads';
			case 'settings.application.brightness.title': return 'Theme';
			case 'settings.application.brightness.values.light': return 'Bright';
			case 'settings.application.brightness.values.dark': return 'Dark';
			case 'settings.application.brightness.values.system': return 'Let the system choose';
			case 'settings.account.title': return 'Account';
			case 'settings.account.kSwitch': return 'Switch account';
			case 'settings.calendar.title': return 'Calendar';
			case 'settings.calendar.server': return 'Server address';
			case 'settings.calendar.name': return 'Name';
			case 'settings.calendar.additionalParameters': return 'Additional parameters';
			case 'settings.calendar.interval': return 'Number of weeks to download';
			case 'weekView.title': return 'Week view';
			default: return null;
		}
	}
}

