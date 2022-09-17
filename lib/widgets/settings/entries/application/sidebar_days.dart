import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';

/// Allows to display the sidebar days settings entry.
class SidebarDaysSettingsEntryWidget extends SettingsEntryWidget<List<int>> {
  /// Creates a new sidebar days settings entry widget instance.
  SidebarDaysSettingsEntryWidget({
    super.key,
    required super.entry,
  });

  @override
  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    List<int>? result = await showDialog<List<int>>(
      context: context,
      builder: (context) => _SidebarDaysSettingsEntryDialogContent(sidebarDays: entry.value),
    );
    if (result != null) {
      entry.value = result;
      flush(ref);
    }
  }

  @override
  Widget createSubtitle(BuildContext context, WidgetRef ref) {
    List<int> days = entry.value;
    if (days.isEmpty) {
      return Text('${context.getString('other.none')}.');
    }

    String? languageCode = EzLocalization.of(context)?.locale.languageCode;
    DateTime monday = DateTime.now().atMonday;
    return Text('${days.map((day) => DateFormat.EEEE(languageCode).format(monday.add(Duration(days: day - 1))).capitalize()).join(', ')}.');
  }
}

/// Allows to display all days and to toggle their showing in the sidebar.
class _SidebarDaysSettingsEntryDialogContent extends StatefulWidget {
  /// The entry.
  final List<int> sidebarDays;

  /// Creates a new sidebar days settings entry dialog content instance.
  const _SidebarDaysSettingsEntryDialogContent({
    required this.sidebarDays,
  });

  @override
  State<StatefulWidget> createState() => _SidebarDaysSettingsEntryDialogContentState();
}

/// Sidebar days settings entry dialog content state.
class _SidebarDaysSettingsEntryDialogContentState extends State<_SidebarDaysSettingsEntryDialogContent> {
  /// The days shown in the sidebar.
  late List<int> sidebarDays;

  @override
  void initState() {
    super.initState();
    sidebarDays = widget.sidebarDays;
  }

  @override
  Widget build(BuildContext context) {
    DateTime monday = DateTime.now().atMonday;
    return AlertDialog(
      title: Text(context.getString('settings.application.sidebar_days')),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: DateTime.daysPerWeek,
          itemBuilder: (context, position) => ListTile(
            title: Text(DateFormat.EEEE(EzLocalization.of(context)?.locale.languageCode).format(monday.add(Duration(days: position))).capitalize()),
            onTap: () => onTap(position + 1),
            trailing: Switch(
              value: sidebarDays.contains(position + 1),
              onChanged: (selected) => onTap(position + 1, selected: selected),
            ),
          ),
          shrinkWrap: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, sidebarDays),
          child: Text(MaterialLocalizations.of(context).okButtonLabel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
        ),
      ],
    );
  }

  /// Triggered when the switch has been tapped on.
  void onTap(int day, {bool? selected}) {
    selected ??= !sidebarDays.contains(day);
    if (selected) {
      setState(() => sidebarDays.add(day));
    } else {
      setState(() => sidebarDays.remove(day));
    }
  }
}
