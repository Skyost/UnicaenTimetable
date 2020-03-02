import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/dialogs/login.dart';
import 'package:unicaen_timetable/intro/scaffold.dart';

class Slide extends StatelessWidget {
  final String slideId;
  final String asset;
  final bool automaticallyAllowNextSlide;

  const Slide({
    @required this.slideId,
    this.asset,
    this.automaticallyAllowNextSlide = true,
  });

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

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 36),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          children: createChildren(context),
          shrinkWrap: true,
        ),
      );
}

class FirstSlide extends Slide {
  const FirstSlide()
      : super(
          slideId: 'main',
          asset: 'assets/icon.svg',
        );
}

class SecondSlide extends Slide {
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
            if (await LoginDialog.show(
              context,
              synchronizeAfterLogin: true,
            )) {
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

class ThirdSlide extends Slide {
  const ThirdSlide() : super(slideId: 'finished');
}
