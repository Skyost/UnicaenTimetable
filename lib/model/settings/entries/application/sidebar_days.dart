import 'dart:math' as math;

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// Allows to configure which days appear in the sidebar.
class SidebarDaysSettingsEntry extends SettingsEntry<List<int>> {
  /// Creates a new sidebar days settings entry instance.
  SidebarDaysSettingsEntry({
    @required String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
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
  Widget render(BuildContext context) => _SidebarDaysSettingsEntryWidget(entry: this);

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

/// Allows to display the sidebar days settings entry.
class _SidebarDaysSettingsEntryWidget extends SettingsEntryWidget {
  /// Creates a new sidebar days settings entry widget instance.
  const _SidebarDaysSettingsEntryWidget({
    @required SidebarDaysSettingsEntry entry,
  }) : super(entry: entry);

  @override
  Future<void> onTap(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.getString('settings.application.sidebar_days')),
        content: ChangeNotifierProvider<SettingsEntry<List<int>>>.value(
          value: entry,
          builder: (context, child) => _SidebarDaysSettingsEntryDialogContent(),
        ),
        actions: [
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel.toUpperCase()),
          ),
        ],
      ),
    );
    unawaited(entry.flush());
  }

  @override
  Widget createSubtitle(BuildContext context) {
    List<int> days = entry.value;
    if(days.isEmpty) {
      return Text('${context.getString('other.none')}.');
    }

    DateTime monday = DateTime.now().atMonday;
    return Text(days.map((day) => DateFormat.EEEE(EzLocalization.of(context).locale.languageCode).format(monday.add(Duration(days: day - 1))).capitalize()).join(', ') + '.');
  }
}

/// Allows to display all days and to toggle their showing in the sidebar.
class _SidebarDaysSettingsEntryDialogContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SidebarDaysSettingsEntry entry = context.watch<SettingsEntry<List<int>>>() as SidebarDaysSettingsEntry;
    DateTime monday = DateTime.now().atMonday;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: DateTime.daysPerWeek,
        itemBuilder: (context, position) => ListTile(
          title: Text(DateFormat.EEEE(EzLocalization.of(context).locale.languageCode).format(monday.add(Duration(days: position)))),
          onTap: () => onTap(entry, position + 1),
          trailing: Switch(
            value: entry.value.contains(position + 1),
            onChanged: (selected) => onTap(entry, position + 1, selected: selected),
          ),
        ),
        shrinkWrap: true,
      ),
    );
  }

  /// Triggered when the switch has been tapped on.
  void onTap(SidebarDaysSettingsEntry entry, int day, {bool selected}) {
    selected ??= !entry.hasDay(day);
    if (selected) {
      entry.addDay(day);
    } else {
      entry.removeDay(day);
    }
  }
}
