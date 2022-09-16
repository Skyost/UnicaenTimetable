import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/widgets/settings/entries/application/theme.dart';

/// The app theme brightness settings entry that controls the app look and feel.
class BrightnessSettingsEntry extends SettingsEntry<ThemeMode> {
  /// Creates a new app brightness settings entry instance.
  BrightnessSettingsEntry({
    required String keyPrefix,
  }) : super(
          categoryKey: keyPrefix,
          key: 'brightness',
          value: ThemeMode.system,
        );

  @override
  void flush(Map<String, dynamic> json) {
    json[key] = value.index;
  }

  @protected
  @override
  ThemeMode decodeValue(dynamic value) {
    if (value == null || value is! int) {
      return value;
    }

    return ThemeMode.values[value];
  }

  /// Returns the theme corresponding to the specified brightness.
  UnicaenTimetableTheme getFromBrightness(Brightness brightness) => brightness == Brightness.light ? UnicaenTimetableTheme.light : UnicaenTimetableTheme.dark;

  /// Resolves the theme from the specified context.
  UnicaenTimetableTheme resolve(BuildContext context) {
    switch (value) {
      case ThemeMode.light:
        return getFromBrightness(Brightness.light);
      case ThemeMode.dark:
        return getFromBrightness(Brightness.dark);
      default:
        return getFromBrightness(MediaQuery.platformBrightnessOf(context));
    }
  }

  @override
  Widget render(BuildContext context) => BrightnessSettingsEntryWidget(entry: this);
}
