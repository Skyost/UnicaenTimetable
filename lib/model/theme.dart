import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:hive/hive.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The app theme settings entry that controls the app look and feel.
class AppThemeSettingsEntry extends SettingsEntry<UnicaenTimetableTheme> {
  /// Creates a new app theme settings entry instance.
  AppThemeSettingsEntry({
    String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
          key: 'theme',
          value: const DarkTheme(),
        );

  @override
  Future<UnicaenTimetableTheme> load([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    return box.get(key, defaultValue: false) ? const DarkTheme() : const LightTheme();
  }

  @override
  set value(UnicaenTimetableTheme value) {
    super.value = value;
  }

  @override
  Future<void> flush([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    await box.put(key, value is DarkTheme);
  }

  void toggleDarkMode() => value = value is DarkTheme ? const LightTheme() : const DarkTheme();
}

/// Represents an app theme.
abstract class UnicaenTimetableTheme {
  /// The primary color.
  final Color primaryColor;

  /// The scaffold background color.
  final Color scaffoldBackgroundColor;

  /// The action bar color.
  final Color actionBarColor;

  /// The list header text color.
  final Color listHeaderTextColor;

  /// The selected list tile text color.
  final Color selectedListTileTextColor;

  /// The text color.
  final Color textColor;

  /// The lesson background color.
  final Color cardsBackgroundColor;

  /// The lesson background color.
  final Color cardsTextColor;

  /// The highlight color.
  final Color highlightColor;

  /// The day bar background color.
  final Color dayBarBackgroundColor;

  /// The day bar text color.
  final Color dayBarTextColor;

  /// The hours column background color.
  final Color hoursColumnBackgroundColor;

  /// The hours column text color.
  final Color hoursColumnTextColor;

  /// The about header background color.
  final Color aboutHeaderBackgroundColor;

  /// Creates a new app theme.
  const UnicaenTimetableTheme({
    @required this.primaryColor,
    @required this.actionBarColor,
    this.scaffoldBackgroundColor,
    @required this.listHeaderTextColor,
    @required this.selectedListTileTextColor,
    this.textColor,
    this.cardsBackgroundColor,
    this.cardsTextColor,
    @required this.highlightColor,
    @required this.dayBarBackgroundColor,
    this.dayBarTextColor,
    @required this.hoursColumnBackgroundColor,
    this.hoursColumnTextColor,
    @required this.aboutHeaderBackgroundColor,
  });

  /// Converts this class values to its corresponding Flutter theme data.
  ThemeData get themeData => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        dialogBackgroundColor: scaffoldBackgroundColor,
        appBarTheme: AppBarTheme(color: actionBarColor),
        textTheme: TextTheme(
          headline1: TextStyle(color: textColor),
          headline2: TextStyle(color: textColor),
          headline3: TextStyle(color: textColor),
          headline4: TextStyle(color: textColor),
          headline5: TextStyle(color: textColor),
          headline6: TextStyle(color: textColor),
          subtitle1: TextStyle(color: textColor),
          subtitle2: TextStyle(color: textColor),
          bodyText1: TextStyle(color: textColor),
          bodyText2: TextStyle(color: textColor),
          caption: TextStyle(color: textColor),
          //button: TextStyle(color: textColor),
          overline: TextStyle(color: textColor),
        ),
        popupMenuTheme: PopupMenuThemeData(color: scaffoldBackgroundColor),
        highlightColor: highlightColor,
        splashColor: highlightColor,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.accent,
          highlightColor: highlightColor,
          splashColor: highlightColor,
        ),
      );

  /// Creates the Flutter Week View day view style.
  DayViewStyle createDayViewStyle(DateTime date) => const DayViewStyle();
}

/// The light theme.
class LightTheme extends UnicaenTimetableTheme {
  /// Creates a new light theme instance.
  const LightTheme()
      : super(
          primaryColor: Colors.indigo,
          actionBarColor: Colors.indigo,
          listHeaderTextColor: Colors.black54,
          selectedListTileTextColor: Colors.indigo,
          highlightColor: Colors.black12,
          dayBarBackgroundColor: const Color(0xFFEBEBEB),
          dayBarTextColor: Colors.black54,
          hoursColumnBackgroundColor: Colors.white,
          hoursColumnTextColor: Colors.black54,
          aboutHeaderBackgroundColor: const Color(0xFF7986CB),
        );
}

/// The dark theme.
class DarkTheme extends UnicaenTimetableTheme {
  /// Creates a new dark theme instance.
  const DarkTheme()
      : super(
          primaryColor: const Color(0xFF253341),
          scaffoldBackgroundColor: const Color(0xFF15202B),
          actionBarColor: const Color(0xFF253341),
          listHeaderTextColor: Colors.white,
          selectedListTileTextColor: Colors.white,
          textColor: Colors.white70,
          cardsBackgroundColor: const Color(0xFF192734),
          cardsTextColor: Colors.white,
          highlightColor: Colors.white12,
          dayBarBackgroundColor: const Color(0xFF202D3B),
          hoursColumnBackgroundColor: const Color(0xFF202D3B),
          aboutHeaderBackgroundColor: const Color(0xFF202D3B),
        );

  @override
  DayViewStyle createDayViewStyle(DateTime date) => DayViewStyle(
        backgroundColor: date.yearMonthDay.difference(DateTime.now().yearMonthDay).inDays == 0 ? primaryColor : scaffoldBackgroundColor,
        backgroundRulesColor: Colors.white12,
      );
}
