import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/utils/progress_dialog.dart';

/// The user login dialog.
class LoginDialog extends StatefulWidget {
  /// Whether the timetable should be synchronized after login.
  final bool synchronizeAfterLogin;

  /// Creates a new login dialog instance.
  const LoginDialog({
    required this.synchronizeAfterLogin,
  });

  @override
  State<StatefulWidget> createState() => _LoginDialogState();

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
class _LoginDialogState extends State<LoginDialog> {
  /// The current form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// The current focus node.
  FocusNode focusNode = FocusNode();

  /// The username text controller.
  late TextEditingController usernameController;

  /// The password text controller.
  late TextEditingController passwordController;

  /// The current login result.
  LoginResult? loginResult;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    passwordController = TextEditingController();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      User? user = await context.read<UserRepository>().getUser();
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

    if (loginResult != null) {
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
          onPressed: () => Navigator.pop(context, false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => onLoginButtonPressed(context),
          child: Text(context.getString('dialogs.login.login').toUpperCase()),
        ),
      ],
    );
  }

  /// Creates the error message widget.
  Widget createErrorMessage() => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          context.getString('dialogs.login.errors.${loginResult.toString().toLowerCase()}'),
          style: TextStyle(color: Colors.red[700]),
        ),
      );

  /// Triggered when the login button has been pressed.
  void onLoginButtonPressed(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    unawaited(ProgressDialog.show(context));

    SettingsModel settingsModel = context.read<SettingsModel>();
    UserRepository userRepository = context.read<UserRepository>();

    User user = User(username: usernameController.text.trim(), password: passwordController.text.trim());
    if (await userRepository.isTestUser(user)) {
      user = TestUser(user);
    }

    LoginResult loginResult = await user.login(settingsModel);

    if (loginResult != LoginResult.SUCCESS) {
      Navigator.pop(context);
      setState(() => this.loginResult = loginResult);
      return;
    }

    await userRepository.updateUser(user);
    Navigator.pop(context);
    Navigator.pop(context, true);

    if (widget.synchronizeAfterLogin) {
      unawaited(context.read<LessonModel>().synchronizeFromZimbra(
        settingsModel: settingsModel,
        user: user,
      ));
    }
  }
}
