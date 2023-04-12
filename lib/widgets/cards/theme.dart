import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/entries/application/theme.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/widgets/cards/card.dart';

/// A card that allows to change the app theme.
class ThemeCard extends MaterialCard<String> {
  /// The card id.
  static const String id = 'current_theme';

  /// Creates a new theme card instance.
  ThemeCard({
    super.key,
    super.onRemove,
  }) : super(
          cardId: id,
        );

  @override
  IconData buildIcon(BuildContext context, WidgetRef ref) => _isDarkMode(context, ref) ? Icons.brightness_3 : Icons.wb_sunny;

  @override
  Color buildColor(BuildContext context, WidgetRef ref) => Colors.indigo[400]!;

  @override
  Future<String> requestData(BuildContext context, WidgetRef ref) async {
    String status = _isDarkMode(context, ref) ? 'dark' : 'light';
    String subtitle = context.getString('home.current_theme.$status');
    if (ref.read(settingsModelProvider).themeEntry.value == ThemeMode.system) {
      subtitle += ' (${context.getString('home.current_theme.auto')})';
    }
    subtitle += '.';
    return subtitle;
  }

  @override
  void onTap(BuildContext context, WidgetRef ref) {
    SettingsModel settingsModel = ref.read(settingsModelProvider);
    BrightnessSettingsEntry themeEntry = settingsModel.themeEntry;
    themeEntry.value = _isDarkMode(context, ref, listen: false) ? ThemeMode.light : ThemeMode.dark;
    settingsModel.flush();
  }

  /// Returns whether the app is in dark mode.
  bool _isDarkMode(BuildContext context, WidgetRef ref, {bool listen = true}) {
    SettingsModel settingsModel = listen ? ref.watch(settingsModelProvider) : ref.read(settingsModelProvider);
    return settingsModel.resolveTheme(context).brightness == Brightness.dark;
  }
}
