import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/settings/entries/server/interval.dart';

/// The server settings category.
class ServerSettingsCategory extends SettingsCategory {
  /// Creates a new server settings category instance.
  ServerSettingsCategory()
      : super(
          key: 'server',
          icon: Icons.wifi,
        ) {
    addEntry(IntervalSettingsEntry(keyPrefix: key));
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
  }
}
