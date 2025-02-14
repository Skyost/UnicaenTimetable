import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/settings/entries/calendar_additional_parameters.dart';
import 'package:unicaen_timetable/pages/settings/entries/calendar_interval.dart';
import 'package:unicaen_timetable/pages/settings/entries/calendar_name.dart';
import 'package:unicaen_timetable/pages/settings/entries/calendar_server.dart';
import 'package:unicaen_timetable/pages/settings/entries/color_lessons_automatically.dart';
import 'package:unicaen_timetable/pages/settings/entries/open_today_automatically.dart';
import 'package:unicaen_timetable/pages/settings/entries/sidebar_days.dart';
import 'package:unicaen_timetable/pages/settings/entries/switch_account.dart';
import 'package:unicaen_timetable/pages/settings/entries/sync_with_device_calendar.dart';
import 'package:unicaen_timetable/pages/settings/entries/theme.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';

/// The home page list tile.
class SettingsPageListTile extends StatelessWidget {
  /// Creates a new home page list tile.
  const SettingsPageListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PageListTitle(
    page: SettingsPage(),
    title: translations.settings.title,
    icon: Icons.settings,
  );
}

/// The settings page app bar.
class SettingsPageAppBar extends StatelessWidget {
  /// Creates a new settings page app bar.
  const SettingsPageAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(translations.settings.title),
  );
}

/// The settings page.
class SettingsPageWidget extends ConsumerWidget {
  /// The page identifier.
  static const String id = 'settings';

  /// Creates a new settings page instance.
  const SettingsPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Theme(
        data: Theme.of(context).copyWith(
          buttonTheme: const ButtonThemeData(
            alignedDropdown: false,
          ),
        ),
        child: ListView(
          children: [
            _SettingsPageSectionTitle(
              icon: Icons.phone_android,
              title: translations.settings.application.title,
            ),
            SyncWithDeviceCalendarSettingsEntryWidget(),
            const ThemeSettingsEntryWidget(),
            const SidebarDaysEntryWidget(),
            ColorLessonsAutomaticallySettingsEntryWidget(),
            OpenTodayAutomaticallySettingsEntryWidget(),
            _SettingsPageSectionTitle(
              icon: Icons.person,
              title: translations.settings.account.title,
            ),
            const SwitchAccountSettingsEntryWidget(),
            _SettingsPageSectionTitle(
              icon: Icons.wifi,
              title: translations.settings.calendar.title,
            ),
            CalendarIntervalSettingsEntryWidget(),
            CalendarServerSettingsEntryWidget(),
            CalendarNameSettingsEntryWidget(),
            CalendarAdditionalParametersSettingsEntryWidget(),
          ],
        ),
      );
}

/// A settings section title.
class _SettingsPageSectionTitle extends StatelessWidget {
  /// The icon.
  final IconData? icon;

  /// The title.
  final String title;

  /// Creates a new settings page section title instance.
  const _SettingsPageSectionTitle({
    this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: icon == null ? null : Icon(icon),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
}
