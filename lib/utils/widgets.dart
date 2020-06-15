import 'package:flutter/material.dart';

/// A centered circular progress indicator.
class CenteredCircularProgressIndicator extends StatelessWidget {
  /// The progress indicator color.
  final Color color;

  /// Creates a new centered circular progress indicator instance.
  const CenteredCircularProgressIndicator({
    this.color,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(backgroundColor: color ?? Theme.of(context).primaryColor),
      );
}
