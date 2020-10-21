import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/settings/renderable.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/theme.dart';

/// A settings category.
abstract class SettingsCategory extends ChangeNotifier with RenderableSettingsObject {
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
      await entry.load(box);
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

  @override
  Widget render(BuildContext context) => _SettingsCategoryWidget(category: this);
}

/// A widget that shows a settings category.
class _SettingsCategoryWidget extends StatelessWidget {
  /// The settings category.
  final SettingsCategory category;

  /// Creates a new settings category widget.
  const _SettingsCategoryWidget({
    @required this.category,
  });

  @override
  Widget build(BuildContext context) {
    UnicaenTimetableTheme theme = context.watch<SettingsModel>().resolveTheme(context);
    return Column(
      children: [
        ListTile(
          leading: Icon(category.icon, color: theme.listHeaderTextColor),
          title: Text(
            context.getString('settings.${category.key}.title'),
            style: TextStyle(color: theme.listHeaderTextColor),
          ),
          enabled: false,
        ),
        for (SettingsEntry entry in category.entries) //
          if (entry.enabled) //
            entry.render(context),
      ],
    );
  }
}
