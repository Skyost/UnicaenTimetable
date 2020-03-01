import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:unicaen_timetable/model/admob.dart';
import 'package:unicaen_timetable/model/app_model.dart';
import 'package:unicaen_timetable/model/theme.dart';

class SettingsModel extends AppModel {
  static const String HIVE_BOX = 'settings';
  final List<SettingsCategory> _categories = [];

  List<SettingsCategory> get categories => List.of(_categories, growable: false);

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
      category._populate();
      await category.load(box);
      addCategory(category);
    }

    markInitialized();
  }

  void flush([Box settingsBox]) async {
    for (SettingsCategory category in _categories) {
      await category.flush(settingsBox);
    }
  }

  void addCategory(SettingsCategory category) {
    category.addListener(notifyListeners);
    _categories.add(category);
  }

  SettingsEntry getEntryByKey(String key) {
    for (SettingsCategory category in _categories) {
      SettingsEntry entry = category.getEntryByKey(key);
      if (entry != null) {
        return entry;
      }
    }
    return null;
  }

  void removeCategory(SettingsCategory category) {
    category.removeListener(notifyListeners);
    _categories.remove(category);
  }

  @override
  void dispose() {
    super.dispose();
    _categories.forEach((category) => category.dispose());
  }

  AppTheme get theme => getEntryByKey('application.theme')?.value;

  AdMobSettingsEntry get adMobEntry => getEntryByKey('application.enable_ads');
}

abstract class SettingsCategory extends ChangeNotifier {
  final String key;
  final IconData icon;
  final List<SettingsEntry> _entries = [];

  SettingsCategory({
    @required this.key,
    @required this.icon,
  });

  void _populate();

  Future<void> load([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    for (SettingsEntry entry in _entries) {
      entry._value = await entry.load(box);
    }
  }

  List<SettingsEntry> get entries => List.of(_entries);

  void addEntry(SettingsEntry entry) {
    if (getEntryByKey(entry.key) == null) {
      entry.addListener(notifyListeners);
      _entries.add(entry);
    }
  }

  SettingsEntry getEntryByKey(String key) => _entries.firstWhere((entry) => entry.key == key, orElse: () => null);

  void removeEntry(SettingsEntry entry) {
    entry.removeListener(notifyListeners);
    _entries.remove(entry);
  }

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

class ApplicationSettingsCategory extends SettingsCategory {
  ApplicationSettingsCategory()
      : super(
          key: 'application',
          icon: Platform.isIOS ? Icons.phone_iphone : Icons.phone_android,
        );

  @override
  void _populate() {
    addEntry(AppThemeSettingsEntry(keyPrefix: key));
    addEntry(SettingsEntry<bool>(
      keyPrefix: key,
      key: 'color_lessons_automatically',
      value: false,
    ));
    addEntry(SettingsEntry<int>(
      keyPrefix: key,
      key: 'lessons_ringer_mode',
      value: 0,
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

class AccountSettingsCategory extends SettingsCategory {
  AccountSettingsCategory()
      : super(
          key: 'account',
          icon: Icons.person,
        );

  @override
  void _populate() {
    addEntry(SettingsEntry(
      keyPrefix: key,
      key: 'account',
      value: null,
      mutable: false,
    ));
  }
}

class ServerSettingsCategory extends SettingsCategory {
  ServerSettingsCategory()
      : super(
          key: 'server',
          icon: Icons.wifi,
        );

  @override
  void _populate() {
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

class SettingsEntry<T> extends ChangeNotifier {
  final String key;
  final bool mutable;
  final bool enabled;
  T _value;

  SettingsEntry({
    String keyPrefix = '',
    @required String key,
    this.mutable = true,
    this.enabled = true,
    @required T value,
  })  : key = (keyPrefix.isEmpty ? '' : (keyPrefix + '.')) + key,
        _value = value;

  Future<T> load([Box settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    return box.get(key, defaultValue: _value);
  }

  T get value => _value;

  set value(T value) {
    if (!mutable) {
      return;
    }

    _value = value;
    notifyListeners();
  }

  Future<void> flush([Box settingsBox]) async {
    if (!mutable) {
      return;
    }

    Box box = settingsBox ?? await Hive.openBox(SettingsModel.HIVE_BOX);
    await box.put(key, value);
  }
}
