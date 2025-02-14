///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';

import 'translations.g.dart';

// Path: <root>
class TranslationsFr extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsFr _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsAboutFr about = _TranslationsAboutFr._(_root);
	@override late final _TranslationsBugsImprovementsFr bugsImprovements = _TranslationsBugsImprovementsFr._(_root);
	@override late final _TranslationsCommonFr common = _TranslationsCommonFr._(_root);
	@override late final _TranslationsDialogsFr dialogs = _TranslationsDialogsFr._(_root);
	@override late final _TranslationsHomeFr home = _TranslationsHomeFr._(_root);
	@override late final _TranslationsIntroFr intro = _TranslationsIntroFr._(_root);
	@override late final _TranslationsScaffoldFr scaffold = _TranslationsScaffoldFr._(_root);
	@override late final _TranslationsSettingsFr settings = _TranslationsSettingsFr._(_root);
	@override late final _TranslationsWeekViewFr weekView = _TranslationsWeekViewFr._(_root);
}

// Path: about
class _TranslationsAboutFr extends TranslationsAboutEn {
	_TranslationsAboutFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'À propos';
	@override late final _TranslationsAboutParagraphsFr paragraphs = _TranslationsAboutParagraphsFr._(_root);
}

// Path: bugsImprovements
class _TranslationsBugsImprovementsFr extends TranslationsBugsImprovementsEn {
	_TranslationsBugsImprovementsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bugs / Améliorations';
	@override late final _TranslationsBugsImprovementsMessageFr message = _TranslationsBugsImprovementsMessageFr._(_root);
}

// Path: common
class _TranslationsCommonFr extends TranslationsCommonEn {
	_TranslationsCommonFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Emploi du temps Unicaen';
	@override late final _TranslationsCommonOtherFr other = _TranslationsCommonOtherFr._(_root);
}

// Path: dialogs
class _TranslationsDialogsFr extends TranslationsDialogsEn {
	_TranslationsDialogsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDialogsLessonInfoFr lessonInfo = _TranslationsDialogsLessonInfoFr._(_root);
	@override late final _TranslationsDialogsLessonColorFr lessonColor = _TranslationsDialogsLessonColorFr._(_root);
	@override late final _TranslationsDialogsWeekPickerFr weekPicker = _TranslationsDialogsWeekPickerFr._(_root);
	@override late final _TranslationsDialogsLoginFr login = _TranslationsDialogsLoginFr._(_root);
	@override late final _TranslationsDialogsCalendarNotFoundFr calendarNotFound = _TranslationsDialogsCalendarNotFoundFr._(_root);
	@override late final _TranslationsDialogsUnauthorizedFr unauthorized = _TranslationsDialogsUnauthorizedFr._(_root);
}

// Path: home
class _TranslationsHomeFr extends TranslationsHomeEn {
	_TranslationsHomeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Accueil';
	@override String get noCard => 'La page d\'accueil de l\'application est acuellement vide. N\'hésitez pas à ajouter des widgets via le bouton situé en haut à droite.';
	@override String get loading => 'Chargement…';
	@override late final _TranslationsHomeSynchronizationStatusFr synchronizationStatus = _TranslationsHomeSynchronizationStatusFr._(_root);
	@override late final _TranslationsHomeCurrentLessonFr currentLesson = _TranslationsHomeCurrentLessonFr._(_root);
	@override late final _TranslationsHomeNextLessonFr nextLesson = _TranslationsHomeNextLessonFr._(_root);
	@override late final _TranslationsHomeCurrentThemeFr currentTheme = _TranslationsHomeCurrentThemeFr._(_root);
	@override late final _TranslationsHomeInfoFr info = _TranslationsHomeInfoFr._(_root);
}

// Path: intro
class _TranslationsIntroFr extends TranslationsIntroEn {
	_TranslationsIntroFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsIntroButtonsFr buttons = _TranslationsIntroButtonsFr._(_root);
	@override late final _TranslationsIntroSlidesFr slides = _TranslationsIntroSlidesFr._(_root);
}

