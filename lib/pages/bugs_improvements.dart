import 'dart:math' as math;

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A page that allows the user to contact me in case of any bug occurred / improvements needed.
class BugsImprovementsPage extends StaticTitlePage {
  /// Creates a new bugs / improvements page instance.
  const BugsImprovementsPage()
      : super(
          titleKey: 'bugs_improvements.title',
          icon: Icons.bug_report,
        );

  @override
  State<StatefulWidget> createState() => _BugsImprovementsPageState();
}

/// The bugs / improvements page state.
class _BugsImprovementsPageState extends State<BugsImprovementsPage> {
  @override
  Widget build(BuildContext context) {
    UnicaenTimetableTheme theme = Provider.of<SettingsModel>(context).theme;
    return Center(
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
            createTextWidgetWithLink(theme, 'github', 'https://github.com/Skyost/UnicaenTimetable/issues/'),
            createTextWidgetWithLink(theme, 'website', 'https://www.skyost.eu/#contact'),
          ],
        ),
      ),
    );
  }

  /// Creates a paragraph with an end link "here".
  Widget createTextWidgetWithLink(UnicaenTimetableTheme theme, String textKey, String link) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: context.getString('bugs_improvements.message.${textKey}') + ' ',
            ),
            TextSpan(
              text: context.getString('other.here'),
              style: TextStyle(
                color: Colors.blue[800],
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => Utils.openUrl(link),
            ),
            const TextSpan(text: '.'),
          ],
          style: TextStyle(color: theme.textColor ?? Colors.black),
        ),
      );
}
