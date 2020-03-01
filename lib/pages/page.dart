import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

abstract class Page extends StatefulWidget {
  final IconData icon;

  const Page({
    @required this.icon,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Page && runtimeType == other.runtimeType && icon == other.icon);

  @override
  int get hashCode => icon.hashCode;

  String buildTitle(BuildContext context);

  List<Widget> buildActions(BuildContext context) => [];
}

abstract class StaticTitlePage extends Page {
  final String titleKey;

  const StaticTitlePage({
    @required IconData icon,
    @required this.titleKey,
  }) : super(icon: icon);

  @override
  String buildTitle(BuildContext context) => EzLocalization.of(context).get(titleKey);

  @override
  bool operator ==(Object other) => super == other && other is StaticTitlePage && titleKey == other.titleKey;

  @override
  int get hashCode => super.hashCode + titleKey.hashCode;
}
