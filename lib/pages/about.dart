import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';
import 'package:unicaen_timetable/widgets/list_page.dart';

/// The about page list tile.
class AboutPageListTile extends StatelessWidget {
  /// Creates a new about page list tile.
  const AboutPageListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PageListTitle(
        page: AboutPage(),
        title: translations.about.title,
        icon: Icons.favorite,
      );
}

/// The about page app bar.
class AboutPageAppBar extends StatelessWidget {
  /// Creates a new about page app bar.
  const AboutPageAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(translations.about.title),
      );
}

/// The about page widget.
class AboutPageWidget extends StatelessWidget {
  /// Creates a new about page instance.
  const AboutPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListPageWidget(
        header: ListPageHeader(
          icon: ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSI(rootBundle, 'assets/icon.si'),
          ),
          title: Text(
            translations.common.appName,
          ),
        ),
        body: ListPageBody(
          children: [
            Text(translations.about.paragraphs.first),
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                height: 50,
                width: 50,
                child: CustomPaint(
                  painter: _SymbolPainter(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  willChange: false,
                ),
              ),
            ),
            Text(translations.about.paragraphs.second),
          ],
        ),
        footer: _ListFooter(),
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
              icon: _GithubLogo(),
              onPressed: () => Utils.openUrl('https://github.com/Skyost/UnicaenTimetable'),
            ),
            IconButton(
              iconSize: 40,
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/about/skyost.png'),
                radius: 20,
              ),
              onPressed: () => Utils.openUrl('https://skyost.eu'),
            ),
          ],
        ),
      );
}

/// A Github logo.
class _GithubLogo extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GithubLogoState();
}

/// The Github logo state.
class _GithubLogoState extends ConsumerState<_GithubLogo> with BrightnessListener {
  @override
  Widget build(BuildContext context) => ColorFiltered(
        colorFilter: ColorFilter.mode(currentBrightness == Brightness.light ? Colors.black : Colors.white, BlendMode.srcIn),
        child: SizedBox(
          height: 40,
          width: 40,
          child: ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSI(rootBundle, 'assets/about/github.si'),
          ),
        ),
      );
}

/// Paints a little but cool symbol between the two paragraphs.
class _SymbolPainter extends CustomPainter {
  /// The symbol color.
  final Color? color;

  /// Creates a new symbol painter instance.
  const _SymbolPainter({
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.strokeWidth = 2;
    paint.color = color ?? Colors.black;
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
