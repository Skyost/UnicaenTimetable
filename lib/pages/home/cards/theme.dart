import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/pages/home/cards/card.dart';

/// A card that allows to change the app theme.
class ThemeCard extends MaterialCard {
  /// The card id.
  static const String ID = 'current_theme';

  /// Creates a new theme card instance.
  const ThemeCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => isDarkMode(context) ? Icons.brightness_3 : Icons.wb_sunny;

  @override
  Color buildColor(BuildContext context) => Colors.indigo[400];

  @override
  String buildSubtitle(BuildContext context) {
    return context.getString('home.current_theme.' + (isDarkMode(context) ? 'dark' : 'light'));
  }

  @override
  void onTap(BuildContext context) {
    SettingsModel settingsModel = Provider.of<SettingsModel>(context, listen: false);
    AppThemeSettingsEntry themeEntry = settingsModel.getEntryByKey('application.theme');
    themeEntry.toggleDarkMode();
    themeEntry.flush();
  }

  /// Returns whether the app is in dark mode.
  bool isDarkMode(BuildContext context) => Provider.of<SettingsModel>(context).theme is DarkTheme;
}