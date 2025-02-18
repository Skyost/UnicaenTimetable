import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';

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
            _TitleWidget(
              text: translations['intro.slides.${slide.slideId}.title'],
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

/// An intro slide title.
class _TitleWidget extends ConsumerStatefulWidget {
  /// The text.
  final String text;

  /// Creates a new title widget instance.
  const _TitleWidget({
    required this.text,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TitleWidgetState();
}

/// The title widget state.
class _TitleWidgetState extends ConsumerState<_TitleWidget> with BrightnessListener {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle? style = theme.textTheme.displaySmall;
    if (currentBrightness == Brightness.light) {
      style = style?.copyWith(color: theme.colorScheme.primary);
    }
    return Text(
      widget.text,
      style: style,
      textAlign: TextAlign.center,
    );
  }
}
