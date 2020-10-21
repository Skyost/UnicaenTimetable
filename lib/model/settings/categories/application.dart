import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/entries/application/admob.dart';
import 'package:unicaen_timetable/model/settings/entries/application/lesson_notification_mode.dart';
import 'package:unicaen_timetable/model/settings/entries/application/sidebar_days.dart';
import 'package:unicaen_timetable/model/settings/entries/application/theme.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';

/// The application settings category.
class ApplicationSettingsCategory extends SettingsCategory {
  /// Creates a new application settings category instance.
  ApplicationSettingsCategory()
      : super(
          key: 'application',
          icon: Platform.isIOS ? Icons.phone_iphone : Icons.phone_android,
        ) {
    addEntry(BrightnessSettingsEntry(keyPrefix: key));
    addEntry(SidebarDaysSettingsEntry(keyPrefix: key));
    addEntry(SettingsEntry<bool>(
      keyPrefix: key,
      key: 'color_lessons_automatically',
      value: false,
    ));
    addEntry(LessonNotificationModeSettingsEntry(keyPrefix: key));
    addEntry(SettingsEntry<bool>(
      keyPrefix: key,
      key: 'open_today_automatically',
      value: false,
    ));
    addEntry(AdMobSettingsEntry(keyPrefix: key));
  }
}
