import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/theme.dart';
import 'package:unicaen_timetable/pages/home/cards/card_content.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';

/// A card that allows to show the current theme.
class ThemeCard extends ConsumerStatefulWidget {
  /// Creates a new theme card instance.
  const ThemeCard({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThemeCardState();
}

/// The theme card state.
class _ThemeCardState extends ConsumerState<ThemeCard> with BrightnessListener {
  @override
  Widget build(BuildContext context) {
    String subtitle = currentBrightness == Brightness.dark ? translations.home.currentTheme.dark : translations.home.currentTheme.light;
    if (ref.watch(themeSettingsEntryProvider).valueOrNull == ThemeMode.system) {
      subtitle += ' (${translations.home.currentTheme.auto})';
    }
    subtitle += '.';
    return MaterialCardContent(
      color: Colors.indigo.shade400,
      icon: currentBrightness == Brightness.dark ? Icons.brightness_3 : Icons.wb_sunny,
      title: translations.home.currentLesson.title,
      subtitle: subtitle,
      onTap: () async => await ref.read(themeSettingsEntryProvider.notifier).changeValue(currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark),
    );
  }
}
