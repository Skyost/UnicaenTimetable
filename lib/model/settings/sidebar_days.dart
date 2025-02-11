import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';

/// The sidebar days settings entry provider.
final sidebarDaysEntryProvider = AsyncNotifierProvider.autoDispose<SidebarDaysSettingsEntry, List<int>>(SidebarDaysSettingsEntry.new);

/// Allows to configure which days appear in the sidebar.
class SidebarDaysSettingsEntry extends SettingsEntry<List<int>> {
  /// Creates a new sidebar days settings entry instance.
  SidebarDaysSettingsEntry()
      : super(
          key: 'sidebarDays',
          defaultValue: [
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          ],
        );

  @override
  Future<List<int>> loadFromPreferences(SharedPreferencesWithCache preferences) async {
    List<String> value = preferences.getStringList(key)!;
    return [
      for (String string in value) int.parse(string),
    ];
  }

  @override
  Future<void> saveToPreferences(SharedPreferencesWithCache preferences, List<int> value) async => await preferences.setStringList(
        key,
        [
          for (int i in value) i.toString(),
        ],
      );
}

/// Allows to work with week days.
extension WeekDays on List<int> {
  /// Returns the previous available day of the sidebar.
  int previousDay(int currentDay) {
    int minDay = this.minDay;
    int result = currentDay - 1;
    while (result > minDay && !contains(result)) {
      result -= 1;
    }
    return result >= minDay ? result : maxDay;
  }

  /// Returns the next available day of the sidebar.
  int nextDay(int currentDay) {
    int maxDay = this.maxDay;
    int result = currentDay + 1;
    while (result < maxDay && !contains(result)) {
      result += 1;
    }
    return result <= maxDay ? result : minDay;
  }

  /// Returns the minimum week day of the sidebar.
  int get minDay => reduce(math.min);

  /// Returns the maximum week day of the sidebar.
  int get maxDay => reduce(math.max);
}
