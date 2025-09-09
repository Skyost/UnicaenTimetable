import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/user/calendar.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';

/// Downloads the user lessons and displays the result.
Future<void> downloadLessons(WidgetRef ref) async {
  Utils.showSnackBar(
    context: ref.context,
    icon: Icons.sync,
    text: translations.scaffold.snackBar.synchronizing,
    color: Theme.of(ref.context).primaryColor,
  );
  RequestResult result = await ref.read(lessonRepositoryProvider.notifier).refreshLessons();
  if (ref.context.mounted) {
    result.handle(ref.context);
  }
}

/// Allows to display the download result in a SnackBar and open required dialogs as well.
extension DisplayLessonDownloadResult on RequestResult {
  /// Handles the current result.
  Future<void> handle(BuildContext context) async {
    await showSnackBar(context);
    if (context.mounted) {
      await openDialogs(context);
    }
  }

  /// Displays a SnackBar for the current result.
  Future<void> showSnackBar(BuildContext context) async {
    switch (this) {
      case RequestSuccess():
        await Utils.showSnackBar(
          context: context,
          icon: Icons.check,
          text: translations.scaffold.snackBar.success,
          color: Colors.green.shade700,
        );
        break;
      case RequestError(:final httpCode):
        switch (httpCode) {
          case HttpStatus.unauthorized:
            await Utils.showSnackBar(
              context: context,
              icon: Icons.error_outline,
              text: translations.scaffold.snackBar.unauthorized,
              color: Colors.amber.shade800,
            );
            break;
          default:
            await Utils.showSnackBar(
              context: context,
              icon: Icons.error_outline,
              text: translations.scaffold.snackBar.genericError,
              color: Colors.red.shade800,
            );
            break;
        }
        break;
    }
  }

  /// Opens the required dialogs.
  Future<void> openDialogs(BuildContext context) async {
    if (this is RequestError) {
      switch ((this as RequestError).httpCode) {
        case HttpStatus.notFound:
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(translations.dialogs.calendarNotFound.title),
              content: Text(translations.dialogs.calendarNotFound.message),
              scrollable: true,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                ),
              ],
            ),
          );
          break;
        case HttpStatus.unauthorized:
          await LoginDialog.show(context);
          break;
      }
    }
  }
}
