import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/categories/category.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/theme.dart';

/// A widget that shows a settings category.
class SettingsCategoryWidget extends ConsumerWidget {
  /// The settings category.
  final SettingsCategory category;

  /// Creates a new settings category widget.
  const SettingsCategoryWidget({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UnicaenTimetableTheme theme = ref.watch(settingsModelProvider).resolveTheme(context);
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