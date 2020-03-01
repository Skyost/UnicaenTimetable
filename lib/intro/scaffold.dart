import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/intro/slides.dart';

class IntroScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF2C3E50),
          textTheme: TextTheme(
            title: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w100,
              height: 1,
            ),
            body1: const TextStyle(color: Colors.white),
            body2: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            button: const TextStyle(color: Colors.white),
          ),
        ),
        isMaterialAppTheme: true,
        child: Scaffold(
          body: ChangeNotifierProvider<IntroScaffoldBodyModel>(
            create: (_) => IntroScaffoldBodyModel(),
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: _IntroScaffoldBody(),
            ),
          ),
        ),
      );
}

class _IntroScaffoldBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<IntroScaffoldBodyModel>(
        builder: (context, model, child) {
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
        }
      );

  Widget createFooter(BuildContext context, IntroScaffoldBodyModel model) => Container(
        color: const Color(0xFF1F2B38),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text((model.currentSlideIndex + 1).toString() + '/' + IntroScaffoldBodyModel.slides.length.toString()),
            ),
            FlatButton(
              child: Text(EzLocalization.of(context).get('intro.buttons.' + (model.isLastSlide ? 'finish' : 'next')).toUpperCase()),
              textColor: Colors.white,
              disabledTextColor: Colors.white54,
              onPressed: model.allowNextSlide ? () => model.goToNextSlide(context) : null,
            ),
          ],
        ),
      );
}

class IntroScaffoldBodyModel extends ChangeNotifier {
  static List<Slide> slides = [
    const FirstSlide(),
    const SecondSlide(),
    const ThirdSlide(),
  ];

  int _currentSlideIndex = 0;

  Slide _currentSlide = slides.first;
  bool _allowNextSlide = slides.first.automaticallyAllowNextSlide;

  int get currentSlideIndex => _currentSlideIndex;

  Slide get currentSlide => _currentSlide;

  bool get allowNextSlide => _allowNextSlide;

  set allowNextSlide(bool allowNextSlide) {
    _allowNextSlide = allowNextSlide;
    notifyListeners();
  }

  void goToPreviousSlide() {
    if (_currentSlideIndex > 0) {
      _currentSlideIndex--;
      _currentSlide = slides[_currentSlideIndex];
      allowNextSlide = _currentSlide.automaticallyAllowNextSlide;
    }
  }

  void goToNextSlide([BuildContext context]) {
    if (isLastSlide && context != null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    _currentSlideIndex++;
    _currentSlide = slides[_currentSlideIndex];
    allowNextSlide = _currentSlide.automaticallyAllowNextSlide;
  }

  bool get isLastSlide => _currentSlideIndex == slides.length - 1;
}
