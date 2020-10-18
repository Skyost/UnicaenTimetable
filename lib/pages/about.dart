import 'dart:ui';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The about page that shows info about the app.
class AboutPage extends StaticTitlePage {
  /// Creates a new about page instance.
  const AboutPage()
      : super(
          titleKey: 'about.title',
          icon: Icons.insert_emoticon,
        );

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

/// The about page state.
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

/// The about page list header.
class _ListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: context.watch<SettingsModel>().resolveTheme(context).aboutHeaderBackgroundColor,
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
                context.getString('app_name'),
                textAlign: TextAlign.center,
                style: const TextStyle(
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

/// The about page list body.
class _ListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.getString('about.paragraphs.first')),
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                height: 50,
                width: 50,
                child: CustomPaint(
                  painter: _SymbolPainter(
                    color: context.watch<SettingsModel>().resolveTheme(context).textColor ?? Colors.black54,
                  ),
                  willChange: false,
                ),
              ),
            ),
            Text(context.getString('about.paragraphs.second')),
          ],
        ),
      );
}

/// The about page list footer.
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
                color: (context.watch<SettingsModel>().resolveTheme(context).textColor ?? Colors.black).withAlpha(255),
              ),
              onPressed: () => Utils.openUrl('https://github.com/Skyost/UnicaenTimetable'),
            ),
            IconButton(
              iconSize: 40,
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/about/skyost.png'),
                radius: 20,
              ),
              onPressed: () => Utils.openUrl('https://www.skyost.eu'),
            ),
          ],
        ),
      );
}

/// Paints a little but cool symbol between the two paragraphs.
class _SymbolPainter extends CustomPainter {
  /// The symbol color.
  final Color color;

  /// Creates a new symbol painter instance.
  const _SymbolPainter({
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.strokeWidth = 2;
    paint.color = color;
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
  bool shouldRepaint(_SymbolPainter oldDelegate) => oldDelegate.color != color;
}