// Path: scaffold
class _TranslationsScaffoldFr extends TranslationsScaffoldEn {
	_TranslationsScaffoldFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsScaffoldSettingsResetFr settingsReset = _TranslationsScaffoldSettingsResetFr._(_root);
	@override String get floatingButtonTooltip => 'Synchroniser';
	@override late final _TranslationsScaffoldWaitFr wait = _TranslationsScaffoldWaitFr._(_root);
	@override late final _TranslationsScaffoldDrawerFr drawer = _TranslationsScaffoldDrawerFr._(_root);
	@override late final _TranslationsScaffoldSnackBarFr snackBar = _TranslationsScaffoldSnackBarFr._(_root);
}

// Path: settings
class _TranslationsSettingsFr extends TranslationsSettingsEn {
	_TranslationsSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Paramètres';
	@override late final _TranslationsSettingsApplicationFr application = _TranslationsSettingsApplicationFr._(_root);
	@override late final _TranslationsSettingsAccountFr account = _TranslationsSettingsAccountFr._(_root);
	@override late final _TranslationsSettingsCalendarFr calendar = _TranslationsSettingsCalendarFr._(_root);
}

// Path: weekView
class _TranslationsWeekViewFr extends TranslationsWeekViewEn {
	_TranslationsWeekViewFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vue semaine';
}

// Path: about.paragraphs
class _TranslationsAboutParagraphsFr extends TranslationsAboutParagraphsEn {
	_TranslationsAboutParagraphsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get first => 'Cette application a été créée par Skyost et est disponible sous licence GNU GPL v3. Elle utilise Flutter et a été écrite en Dart en utilisant certaines technologies. Vous pouvez consulter tout ça en cliquant sur les liens disponibles ci-dessous.';
	@override String get second => 'Avertissement. Cette application n\'a en aucun cas été conçue par un employé de l\'Université. Par conséquent, il est inutile de s\'adresser à l\'Université en cas de problème avec l\'application. De plus, il faut préciser que cette application a besoin de votre numéro d\'étudiant ainsi que de votre mot de passe pour fonctionner. Ceux-ci ne seront envoyés à aucun tiers, excepté aux serveurs de l\'Université pour récupérer votre emploi du temps. Si vous n\'êtes pas convaincu du fonctionnement de l\'application, le code source est disponible via le lien "Github" ci-dessous.';
}

// Path: bugsImprovements.message
class _TranslationsBugsImprovementsMessageFr extends TranslationsBugsImprovementsMessageEn {
	_TranslationsBugsImprovementsMessageFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get github => 'Il y a plusieurs manières pour vous de me suggérer des améliorations ou de me rapporter un bug. Vous pouvez par exemple utiliser le tracker de bugs Github disponible <a href="https://github.com/Skyost/UnicaenTimetable/issues/">ici</a>.';
	@override String get website => 'Vous pouvez également m\'envoyer un email via le formulaire disponible <a href="https://skyost.eu/#contact">ici</a>.';
}

// Path: common.other
class _TranslationsCommonOtherFr extends TranslationsCommonOtherEn {
	_TranslationsCommonOtherFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get fieldEmpty => 'Ce champ ne peut être vide.';
	@override String get pleaseWait => 'Veuillez patienter…';
}

// Path: dialogs.lessonInfo
class _TranslationsDialogsLessonInfoFr extends TranslationsDialogsLessonInfoEn {
	_TranslationsDialogsLessonInfoFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get resetColor => 'Couleur par défaut';
	@override String get setAlarm => 'Mettre une alarme';
}

// Path: dialogs.lessonColor
class _TranslationsDialogsLessonColorFr extends TranslationsDialogsLessonColorEn {
	_TranslationsDialogsLessonColorFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Couleur du cours';
}

// Path: dialogs.weekPicker
class _TranslationsDialogsWeekPickerFr extends TranslationsDialogsWeekPickerEn {
	_TranslationsDialogsWeekPickerFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Séléctionnez la semaine à afficher';
	@override String get empty => 'Pas de cours disponible. Veuillez vous assurer que vos cours sont bien disponibles sur l\'interface Zimbra.';
}

