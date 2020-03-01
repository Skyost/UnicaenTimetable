import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/user.dart';
import 'package:unicaen_timetable/utils/utils.dart';

class LoginDialog extends StatefulWidget {
  final bool synchronizeAfterLogin;

  const LoginDialog({
    @required this.synchronizeAfterLogin,
  });

  @override
  State<StatefulWidget> createState() => _LoginDialogState();

  static Future<bool> show(BuildContext context, {bool synchronizeAfterLogin = false}) => showDialog(
        context: context,
        builder: (_) => LoginDialog(synchronizeAfterLogin: synchronizeAfterLogin),
      );
}

class _LoginDialogState extends State<LoginDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();

  TextEditingController usernameController;
  TextEditingController passwordController;

  LoginResult loginResult;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      User user = await Provider.of<UserRepository>(context, listen: false).get();
      if (user != null) {
        usernameController.text = user.username;
        passwordController.text = user.password;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text(EzLocalization.of(context).get('dialogs.login.username')),
      TextFormField(
        decoration: InputDecoration(hintText: EzLocalization.of(context).get('dialogs.login.username_hint')),
        autocorrect: false,
        validator: (value) => value == null || value.isEmpty ? EzLocalization.of(context).get('other.field_empty') : null,
        controller: usernameController,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(focusNode),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(EzLocalization.of(context).get('dialogs.login.password')),
      ),
      TextFormField(
        decoration: InputDecoration(hintText: EzLocalization.of(context).get('dialogs.login.password_hint')),
        autocorrect: false,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) => value == null || value.isEmpty ? EzLocalization.of(context).get('other.field_empty') : null,
        controller: passwordController,
        textInputAction: TextInputAction.done,
        focusNode: focusNode,
      ),
    ];

    if (loginResult != null) {
      children.add(createErrorMessage());
    }

    return AlertDialog(
      title: Text(EzLocalization.of(context).get('dialogs.login.title')),
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
        FlatButton(
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
          onPressed: () => Navigator.pop(context, false),
        ),
        FlatButton(
          child: Text(EzLocalization.of(context).get('dialogs.login.login').toUpperCase()),
          onPressed: () async {
            if (!formKey.currentState.validate()) {
              return;
            }

            unawaited(ProgressDialog.show(context));

            SettingsModel settingsModel = Provider.of<SettingsModel>(context, listen: false);
            User user = User(username: usernameController.text.trim(), password: passwordController.text.trim());
            LoginResult loginResult = await user.login(settingsModel);

            if (loginResult != LoginResult.SUCCESS) {
              await Navigator.pop(context);
              setState(() => this.loginResult = loginResult);
              return;
            }

            UserRepository userRepository = Provider.of<UserRepository>(context, listen: false);
            await userRepository.update(user);
            await Navigator.pop(context);
            Navigator.pop(context, true);

            if (widget.synchronizeAfterLogin) {
              unawaited(Provider.of<LessonModel>(context, listen: false).synchronizeFromZimbra(
                settingsModel: settingsModel,
                user: user,
              ));
            }
          },
        ),
      ],
    );
  }

  Widget createErrorMessage() => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          EzLocalization.of(context).get('dialogs.login.errors.${loginResult.toString().toLowerCase()}'),
          style: TextStyle(color: Colors.red[700]),
        ),
      );
}
