import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/entries/application/admob.dart';
import 'package:unicaen_timetable/model/settings/entries/application/sidebar_days.dart';
import 'package:unicaen_timetable/model/settings/entries/application/theme.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';

/// The application settings category.
class ApplicationSettingsCategory extends SettingsCategory {
  /// This category key.
  static const String categoryKey = 'application';

  /// Creates a new application settings category instance.
  ApplicationSettingsCategory()
      : super(
          key: categoryKey,
          icon: Platform.isIOS ? Icons.phone_iphone : Icons.phone_android,
          entries: [
            BrightnessSettingsEntry(keyPrefix: categoryKey),
            SidebarDaysSettingsEntry(keyPrefix: categoryKey),
            SettingsEntry<bool>(
              categoryKey: categoryKey,
              key: 'color_lessons_automatically',
              value: false,
            ),
            SettingsEntry<bool>(
              categoryKey: categoryKey,
              key: 'open_today_automatically',
              value: false,
            ),
            AdMobSettingsEntry(keyPrefix: categoryKey),
          ]
        );
}
