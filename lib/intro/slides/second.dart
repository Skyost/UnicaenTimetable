import 'package:flutter/material.dart';
import 'package:unicaen_timetable/intro/slides/first.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';
import 'package:unicaen_timetable/intro/slides/third.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';

/// The second intro slide.
class SecondSlide extends Slide {
  /// Creates a new second intro slide instance.
  const SecondSlide()
      : super(
    slideId: 'login',
    slideIndex: 1,
  );

  @override
  Future<bool> onGoToNextSlide(BuildContext context) => LoginDialog.show(context, synchronizeAfterLogin: true);

  @override
  Slide? createPreviousSlide() => const FirstSlide();

  @override
  Slide? createNextSlide() => const ThirdSlide();
}