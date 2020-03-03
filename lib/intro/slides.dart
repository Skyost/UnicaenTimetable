import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/intro/scaffold.dart';

/// An intro slide widget.
class Slide extends StatelessWidget {
  /// The slide id.
  final String slideId;

  /// The image asset.
  final String asset;

  /// Whether to the next slide button should be enabled by default.
  final bool automaticallyAllowNextSlide;

  /// Creates a new slide instance.
  const Slide({
    @required this.slideId,
    this.asset,
    this.automaticallyAllowNextSlide = true,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 36),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          children: createChildren(context),
          shrinkWrap: true,
        ),
      );

  /// Creates the list view children.
  List<Widget> createChildren(BuildContext context) => [
        Text(
          EzLocalization.of(context).get('intro.slides.${slideId}.title'),
          style: Theme.of(context).textTheme.title,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: SvgPicture.asset(
            asset ?? 'assets/intro/${slideId}.svg',
            width: MediaQuery.of(context).size.width - 100,
          ),
        ),
        Text(
          EzLocalization.of(context).get('intro.slides.${slideId}.message'),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ];
}

/// The first intro slide.
class FirstSlide extends Slide {
  /// Creates a new first intro slide instance.
  const FirstSlide()
      : super(
          slideId: 'main',
          asset: 'assets/icon.svg',
        );
}

/// The second intro slide.
class SecondSlide extends Slide {
  /// Creates a new second intro slide instance.
  const SecondSlide()
      : super(
          slideId: 'login',
          automaticallyAllowNextSlide: false,
        );

  @override
  List<Widget> createChildren(BuildContext context) {
    List<Widget> children = super.createChildren(context);
    children.add(Padding(
      padding: const EdgeInsets.only(top: 30),
      child: SizedBox(
        width: double.infinity,
        child: FlatButton(
          textColor: Colors.white,
          onPressed: () async {
            if (await LoginDialog.show(context, synchronizeAfterLogin: true)) {
              Provider.of<IntroScaffoldBodyModel>(context, listen: false).goToNextSlide(context);
            }
          },
          child: Text(EzLocalization.of(context).get('intro.slides.login.login_button').toUpperCase()),
          color: const Color(0xFF1F2B38),
          highlightColor: Colors.black12,
          splashColor: Colors.black26,
        ),
      ),
    ));
    return children;
  }
}

/// The third intro slide.
class ThirdSlide extends Slide {
  /// Creates a new third intro slide instance.
  const ThirdSlide() : super(slideId: 'finished');
}
