import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:hive/hive.dart';
import 'package:pedantic/pedantic.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/utils/utils.dart';

class AppThemeSettingsEntry extends SettingsEntry<AppTheme> {
  AppThemeSettingsEntry({
    String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
          key: 'theme',
          value: const DarkAppTheme(),
        );

  @override
  Future<AppTheme> load([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    AppTheme theme = box.get(key, defaultValue: false) ? const DarkAppTheme() : const LightAppTheme();
    unawaited(theme.updateNavigationBarColor());
    return theme;
  }

  @override
  set value(AppTheme value) {
    super.value = value;
    unawaited(value.updateNavigationBarColor());
  }

  @override
  Future<void> flush([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    await box.put(key, value is DarkAppTheme);
  }
}

abstract class AppTheme {
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

  const AppTheme({
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

  ThemeData get themeData => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        dialogBackgroundColor: scaffoldBackgroundColor,
        appBarTheme: AppBarTheme(color: actionBarColor),
        textTheme: TextTheme(
          display4: TextStyle(color: textColor),
          display3: TextStyle(color: textColor),
          display2: TextStyle(color: textColor),
          display1: TextStyle(color: textColor),
          headline: TextStyle(color: textColor),
          title: TextStyle(color: textColor),
          subhead: TextStyle(color: textColor),
          body2: TextStyle(color: textColor),
          body1: TextStyle(color: textColor),
          caption: TextStyle(color: textColor),
          subtitle: TextStyle(color: textColor),
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

  Future<void> updateNavigationBarColor() => FlutterStatusbarcolor.setNavigationBarColor(actionBarColor);

  AppTheme get opposite;

  EventsColumnBackgroundPainter createEventsColumnBackgroundPainter(DateTime date);
}

class LightAppTheme extends AppTheme {
  const LightAppTheme()
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

  @override
  AppTheme get opposite => const DarkAppTheme();

  @override
  EventsColumnBackgroundPainter createEventsColumnBackgroundPainter(DateTime date) => null;
}

class DarkAppTheme extends AppTheme {
  const DarkAppTheme()
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
  AppTheme get opposite => const LightAppTheme();

  @override
  EventsColumnBackgroundPainter createEventsColumnBackgroundPainter(DateTime date) => EventsColumnBackgroundPainter(
        backgroundColor: date.yearMonthDay.difference(DateTime.now().yearMonthDay).inDays == 0 ? primaryColor : scaffoldBackgroundColor,
        rulesColor: Colors.white12,
      );
}
