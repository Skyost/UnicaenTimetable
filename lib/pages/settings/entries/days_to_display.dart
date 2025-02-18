import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/days_to_display.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// Allows to configure [daysToDisplayEntryProvider].
class DaysToDisplaySettingsEntryWidget extends ConsumerWidget {
  /// Creates a new days to display settings entry widget instance.
  const DaysToDisplaySettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<int>> sidebarDays = ref.watch(daysToDisplayEntryProvider);
    DateFormat formatter = DateFormat.EEEE(TranslationProvider.of(context).locale.languageCode);
    DateTime monday = DateTime.now().atMonday;
    return ListTile(
      enabled: sidebarDays.hasValue,
      title: Text(translations.settings.application.daysToDisplay),
      subtitle: Text(
        [for (int day in sidebarDays.valueOrNull ?? []) formatter.format(monday.add(Duration(days: day - 1)))].join(', '),
      ),
      onTap: () async {
        List<int>? result = await showDialog<List<int>>(
          context: context,
          builder: (context) => _SidebarDaysSettingsEntryDialogContent(sidebarDays: sidebarDays.value!),
        );
        if (result != null) {
          await ref.read(daysToDisplayEntryProvider.notifier).changeValue(result);
        }
      },
    );
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
    sidebarDays = List.of(widget.sidebarDays);
  }

  @override
  Widget build(BuildContext context) {
    DateTime monday = DateTime.now().atMonday;
    return AlertDialog(
      title: Text(translations.settings.application.daysToDisplay),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: DateTime.daysPerWeek,
          itemBuilder: (context, position) => ListTile(
            title: Text(DateFormat.EEEE(TranslationProvider.of(context).locale.languageCode).format(monday.add(Duration(days: position))).capitalize()),
            onTap: () => onTap(position + 1),
            trailing: Checkbox(
              value: sidebarDays.contains(position + 1),
              onChanged: (selected) => onTap(position + 1, selected: selected),
            ),
          ),
          shrinkWrap: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, sidebarDays),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
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
