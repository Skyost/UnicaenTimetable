import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/model/settings/categories/account.dart';
import 'package:unicaen_timetable/model/settings/categories/application.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/categories/server.dart';
import 'package:unicaen_timetable/model/settings/entries/application/admob.dart';
import 'package:unicaen_timetable/model/settings/entries/application/sidebar_days.dart';
import 'package:unicaen_timetable/model/settings/entries/application/theme.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/utils/calendar_url.dart';

final settingsModelProvider = ChangeNotifierProvider((ref) {
  SettingsModel settingsModel = SettingsModel();
  settingsModel.initialize();
  return settingsModel;
});

/// The settings model.
class SettingsModel extends UnicaenTimetableModel {
  /// The settings Hive box name.
  static const String _settingsFilename = 'settings.json';

  /// Available settings categories.
  final List<SettingsCategory> _categories = [];

  /// Returns all available settings categories.
  List<SettingsCategory> get categories => List<SettingsCategory>.of(_categories, growable: false);

  /// Initializes this model.
  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    List<SettingsCategory> categories = [
      ApplicationSettingsCategory(),
      AccountSettingsCategory(),
      ServerSettingsCategory(),
    ];

    Map<String, dynamic> json = jsonDecode(await UnicaenTimetableModel.storage.readFile(_settingsFilename));
    for (SettingsCategory category in categories) {
      await category.load(json);
      addCategory(category);
    }

    markInitialized();
  }

  /// Flushes this model entries to the storage.
  void flush() async {
    Map<String, dynamic> json = jsonDecode(await UnicaenTimetableModel.storage.readFile(_settingsFilename));
    for (SettingsCategory category in _categories) {
      await category.flush(json);
    }
    await UnicaenTimetableModel.storage.saveFile(_settingsFilename, jsonEncode(json));
  }

  /// Adds a category to this model.
  void addCategory(SettingsCategory category) {
    category.addListener(notifyListeners);
    _categories.add(category);
  }

  /// Returns the settings entry thanks to its key.
  SettingsEntry? getEntryByKey(String key) {
    for (SettingsCategory category in _categories) {
      SettingsEntry? entry = category.getEntryByKey(key);
      if (entry != null) {
        return entry;
      }
    }
    return null;
  }

  /// Removes a category from this model.
  void removeCategory(SettingsCategory category) {
    category.removeListener(notifyListeners);
    _categories.remove(category);
  }

  @override
  void dispose() {
    for (SettingsCategory category in _categories) {
      category.dispose();
    }
    super.dispose();
  }

  /// Returns the app theme according to the current brightness.
  UnicaenTimetableTheme resolveTheme(BuildContext context) => themeEntry.resolve(context);

  /// Returns the app theme brightness settings entry.
  BrightnessSettingsEntry get themeEntry => getEntryByKey('application.brightness') as BrightnessSettingsEntry;

  /// Returns the ad mob settings entry.
  AdMobSettingsEntry get adMobEntry => getEntryByKey('application.enable_ads') as AdMobSettingsEntry;

  /// Returns the days shown at the sidebar.
  SidebarDaysSettingsEntry get sidebarDaysEntry => getEntryByKey('application.sidebar_days') as SidebarDaysSettingsEntry;

  /// Returns the calendar URL.
  CalendarUrl get calendarUrl => CalendarUrl(
    server: getEntryByKey('server.server')?.value,
    calendar: getEntryByKey('server.calendar')?.value,
    additionalParameters: getEntryByKey('server.additional_parameters')?.value,
    interval: getEntryByKey('server.interval')?.value,
  );
}
