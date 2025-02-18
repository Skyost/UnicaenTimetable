import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/intro/slides/first.dart';
import 'package:unicaen_timetable/intro/slides/slide.dart';
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
          Text(
            '${slide.slideIndex + 1}/${Slide.slideCount}',
          ),
          TextButton.icon(
            onPressed: () async {
              if (slide.isLastSlide) {
                await Navigator.pushReplacementNamed(context, '/');
                // ignore: use_build_context_synchronously
              } else if (await slide.onGoToNextSlide(context)) {
                ref.read(currentSlideProvider).value = slide.createNextSlide()!;
              }
            },
            icon: Icon(
              slide.isLastSlide ? Icons.check : Icons.chevron_right,
            ),
            label: Text(
              (slide.isLastSlide ? translations.intro.buttons.finish : translations.intro.buttons.next).toUpperCase(),
            ),
          ),
        ],
      );
}
