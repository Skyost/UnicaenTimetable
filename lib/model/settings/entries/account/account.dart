import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/pages/scaffold.dart';

/// The account settings entry that defines the current account.
class AccountSettingsEntry extends SettingsEntry {
  /// Creates a new app account settings entry instance.
  AccountSettingsEntry({
    required String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
          key: 'account',
          value: null,
          mutable: false,
        );

  @override
  Widget render(BuildContext context) => _AccountSettingsEntryWidget(entry: this);
}

/// Allows to display the account settings entry.
class _AccountSettingsEntryWidget extends SettingsEntryWidget {
  /// Creates a new account settings entry widget instance.
  const _AccountSettingsEntryWidget({
    required AccountSettingsEntry entry,
  }) : super(entry: entry);

  @override
  Widget createSubtitle(BuildContext context) {
    UserRepository userRepository = context.watch<UserRepository>();
    Future<User?> user = userRepository.getUser();
    return FutureProvider<User?>.value(
      initialData: null,
      value: user,
      child: Consumer<User?>(
        builder: (context, user, widget) => user == null ? const SizedBox.shrink() : Text(user.usernameWithoutAt),
      ),
    );
  }

  @override
  Future<void> afterOnTap(BuildContext context) async {
    bool result = await LoginDialog.show(context);
    if (result) {
      unawaited(SynchronizeFloatingButton.onPressed(context));
    }
  }
}
