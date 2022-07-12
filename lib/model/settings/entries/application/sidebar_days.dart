import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/widgets/settings/entries/application/sidebar_days.dart';

/// Allows to configure which days appear in the sidebar.
class SidebarDaysSettingsEntry extends SettingsEntry<List<int>> {
  /// Creates a new sidebar days settings entry instance.
  SidebarDaysSettingsEntry({
    required String keyPrefix,
  }) : super(
          categoryKey: keyPrefix,
          key: 'sidebar_days',
          value: [
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          ],
        );

  @override
  set value(List<int> value) {
    super.value = value..sort();
  }

  @protected
  @override
  List<int> decodeValue(dynamic boxValue) {
    if (boxValue == null || boxValue is! List) {
      return super.value;
    }

    return List<int>.from(boxValue)..sort();
  }

  @override
  Widget render(BuildContext context) => SidebarDaysSettingsEntryWidget(entry: this);

  @override
  List<int> get value => List<int>.from(super.value);

  /// Adds a day to this entry.
  void addDay(int day) {
    if (!hasDay(day)) {
      super.value.add(day);
      super.value.sort();
      notifyListeners();
    }
  }

  /// Removes a day from this entry.
  void removeDay(int day) {
    if (hasDay(day)) {
      super.value.remove(day);
      super.value.sort();
      notifyListeners();
    }
  }

  /// Returns whether this entry has the given day.
  bool hasDay(int day) => super.value.contains(day);

  /// Returns the previous available day of the sidebar.
  int previousDay(int currentDay) {
    int minDay = this.minDay;
    int result = currentDay - 1;
    while (result > minDay && !super.value.contains(result)) {
      result -= 1;
    }
    return result >= minDay ? result : maxDay;
  }

  /// Returns the next available day of the sidebar.
  int nextDay(int currentDay) {
    int maxDay = this.maxDay;
    int result = currentDay + 1;
    while (result < maxDay && !super.value.contains(result)) {
      result += 1;
    }
    return result <= maxDay ? result : minDay;
  }

  /// Returns the minimum week day of the sidebar.
  int get minDay => super.value.reduce(math.min);

  /// Returns the maximum week day of the sidebar.
  int get maxDay => super.value.reduce(math.max);
}
