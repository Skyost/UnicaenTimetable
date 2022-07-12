import 'package:unicaen_timetable/model/settings/entries/entry.dart';

/// The server interval settings entry that defines the number of weeks to download.
class IntervalSettingsEntry extends SettingsEntry<int> {
  /// Creates a new server interval settings entry instance.
  IntervalSettingsEntry({
    required String keyPrefix,
  }) : super(
          categoryKey: keyPrefix,
          key: 'interval',
          value: 2,
        );
}
