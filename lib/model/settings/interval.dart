import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';

/// The interval settings entry provider.
final invervalSettingsEntryProvider = AsyncNotifierProvider.autoDispose<IntervalSettingsEntry, int>(IntervalSettingsEntry.new);

/// The server interval settings entry that defines the number of weeks to download.
class IntervalSettingsEntry extends SettingsEntry<int> {
  /// Creates a new server interval settings entry instance.
  IntervalSettingsEntry()
      : super(
          key: 'interval',
          defaultValue: 2,
        );
}
