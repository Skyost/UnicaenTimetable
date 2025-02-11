import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/pages/page.dart';

/// Allows to show a page in the drawer (with its icon and its title).
class PageListTitle extends ConsumerWidget {
  /// The page.
  final Page page;

  /// The icon.
  final IconData? icon;

  /// The title.
  final String title;

  /// Creates a new page list title instance.
  const PageListTitle({
    super.key,
    required this.page,
    this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Page? currentPage = ref.watch(pageProvider).valueOrNull;
    return ListTile(
      selected: currentPage?.isSamePage(page) == true,
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        ref.read(pageProvider.notifier).changePage(page);
      },
    );
  }
}
