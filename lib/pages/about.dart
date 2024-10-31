import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The about page that shows info about the app.
class AboutPage extends Page {
  /// The page identifier.
  static const String id = 'about';

  /// Creates a new about page instance.
  const AboutPage({
    super.key,
  }) : super(
          pageId: id,
          icon: Icons.insert_emoticon,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
        children: [
          _ListHeader(),
          _ListBody(),
          _ListFooter(),
        ],
      );
}

/// The about page list header.
class _ListHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        color: ref.watch(settingsModelProvider).resolveTheme(context).aboutHeaderBackgroundColor,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              child: ScalableImageWidget.fromSISource(
                si: ScalableImageSource.fromSI(rootBundle, 'assets/icon.si'),
              ),
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
class _ListBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
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
                    color: ref.watch(settingsModelProvider).resolveTheme(context).textColor,
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
class _ListFooter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
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
              icon: ColorFiltered(
                colorFilter: ColorFilter.mode(ref.watch(settingsModelProvider).resolveTheme(context).textColor.withAlpha(255), BlendMode.srcIn),
                child: SizedBox(
                  height: 40,
                  child: ScalableImageWidget.fromSISource(
                    si: ScalableImageSource.fromSI(rootBundle, 'assets/about/github.si'),
                  ),
                ),
              ),
              onPressed: () => Utils.openUrl(Uri.parse('https://github.com/Skyost/UnicaenTimetable')),
            ),
            IconButton(
              iconSize: 40,
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/about/skyost.png'),
                radius: 20,
              ),
              onPressed: () => Utils.openUrl(Uri.parse('https://skyost.eu')),
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
    required this.color,
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
