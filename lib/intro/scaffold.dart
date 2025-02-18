import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/intro/slides/first.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';
import 'package:unicaen_timetable/widgets/slide.dart';

final currentSlideProvider = ChangeNotifierProvider((ref) => ValueNotifier<Slide>(const FirstSlide()));

/// The intro scaffold.
class IntroScaffold extends StatelessWidget {
  /// Creates a new intro scaffold instance.
  const IntroScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: _IntroScaffoldBody(),
        ),
      );
}

/// The intro scaffold body.
class _IntroScaffoldBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Slide slide = ref.watch(currentSlideProvider.select((provider) => provider.value));
    return PopScope(
      canPop: slide.isFirstSlide,
      onPopInvokedWithResult: (didPop, result) {
        if (!slide.isFirstSlide) {
          ref.read(currentSlideProvider).value = slide.createPreviousSlide()!;
        }
      },
      child: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 50),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SlideWidget(
                slide: slide,
              ),
            ),
            Positioned(
              right: 10,
              bottom: 0,
              left: 18,
              child: createFooter(context, ref, slide),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates the footer widget.
  Widget createFooter(BuildContext context, WidgetRef ref, Slide slide) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${slide.slideIndex + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: '/',
                ),
                const TextSpan(
                  text: '${Slide.slideCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _NextButton(
            slide: slide,
          ),
        ],
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
        onPressed: () async {
          if (widget.slide.isLastSlide) {
            await Navigator.pushReplacementNamed(context, '/');
          } else if (await widget.slide.onGoToNextSlide(context)) {
            ref.read(currentSlideProvider).value = widget.slide.createNextSlide()!;
          }
        },
        icon: Icon(
          widget.slide.isLastSlide ? Icons.check : Icons.chevron_right,
        ),
        label: Text(
          (widget.slide.isLastSlide ? translations.intro.buttons.finish : translations.intro.buttons.next).toUpperCase(),
        ),
      );
}
