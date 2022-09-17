import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';

/// Allows to display the brightness settings entry.
class BrightnessSettingsEntryWidget extends SettingsEntryWidget<ThemeMode> {
  /// Creates a new brightness settings entry widget instance.
  BrightnessSettingsEntryWidget({
    super.key,
    required super.entry,
  }) : super(
          disableOnTap: true,
        );

  @override
  Widget createTitle(BuildContext context, WidgetRef ref) => Text(
        context.getString('settings.${entry.key}.title'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  @override
  Widget createSubtitle(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: DropdownButton<ThemeMode>(
          isExpanded: true,
          onChanged: (value) async {
            if (value != null) {
              entry.value = value;
              flush(ref);
            }
          },
          items: [
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Text(context.getString('settings.application.brightness.system')),
            ),
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Text(context.getString('settings.application.brightness.light')),
            ),
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Text(context.getString('settings.application.brightness.dark')),
            ),
          ],
          value: entry.value,
        ),
      );
}
