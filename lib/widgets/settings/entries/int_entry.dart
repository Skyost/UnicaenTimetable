import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';

/// A widget that allows to display an int settings entries.
class IntSettingsEntryWidget extends SettingsEntryWidget<int> {
  /// Creates a new int settings entry widget instance.
  IntSettingsEntryWidget({
    super.key,
    required super.entry,
  });

  @override
  Widget createSubtitle(BuildContext context, WidgetRef ref) => Text(entry.value.toString());

  @override
  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    int? value = await IntInputDialog.getValue(
      context,
      titleKey: 'settings.${entry.key}',
      initialValue: entry.value,
      min: 1,
      max: 52,
      divisions: 52,
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
