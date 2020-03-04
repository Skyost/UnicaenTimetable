import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// A progress dialog.
class ProgressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () => Future.value(false),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 30),
          child: CircularProgressIndicator(),
        ),
        Text(EzLocalization.of(context).get('other.please_wait')),
      ],
    ),
  );

  /// Shows the progress dialog.
  static Future<void> show(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: ProgressDialog(),
    ),
    barrierDismissible: false,
  );
}