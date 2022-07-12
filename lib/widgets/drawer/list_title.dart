import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/theme.dart';

/// Allows to show a page in the drawer (with its icon and its title).
class PageListTitle extends ConsumerWidget {
  /// The page.
  final Page page;

  /// Creates a new page list title instance.
  const PageListTitle({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UnicaenTimetableTheme theme = ref.watch(settingsModelProvider).resolveTheme(context);
    ValueNotifier<String> currentPage = ref.watch(currentPageProvider);
    bool isCurrentPage = page.isSamePage(Page.createFromId(currentPage.value));
    return Material(
      color: isCurrentPage ? Colors.black12 : theme.scaffoldBackgroundColor,
      child: ListTile(
        selected: isCurrentPage,
        leading: Icon(page.icon),
        title: Text(page.buildTitle(context)),
        onTap: () {
          Navigator.pop(context);
          if (isCurrentPage) {
            return;
          }

          currentPage.value = page.pageId;
        },
      ),
    );
  }
}
