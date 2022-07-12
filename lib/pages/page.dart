import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/pages/about.dart';
import 'package:unicaen_timetable/pages/bugs_improvements.dart';
import 'package:unicaen_timetable/pages/day_view.dart';
import 'package:unicaen_timetable/pages/home.dart';
import 'package:unicaen_timetable/pages/settings.dart';
import 'package:unicaen_timetable/pages/week_view.dart';

/// A page with a title and an icon, can be added to a drawer.
abstract class Page extends ConsumerWidget {
  /// The page identifier.
  final String pageId;

  /// The icon.
  final IconData? icon;

  /// Creates a new page instance.
  const Page({
    super.key,
    required this.pageId,
    this.icon,
  });

  /// Creates a page instance from the specified identifier.
  static Page createFromId(String id) {
    switch (id) {
      case WeekViewPage.id:
        return const WeekViewPage();
      case MondayPage.id:
        return MondayPage();
      case TuesdayPage.id:
        return TuesdayPage();
      case WednesdayPage.id:
        return WednesdayPage();
      case ThursdayPage.id:
        return ThursdayPage();
      case FridayPage.id:
        return FridayPage();
      case SaturdayPage.id:
        return SaturdayPage();
      case SundayPage.id:
        return SundayPage();
      case BugsImprovementsPage.id:
        return const BugsImprovementsPage();
      case SettingsPage.id:
        return const SettingsPage();
      case AboutPage.id:
        return const AboutPage();
      case HomePage.id:
      default:
        return const HomePage();
    }
  }

  /// Returns whether the given page is the same as this one.
  bool isSamePage(Page other) => other.pageId == pageId;

  /// Builds the page title.
  String buildTitle(BuildContext context) => context.getString('$pageId.title');

  /// Builds the page actions.
  List<Widget> buildActions(BuildContext context, WidgetRef ref) => [];
}