// Path: dialogs.login
class _TranslationsDialogsLoginFr extends TranslationsDialogsLoginEn {
	_TranslationsDialogsLoginFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Connexion';
	@override String get username => 'Étupass :';
	@override String get usernameHint => 'Avant le @etu.unicaen.fr';
	@override String get password => 'Mot de passe :';
	@override String get passwordHint => 'Votre mot de passe';
	@override String get login => 'Connexion';
	@override late final _TranslationsDialogsLoginMoreSettingsFr moreSettings = _TranslationsDialogsLoginMoreSettingsFr._(_root);
	@override late final _TranslationsDialogsLoginErrorsFr errors = _TranslationsDialogsLoginErrorsFr._(_root);
}

// Path: dialogs.calendarNotFound
class _TranslationsDialogsCalendarNotFoundFr extends TranslationsDialogsCalendarNotFoundEn {
	_TranslationsDialogsCalendarNotFoundFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Calendrier non trouvé';
	@override String get message => 'Si vous êtes en vacances ou que vous venez de rentrer, ceci est normal, veuillez réessayer une fois que votre emploi du temps sera disponible sur Zimbra.\nSinon, cela signifie probablement que le nom d\'utilisateur que vous avez entré est incorrect.\nVous pouvez également avoir entré un mauvais nom de calendrier dans les paramètres de l\'application ou les serveurs sont tout simplement en maintenance.\nQuoi qu\'il en soit, cette erreur est fréquente. Veuillez réessayer plus tard.';
}

// Path: dialogs.unauthorized
class _TranslationsDialogsUnauthorizedFr extends TranslationsDialogsUnauthorizedEn {
	_TranslationsDialogsUnauthorizedFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mauvais identifiants';
	@override String get message => 'Votre nom d\'utilisateur ou votre mot de passe est incorrect.';
	@override String get buttonLogin => 'Changer de compte';
}

// Path: home.synchronizationStatus
class _TranslationsHomeSynchronizationStatusFr extends TranslationsHomeSynchronizationStatusEn {
	_TranslationsHomeSynchronizationStatusFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Synchronisation';
	@override String get title => 'Dernière synchronisation :';
	@override String get bad => 'Une synchronisation peut être requise.';
	@override String get good => 'L\'application est à jour.';
	@override String get never => 'Jamais';
}

// Path: home.currentLesson
class _TranslationsHomeCurrentLessonFr extends TranslationsHomeCurrentLessonEn {
	_TranslationsHomeCurrentLessonFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Cours en cours';
	@override String get title => 'Maintenant :';
	@override String get nothing => 'Aucun cours';
}

// Path: home.nextLesson
class _TranslationsHomeNextLessonFr extends TranslationsHomeNextLessonEn {
	_TranslationsHomeNextLessonFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Prochain cours';
	@override String get title => 'Prochain cours :';
	@override String get nothing => 'Aucun aujourd\'hui.';
}

// Path: home.currentTheme
class _TranslationsHomeCurrentThemeFr extends TranslationsHomeCurrentThemeEn {
	_TranslationsHomeCurrentThemeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Thème actuel';
	@override String get title => 'Thème actuel :';
	@override String get light => 'Mode jour';
	@override String get dark => 'Mode nuit';
	@override String get auto => 'choisi par le système';
}

// Path: home.info
class _TranslationsHomeInfoFr extends TranslationsHomeInfoEn {
	_TranslationsHomeInfoFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Informations sur l\'app';
	@override String get title => 'Informations :';
}

// Path: intro.buttons
class _TranslationsIntroButtonsFr extends TranslationsIntroButtonsEn {
	_TranslationsIntroButtonsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get next => 'Suivant';
	@override String get finish => 'Terminer';
}

