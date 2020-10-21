import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:unicaen_timetable/dialogs/input.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';

/// The server interval settings entry that defines the number of weeks to download.
class IntervalSettingsEntry extends SettingsEntry<int> {
  /// Creates a new server interval settings entry instance.
  IntervalSettingsEntry({
    @required String keyPrefix,
  }) : super(
    keyPrefix: keyPrefix,
    key: 'interval',
    value: 2,
  );

  @override
  Widget render(BuildContext context) => _IntervalSettingsEntryWidget(entry: this);
}

/// Allows to display the server sync interval settings entry.
class _IntervalSettingsEntryWidget extends SettingsEntryWidget {
  /// Creates a new server sync interval settings entry widget instance.
  _IntervalSettingsEntryWidget({
    @required IntervalSettingsEntry entry,
  }) : super(entry: entry);

  @override
  Widget createSubtitle(BuildContext context)=>Text(context.getString('other.weeks', {'interval': entry.value}));

  @override
  Future<void> afterOnTap(BuildContext context) async {
    int value = await IntInputDialog.getValue(
      context,
      titleKey: 'settings.server.interval',
      initialValue: entry.value,
      min: 1,
      max: 52,
      divisions: 52,
    );

    if (value == null || value == entry.value) {
      return;
    }

    entry.value = value;
    unawaited(entry.flush());
    await super.afterOnTap(context);
  }
}