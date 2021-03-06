import 'dart:math' as math;

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/intro/scaffold.dart';

/// An intro slide widget.
class Slide extends StatelessWidget {
  /// The slide id.
  final String slideId;

  /// The image asset.
  final String? asset;

  /// Creates a new slide instance.
  const Slide({
    required this.slideId,
    this.asset,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 36),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          shrinkWrap: true,
          children: createChildren(context),
        ),
      );

  /// Creates the list view children.
  List<Widget> createChildren(BuildContext context) => [
        Text(
          context.getString('intro.slides.$slideId.title'),
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SvgPicture.asset(
            asset ?? 'assets/intro/$slideId.svg',
            width: math.min(350, MediaQuery.of(context).size.width - 160),
          ),
        ),
        Text(
          context.getString('intro.slides.$slideId.message'),
          textAlign: TextAlign.center,
        ),
      ];

  /// Triggered when the user wants to go to the next slide.
  Future<bool> onGoToNextSlide(BuildContext context) => Future<bool>.value(true);
}

/// The first intro slide.
class FirstSlide extends Slide {
  /// Creates a new first intro slide instance.
  const FirstSlide()
      : super(
          slideId: 'main',
          asset: 'assets/icon.svg',
        );
}

/// The second intro slide.
class SecondSlide extends Slide {
  /// Creates a new second intro slide instance.
  const SecondSlide() : super(slideId: 'login');

  @override
  List<Widget> createChildren(BuildContext context) {
    List<Widget> children = super.createChildren(context);
    children.add(Padding(
      padding: const EdgeInsets.only(top: 30),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => context.read<IntroScaffoldBodyModel>().goToNextSlide(context),
          style: IntroScaffold.buttonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF1F2B38)),
          ),
          child: Text(context.getString('intro.slides.login.login_button').toUpperCase()),
        ),
      ),
    ));
    return children;
  }

  @override
  Future<bool> onGoToNextSlide(BuildContext context) => LoginDialog.show(context, synchronizeAfterLogin: true);
}

/// The third intro slide.
class ThirdSlide extends Slide {
  /// Creates a new third intro slide instance.
  const ThirdSlide() : super(slideId: 'finished');
}
