import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';
import 'package:unicaen_timetable/widgets/animated.dart';

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
              child: _ImageWidget(
                key: ValueKey('image-${slide.slideId}'),
                image: ScalableImageWidget.fromSISource(
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

/// An intro image.
class _ImageWidget extends ConsumerStatefulWidget {
  /// The size.
  final double size;

  /// The image.
  final Widget image;

  /// Creates a new image widget instance.
  const _ImageWidget({
    super.key,
    this.size = 220,
    required this.image,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageWidgetState();
}

/// The title widget state.
class _ImageWidgetState extends ConsumerState<_ImageWidget> with BrightnessListener {
  @override
  Widget build(BuildContext context) => FadeInWidget(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentBrightness == Brightness.light ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceBright,
          ),
          height: math.min(widget.size, MediaQuery.of(context).size.width - 20),
          width: math.min(widget.size, MediaQuery.of(context).size.width - 20),
          padding: const EdgeInsets.all(50),
          child: FadeInWidget(
            delay: const Duration(milliseconds: 700),
            child: RepeatingScaleAnimation(
              child: widget.image,
            ),
          ),
        ),
      );
}
