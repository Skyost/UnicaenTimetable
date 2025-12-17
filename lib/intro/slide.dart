import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';
import 'package:unicaen_timetable/widgets/animated.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';

/// The current slide provider.
final currentSlideProvider = NotifierProvider.autoDispose<SlideNotifier, Slide>(SlideNotifier.new);

/// The slide notifier.
class SlideNotifier extends Notifier<Slide> {
  @override
  Slide build() => Slide.main;

  /// Goes to the previous slide.
  Future<bool> goToPreviousSlide(BuildContext context) async {
    Slide? previous = state.previousSlide;
    if (previous != null) {
      state = previous;
    }
    return true;
  }

  /// Goes to the next slide.
  Future<bool> goToNextSlide(BuildContext context) async {
    switch (state) {
      case Slide.main:
        break;
      case Slide.login:
        if (!(await LoginDialog.show(context, synchronizeAfterLogin: true))) {
          return false;
        }
        break;
      case Slide.finished:
        await Navigator.pushReplacementNamed(context, '/');
        break;
    }

    Slide? next = state.nextSlide;
    if (next != null) {
      state = next;
    }
    return true;
  }
}

/// An intro slide widget.
enum Slide {
  main(asset: 'assets/icon.si'),
  login,
  finished;

  /// The image asset.
  final String? _asset;

  /// Creates a new slide instance.
  const Slide({
    String? asset,
  }) : _asset = asset;

  /// Returns the slide asset.
  String get asset => _asset ?? 'assets/intro/$name.si';

  /// Creates the previous slide.
  Slide? get previousSlide => isFirstSlide ? null : Slide.values[index - 1];

  /// Creates the next slide.
  Slide? get nextSlide => isLastSlide ? null : Slide.values[index + 1];

  /// Returns whether this slide is the first slide.
  bool get isFirstSlide => this == main;

  /// Returns whether this slide is the last slide.
  bool get isLastSlide => this == finished;
}

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
          text: translations['intro.slides.${slide.name}.title'],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: _ImageWidget(
            key: ValueKey('image.${slide.name}'),
            image: ScalableImageWidget.fromSISource(
              si: ScalableImageSource.fromSI(rootBundle, slide.asset),
            ),
          ),
        ),
        Text(
          translations['intro.slides.${slide.name}.message'],
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
    delay: const Duration(milliseconds: 200),
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentBrightness == Brightness.light ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceBright,
      ),
      height: math.min(widget.size, MediaQuery.sizeOf(context).width - 20),
      width: math.min(widget.size, MediaQuery.sizeOf(context).width - 20),
      padding: const EdgeInsets.all(50),
      child: FadeInWidget(
        delay: const Duration(milliseconds: 900),
        child: RepeatingScaleAnimation(
          child: widget.image,
        ),
      ),
    ),
  );
}
