import 'dart:math';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';

extension StringUtils on String {
  String capitalize() {
    if (isEmpty || length == 1) {
      return toUpperCase();
    }

    return substring(0, 1).toUpperCase() + substring(1, length);
  }

  List<String> splitEqually(int size) {
    List<String> result = [];
    int start = 0;
    int end = (length / size).round();
    for (int i = 0; i != size; i++) {
      StringBuffer builder = StringBuffer();
      int j;
      for (j = start; j != end; j++) {
        if (j >= length) {
          break;
        }
        builder.write(this[j]);
      }
      result.add(builder.toString());
      start = j;
      end += end;
    }
    return result;
  }
}

extension ColorUtils on Color {
  bool get isDark => computeLuminance() < 0.6;
}

extension DateUtils on DateTime {
  DateTime get yearMonthDay => DateTime(year, month, day);

  DateTime get atMonday => subtract(Duration(days: weekday - 1));
}

extension NumUtils on num {
  String get withLeadingZero => (this < 10 ? '0' : '') + toString();
}

extension MapUtils<K, V> on Map<K, V> {
  K getByValue(V value) => keys.firstWhere((K key) => this[key] == value, orElse: () => null);
}

class Utils {
  static Color randomColor(int alpha, List<String> seeds) {
    if (seeds.length < 3) {
      return Colors.white;
    }

    return Color.fromARGB(alpha, Random(seeds[0].hashCode).nextInt(256), Random(seeds[1].hashCode).nextInt(256), Random(seeds[2].hashCode).nextInt(256));
  }

  static void showSnackBar({
    @required BuildContext context,
    @required IconData icon,
    @required String textKey,
    @required Color color,
    VoidCallback onVisible,
  }) =>
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  EzLocalization.of(context).get('scaffold.snack_bar.${textKey}'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        onVisible: onVisible,
      ));
}

class ProgressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 30),
              child: CircularProgressIndicator(),
            ),
            Text(EzLocalization.of(context).get('other.please_wait')),
          ],
        ),
      );

  static Future<void> show(BuildContext context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: ProgressDialog(),
        ),
        barrierDismissible: false,
      );
}

class CenteredCircularProgressIndicator extends StatelessWidget {
  final Color color;

  const CenteredCircularProgressIndicator({
    this.color,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(backgroundColor: color ?? Theme.of(context).primaryColor),
      );
}
