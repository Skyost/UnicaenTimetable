
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/theme.dart';

/// A drawer section title.
class DrawerSectionTitle extends ConsumerWidget {
  /// The title string key.
  final String titleKey;

  /// Creates a new drawer section title instance.
  const DrawerSectionTitle({
    super.key,
    required this.titleKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UnicaenTimetableTheme theme = ref.watch(settingsModelProvider).resolveTheme(context);
    return ListTile(
      title: Text(
        context.getString('scaffold.drawer.$titleKey'),
        style: TextStyle(color: theme.listHeaderTextColor),
      ),
      enabled: false,
    );
  }
}
