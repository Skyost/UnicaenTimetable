import 'dart:math';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contains some useful build context methods.
extension BuildContextUtils on BuildContext {
  /// Extension method for provider (but with listen sets to false).
  T get<T>() => Provider.of<T>(this, listen: false);
}

/// Contains some useful string methods.
extension StringUtils on String {
  /// Capitalizes a string.
  String capitalize() {
    if (isEmpty || length == 1) {
      return toUpperCase();
    }

    return substring(0, 1).toUpperCase() + substring(1, length);
  }

  /// Splits a string in equal parts.
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

/// Contains some useful color methods.
extension ColorUtils on Color {
  /// Returns whether a color is dark.
  bool get isDark => computeLuminance() < 0.6;
}

/// Contains some useful date methods.
extension DateUtils on DateTime {
  /// Cuts a date by keeping only its year, month and day.
  DateTime get yearMonthDay => DateTime(year, month, day);

  /// Changes the day of week by putting it at monday.
  DateTime get atMonday => subtract(Duration(days: weekday - 1));
}

/// Contains some useful number methods.
extension NumUtils on num {
  /// Returns a string with a leading number zero (if needed).
  String get withLeadingZero => (this < 10 ? '0' : '') + toString();
}

/// Contains some useful map methods.
extension MapUtils<K, V> on Map<K, V> {
  /// Returns a key by its value (returns the first).
  K getByValue(V value) => keys.firstWhere((K key) => this[key] == value, orElse: () => null);
}

/// Contains some useful methods.
class Utils {
  /// Returns whether the current date is today.
  static bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.yearMonthDay.difference(now.yearMonthDay).inDays == 0;
  }

  /// Opens an url, if possible.
  static Future<void> openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  /// Creates a random color by using a seed for each value (rgb).
  static Color randomColor(int alpha, List<String> seeds) {
    if (seeds.length < 3) {
      return Colors.white;
    }

    return Color.fromARGB(alpha, Random(seeds[0].hashCode).nextInt(256), Random(seeds[1].hashCode).nextInt(256), Random(seeds[2].hashCode).nextInt(256));
  }

  /// Shows a snack bar with an icon, a text and a color.
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
                  context.getString('scaffold.snack_bar.${textKey}'),
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

/// A pair of two elements.
class Pair<A, B> {
  /// The first element.
  final A first;

  /// The second element.
  final B second;

  /// Creates a new pair instance.
  const Pair(this.first, this.second);
}
