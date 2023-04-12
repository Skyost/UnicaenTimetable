import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A settings category.
class SettingsCategory extends ChangeNotifier {
  /// This settings category key.
  final String key;

  /// This settings category icon.
  final IconData icon;

  /// This settings category entries.
  final List<SettingsEntry> _entries = [];

  /// Creates a new settings category instance.
  SettingsCategory({
    required this.key,
    required this.icon,
    List<SettingsEntry> entries = const [],
  }) {
    for (SettingsEntry entry in entries) {
      _addEntry(entry);
    }
  }

  /// Loads this settings entry from the storage.
  Future<void> load(Map<String, dynamic> json) async {
    for (SettingsEntry entry in _entries) {
      await entry.load(json);
    }
  }

  /// Returns all entries managed by this category.
  List<SettingsEntry> get entries => List<SettingsEntry>.of(_entries, growable: false);

  /// Adds an entry to this category.
  void _addEntry(SettingsEntry entry) {
    if (getEntryByKey(entry.key) == null) {
      entry.addListener(notifyListeners);
      _entries.add(entry);
    }
  }

  /// Returns an entry by its key.
  SettingsEntry? getEntryByKey(String key) => _entries.firstWhereOrNull((entry) => entry.key == key);

  /// Flushes this category entries to the specified json map.
  Future<void> flush(Map<String, dynamic> json) async {
    for (SettingsEntry entry in _entries) {
      entry.flush(json);
    }
  }

  @override
  void dispose() {
    for (SettingsEntry entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }
}
