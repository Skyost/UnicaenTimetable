import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/authentication/state.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/test.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/utils/progress_dialog.dart';

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
  late TextEditingController usernameController;

  /// The password text controller.
  late TextEditingController passwordController;

  /// The current login result state.
  RequestResultState? loginResultState;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      User? user = await ref.read(userRepositoryProvider).getUser();
      if (user != null) {
        setState(() {
          usernameController.text = user.username;
          passwordController.text = user.password;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text(context.getString('dialogs.login.username')),
      TextFormField(
        decoration: InputDecoration(hintText: context.getString('dialogs.login.username_hint')),
        autocorrect: false,
        validator: (value) => value == null || value.isEmpty ? context.getString('other.field_empty') : null,
        controller: usernameController,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(focusNode),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(context.getString('dialogs.login.password')),
      ),
      TextFormField(
        decoration: InputDecoration(hintText: context.getString('dialogs.login.password_hint')),
        autocorrect: false,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) => value == null || value.isEmpty ? context.getString('other.field_empty') : null,
        controller: passwordController,
        textInputAction: TextInputAction.done,
        focusNode: focusNode,
      ),
    ];

    if (loginResultState != null) {
      children.add(createErrorMessage());
    }

    return AlertDialog(
      title: Text(context.getString('dialogs.login.title')),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => onLoginButtonPressed(context),
          child: Text(context.getString('dialogs.login.login').toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
        ),
      ],
    );
  }

  /// Creates the error message widget.
  Widget createErrorMessage() => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          context.getString('dialogs.login.errors.${loginResultState!.id}'),
          style: TextStyle(color: Colors.red[700]),
        ),
      );

  /// Triggered when the login button has been pressed.
  void onLoginButtonPressed(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    ProgressDialog.show(context);

    SettingsModel settingsModel = ref.read(settingsModelProvider);
    UserRepository userRepository = ref.read(userRepositoryProvider);

    User user = User(username: usernameController.text.trim(), password: passwordController.text.trim());
    if (await userRepository.isTestUser(user)) {
      user = TestUser(user);
    }

    RequestResultState loginResultState = await user.login(settingsModel.calendarUrl);

    if (loginResultState != RequestResultState.success) {
      if (mounted) {
        Navigator.pop(context);
        setState(() => this.loginResultState = loginResultState);
      }
      return;
    }

    await userRepository.updateUser(user);
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }

    if (widget.synchronizeAfterLogin) {
      ref.read(lessonRepositoryProvider).downloadLessons(
        calendarUrl: settingsModel.calendarUrl,
        user: user,
      );
    }
  }
}
