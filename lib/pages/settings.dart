import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/input.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/scaffold.dart';

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
          itemBuilder: (context, position) => _SettingsCategoryWidget(category: settings.categories[position]),
        ),
      );
}

/// A widget that shows a settings category.
class _SettingsCategoryWidget extends StatelessWidget {
  /// The settings category.
  final SettingsCategory category;

  /// Creates a new settings category widget.
  const _SettingsCategoryWidget({
    @required this.category,
  });

  @override
  Widget build(BuildContext context) {
    UnicaenTimetableTheme theme = Provider.of<SettingsModel>(context).theme;
    return Column(
      children: [
        ListTile(
          leading: Icon(category.icon, color: theme.listHeaderTextColor),
          title: Text(
            EzLocalization.of(context).get('settings.${category.key}.title'),
            style: TextStyle(color: theme.listHeaderTextColor),
          ),
          enabled: false,
        ),
        for (int i = 0; i < category.entries.length; i++) //
          if (category.entries[i].enabled)
            _SettingsEntryWidget(entry: category.entries[i]),
      ],
    );
  }
}

/// A widget that shows a settings entry.
class _SettingsEntryWidget extends StatelessWidget {
  /// The settings entry.
  final SettingsEntry entry;

  /// Creates a new settings entry widget instance.
  const _SettingsEntryWidget({
    @required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    if (entry.key == 'application.lessons_ringer_mode') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          title: Text(EzLocalization.of(context).get('settings.${entry.key}')),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: DropdownButton(
              isExpanded: true,
              onChanged: (value) async {
                bool result = await UnicaenTimetableApp.CHANNEL.invokeMethod('activity.ringer_mode_changed', {'value': value});
                if (result) {
                  entry.value = value;
                  await entry.flush();
                }
              },
              items: [
                DropdownMenuItem<int>(
                  child: Text(EzLocalization.of(context).get('other.ringer_mode.disabled')),
                  value: -1,
                ),
                DropdownMenuItem<int>(
                  child: Text(EzLocalization.of(context).get('other.ringer_mode.silent')),
                  value: 0,
                ),
                DropdownMenuItem<int>(
                  child: Text(EzLocalization.of(context).get('other.ringer_mode.vibrate')),
                  value: 1,
                ),
              ],
              value: entry.value,
            ),
          ),
        ),
      );
    }

    return ListTile(
      onTap: () => onTap(context),
      title: Text(EzLocalization.of(context).get('settings.${entry.key}')),
      subtitle: createSubtitle(context),
      trailing: createController(context),
    );
  }

  /// Creates the subtitle widget.
  Widget createSubtitle(BuildContext context) {
    if (entry.value is String) {
      return Text(entry.value == null || entry.value.isEmpty ? EzLocalization.of(context).get('other.empty') : entry.value);
    }

    if (entry.key == 'account.account') {
      UserRepository userRepository = Provider.of<UserRepository>(context);
      Future<User> user = userRepository.getUser();
      return FutureProvider<User>.value(
        value: user,
        child: Consumer<User>(
          builder: (context, user, widget) => user == null ? const SizedBox.shrink() : Text(user.usernameWithoutAt),
        ),
      );
    }

    return null;
  }

  /// Creates the controller widget.
  Widget createController(BuildContext context) {
    if (entry.value is bool) {
      return Switch(
        value: entry.value,
        onChanged: (_) => onTap(context),
      );
    }

    if (entry.value is UnicaenTimetableTheme) {
      return Switch(
        value: entry.value is DarkTheme,
        onChanged: (_) => onTap(context),
      );
    }

    return null;
  }

  /// Triggered before running the "on tap" action.
  Future<bool> beforeOnTap(BuildContext context) async {
    switch (entry.key) {
      case 'application.enable_ads':
        bool result = await BoolInputDialog.getValue(
          context,
          titleKey: 'dialogs.enable_ads.title',
          messageKey: 'dialogs.enable_ads.message',
          yesButtonKey: 'dialogs.enable_ads.enable',
          noButtonKey: 'dialogs.enable_ads.disable',
        );
        return result != null && result != entry.value;
      default:
        return true;
    }
  }

  /// Triggered when the user has tapped the controller.
  Future<void> onTap(BuildContext context) async {
    bool result = await beforeOnTap(context);
    if (!result) {
      return;
    }

    if (entry.value is bool) {
      entry.value = !entry.value;
      unawaited(entry.flush());
    }

    if (entry.value is UnicaenTimetableTheme) {
      entry.value = entry.value.opposite;
      unawaited(entry.flush());
    }

    if (entry.value is String) {
      String value = await TextInputDialog.getValue(
        context,
        titleKey: 'settings.${entry.key}',
        initialValue: entry.value,
      );

      if (value == null || value == entry.value) {
        return;
      }

      entry.value = value;
      unawaited(entry.flush());
    }

    unawaited(afterOnTap(context));
  }

  /// Triggered after the user has tapped the controller.
  Future<void> afterOnTap(BuildContext context) async {
    switch (entry.key) {
      case 'account.account':
        bool result = await LoginDialog.show(context);
        if (result != null && result) {
          synchronize(context);
        }
        break;
      case 'server.interval':
        int value = await IntInputDialog.getValue(
          context,
          titleKey: 'settings.server.interval',
          initialValue: entry.value,
          min: 1,
          max: 52,
          divisions: 52,
        );

        if (value == null || value == entry.value) {
          break;
        }

        entry.value = value;
        unawaited(entry.flush());
        synchronize(context);
        break;
      case 'server.server':
      case 'server.calendar':
      case 'server.additional_parameters':
        synchronize(context);
        break;
    }
  }

  /// Synchronizes the app.
  void synchronize(BuildContext context) async {
    unawaited(SynchronizeFloatingButton.onPressed(context));
  }
}
