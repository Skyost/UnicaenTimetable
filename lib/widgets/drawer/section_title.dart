import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A drawer section title.
class DrawerSectionTitle extends ConsumerWidget {
  /// The title string key.
  final String title;

  /// Creates a new drawer section title instance.
  const DrawerSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        title: Text(
          title,
        ),
        enabled: false,
      );
}
