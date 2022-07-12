import 'dart:math' as math;

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:unicaen_timetable/pages/page.dart';

/// A page that allows the user to contact me in case of any bug occurred / improvements needed.
class BugsImprovementsPage extends Page {
  /// The page identifier.
  static const String id = 'bugs_improvements';

  /// Creates a new bugs / improvements page instance.
  const BugsImprovementsPage({
    super.key,
  }) : super(
          pageId: id,
          icon: Icons.bug_report,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
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
              HtmlWidget(context.getString('bugs_improvements.message.github')),
              HtmlWidget(context.getString('bugs_improvements.message.website')),
            ],
          ),
        ),
      );
}
