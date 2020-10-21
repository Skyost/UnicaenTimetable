import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/model/settings/categories/account.dart';
import 'package:unicaen_timetable/model/settings/categories/application.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/categories/server.dart';
import 'package:unicaen_timetable/model/settings/entries/application/admob.dart';
import 'package:unicaen_timetable/model/settings/entries/application/sidebar_days.dart';
import 'package:unicaen_timetable/model/settings/entries/application/theme.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/utils/http_client.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The settings model.
class SettingsModel extends UnicaenTimetableModel {
  /// The settings Hive box name.
  static const String HIVE_BOX = 'settings';

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

    Box box = await Hive.openBox(HIVE_BOX);
    for (SettingsCategory category in categories) {
      await category.load(box);
      addCategory(category);
    }

    markInitialized();
  }

  /// Flushes this model entries to the settings box.
  void flush([Box settingsBox]) async {
    for (SettingsCategory category in _categories) {
      await category.flush(settingsBox);
    }
  }

  /// Adds a category to this model.
  void addCategory(SettingsCategory category) {
    category.addListener(notifyListeners);
    _categories.add(category);
  }

  /// Returns the settings entry thanks to its key.
  SettingsEntry getEntryByKey(String key) {
    for (SettingsCategory category in _categories) {
      SettingsEntry entry = category.getEntryByKey(key);
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
    super.dispose();
    _categories.forEach((category) => category.dispose());
  }

  /// Returns the app theme according to the current brightness.
  UnicaenTimetableTheme resolveTheme(BuildContext context) => themeEntry?.resolve(context);

  /// Returns the app theme brightness settings entry.
  BrightnessSettingsEntry get themeEntry => getEntryByKey('application.brightness') as BrightnessSettingsEntry;

  /// Returns the ad mob settings entry.
  AdMobSettingsEntry get adMobEntry => getEntryByKey('application.enable_ads') as AdMobSettingsEntry;

  /// Returns the days shown at the sidebar.
  SidebarDaysSettingsEntry get sidebarDaysEntry => getEntryByKey('application.sidebar_days') as SidebarDaysSettingsEntry;

  /// Returns the calendar address according to the specified user.
  Uri getCalendarAddressFromSettings(User user) {
    String url = getEntryByKey('server.server').value;
    url += '/home/';
    url += user.username;
    url += '/';
    url += Uri.encodeFull(getEntryByKey('server.calendar').value);
    url += '?auth=ba&fmt=json';

    String additionalParameters = getEntryByKey('server.additional_parameters').value;
    if (additionalParameters.isNotEmpty) {
      url += '&';
      url += additionalParameters;
    }

    int interval = getEntryByKey('server.interval').value;
    if (interval > 0) {
      DateTime now = DateTime.now().atMonday.yearMonthDay;
      DateTime min = now.subtract(Duration(days: interval * 7));
      DateTime max = now.add(Duration(days: interval * 7)).add(const Duration(days: DateTime.friday));

      url += '&start=' + min.year.toString() + '/' + min.month.withLeadingZero + '/' + min.day.withLeadingZero;
      url += '&end=' + max.year.toString() + '/' + max.month.withLeadingZero + '/' + max.day.withLeadingZero;
    }

    return Uri.parse(url);
  }

  /// Requests the calendar according to the specified settings model.
  Future<Response> requestCalendar(User user) async {
    UnicaenTimetableHttpClient client = const UnicaenTimetableHttpClient();
    Response response = await client.connect(getCalendarAddressFromSettings(user), user);
    if (response?.statusCode == 401 || response?.statusCode == 404) {
      user.username = user.username.endsWith('@etu.unicaen.fr') ? user.username.substring(0, user.username.lastIndexOf('@etu.unicaen.fr')) : (user.username + '@etu.unicaen.fr');
      if (user.isInBox) {
        await user.save();
      }
      response = await client.connect(getCalendarAddressFromSettings(user), user);
    }

    return response;
  }
}
