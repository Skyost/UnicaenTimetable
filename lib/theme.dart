import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// Represents an app theme.
abstract class UnicaenTimetableTheme {
  /// The light theme instance.
  static final _LightTheme LIGHT = const _LightTheme();

  /// The dark theme instance.
  static final _DarkTheme DARK = const _DarkTheme();

  /// The theme brightness.
  final Brightness brightness;

  /// The primary color.
  final Color primaryColor;

  /// The scaffold background color.
  final Color? scaffoldBackgroundColor;

  /// The action bar color.
  final Color actionBarColor;

  /// The list header text color.
  final Color listHeaderTextColor;

  /// The selected list tile text color.
  final Color selectedListTileTextColor;

  /// The text color.
  final Color? textColor;

  /// The lesson background color.
  final Color? cardsBackgroundColor;

  /// The lesson background color.
  final Color? cardsTextColor;

  /// The highlight color.
  final Color highlightColor;

  /// The day view background color (today).
  final Color? dayViewBackgroundColorToday;

  /// The day bar background color.
  final Color? dayBarBackgroundColor;

  /// The day bar text color.
  final Color? dayBarTextColor;

  /// The day bar text color (today).
  final Color? dayBarTextColorToday;

  /// The hours column background color.
  final Color hoursColumnBackgroundColor;

  /// The hours column text color.
  final Color? hoursColumnTextColor;

  /// The about header background color.
  final Color aboutHeaderBackgroundColor;

  /// Creates a new app theme.
  const UnicaenTimetableTheme._internal({
    required this.brightness,
    required this.primaryColor,
    required this.actionBarColor,
    this.scaffoldBackgroundColor,
    required this.listHeaderTextColor,
    required this.selectedListTileTextColor,
    this.textColor,
    this.cardsBackgroundColor,
    this.cardsTextColor,
    required this.highlightColor,
    this.dayViewBackgroundColorToday,
    this.dayBarBackgroundColor,
    this.dayBarTextColor,
    this.dayBarTextColorToday,
    required this.hoursColumnBackgroundColor,
    this.hoursColumnTextColor,
    required this.aboutHeaderBackgroundColor,
  });

  /// Converts this class values to its corresponding Flutter theme data.
  ThemeData get themeData => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        dialogBackgroundColor: scaffoldBackgroundColor,
        appBarTheme: AppBarTheme(
          color: actionBarColor,
          brightness: Brightness.dark,
        ),
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
        canvasColor: scaffoldBackgroundColor,
        brightness: brightness,
      );

  /// Creates the Flutter Week View day view style.
  DayViewStyle createDayViewStyle(DateTime date) => DayViewStyle(
        backgroundColor: Utils.isToday(date) ? dayViewBackgroundColorToday : scaffoldBackgroundColor,
        backgroundRulesColor: Colors.black12,
      );

  /// Creates the day bar style.
  DayBarStyle createDayBarStyle(DateTime date, DateFormatter dateFormatter) => DayBarStyle.fromDate(
        date: date,
        textStyle: TextStyle(color: (Utils.isToday(date) ? dayBarTextColorToday : dayBarTextColor)),
        color: dayBarBackgroundColor,
        dateFormatter: dateFormatter,
      );

  /// Creates the hours column style.
  HoursColumnStyle createHoursColumnStyle() => HoursColumnStyle(
        color: hoursColumnBackgroundColor,
        textStyle: TextStyle(color: hoursColumnTextColor ?? textColor),
      );
}

/// The light theme.
class _LightTheme extends UnicaenTimetableTheme {
  /// Creates a new light theme instance.
  const _LightTheme()
      : super._internal(
          brightness: Brightness.light,
          primaryColor: Colors.indigo,
          actionBarColor: Colors.indigo,
          listHeaderTextColor: Colors.black54,
          selectedListTileTextColor: Colors.indigo,
          highlightColor: Colors.black12,
          dayViewBackgroundColorToday: const Color(0xFFE3F5FF),
          dayBarTextColorToday: Colors.indigo,
          hoursColumnBackgroundColor: Colors.white,
          hoursColumnTextColor: Colors.black54,
          aboutHeaderBackgroundColor: const Color(0xFF7986CB),
        );
}

/// The dark theme.
class _DarkTheme extends UnicaenTimetableTheme {
  /// Creates a new dark theme instance.
  const _DarkTheme()
      : super._internal(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF253341),
          scaffoldBackgroundColor: const Color(0xFF15202B),
          actionBarColor: const Color(0xFF253341),
          listHeaderTextColor: Colors.white,
          selectedListTileTextColor: Colors.white,
          textColor: Colors.white70,
          cardsBackgroundColor: const Color(0xFF192734),
          cardsTextColor: Colors.white,
          highlightColor: Colors.white12,
          dayViewBackgroundColorToday: const Color(0xFF253341),
          dayBarBackgroundColor: const Color(0xFF202D3B),
          dayBarTextColorToday: Colors.white,
          hoursColumnBackgroundColor: const Color(0xFF202D3B),
          aboutHeaderBackgroundColor: const Color(0xFF202D3B),
        );

  @override
  DayViewStyle createDayViewStyle(DateTime date) => super.createDayViewStyle(date).copyWith(
        backgroundRulesColor: Colors.white12,
      );
}
