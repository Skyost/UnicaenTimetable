import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/theme.dart';

/// The app theme brightness settings entry that controls the app look and feel.
class BrightnessSettingsEntry extends SettingsEntry<ThemeMode> {
  /// Creates a new app brightness settings entry instance.
  BrightnessSettingsEntry({
    @required String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
          key: 'brightness',
          value: ThemeMode.system,
        );

  @override
  Future<void> flush([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    await box.put(key, value.index);
  }

  @protected
  @override
  ThemeMode decodeValue(dynamic boxValue) {
    if (boxValue == null || boxValue is! int) {
      return value;
    }

    return ThemeMode.values[boxValue];
  }

  /// Returns the theme corresponding to the specified brightness.
  UnicaenTimetableTheme getFromBrightness(Brightness brightness) => brightness == Brightness.light ? UnicaenTimetableTheme.LIGHT : UnicaenTimetableTheme.DARK;

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
  Widget render(BuildContext context) => _BrightnessSettingsEntryWidget(entry: this);
}

/// Allows to display the brightness settings entry.
class _BrightnessSettingsEntryWidget extends StatelessWidget {
  /// The entry.
  final BrightnessSettingsEntry entry;

  /// Creates a new brightness settings entry widget instance.
  const _BrightnessSettingsEntryWidget({
    @required this.entry,
  });

  @override
  Widget build(BuildContext context) => SettingsDropdownButton<ThemeMode>(
        titleKey: 'settings.application.brightness.title',
        onChanged: (value) async {
          entry.value = value;
          await entry.flush();
        },
        items: [
          DropdownMenuItem<ThemeMode>(
            child: Text(context.getString('settings.application.brightness.system')),
            value: ThemeMode.system,
          ),
          DropdownMenuItem<ThemeMode>(
            child: Text(context.getString('settings.application.brightness.light')),
            value: ThemeMode.light,
          ),
          DropdownMenuItem<ThemeMode>(
            child: Text(context.getString('settings.application.brightness.dark')),
            value: ThemeMode.dark,
          ),
        ],
        value: entry.value,
      );
}
