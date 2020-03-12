import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:unicaen_timetable/model/admob.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/model/user.dart';
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

  /// Returns the app theme from its settings entry.
  UnicaenTimetableTheme get theme => getEntryByKey('application.theme')?.value;

  /// Returns the ad mob settings entry.
  AdMobSettingsEntry get adMobEntry => getEntryByKey('application.enable_ads');

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
      DateTime max = now.add(Duration(days: interval * 7)).add(Duration(days: DateTime.friday));

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

/// A settings category.
abstract class SettingsCategory extends ChangeNotifier {
  /// This settings category key.
  final String key;

  /// This settings category icon.
  final IconData icon;

  /// This settings category entries.
  final List<SettingsEntry> _entries = [];

  /// Creates a new settings category instance.
  SettingsCategory({
    @required this.key,
    @required this.icon,
  });

  /// Loads this settings entry from the settings box.
  Future<void> load([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    for (SettingsEntry entry in _entries) {
      entry._value = await entry.load(box);
    }
  }

  /// Returns all entries managed by this category.
  List<SettingsEntry> get entries => List<SettingsEntry>.of(_entries, growable: false);

  /// Adds an entry to this category.
  void addEntry(SettingsEntry entry) {
    if (getEntryByKey(entry.key) == null) {
      entry.addListener(notifyListeners);
      _entries.add(entry);
    }
  }

  /// Returns an entry by its key.
  SettingsEntry getEntryByKey(String key) => _entries.firstWhere((entry) => entry.key == key, orElse: () => null);

  /// Removes an entry from this category.
  void removeEntry(SettingsEntry entry) {
    entry.removeListener(notifyListeners);
    _entries.remove(entry);
  }

  /// Flushes this category entries to the settings box.
  Future<void> flush([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    _entries.forEach((entry) => entry.flush(box));
  }

  @override
  void dispose() {
    super.dispose();
    _entries.forEach((entry) => entry.dispose());
  }
}

/// The application settings category.
class ApplicationSettingsCategory extends SettingsCategory {
  /// Creates a new application settings category instance.
  ApplicationSettingsCategory()
      : super(
          key: 'application',
          icon: Platform.isIOS ? Icons.phone_iphone : Icons.phone_android,
        ) {
    addEntry(AppThemeSettingsEntry(keyPrefix: key));
    addEntry(SettingsEntry<bool>(
      keyPrefix: key,
      key: 'color_lessons_automatically',
      value: false,
    ));
    addEntry(SettingsEntry<int>(
      keyPrefix: key,
      key: 'lesson_notification_mode',
      value: -1,
      enabled: Platform.isAndroid,
    ));
    addEntry(SettingsEntry<bool>(
      keyPrefix: key,
      key: 'open_today_automatically',
      value: false,
    ));
    addEntry(AdMobSettingsEntry(keyPrefix: key));
  }
}

/// The account settings category.
class AccountSettingsCategory extends SettingsCategory {
  /// Creates a new account settings category instance.
  AccountSettingsCategory()
      : super(
          key: 'account',
          icon: Icons.person,
        ) {
    addEntry(SettingsEntry(
      keyPrefix: key,
      key: 'account',
      value: null,
      mutable: false,
    ));
  }
}

/// The server settings category.
class ServerSettingsCategory extends SettingsCategory {
  /// Creates a new server settings category instance.
  ServerSettingsCategory()
      : super(
          key: 'server',
          icon: Icons.wifi,
        ) {
    addEntry(SettingsEntry<String>(
      keyPrefix: key,
      key: 'server',
      value: 'https://webmail.unicaen.fr',
    ));
    addEntry(SettingsEntry<String>(
      keyPrefix: key,
      key: 'calendar',
      value: 'Emploi du temps',
    ));
    addEntry(SettingsEntry<String>(
      keyPrefix: key,
      key: 'additional_parameters',
      value: '',
    ));
    addEntry(SettingsEntry<int>(
      keyPrefix: key,
      key: 'interval',
      value: 2,
    ));
  }
}

/// A settings entry.
class SettingsEntry<T> extends ChangeNotifier {
  /// This entry key.
  final String key;

  /// Whether this entry is mutable.
  final bool mutable;

  /// Whether this entry is enabled and should be shown.
  final bool enabled;

  /// This entry value.
  T _value;

  /// Creates a new settings entry instance.
  SettingsEntry({
    String keyPrefix = '',
    @required String key,
    this.mutable = true,
    this.enabled = true,
    @required T value,
  })  : key = (keyPrefix.isEmpty ? '' : (keyPrefix + '.')) + key,
        _value = value;

  /// Loads this entry value from the settings box.
  Future<T> load([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    return box.get(key, defaultValue: _value);
  }

  /// Returns this entry current value.
  T get value => _value;

  /// Sets this entry value.
  set value(T value) {
    if (!mutable) {
      return;
    }

    _value = value;
    notifyListeners();
  }

  /// Flushes this entry value to the settings box.
  Future<void> flush([Box settingsBox]) async {
    if (!mutable) {
      return;
    }

    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    await box.put(key, value);
  }
}
