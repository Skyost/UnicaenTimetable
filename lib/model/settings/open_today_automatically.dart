import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';

/// The open today settings entry provider.
final openTodayAutomaticallyEntryProvider = AsyncNotifierProvider.autoDispose<OpenTodayAutomaticallySettingsEntry, bool>(OpenTodayAutomaticallySettingsEntry.new);

/// The settings entry that defines whether the today page should be automatically opened.
class OpenTodayAutomaticallySettingsEntry extends SettingsEntry<bool> {
  /// Creates a new server interval settings entry instance.
  OpenTodayAutomaticallySettingsEntry()
      : super(
          key: 'openTodayAutomatically',
          defaultValue: false,
        );
}
