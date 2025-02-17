import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/color_resolver.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/lessons/storage.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/brightness_listener.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/utils/widgets.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';

/// A widget that shows a FlutterWeekView widget.
abstract class FlutterWeekViewWidgetState<T extends ConsumerStatefulWidget> extends ConsumerState<T> with BrightnessListener {
  /// The default event color.
  static const defaultColor = Color(0xCC2196F3);

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<Lesson>> lessons = queryLessons();
    return switch (lessons) {
      AsyncData<List<Lesson>>(:final value) => buildChild(
          value.map(createEvent).toList(),
        ),
      AsyncError(:final error) => Center(
          child: Text(
            error.toString(),
          ),
        ),
      _ => const CenteredCircularProgressIndicator(),
    };
  }

  /// Creates an event.
  FlutterWeekViewEvent createEvent(Lesson lesson) {
    Color? backgroundColor = lesson is LessonWithColor ? lesson.color : null;
    backgroundColor ??= defaultColor.withAlpha(150);
    Color textColor = backgroundColor.isDark ? Colors.white : Colors.black;
    return FlutterWeekViewEvent(
      title: lesson.name,
      description: lesson.description ?? '',
      start: lesson.dateTime.start,
      end: lesson.dateTime.end,
      backgroundColor: backgroundColor,
      onLongPress: () async {
        Color? color = await ColorInputDialog.getValue(
          context,
          title: translations.dialogs.lessonColor.title,
          initialValue: backgroundColor,
          resetColor: defaultColor,
        );
        if (color == defaultColor) {
          color = null;
        }
        await ref.read(lessonColorResolverProvider.notifier).setLessonColor(lesson, color);
      },
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(lesson.name),
          scrollable: true,
          content: Text(
              '${lesson.dateTime.start.hour.withLeadingZero}:${lesson.dateTime.start.minute.withLeadingZero} — ${lesson.dateTime.end.hour.withLeadingZero}:${lesson.dateTime.end.minute.withLeadingZero}\n\n${lesson.description ?? ''}'),
          actions: [
            TextButton(
              onPressed: () => UnicaenTimetableRoot.channel.invokeMethod(
                'activity.scheduleReminder',
                {
                  'title': lesson.name,
                  'hour': lesson.dateTime.start.hour,
                  'minute': lesson.dateTime.start.minute,
                },
              ),
              child: Text(translations.dialogs.lessonInfo.scheduleReminder),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ),
      ),
      textStyle: TextStyle(color: textColor),
    );
  }

  /// Creates the Flutter Week View day view style.
  DayViewStyle createDayViewStyle(DateTime date) => DayViewStyle(
        backgroundColor: Utils.isToday(date) ? (currentBrightness == Brightness.light ? const Color(0xFFE3F5FF) : const Color(0xFF253341)) : Theme.of(context).scaffoldBackgroundColor,
        backgroundRulesColor: Colors.black12,
      );

  /// Creates the day bar style.
  DayBarStyle createDayBarStyle(DateTime date, DateFormatter dateFormatter) => DayBarStyle.fromDate(
        date: date,
        textStyle: TextStyle(color: Utils.isToday(date) ? (currentBrightness == Brightness.light ? Colors.indigo : Colors.white) : null),
        color: currentBrightness == Brightness.light ? null : const Color(0xFF202D3B),
        dateFormatter: dateFormatter,
      );

  /// Creates the hours column style.
  HoursColumnStyle createHoursColumnStyle() => HoursColumnStyle(
        color: currentBrightness == Brightness.light ? Colors.white : const Color(0xFF202D3B),
        textStyle: Theme.of(context).textTheme.bodySmall,
      );

  /// Formats a date.
  String formatDate(BuildContext context, int year, int month, int day) {
    String? languageCode = TranslationProvider.of(context).locale.languageCode;
    return DateFormat.yMMMMEEEEd(languageCode).format(DateTime(year, month, day)).capitalize();
  }

  /// Builds the widget child.
  Widget buildChild(List<FlutterWeekViewEvent> events);

  /// Returns the lessons.
  AsyncValue<List<Lesson>> queryLessons();
}

/// A button that allows to show the week picker.
class WeekPickerButton extends ConsumerWidget {
  /// Creates a new week picker button instance.
  const WeekPickerButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<List<DateTime>> availableWeeks = ref.watch(localStorageProvider).getAvailableWeeks();
    return FutureBuilder<List<DateTime>>(
      future: availableWeeks,
      builder: (context, snapshot) => IconButton(
        icon: const Icon(Icons.date_range),
        onPressed: snapshot.hasData
            ? (() async {
                DateFormat formatter = DateFormat.yMMMd(TranslationProvider.of(context).locale.languageCode);
                DateTime monday = ref.read(dateProvider).atMonday;
                DateTime? selectedDate = await MultiChoicePickerDialog.getValue<DateTime>(
                  context,
                  title: translations.dialogs.weekPicker.title,
                  emptyMessage: translations.dialogs.weekPicker.empty,
                  values: snapshot.requireData,
                  initialValue: monday,
                  valueToString: (date) => '${formatter.format(monday)} — ${formatter.format(monday.atSunday)}',
                );
                if (selectedDate != null) {
                  ref.read(dateProvider.notifier).changeDate(selectedDate);
                }
              })
            : null,
      ),
    );
  }
}
