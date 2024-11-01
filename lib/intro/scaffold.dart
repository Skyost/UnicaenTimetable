import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: const Color(0xFF171F29)),
        child: Scaffold(
          backgroundColor: const Color(0xFF2C3E50),
          body: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: _IntroScaffoldBody(),
          ),
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
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Theme(
              data: ThemeData(
                textTheme: const TextTheme(
                  headlineMedium: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w100,
                    height: 1,
                  ),
                  bodyMedium: TextStyle(
                    color: Colors.white,
                  ),
                  bodyLarge: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                // textButtonTheme: TextButtonThemeData(
                //   style: ButtonStyle(
                //     foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                //   ),
                // ),
              ),
              child: SlideWidget(
                slide: slide,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            left: 0,
            child: createFooter(context, ref, slide),
          ),
        ],
      ),
    );
  }

  /// Creates the footer widget.
  Widget createFooter(BuildContext context, WidgetRef ref, Slide slide) => Container(
        color: const Color(0xFF1F2B38),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${slide.slideIndex + 1}/${Slide.slideCount}',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () async {
                  if (slide.isLastSlide) {
                    await Navigator.pushReplacementNamed(context, '/');
                    // ignore: use_build_context_synchronously
                  } else if (await slide.onGoToNextSlide(context)) {
                    ref.read(currentSlideProvider).value = slide.createNextSlide()!;
                  }
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                child: Text(context.getString('intro.buttons.${slide.isLastSlide ? 'finish' : 'next'}').toUpperCase()),
              ),
            ],
          ),
        ),
      );
}
