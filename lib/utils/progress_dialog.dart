import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// A progress dialog.
class ProgressDialog extends StatelessWidget {
  /// Creates a new progress dialog instance.
  const ProgressDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 30),
              child: CircularProgressIndicator(),
            ),
            Text(context.getString('other.please_wait')),
          ],
        ),
      );

  /// Shows the progress dialog.
  static Future<void> show(BuildContext context) => showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: ProgressDialog(),
        ),
        barrierDismissible: false,
      );
}
