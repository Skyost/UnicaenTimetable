import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

/// A page with a title and an icon, can be added to a drawer.
abstract class Page extends StatefulWidget {
  /// The icon.
  final IconData icon;

  /// Creates a new page instance.
  const Page({
    @required this.icon,
  });

  /// Returns whether the given page is the same as this one.
  bool isSamePage(Page other) => identical(this, other) || (runtimeType == other.runtimeType && icon == other.icon);

  /// Builds the page title.
  String buildTitle(BuildContext context);

  /// Builds the page actions.
  List<Widget> buildActions(BuildContext context) => [];
}

/// A page with a static title.
abstract class StaticTitlePage extends Page {
  /// The title key.
  final String titleKey;

  /// Creates a new static title page instance.
  const StaticTitlePage({
    @required IconData icon,
    @required this.titleKey,
  }) : super(icon: icon);

  @override
  String buildTitle(BuildContext context) => context.getString(titleKey);

  @override
  bool isSamePage(Page other) => super.isSamePage(other) && other is StaticTitlePage && titleKey == other.titleKey;
}
