import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
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
  Widget build(BuildContext context) => Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          shrinkWrap: true,
          children: [
            Text(
              translations['intro.slides.${slide.slideId}.title'],
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: SizedBox(
                height: 220,
                width: math.min(220, MediaQuery.of(context).size.width - 20),
                child: ScalableImageWidget.fromSISource(
                  si: ScalableImageSource.fromSI(rootBundle, slide.asset),
                ),
              ),
            ),
            Text(
              translations['intro.slides.${slide.slideId}.message'],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
