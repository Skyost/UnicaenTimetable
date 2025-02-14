import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/settings/color_lessons_automatically.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The lesson color resolver provider.
final lessonColorResolverProvider = AsyncNotifierProvider<LessonColorResolver, ColorResolver>(LessonColorResolver.new);

/// Allows to get and set lessons color.
class LessonColorResolver extends AsyncNotifier<ColorResolver> {
  @override
  FutureOr<ColorResolver> build() async {
    bool automaticallyColorLessons = await ref.watch(colorLessonsAutomaticallyEntryProvider.future);
    Map<String, Color> colors;
    File file = await _getFile(create: false);
    if (file.existsSync()) {
      try {
        Map<String, dynamic> content = jsonDecode(file.readAsStringSync());
        colors = {
          for (MapEntry<String, dynamic> entry in content.entries) entry.key: Color(entry.value),
        };
      } catch (ex) {
        colors = {};
      }
    } else {
      colors = {};
    }
    return ColorResolver._(
      automaticallyColorLessons: automaticallyColorLessons,
      colors: colors,
    );
  }

  /// Returns the lessons color file.
  Future<File> _getFile({bool create = true}) async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    File file = File('${appDocumentsDir.path}/colors.json');
    if (create && !file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  /// Sets the lesson color according to its name.
  Future<void> setLessonColor(Lesson lesson, Color? color) async {
    Map<String, Color> colors = Map.of((await future)._colors);
    if (color == null) {
      colors.remove(lesson.name);
    } else {
      colors[lesson.name] = color;
    }
    _saveAndUse(colors);
  }

  /// Resets the lesson color according to its name.
  Future<void> resetLessonColor(Lesson lesson) => setLessonColor(lesson, null);

  /// Saves and uses the [colors] as [state].
  Future<void> _saveAndUse(Map<String, Color> colors) async {
    File file = await _getFile();
    file.writeAsStringSync(
      jsonEncode(
        {
          for (MapEntry<String, Color> entry in colors.entries) entry.key: entry.value.value,
        },
      ),
    );
    state = AsyncData(
      ColorResolver._(
        automaticallyColorLessons: await ref.read(colorLessonsAutomaticallyEntryProvider.future),
        colors: colors,
      ),
    );
  }
}

/// Allows to color lessons.
class ColorResolver {
  /// Whether to automatically color lessons.
  final bool _automaticallyColorLessons;

  /// The color map.
  final Map<String, Color> _colors;

  /// Creates a new color resolver instance.
  const ColorResolver._({
    bool automaticallyColorLessons = false,
    Map<String, Color> colors = const {},
  })  : _automaticallyColorLessons = automaticallyColorLessons,
        _colors = colors;

  /// Returns the [lesson] color.
  Color? resolveColor(Lesson lesson) => _automaticallyColorLessons ? Utils.randomColor(150, lesson.name.splitEqually(3)) : _colors[lesson.name];
}
