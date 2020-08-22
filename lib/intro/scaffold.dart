import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/intro/slides.dart';

/// The intro scaffold.
class IntroScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF2C3E50),
          textTheme: const TextTheme(
            headline6: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w100,
              height: 1,
            ),
            bodyText2: TextStyle(color: Colors.white),
            bodyText1: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            button: TextStyle(color: Colors.white),
          ),
        ),
        isMaterialAppTheme: true,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: const Color(0xFF171F29)),
          child: Scaffold(
            body: ChangeNotifierProvider<IntroScaffoldBodyModel>(
              create: (_) => IntroScaffoldBodyModel(),
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: _IntroScaffoldBody(),
              ),
            ),
          ),
        ),
      );
}

/// The intro scaffold body.
class _IntroScaffoldBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<IntroScaffoldBodyModel>(builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () {
            if (model.isLastSlide) {
              return Future.value(true);
            }

            model.goToPreviousSlide();
            return Future.value(false);
          },
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: model.currentSlide,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    left: 0,
                    child: createFooter(context, model),
                  ),
                ],
              ),
            ),
          ),
        );
      });

  /// Creates the footer widget.
  Widget createFooter(BuildContext context, IntroScaffoldBodyModel model) => Container(
        color: const Color(0xFF1F2B38),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text((model.currentSlideIndex + 1).toString() + '/' + model.slides.length.toString()),
            ),
            FlatButton(
              child: Text(context.getString('intro.buttons.' + (model.isLastSlide ? 'finish' : 'next')).toUpperCase()),
              textColor: Colors.white,
              disabledTextColor: Colors.white54,
              onPressed: () => model.goToNextSlide(context),
            ),
          ],
        ),
      );
}

/// The intro scaffold body model.
class IntroScaffoldBodyModel extends ChangeNotifier {
  /// The intro slides.
  List<Slide> slides = [
    const FirstSlide(),
    const SecondSlide(),
    const ThirdSlide(),
  ];

  /// The currently shown slide index.
  int _currentSlideIndex = 0;

  /// The currently shown slide.
  Slide _currentSlide;

  /// Creates a new intro scaffold body model instance.
  IntroScaffoldBodyModel() {
    _currentSlide = slides.first;
  }

  /// Returns the currently shown slide index.
  int get currentSlideIndex => _currentSlideIndex;

  /// Returns the currently shown slide.
  Slide get currentSlide => _currentSlide;

  /// Sets the current slide.
  set currentSlide(Slide slide) {
    _currentSlide = slide;
    notifyListeners();
  }

  /// Goes to the previous slide if possible.
  void goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      _currentSlideIndex--;
      currentSlide = slides[_currentSlideIndex];
    }
  }

  /// Goes to the next slide if possible.
  Future<void> goToNextSlide(BuildContext context) async {
    if (isLastSlide) {
      await Navigator.pushReplacementNamed(context, '/');
      return;
    }

    if (await _currentSlide.onGoToNextSlide(context)) {
      _currentSlideIndex++;
      currentSlide = slides[_currentSlideIndex];
    }
  }

  /// Returns whether this is the last slide.
  bool get isLastSlide => _currentSlideIndex == slides.length - 1;
}
