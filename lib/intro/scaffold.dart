import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/intro/slide.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';

/// The intro scaffold.
class IntroScaffold extends StatelessWidget {
  /// Creates a new intro scaffold instance.
  const IntroScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _IntroScaffoldBody(),
    bottomNavigationBar: _IntroScaffoldFooter(),
  );
}

/// The intro scaffold body.
class _IntroScaffoldBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Slide slide = ref.watch(currentSlideProvider);
    return PopScope(
      canPop: slide.isFirstSlide,
      onPopInvokedWithResult: (didPop, result) => ref.read(currentSlideProvider.notifier).goToPreviousSlide(context),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: SlideWidget(
          key: ValueKey('slide.${slide.name}'),
          slide: slide,
        ),
      ),
    );
  }
}

/// The intro scaffold footer.
class _IntroScaffoldFooter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Slide slide = ref.watch(currentSlideProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CurrentProgressIndicator(
            slide: slide,
          ),
          _NextButton(
            slide: slide,
          ),
        ],
      ),
    );
  }
}

/// The current progress indicator.
class _CurrentProgressIndicator extends ConsumerStatefulWidget {
  /// The slide instance.
  final Slide slide;

  /// Creates a new current progress indicator.
  const _CurrentProgressIndicator({
    required this.slide,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CurrentProgressIndicatorState();
}

/// The current progress indicator state.
class _CurrentProgressIndicatorState extends ConsumerState<_CurrentProgressIndicator> with BrightnessListener {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: currentBrightness == Brightness.dark ? 8 : 0),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${widget.slide.index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: '/',
          ),
          TextSpan(
            text: '${Slide.values.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

/// The next button.
class _NextButton extends ConsumerStatefulWidget {
  /// The slide instance.
  final Slide slide;

  /// Creates a new next button instance.
  const _NextButton({
    required this.slide,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NextButtonState();
}

/// The next button state.
class _NextButtonState extends ConsumerState<_NextButton> with BrightnessListener {
  @override
  Widget build(BuildContext context) => (currentBrightness == Brightness.light ? FilledButton.tonalIcon : TextButton.icon)(
    onPressed: () => ref.read(currentSlideProvider.notifier).goToNextSlide(context),
    icon: Icon(
      widget.slide.isLastSlide ? Icons.check : Icons.chevron_right,
    ),
    label: Text(
      (widget.slide.isLastSlide ? translations.intro.buttons.finish : translations.intro.buttons.next).toUpperCase(),
    ),
  );
}
