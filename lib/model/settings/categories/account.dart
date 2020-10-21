import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/entries/account/account.dart';

/// The account settings category.
class AccountSettingsCategory extends SettingsCategory {
  /// Creates a new account settings category instance.
  AccountSettingsCategory()
      : super(
          key: 'account',
          icon: Icons.person,
        ) {
    addEntry(AccountSettingsEntry(keyPrefix: key));
  }
}
