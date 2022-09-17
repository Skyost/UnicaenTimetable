import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';

/// A widget that allows to display a bool settings entries.
class BoolSettingsEntryWidget extends SettingsEntryWidget<bool> {
  /// Creates a new bool settings entry widget instance.
  BoolSettingsEntryWidget({
    super.key,
    required super.entry,
  });

  @override
  Widget? createController(BuildContext context, WidgetRef ref) => Switch(
    value: entry.value,
    onChanged: (_) => onTap(context, ref),
  );

  @override
  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    entry.value = !entry.value;
    flush(ref);
    super.onTap(context, ref);
  }
}
