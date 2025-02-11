import 'package:flutter/material.dart';

/// An intro slide widget.
abstract class Slide {
  /// The slide count.
  static const slideCount = 3;

  /// The slide id.
  final String slideId;

  /// The slide index.
  final int slideIndex;

  /// The image asset.
  final String asset;

  /// Creates a new slide instance.
  const Slide({
    required this.slideId,
    required this.slideIndex,
    String? asset,
  }) : asset = asset ?? 'assets/intro/$slideId.si';

  /// Triggered when the user wants to go to the next slide.
  Future<bool> onGoToNextSlide(BuildContext context) => Future<bool>.value(true);

  /// Creates the previous slide.
  Slide? createPreviousSlide();

  /// Creates the next slide.
  Slide? createNextSlide();

  /// Returns whether this slide is the first slide.
  bool get isFirstSlide => slideIndex == 0;

  /// Returns whether this slide is the last slide.
  bool get isLastSlide => slideIndex == slideCount - 1;
}
