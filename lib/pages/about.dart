import 'dart:ui';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StaticTitlePage {
  const AboutPage()
      : super(
          titleKey: 'about.title',
          icon: Icons.insert_emoticon,
        );

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) => ListView(
        children: [
          _ListHeader(),
          _ListBody(),
          _ListFooter(),
        ],
      );
}

class _ListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Provider.of<SettingsModel>(context).theme.aboutHeaderBackgroundColor,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icon.svg',
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                EzLocalization.of(context).get('app_name'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(EzLocalization.of(context).get('about.paragraphs.first')),
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                height: 50,
                width: 50,
                child: CustomPaint(
                  painter: _SymbolPainter(),
                  willChange: false,
                ),
              ),
            ),
            Text(EzLocalization.of(context).get('about.paragraphs.second')),
          ],
        ),
      );
}

class _ListFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          left: 40,
          right: 40,
          bottom: 20,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            IconButton(
              iconSize: 40,
              icon: SvgPicture.asset(
                'assets/about/github.svg',
                height: 40,
              ),
              onPressed: () async {
                if (await canLaunch('https://github.com/Skyost/UnicaenTimetable')) {
                  await launch('https://github.com/Skyost/UnicaenTimetable');
                }
              },
            ),
            IconButton(
              iconSize: 40,
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/about/skyost.png'),
                radius: 20,
              ),
              onPressed: () async {
                if (await canLaunch('https://www.skyost.eu')) {
                  await launch('https://www.skyost.eu');
                }
              },
            ),
          ],
        ),
      );
}

class _SymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.strokeWidth = 2;
    paint.color = Colors.black54;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.butt;
    paint.isAntiAlias = true;

    double range = 3 * size.width / 20;

    Path path = Path();
    path.moveTo(size.width / 2, size.height / 2);
    path.cubicTo(size.width, 0, size.width, size.height, (size.width / 2) + range, size.height / 2);
    path.moveTo((size.width / 2) - range, size.height / 2);
    path.cubicTo(0, 0, 0, size.height, size.width / 2, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SymbolPainter oldDelegate) => false;
}
