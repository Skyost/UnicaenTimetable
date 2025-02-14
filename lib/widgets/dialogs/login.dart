import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/calendar.dart';
import 'package:unicaen_timetable/model/user/calendar.dart';
import 'package:unicaen_timetable/model/user/user.dart';
import 'package:unicaen_timetable/utils/lesson_download.dart';
import 'package:unicaen_timetable/utils/widgets.dart';

/// The user login dialog.
class LoginDialog extends ConsumerStatefulWidget {
  /// Whether the timetable should be synchronized after login.
  final bool synchronizeAfterLogin;

  /// Creates a new login dialog instance.
  const LoginDialog({
    super.key,
    required this.synchronizeAfterLogin,
  });

  @override
  ConsumerState createState() => _LoginDialogState();

  /// Shows the login dialog and returns the result.
  static Future<bool> show(BuildContext context, {bool synchronizeAfterLogin = false}) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginDialog(synchronizeAfterLogin: synchronizeAfterLogin),
    );
    return result ?? false;
  }
}

/// The login dialog state.
class _LoginDialogState extends ConsumerState<LoginDialog> {
  /// The current form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// The username text controller.
  late TextEditingController usernameController = TextEditingController();

  /// The password text controller.
  late TextEditingController passwordController = TextEditingController();

  /// The server text controller.
  late TextEditingController serverAddressController = TextEditingController();

  /// The calendar name text controller.
  late TextEditingController calendarNameController = TextEditingController();

  /// The additional parameters text controller.
  late TextEditingController additionalParametersController = TextEditingController();

  /// Whether a login has been requested.
  bool waiting = false;

  /// Whether the login button is enabled.
  bool canLogin = false;

  /// Whether to display more settings.
  bool moreSettings = false;

  /// The current login result.
  int? loginHttpResponseCode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      User? user = await ref.read(userProvider.future);
      if (user != null) {
        setState(() {
          usernameController.text = user.username;
          passwordController.text = user.password;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(translations.dialogs.login.title),
        content: waiting
            ? const CenteredCircularProgressIndicator()
            : Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translations.dialogs.login.username),
                    TextFormField(
                      decoration: InputDecoration(hintText: translations.dialogs.login.usernameHint),
                      autocorrect: false,
                      onChanged: refreshLogin,
                      validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                      controller: usernameController,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autofocus: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(translations.dialogs.login.password),
                    ),
                    TextFormField(
                      decoration: InputDecoration(hintText: translations.dialogs.login.passwordHint),
                      autocorrect: false,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: refreshLogin,
                      validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                      controller: passwordController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: moreSettings ? TextInputAction.next : TextInputAction.done,
                    ),
                    if (loginHttpResponseCode != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          switch (loginHttpResponseCode) {
                            HttpStatus.notFound => translations.dialogs.login.errors.notFound,
                            HttpStatus.unauthorized => translations.dialogs.login.errors.unauthorized,
                            _ => translations.dialogs.login.errors.genericError,
                          },
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    if (moreSettings)
                      ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(translations.dialogs.login.moreSettings.server),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(hintText: kDefaultServer),
                          autocorrect: false,
                          keyboardType: TextInputType.url,
                          onChanged: refreshLogin,
                          validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                          controller: serverAddressController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(translations.dialogs.login.moreSettings.calendarName),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(hintText: kDefaultCalendarName),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          onChanged: refreshLogin,
                          validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                          controller: calendarNameController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(translations.dialogs.login.moreSettings.additionalParameters),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(hintText: kDefaultAdditionalParameters),
                          autocorrect: false,
                          onChanged: refreshLogin,
                          keyboardType: TextInputType.url,
                          controller: additionalParametersController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                  ],
                ),
              ),
        scrollable: true,
        actions: waiting
            ? []
            : [
                if (loginHttpResponseCode != null && !moreSettings)
                  TextButton(
                    onPressed: () {
                      setState(() => moreSettings = true);
                    },
                    child: Text(translations.dialogs.login.moreSettings.button),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                TextButton(
                  onPressed: canLogin ? (onLoginButtonPressed) : null,
                  child: Text(translations.dialogs.login.login),
                ),
              ],
      );

  /// Refreshes whether the login button is enabled.
  void refreshLogin(String? _) => setState(() => canLogin = formKey.currentState?.validate() == true);

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    serverAddressController.dispose();
    calendarNameController.dispose();
    additionalParametersController.dispose();
    super.dispose();
  }

  /// Triggered when the login button has been pressed.
  void onLoginButtonPressed() async {
    if (!canLogin) {
      return;
    }

    setState(() => waiting = true);

    if (moreSettings) {
      if (serverAddressController.text.isNotEmpty) {
        await ref.read(serverSettingsEntryProvider.notifier).changeValue(serverAddressController.text);
      }
      if (calendarNameController.text.isNotEmpty) {
        await ref.read(calendarNameSettingsEntryProvider.notifier).changeValue(calendarNameController.text);
      }
      await ref.read(additionalParametersSettingsEntryProvider.notifier).changeValue(additionalParametersController.text);
    }

    User user = User(username: usernameController.text.trim(), password: passwordController.text.trim());
    Calendar? calendar = await ref.read(userCalendarProvider(user).future);
    int result = (await calendar?.get()) ?? HttpStatus.networkConnectTimeoutError;

    if (result == HttpStatus.ok) {
      await ref.read(userProvider.notifier).updateUser(user);
      if (widget.synchronizeAfterLogin) {
        downloadLessons(ref);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        loginHttpResponseCode = result;
        waiting = false;
      });
    }
  }
}
