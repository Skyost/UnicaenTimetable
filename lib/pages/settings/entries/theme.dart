import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/theme.dart';

/// Allows to configure [themeSettingsEntryProvider].
class ThemeSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new theme settings entry widget instance.
  const ThemeSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ThemeMode> theme = ref.watch(themeSettingsEntryProvider);
    return ListTile(
      enabled: theme.hasValue,
      title: DropdownButtonFormField<ThemeMode>(
        value: theme.valueOrNull,
        decoration: InputDecoration(
          labelText: translations.settings.application.brightness.title,
        ),
        items: [
          for (ThemeMode theme in ThemeMode.values)
            if (translations.settings.application.brightness.values.containsKey(theme.name))
              DropdownMenuItem<ThemeMode>(
                value: theme,
                child: Text(translations.settings.application.brightness.values[theme.name]!),
              ),
        ],
        onChanged: (value) async {
          if (value != null) {
            await ref.read(themeSettingsEntryProvider.notifier).changeValue(value);
          }
        },
      ),
    );
  }
}
