import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/user/user.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';

/// Allows to configure the user account.
class SwitchAccountSettingsEntryWidget extends ConsumerWidget {
  /// Creates a new account settings entry widget instance.
  const SwitchAccountSettingsEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<User?> user = ref.watch(userProvider);
    return ListTile(
      enabled: user.hasValue,
      title: Text(translations.settings.account.kSwitch),
      onTap: () async => await LoginDialog.show(context, synchronizeAfterLogin: true),
    );
  }
}
