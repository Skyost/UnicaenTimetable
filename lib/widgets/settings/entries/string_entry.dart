import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';

/// A widget that allows to display a string settings entries.
class StringSettingsEntryWidget extends SettingsEntryWidget<String> {
  /// Creates a new string settings entry widget instance.
  StringSettingsEntryWidget({
    super.key,
    required super.entry,
  });

  @override
  Widget? createSubtitle(BuildContext context, WidgetRef ref) => Text(
        entry.value.isEmpty ? context.getString('other.empty') : entry.value,
      );

  @override
  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    String? value = await TextInputDialog.getValue(
      context,
      titleKey: 'settings.${entry.key}',
      initialValue: entry.value,
    );

    if (value == null || value == entry.value) {
      return;
    }

    entry.value = value;
    flush(ref);
    if (context.mounted) {
      super.onTap(context, ref);
    }
  }
}
