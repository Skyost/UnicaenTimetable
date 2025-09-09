import 'dart:io';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/user/calendar.dart';
import 'package:unicaen_timetable/model/user/user.dart';
import 'package:unicaen_timetable/widgets/centered_circular_progress_indicator.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';

/// Allows to ensure that the user is logged in.
class EnsureLoggedInWidget extends ConsumerStatefulWidget {
  /// The child widget.
  final Widget child;

  /// Creates a new ensure logged in widget instance.
  const EnsureLoggedInWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EnsureLoggedInWidgetState();
}

class _EnsureLoggedInWidgetState extends ConsumerState<EnsureLoggedInWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Calendar? calendar = await ref.read(calendarProvider.future);
      if (calendar == null) {
        if (mounted) {
          await Navigator.pushReplacementNamed(context, '/intro');
        }
        return;
      }
      int response = await calendar.get();
      if (response == HttpStatus.unauthorized && mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(translations.dialogs.unauthorized.title),
            content: SingleChildScrollView(
              child: Text(translations.dialogs.unauthorized.message),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  LoginDialog.show(context);
                },
                child: Text(translations.dialogs.unauthorized.buttonLogin),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<User?> user = ref.watch(userProvider);
    return user.hasValue ? widget.child : const _WaitScaffold();
  }
}

/// A scaffold that allows the user to wait.
class _WaitScaffold extends StatelessWidget {
  /// The wait message.
  final String? message;

  /// Creates a new wait scaffold instance.
  const _WaitScaffold({
    this.message,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CenteredCircularProgressIndicator(
      message: message ?? translations.common.other.pleaseWait,
    ),
  );
}
