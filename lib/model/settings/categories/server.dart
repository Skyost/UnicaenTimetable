import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/settings/entries/server/interval.dart';

/// The server settings category.
class ServerSettingsCategory extends SettingsCategory {
  /// This category key.
  static const String categoryKey = 'server';

  /// Creates a new server settings category instance.
  ServerSettingsCategory()
      : super(
          key: categoryKey,
          icon: Icons.wifi,
          entries: [
            IntervalSettingsEntry(keyPrefix: categoryKey),
            SettingsEntry<String>(
              categoryKey: categoryKey,
              key: 'server',
              value: 'https://webmail.unicaen.fr',
            ),
            SettingsEntry<String>(
              categoryKey: categoryKey,
              key: 'calendar',
              value: 'Emploi du temps',
            ),
            SettingsEntry<String>(
              categoryKey: categoryKey,
              key: 'additional_parameters',
              value: '',
            ),
          ],
        );
}
