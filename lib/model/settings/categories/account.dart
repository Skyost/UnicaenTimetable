import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/entries/account/account.dart';

/// The account settings category.
class AccountSettingsCategory extends SettingsCategory {
  /// This category key.
  static const String categoryKey = 'account';

  /// Creates a new account settings category instance.
  AccountSettingsCategory()
      : super(
          key: categoryKey,
          icon: Icons.person,
          entries: [
            AccountSettingsEntry(keyPrefix: categoryKey),
          ]
        );
}
