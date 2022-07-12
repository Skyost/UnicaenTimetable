import 'package:unicaen_timetable/intro/slides/second.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';

/// The first intro slide.
class FirstSlide extends Slide {
  /// Creates a new first intro slide instance.
  const FirstSlide()
      : super(
    slideId: 'main',
    slideIndex: 0,
    asset: 'assets/icon.svg',
  );

  @override
  Slide? createPreviousSlide() => null;

  @override
  Slide? createNextSlide() => const SecondSlide();
}