import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';

/// The page that allows to configure the app.
class SettingsPage extends StaticTitlePage {
  /// Creates a new settings page instance.
  const SettingsPage()
      : super(
          titleKey: 'settings.title',
          icon: Icons.settings,
        );

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

/// The settings page state.
class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Consumer<SettingsModel>(
        builder: (context, settings, child) => ListView.builder(
          itemCount: settings.categories.length,
          itemBuilder: (context, position) => settings.categories[position].render(context),
        ),
      );
}
