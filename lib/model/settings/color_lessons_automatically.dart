import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';

/// The automatically color lessons settings entry provider.
final colorLessonsAutomaticallyEntryProvider = AsyncNotifierProvider.autoDispose<ColorLessonsAutomaticallySettingsEntry, bool>(ColorLessonsAutomaticallySettingsEntry.new);

/// The automatically color lessons settings entry that defines whether lessons are colored automatically or not.
class ColorLessonsAutomaticallySettingsEntry extends SettingsEntry<bool> {
  /// Creates a new server interval settings entry instance.
  ColorLessonsAutomaticallySettingsEntry()
      : super(
          key: 'colorLessonsAutomatically',
          defaultValue: false,
        );
}
