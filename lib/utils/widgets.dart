import 'package:flutter/material.dart';

/// A centered circular progress indicator.
class CenteredCircularProgressIndicator extends StatelessWidget {
  /// The wait message.
  final String? message;

  /// The progress indicator color.
  final Color? color;

  /// Creates a new centered circular progress indicator instance.
  const CenteredCircularProgressIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: CircularProgressIndicator(color: color ?? Theme.of(context).primaryColor),
              ),
              if (message != null) Text(message!),
            ],
          ),
        ),
      );
}
