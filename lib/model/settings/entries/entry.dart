import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/widgets/settings/entries/bool_entry.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';
import 'package:unicaen_timetable/widgets/settings/entries/int_entry.dart';
import 'package:unicaen_timetable/widgets/settings/entries/string_entry.dart';

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
    String categoryKey = '',
    required String key,
    this.mutable = true,
    this.enabled = true,
    required T value,
  })  : key = (categoryKey.isEmpty ? '' : ('$categoryKey.')) + key,
        _value = value;

  /// Loads this entry value from the settings box.
  Future<void> load([Box? settingsBox]) async {
    Box box = settingsBox ?? await Hive.openBox(SettingsModel.hiveBox);
    _value = decodeValue(box.get(key));
  }

  /// Returns this entry current value.
  T get value => _value;

  /// Sets this entry value.
  set value(T value) {
    if (!mutable) {
      return;
    }

    _value = value;
    flush();
    notifyListeners();
  }

  /// Flushes this entry value to the settings box.
  Future<void> flush([Box? settingsBox]) async {
    if (!mutable) {
      return;
    }

    Box box = settingsBox ?? await Hive.openBox(SettingsModel.hiveBox);
    await box.put(key, value);
  }

  /// Decodes the value that was read from a Hive box.
  @protected
  T decodeValue(dynamic boxValue) => boxValue ?? _value;

  /// Renders this entry.
  Widget render(BuildContext context) {
    if (T == String) {
      return StringSettingsEntryWidget(entry: this as SettingsEntry<String>);
    }
    if (T == bool) {
      return BoolSettingsEntryWidget(entry: this as SettingsEntry<bool>);
    }
    if (T == int) {
      return IntSettingsEntryWidget(entry: this as SettingsEntry<int>);
    }
    return SettingsEntryWidget<T>(entry: this);
  }
}
