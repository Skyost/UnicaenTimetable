import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/authentication/state.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/utils/widgets.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';

/// Allows to ensure that the user is logged in.
class EnsureLoggedInWidget extends StatelessWidget {
  /// The child widget.
  final Widget child;

  /// Creates a new ensure logged in widget instance.
  const EnsureLoggedInWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => WaitForModelsToLoadWidget(
    child: _RedirectIfNotLoggedInWidget(child: child),
  );
}

/// Allows to wait for models to load before showing the main widget.
class WaitForModelsToLoadWidget extends ConsumerWidget {
  /// The child widget.
  final Widget child;

  /// Creates a new widget that allows to wait for models to load.
  const WaitForModelsToLoadWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool lessonRepositoryIsInitialized = ref.watch(lessonRepositoryProvider.select((model) => model.isInitialized));
    bool userRepositoryIsInitialized = ref.watch(userRepositoryProvider.select((model) => model.isInitialized));
    bool settingsModelIsInitialized = ref.watch(settingsModelProvider.select((model) => model.isInitialized));
    return lessonRepositoryIsInitialized && userRepositoryIsInitialized && settingsModelIsInitialized
        ? child
        : const Scaffold(
      body: CenteredCircularProgressIndicator(color: Colors.white),
      backgroundColor: Colors.indigo,
    );
  }
}

/// Allows to redirect the user if he's not logged in.
class _RedirectIfNotLoggedInWidget extends ConsumerStatefulWidget {
  /// The child widget.
  final Widget child;

  /// Creates a new redirect if not logged in widget instance.
  const _RedirectIfNotLoggedInWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RedirectIfNotLoggedInWidgetState();
}

/// The redirect if not logged in widget state.
class _RedirectIfNotLoggedInWidgetState extends ConsumerState<_RedirectIfNotLoggedInWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserRepository userRepository = ref.read(userRepositoryProvider);
      User? user = await userRepository.getUser();
      if (user == null) {
        await Navigator.pushReplacementNamed(context, '/intro');
        return;
      }

      SettingsModel settingsModel = ref.read(settingsModelProvider);
      RequestResultState loginResult = await user.login(settingsModel.calendarUrl);
      if (loginResult == RequestResultState.unauthorized) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.getString('dialogs.unauthorized.title')),
            content: SingleChildScrollView(
              child: Text(context.getString('dialogs.unauthorized.message')),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  LoginDialog.show(context);
                },
                child: Text(context.getString('dialogs.unauthorized.button_login').toUpperCase()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel.toUpperCase()),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
