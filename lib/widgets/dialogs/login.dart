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

  /// The current focus node.
  FocusNode focusNode = FocusNode();

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

  /// The password text controller.

  /// Whether a login has been requested.
  bool waiting = false;

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
                      validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                      controller: usernameController,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(focusNode),
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
                      validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                      controller: passwordController,
                      textInputAction: moreSettings ? TextInputAction.next : TextInputAction.done,
                      focusNode: focusNode,
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
                          validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                          controller: serverAddressController,
                          textInputAction: TextInputAction.next,
                          focusNode: focusNode,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(translations.dialogs.login.moreSettings.calendarName),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(hintText: kDefaultCalendarName),
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          validator: (value) => value == null || value.isEmpty ? translations.common.other.fieldEmpty : null,
                          controller: calendarNameController,
                          textInputAction: TextInputAction.next,
                          focusNode: focusNode,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(translations.dialogs.login.moreSettings.additionalParameters),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(hintText: kDefaultAdditionalParameters),
                          autocorrect: false,
                          keyboardType: TextInputType.url,
                          controller: additionalParametersController,
                          textInputAction: TextInputAction.done,
                          focusNode: focusNode,
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
                  onPressed: () => onLoginButtonPressed(context),
                  child: Text(translations.dialogs.login.login),
                ),
              ],
      );

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
  void onLoginButtonPressed(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => waiting = true);

    await ref.read(serverSettingsEntryProvider.notifier).changeValue(serverAddressController.text);
    await ref.read(calendarNameSettingsEntryProvider.notifier).changeValue(calendarNameController.text);
    await ref.read(additionalParametersSettingsEntryProvider.notifier).changeValue(additionalParametersController.text);

    User user = User(username: usernameController.text.trim(), password: passwordController.text.trim());
    Calendar? calendar = await ref.read(userCalendarProvider(user).future);
    int result = (await calendar?.get()) ?? HttpStatus.networkConnectTimeoutError;
    setState(() => loginHttpResponseCode = result);

    if (result is RequestSuccess) {
      await ref.read(userProvider.notifier).updateUser(user);
      if (widget.synchronizeAfterLogin) {
        downloadLessons(ref);
      }
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
