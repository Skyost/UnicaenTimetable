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
  static const Color defaultColor = Color(0xCC2196F3);

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<LessonWithColor>> lessons = queryLessons();
    return switch (lessons) {
      AsyncData<List<LessonWithColor>>(:final value) => buildChild(
          value.map(FlutterWeekViewEventWithLesson.fromLesson).toList(),
        ),
      AsyncError(:final error) => Center(
          child: Text(
            error.toString(),
          ),
        ),
      _ => const CenteredCircularProgressIndicator(),
    };
  }

  /// Creates an event widget.
  Widget createEventWidget(FlutterWeekViewEventWithLesson event, double height, double width) {
    Color? backgroundColor = event.value.color;
    backgroundColor ??= defaultColor.withAlpha(150);
    Color textColor = backgroundColor.isDark ? Colors.white : Colors.black;
    return GestureDetector(
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
        await ref.read(lessonColorResolverProvider.notifier).setLessonColor(event.value, color);
      },
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(event.title),
          scrollable: true,
          content: Text('${event.start.hour.withLeadingZero}:${event.start.minute.withLeadingZero} — ${event.end.hour.withLeadingZero}:${event.end.minute.withLeadingZero}\n\n${event.description}'),
          actions: [
            TextButton(
              onPressed: () => UnicaenTimetableRoot.channel.invokeMethod(
                'activity.scheduleReminder',
                {
                  'title': event.title,
                  'hour': event.start.hour,
                  'minute': event.start.minute,
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
      child: FlutterWeekViewEventWidget<FlutterWeekViewEventWithLesson>(
        event: event,
        height: height,
        width: width,
        textStyle: TextStyle(color: textColor),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Creates the Flutter Week View day view style.
  DayViewStyle createDayViewStyle(DateTime date) => DayViewStyle(
        backgroundColor: Utils.isToday(date) ? (currentBrightness == Brightness.light ? const Color(0xFFE3F5FF) : Theme.of(context).colorScheme.surfaceBright) : Theme.of(context).colorScheme.surface,
        backgroundRulesColor: Colors.black12,
      );

  /// Creates the day bar style.
  DayBarStyle createDayBarStyle(DateTime date, DateFormatter dateFormatter) => DayBarStyle.fromDate(
        date: date,
        textStyle: TextStyle(color: Utils.isToday(date) ? (currentBrightness == Brightness.light ? Colors.indigo : Colors.white) : null),
        color: currentBrightness == Brightness.light ? null : Theme.of(context).colorScheme.surface,
        dateFormatter: dateFormatter,
      );

  /// Creates the hours column style.
  HourColumnStyle createHoursColumnStyle() => HourColumnStyle(
        color: currentBrightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
        textStyle: Theme.of(context).textTheme.bodySmall,
      );

  /// Formats a date.
  String formatDate(BuildContext context, int year, int month, int day) {
    String? languageCode = TranslationProvider.of(context).locale.languageCode;
    return DateFormat.yMMMMEEEEd(languageCode).format(DateTime(year, month, day)).capitalize();
  }

  /// Builds the widget child.
  Widget buildChild(List<FlutterWeekViewEventWithLesson> events);

  /// Returns the lessons.
  AsyncValue<List<LessonWithColor>> queryLessons();
}

/// A [FlutterWeekViewEvent] that holds a [Lesson].
class FlutterWeekViewEventWithLesson extends FlutterWeekViewEventWithValue<LessonWithColor> {
  /// Creates a new flutter week view event instance.
  FlutterWeekViewEventWithLesson._({
    required super.value,
    required super.title,
    required super.description,
    required super.start,
    required super.end,
  });

  /// Creates a new flutter week view event instance.
  FlutterWeekViewEventWithLesson.fromLesson(LessonWithColor lesson)
      : this._(
          value: lesson,
          title: lesson.name,
          description: lesson.description ?? '',
          start: lesson.dateTime.start,
          end: lesson.dateTime.end,
        );

  @override
  FlutterWeekViewEventWithLesson copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    LessonWithColor? value,
  }) =>
      FlutterWeekViewEventWithLesson._(
        title: title ?? this.title,
        description: description ?? this.description,
        start: start ?? this.start,
        end: end ?? this.end,
        value: value ?? this.value,
      );
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