// Path: intro.slides
class _TranslationsIntroSlidesFr extends TranslationsIntroSlidesEn {
	_TranslationsIntroSlidesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsIntroSlidesMainFr main = _TranslationsIntroSlidesMainFr._(_root);
	@override late final _TranslationsIntroSlidesLoginFr login = _TranslationsIntroSlidesLoginFr._(_root);
	@override late final _TranslationsIntroSlidesFinishedFr finished = _TranslationsIntroSlidesFinishedFr._(_root);
}

// Path: scaffold.settingsReset
class _TranslationsScaffoldSettingsResetFr extends TranslationsScaffoldSettingsResetEn {
	_TranslationsScaffoldSettingsResetFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get message => 'Les paramètres de l\'application ont dû être réinitialisés suite à une mise à jour. Nous nous excusons pour la gêne encourue.';
	@override String get ios => 'Si vous êtes sur iOS, vous devrez peut-être également vous reconnecter.';
	@override String get end => 'Merci pour votre fidélité dans l\'utilisation de cette application 💘';
}

// Path: scaffold.wait
class _TranslationsScaffoldWaitFr extends TranslationsScaffoldWaitEn {
	_TranslationsScaffoldWaitFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get settingsRepository => 'Initialisation des paramètres…';
	@override String get lessonRepository => 'Initialisation du dépôt de cours…';
	@override String get userRepository => 'Initialisation du dépôt utilisateur…';
	@override String get hasUser => 'En attente de l\'utilisateur…';
}

// Path: scaffold.drawer
class _TranslationsScaffoldDrawerFr extends TranslationsScaffoldDrawerEn {
	_TranslationsScaffoldDrawerFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get home => 'Accueil';
	@override String get timetable => 'Emploi du temps';
	@override String get others => 'Autres';
}

// Path: scaffold.snackBar
class _TranslationsScaffoldSnackBarFr extends TranslationsScaffoldSnackBarEn {
	_TranslationsScaffoldSnackBarFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get synchronizing => 'Synchronisation…';
	@override String get success => 'Succès.';
	@override String get unauthorized => 'Mauvais nom d\'utilisateur / mot de passe.';
	@override String get genericError => 'Erreur. Veuillez réessayer plus tard.';
	@override String get widgetAlreadyPresent => 'Un tel widget est déjà ajouté sur la page d\'accueil de l\'application.';
}

// Path: settings.application
class _TranslationsSettingsApplicationFr extends TranslationsSettingsApplicationEn {
	_TranslationsSettingsApplicationFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Application';
	@override String get sidebarDays => 'Jours à afficher dans la menu déroulant';
	@override String get colorLessonsAutomatically => 'Colorer automatiquement les cours';
	@override String get openTodayAutomatically => 'Ouvrir automatiquement sur le jour d\'aujourd\'hui';
	@override String get enableAds => 'Activer les publicités';
	@override late final _TranslationsSettingsApplicationBrightnessFr brightness = _TranslationsSettingsApplicationBrightnessFr._(_root);
	@override String get syncWithDeviceCalendar => 'Synchroniser le calendrier avec l\'appareil';
}

// Path: settings.account
class _TranslationsSettingsAccountFr extends TranslationsSettingsAccountEn {
	_TranslationsSettingsAccountFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Compte';
	@override String get kSwitch => 'Changer de compte';
}

// Path: settings.calendar
class _TranslationsSettingsCalendarFr extends TranslationsSettingsCalendarEn {
	_TranslationsSettingsCalendarFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Calendrier distant';
	@override String get server => 'Adresse du serveur';
	@override String get name => 'Nom';
	@override String get additionalParameters => 'Paramètres additionnels';
	@override String get interval => 'Nombre de semaines à télécharger';
}

// Path: dialogs.login.moreSettings
class _TranslationsDialogsLoginMoreSettingsFr extends TranslationsDialogsLoginMoreSettingsEn {
	_TranslationsDialogsLoginMoreSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get button => 'Paramètres';
	@override String get server => 'Adresse du serveur';
	@override String get calendarName => 'Nom du calendrier';
	@override String get additionalParameters => 'Paramètres additionnels';
}

