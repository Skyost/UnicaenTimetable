import 'dart:math' as math;

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';

/// The bugs / improvements page list tile.
class BugsImprovementsPageListTile extends StatelessWidget {
  /// Creates a new bugs / improvements page list tile.
  const BugsImprovementsPageListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PageListTitle(
        page: BugsImprovementsPage(),
        title: translations.bugsImprovements.title,
        icon: Icons.bug_report,
      );
}

/// The bugs / improvements page app bar.
class BugsImprovementsPageAppBar extends StatelessWidget {
  /// Creates a new about page app bar.
  const BugsImprovementsPageAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(translations.about.title),
      );
}

/// The bugs / improvements page widget.
class BugsImprovementsPageWidget extends StatelessWidget {
  /// Creates a new bugs / improvements page instance.
  const BugsImprovementsPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(
                  Icons.bug_report,
                  size: math.min(100, MediaQuery.of(context).size.width),
                  color: Colors.red[400],
                ),
              ),
              HtmlWidget(translations.bugsImprovements.message.github),
              HtmlWidget(translations.bugsImprovements.message.website),
            ],
          ),
        ),
      );
}
