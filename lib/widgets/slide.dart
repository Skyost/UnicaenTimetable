import 'dart:math' as math;

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';

/// Allows to render a slide.
class SlideWidget extends StatelessWidget {
  /// The slide.
  final Slide slide;

  /// Creates a new slide widget instance.
  const SlideWidget({
    super.key,
    required this.slide,
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
      context.getString('intro.slides.${slide.slideId}.title'),
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: SizedBox(
        height: 350,
        width: math.min(350, MediaQuery.of(context).size.width - 160),
        child: ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSI(rootBundle, slide.asset),
        ),
      ),
    ),
    Text(
      context.getString('intro.slides.${slide.slideId}.message'),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  ];
}