// Path: dialogs.login.errors
class _TranslationsDialogsLoginErrorsFr extends TranslationsDialogsLoginErrorsEn {
	_TranslationsDialogsLoginErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get notFound => 'Calendrier non trouvé : cela peut être dû à une période de vacances en cours, un emploi du temps indisponible sur Zimbra ou à un mauvais nom d\'utilisateur. Cela peut également être dû à une maintenance donc réessayez plus tard.';
	@override String get unauthorized => 'Mauvais nom d\'utilisateur / mauvais mot de passe.';
	@override String get genericError => 'Une erreur est survenue. Veuillez réessayer plus tard.';
}

// Path: intro.slides.main
class _TranslationsIntroSlidesMainFr extends TranslationsIntroSlidesMainEn {
	_TranslationsIntroSlidesMainFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Votre emploi du temps sur votre smartphone !';
	@override String get message => 'Cette application permet aux étudiants de l\'Université de Caen Normandie d\'avoir leur emploi du temps directement sur leur smartphone.';
}

// Path: intro.slides.login
class _TranslationsIntroSlidesLoginFr extends TranslationsIntroSlidesLoginEn {
	_TranslationsIntroSlidesLoginFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nous devons maintenant accéder à votre compte Unicaen…';
	@override String get message => 'Pas d\'inquiétude ! Ces identifiants ne seront communiqués à aucun tiers et ne seront utilisés que pour récupérer votre emploi du temps sur les serveurs Unicaen.';
}

// Path: intro.slides.finished
class _TranslationsIntroSlidesFinishedFr extends TranslationsIntroSlidesFinishedEn {
	_TranslationsIntroSlidesFinishedFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tout est prêt !';
	@override String get message => 'Vous êtes fin prêt. Appuyez sur le bouton ci-dessous pour commencer.';
}

