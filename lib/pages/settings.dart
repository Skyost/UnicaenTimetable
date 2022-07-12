import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/widgets/settings/category.dart';

/// The page that allows to configure the app.
class SettingsPage extends Page {
  /// The page identifier.
  static const String id = 'settings';

  /// Creates a new settings page instance.
  const SettingsPage({
    super.key,
  }) : super(
          pageId: id,
          icon: Icons.settings,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SettingsModel settingsModel = ref.watch(settingsModelProvider);
    return ListView.builder(
      itemCount: settingsModel.categories.length,
      itemBuilder: (context, position) => SettingsCategoryWidget(category: settingsModel.categories[position]),
    );
  }
}
