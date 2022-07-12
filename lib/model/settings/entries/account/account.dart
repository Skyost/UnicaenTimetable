import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/widgets/settings/entries/account/account.dart';

/// The account settings entry that defines the current account.
class AccountSettingsEntry extends SettingsEntry {
  /// Creates a new app account settings entry instance.
  AccountSettingsEntry({
    required String keyPrefix,
  }) : super(
          categoryKey: keyPrefix,
          key: 'account',
          value: null,
          mutable: false,
        );

  @override
  Widget render(BuildContext context) => AccountSettingsEntryWidget(entry: this);
}