// Path: settings.application.brightness
class _TranslationsSettingsApplicationBrightnessFr extends TranslationsSettingsApplicationBrightnessEn {
	_TranslationsSettingsApplicationBrightnessFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thème';
	@override Map<String, String> get values => {
		'light': 'Lumineux',
		'dark': 'Sombre',
		'system': 'Laisser le système choisir',
	};
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsFr {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'about.title': return 'À propos';
			case 'about.paragraphs.first': return 'Cette application a été créée par Skyost et est disponible sous licence GNU GPL v3. Elle utilise Flutter et a été écrite en Dart en utilisant certaines technologies. Vous pouvez consulter tout ça en cliquant sur les liens disponibles ci-dessous.';
			case 'about.paragraphs.second': return 'Avertissement. Cette application n\'a en aucun cas été conçue par un employé de l\'Université. Par conséquent, il est inutile de s\'adresser à l\'Université en cas de problème avec l\'application. De plus, il faut préciser que cette application a besoin de votre numéro d\'étudiant ainsi que de votre mot de passe pour fonctionner. Ceux-ci ne seront envoyés à aucun tiers, excepté aux serveurs de l\'Université pour récupérer votre emploi du temps. Si vous n\'êtes pas convaincu du fonctionnement de l\'application, le code source est disponible via le lien "Github" ci-dessous.';
			case 'bugsImprovements.title': return 'Bugs / Améliorations';
			case 'bugsImprovements.message.github': return 'Il y a plusieurs manières pour vous de me suggérer des améliorations ou de me rapporter un bug. Vous pouvez par exemple utiliser le tracker de bugs Github disponible <a href="https://github.com/Skyost/UnicaenTimetable/issues/">ici</a>.';
			case 'bugsImprovements.message.website': return 'Vous pouvez également m\'envoyer un email via le formulaire disponible <a href="https://skyost.eu/#contact">ici</a>.';
			case 'common.appName': return 'Emploi du temps Unicaen';
			case 'common.other.fieldEmpty': return 'Ce champ ne peut être vide.';
			case 'common.other.pleaseWait': return 'Veuillez patienter…';
			case 'dialogs.lessonInfo.resetColor': return 'Couleur par défaut';
			case 'dialogs.lessonInfo.setAlarm': return 'Mettre une alarme';
			case 'dialogs.lessonColor.title': return 'Couleur du cours';
			case 'dialogs.weekPicker.title': return 'Séléctionnez la semaine à afficher';
			case 'dialogs.weekPicker.empty': return 'Pas de cours disponible. Veuillez vous assurer que vos cours sont bien disponibles sur l\'interface Zimbra.';
			case 'dialogs.login.title': return 'Connexion';
			case 'dialogs.login.username': return 'Étupass :';
			case 'dialogs.login.usernameHint': return 'Avant le @etu.unicaen.fr';
			case 'dialogs.login.password': return 'Mot de passe :';
			case 'dialogs.login.passwordHint': return 'Votre mot de passe';
			case 'dialogs.login.login': return 'Connexion';
			case 'dialogs.login.moreSettings.button': return 'Paramètres';
			case 'dialogs.login.moreSettings.server': return 'Adresse du serveur';
			case 'dialogs.login.moreSettings.calendarName': return 'Nom du calendrier';
			case 'dialogs.login.moreSettings.additionalParameters': return 'Paramètres additionnels';
			case 'dialogs.login.errors.notFound': return 'Calendrier non trouvé : cela peut être dû à une période de vacances en cours, un emploi du temps indisponible sur Zimbra ou à un mauvais nom d\'utilisateur. Cela peut également être dû à une maintenance donc réessayez plus tard.';
			case 'dialogs.login.errors.unauthorized': return 'Mauvais nom d\'utilisateur / mauvais mot de passe.';
			case 'dialogs.login.errors.genericError': return 'Une erreur est survenue. Veuillez réessayer plus tard.';
			case 'dialogs.calendarNotFound.title': return 'Calendrier non trouvé';
			case 'dialogs.calendarNotFound.message': return 'Si vous êtes en vacances ou que vous venez de rentrer, ceci est normal, veuillez réessayer une fois que votre emploi du temps sera disponible sur Zimbra.\nSinon, cela signifie probablement que le nom d\'utilisateur que vous avez entré est incorrect.\nVous pouvez également avoir entré un mauvais nom de calendrier dans les paramètres de l\'application ou les serveurs sont tout simplement en maintenance.\nQuoi qu\'il en soit, cette erreur est fréquente. Veuillez réessayer plus tard.';
			case 'dialogs.unauthorized.title': return 'Mauvais identifiants';
			case 'dialogs.unauthorized.message': return 'Votre nom d\'utilisateur ou votre mot de passe est incorrect.';
			case 'dialogs.unauthorized.buttonLogin': return 'Changer de compte';
			case 'home.title': return 'Accueil';
			case 'home.noCard': return 'La page d\'accueil de l\'application est acuellement vide. N\'hésitez pas à ajouter des widgets via le bouton situé en haut à droite.';
			case 'home.loading': return 'Chargement…';
			case 'home.synchronizationStatus.name': return 'Synchronisation';
			case 'home.synchronizationStatus.title': return 'Dernière synchronisation :';
			case 'home.synchronizationStatus.bad': return 'Une synchronisation peut être requise.';
			case 'home.synchronizationStatus.good': return 'L\'application est à jour.';
			case 'home.synchronizationStatus.never': return 'Jamais';
			case 'home.currentLesson.name': return 'Cours en cours';
			case 'home.currentLesson.title': return 'Maintenant :';
			case 'home.currentLesson.nothing': return 'Aucun cours';
			case 'home.nextLesson.name': return 'Prochain cours';
			case 'home.nextLesson.title': return 'Prochain cours :';
			case 'home.nextLesson.nothing': return 'Aucun aujourd\'hui.';
			case 'home.currentTheme.name': return 'Thème actuel';
			case 'home.currentTheme.title': return 'Thème actuel :';
			case 'home.currentTheme.light': return 'Mode jour';
			case 'home.currentTheme.dark': return 'Mode nuit';
			case 'home.currentTheme.auto': return 'choisi par le système';
			case 'home.info.name': return 'Informations sur l\'app';
			case 'home.info.title': return 'Informations :';
			case 'intro.buttons.next': return 'Suivant';
			case 'intro.buttons.finish': return 'Terminer';
			case 'intro.slides.main.title': return 'Votre emploi du temps sur votre smartphone !';
			case 'intro.slides.main.message': return 'Cette application permet aux étudiants de l\'Université de Caen Normandie d\'avoir leur emploi du temps directement sur leur smartphone.';
			case 'intro.slides.login.title': return 'Nous devons maintenant accéder à votre compte Unicaen…';
			case 'intro.slides.login.message': return 'Pas d\'inquiétude ! Ces identifiants ne seront communiqués à aucun tiers et ne seront utilisés que pour récupérer votre emploi du temps sur les serveurs Unicaen.';
			case 'intro.slides.finished.title': return 'Tout est prêt !';
			case 'intro.slides.finished.message': return 'Vous êtes fin prêt. Appuyez sur le bouton ci-dessous pour commencer.';
			case 'scaffold.settingsReset.message': return 'Les paramètres de l\'application ont dû être réinitialisés suite à une mise à jour. Nous nous excusons pour la gêne encourue.';
			case 'scaffold.settingsReset.ios': return 'Si vous êtes sur iOS, vous devrez peut-être également vous reconnecter.';
			case 'scaffold.settingsReset.end': return 'Merci pour votre fidélité dans l\'utilisation de cette application 💘';
			case 'scaffold.floatingButtonTooltip': return 'Synchroniser';
			case 'scaffold.wait.settingsRepository': return 'Initialisation des paramètres…';
			case 'scaffold.wait.lessonRepository': return 'Initialisation du dépôt de cours…';
			case 'scaffold.wait.userRepository': return 'Initialisation du dépôt utilisateur…';
			case 'scaffold.wait.hasUser': return 'En attente de l\'utilisateur…';
			case 'scaffold.drawer.home': return 'Accueil';
			case 'scaffold.drawer.timetable': return 'Emploi du temps';
			case 'scaffold.drawer.others': return 'Autres';
			case 'scaffold.snackBar.synchronizing': return 'Synchronisation…';
			case 'scaffold.snackBar.success': return 'Succès.';
			case 'scaffold.snackBar.unauthorized': return 'Mauvais nom d\'utilisateur / mot de passe.';
			case 'scaffold.snackBar.genericError': return 'Erreur. Veuillez réessayer plus tard.';
			case 'scaffold.snackBar.widgetAlreadyPresent': return 'Un tel widget est déjà ajouté sur la page d\'accueil de l\'application.';
			case 'settings.title': return 'Paramètres';
			case 'settings.application.title': return 'Application';
			case 'settings.application.sidebarDays': return 'Jours à afficher dans la menu déroulant';
			case 'settings.application.colorLessonsAutomatically': return 'Colorer automatiquement les cours';
			case 'settings.application.openTodayAutomatically': return 'Ouvrir automatiquement sur le jour d\'aujourd\'hui';
			case 'settings.application.enableAds': return 'Activer les publicités';
			case 'settings.application.brightness.title': return 'Thème';
			case 'settings.application.brightness.values.light': return 'Lumineux';
			case 'settings.application.brightness.values.dark': return 'Sombre';
			case 'settings.application.brightness.values.system': return 'Laisser le système choisir';
			case 'settings.application.syncWithDeviceCalendar': return 'Synchroniser le calendrier avec l\'appareil';
			case 'settings.account.title': return 'Compte';
			case 'settings.account.kSwitch': return 'Changer de compte';
			case 'settings.calendar.title': return 'Calendrier distant';
			case 'settings.calendar.server': return 'Adresse du serveur';
			case 'settings.calendar.name': return 'Nom';
			case 'settings.calendar.additionalParameters': return 'Paramètres additionnels';
			case 'settings.calendar.interval': return 'Nombre de semaines à télécharger';
			case 'weekView.title': return 'Vue semaine';
			default: return null;
		}
	}
}

