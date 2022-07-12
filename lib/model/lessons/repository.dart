import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/authentication/result.dart';
import 'package:unicaen_timetable/model/lessons/authentication/state.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/user/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/utils/calendar_url.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';

final lessonRepositoryProvider = ChangeNotifierProvider((ref) {
  LessonRepository repository = LessonRepository();
  repository.initialize();
  return repository;
});

/// The lesson model.
class LessonRepository extends UnicaenTimetableModel {
  /// The lessons Hive box name.
  static const String _lessonsHiveBox = 'lessons';

  /// The lessons colors Hive box name.
  static const String _lessonsColorsHiveBox = 'lessons_colors';

  /// The lessons Hive box.
  LazyBox<List>? _lessonsBox;

  /// The lessons colors Hive box.
  Box<int>? _lessonsColorsBox;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    Hive.registerAdapter(LessonAdapter());
    _lessonsBox = await Hive.openLazyBox<List>(_lessonsHiveBox);
    _lessonsColorsBox = await Hive.openBox(_lessonsColorsHiveBox);

    markInitialized();
  }

  /// Returns the lessons of a date.
  Future<List<Lesson>> getLessonsForDate(DateTime date) async {
    if (!isInitialized) {
      return [];
    }

    List result = (await _lessonsBox!.get(date.yearMonthDay.toString())) ?? [];
    return List<Lesson>.from(result);
  }

  /// Selects the lessons available between two dates.
  Future<List<Lesson>> selectLessons(DateTime min, DateTime max) async {
    List<Lesson> result = [];
    DateTime date = min;
    while (date.isBefore(max)) {
      result.addAll(await getLessonsForDate(date));
      date = date.add(const Duration(days: 1));
    }
    return result;
  }

  /// Returns the remaining today's lessons.
  Future<List<Lesson>> get remainingLessons async {
    DateTime now = DateTime.now();
    List<Lesson> result = await getLessonsForDate(now);
    for (Lesson lesson in List<Lesson>.of(result, growable: false)) {
      if (now.isAfter(lesson.end)) {
        result.remove(lesson);
      }
    }

    return result..sort();
  }

  /// Clears all lessons.
  Future<void> clearLessons() async {
    if (!isInitialized) {
      return;
    }

    await _lessonsBox!.clear();
    notifyListeners();
  }

  /// Returns all weeks handled.
  Future<List<DateTime>> get availableWeeks async {
    if (!isInitialized) {
      return [];
    }

    Set<DateTime> result = HashSet();
    for (String date in _lessonsBox!.keys) {
      DateTime monday = DateTime.parse(date).atMonday;
      if (!result.contains(monday)) {
        result.add(monday);
      }
    }
    return result.toList()..sort();
  }

  /// Downloads lessons from a widget.
  Future<void> downloadLessonsFromWidget(BuildContext context, WidgetRef ref) async {
    Utils.showSnackBar(
      context: context,
      icon: Icons.sync,
      textKey: 'synchronizing',
      color: Theme.of(context).primaryColor,
    );

    User? user = await ref.read(userRepositoryProvider).getUser();
    SettingsModel settingsModel = ref.read(settingsModelProvider);
    RequestResultState state = await downloadLessons(calendarUrl: settingsModel.calendarUrl, user: user);
    switch (state) {
      case RequestResultState.success:
        Utils.showSnackBar(
          context: context,
          icon: Icons.check,
          textKey: state.id,
          color: Colors.green[700]!,
        );
        break;
      case RequestResultState.notFound:
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.getString('calendar_not_found.title')),
            content: SingleChildScrollView(
              child: Text(context.getString('calendar_not_found.message')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
              )
            ],
          ),
        );
        break;
      case RequestResultState.unauthorized:
        Utils.showSnackBar(
          context: context,
          icon: Icons.error_outline,
          textKey: state.id,
          color: Colors.amber[800]!,
          onVisible: () => LoginDialog.show(context),
        );
        break;
      default:
        Utils.showSnackBar(
          context: context,
          icon: Icons.error_outline,
          textKey: state.id,
          color: Colors.red[800]!,
        );
        break;
    }
  }

  /// Synchronizes the app with Zimbra.
  Future<RequestResultState> downloadLessons({
    required CalendarUrl calendarUrl,
    required User? user,
  }) async {
    try {
      if (!isInitialized) {
        return RequestResultState.genericError;
      }

      if (user == null) {
        return RequestResultState.unauthorized;
      }

      RequestResult<Map<DateTime, List<Lesson>>> result = await user.downloadLessons(calendarUrl);
      if (result.state != RequestResultState.success) {
        return result.state;
      }

      Map<DateTime, List<Lesson>> lessons = result.object;
      _lessonsBox!.clear();
      for (MapEntry<DateTime, List<Lesson>> entry in lessons.entries) {
        _lessonsBox!.put(entry.key.toString(), entry.value);
      }
      if (Platform.isAndroid) {
        Map<String, List<_JsonLesson>> jsonContent = HashMap();
        for (String boxKey in _lessonsBox!.keys) {
          DateTime date = DateTime.parse(boxKey);
          String key = date.millisecondsSinceEpoch.toString();

          List lessons = (await _lessonsBox!.get(boxKey)) ?? [];
          jsonContent[key] = lessons.map((lesson) => _JsonLesson.fromLesson(lesson)).toList();
        }

        Directory directory = await getApplicationDocumentsDirectory();
        File('${directory.path}/android_lessons.json').writeAsStringSync(jsonEncode(jsonContent), flush: true);
        UnicaenTimetableRoot.channel.invokeMethod('sync.finished');
      }

      notifyListeners();
      return RequestResultState.success;
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return RequestResultState.genericError;
  }

  /// Returns the last modification time.
  DateTime? get lastModificationTime => isInitialized ? File(_lessonsBox!.path!).lastModifiedSync() : null;

  /// Returns the color of a lesson (depends on the name).
  Color? getLessonColor(Lesson lesson) {
    int? value = _lessonsColorsBox?.get(lesson.name);
    return value == null ? null : Color(value);
  }

  /// Sets the lesson color according to its name.
  Future<void> setLessonColor(Lesson lesson, Color color) async {
    if (isInitialized) {
      await _lessonsColorsBox!.put(lesson.name, color.value);
      notifyListeners();
    }
  }

  /// Resets the lesson color according to its name.
  Future<void> resetLessonColor(Lesson lesson) async {
    if (isInitialized) {
      await _lessonsColorsBox!.delete(lesson.name);
      notifyListeners();
    }
  }
}

/// Represents a JSON lesson.
class _JsonLesson {
  /// The lesson name.
  final String name;

  /// The lesson start timestamp.
  final int start;

  /// The lesson end timestamp.
  final int end;

  /// The lesson location.
  final String location;

  /// Creates a new JSON lesson instance from a lesson.
  _JsonLesson.fromLesson(Lesson lesson)
      : name = lesson.name,
        start = lesson.start.millisecondsSinceEpoch,
        end = lesson.end.millisecondsSinceEpoch,
        location = lesson.location;

  /// Converts this lesson to a JSON map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'start': start,
        'end': end,
        'location': location,
      };
}
