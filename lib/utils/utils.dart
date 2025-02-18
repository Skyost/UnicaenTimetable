import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Finds the enum value in this list with name.
extension EnumByName<T extends Enum> on Iterable<T> {
  /// Finds the enum value in this list with name [name].
  /// Returns `null` if not found.
  T? byNameOrNull(String name) {
    for (T value in this) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
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
    if (size > length) {
      return List.generate(size, (index) => index >= length ? index.toString() : this[index]);
    }

    List<String> result = [];
    int partLength = (length / size).floor();
    for (int part = 0; part < size; part++) {
      result.add(substring(part * partLength, (part + 1) * partLength));
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

  /// Changes the day of week by putting it at sunday.
  DateTime get atSunday => add(Duration(days: DateTime.sunday - weekday));
}

/// Contains some useful number methods.
extension NumUtils on num {
  /// Returns a string with a leading number zero (if needed).
  String get withLeadingZero => (this < 10 ? '0' : '') + toString();
}

/// Contains some useful map methods.
extension MapUtils<K, V> on Map<K, V> {
  /// Returns a key by its value (returns the first).
  K? getByValue(V value) => keys.firstWhereOrNull((K key) => this[key] == value);
}

/// Contains some useful iterable methods.
extension IterableUtils<T> on Iterable<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
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
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
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
  static Future<SnackBarClosedReason?> showSnackBar({
    required BuildContext context,
    IconData? icon,
    required String text,
    Color? color,
    bool waitBeforeReturning = false,
  }) async {
    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> result = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
      ),
    );
    if (waitBeforeReturning) {
      return await result.closed;
    }
    return null;
  }
}

/// Allows to cache a given provider for an amount of time.
extension CacheForExtension on Ref<Object?> {
  /// Keeps the provider alive for [duration].
  void cacheFor(Duration duration) {
    // Immediately prevent the state from getting destroyed.
    KeepAliveLink link = keepAlive();
    // After duration has elapsed, we re-enable automatic disposal.
    Timer timer = Timer(duration, link.close);
    // Optional: when the provider is recomputed (such as with ref.watch),
    // we cancel the pending timer.
    onDispose(timer.cancel);
  }
}
