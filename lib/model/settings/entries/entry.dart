import 'package:flutter/material.dart';
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

  /// Loads this entry value from the storage.
  Future<void> load(Map<String, dynamic> json) async {
    _value = decodeValue(json[key]);
  }

  /// Returns this entry current value.
  T get value => _value;

  /// Sets this entry value.
  set value(T value) {
    if (!mutable) {
      return;
    }

    _value = value;
    // TODO: flush();
    notifyListeners();
  }

  /// Flushes this entry value to the storage.
  void flush(Map<String, dynamic> json) {
    if (!mutable) {
      return;
    }

    json[key] = _value;
  }

  /// Decodes the value that was read from a Hive box.
  @protected
  T decodeValue(dynamic value) => value ?? _value;

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
