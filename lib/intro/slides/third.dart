import 'package:unicaen_timetable/intro/slides/second.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';

/// The third intro slide.
class ThirdSlide extends Slide {
  /// Creates a new third intro slide instance.
  const ThirdSlide()
      : super(
          slideId: 'finished',
          slideIndex: 2,
        );

  @override
  Slide? createPreviousSlide() => const SecondSlide();

  @override
  Slide? createNextSlide() => null;
}
