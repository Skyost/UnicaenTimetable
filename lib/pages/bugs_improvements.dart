import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';
import 'package:unicaen_timetable/widgets/list_page.dart';

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
class BugsImprovementsPageWidget extends StatefulWidget {
  /// Creates a new bugs / improvements page instance.
  const BugsImprovementsPageWidget({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _BugsImprovementsPageWidgetState();
}

/// The bugs / improvements page widget state.
class _BugsImprovementsPageWidgetState extends State<BugsImprovementsPageWidget> {
  /// The issue tracker recognizer.
  late final TapGestureRecognizer issueTrackerRecognizer = TapGestureRecognizer()..onTap = () => Utils.openUrl('https://github.com/Skyost/UnicaenTimetable/issues/');

  /// The contact form recognizer.
  late final TapGestureRecognizer contactFormRecognizer = TapGestureRecognizer()..onTap = () => Utils.openUrl('https://skyost.eu/#contact');

  @override
  Widget build(BuildContext context) => ListPageWidget(
        header: ListPageHeader(
          icon: Icon(
            Icons.bug_report,
            size: math.min(100, MediaQuery.of(context).size.width),
            color: Colors.white,
          ),
          title: Text(
            translations.bugsImprovements.title,
          ),
        ),
        body: ListPageBody(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  translations.bugsImprovements.message.github(
                    issueTracker: (text) => TextSpan(
                      text: text,
                      recognizer: issueTrackerRecognizer,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  translations.bugsImprovements.message.website(
                    contactForm: (text) => TextSpan(
                      text: text,
                      recognizer: contactFormRecognizer,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    issueTrackerRecognizer.dispose();
    super.dispose();
  }
}
