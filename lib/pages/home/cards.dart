import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/model/theme.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/pages/scaffold.dart';
import 'package:unicaen_timetable/pages/week_view/day_view.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A home material card, draggable and with an id.
abstract class MaterialCard extends StatelessWidget {
  /// The card identifier.
  final String cardId;

  /// Creates a new material card instance.
  const MaterialCard({
    @required this.cardId,
  });

  @override
  Widget build(BuildContext context) {
    UnicaenTimetableTheme theme = Provider.of<SettingsModel>(context).theme;
    Color color = buildColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Handle(
        delay: const Duration(milliseconds: 900),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                stops: [0.03, 0.03],
                colors: [color, theme.cardsBackgroundColor ?? color.withAlpha(40)],
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: LayoutBuilder(
                builder: (_, constraints) => Icon(
                  buildIcon(context),
                  color: theme.cardsTextColor ?? color,
                  size: constraints.maxHeight,
                ),
              ),
              title: Text(
                buildTitle(context),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.cardsTextColor ?? color,
                ),
              ),
              subtitle: Text(
                buildSubtitle(context),
                style: TextStyle(color: theme.cardsTextColor?.withAlpha(200) ?? color),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.cardsTextColor ?? color,
                ),
                onPressed: () => Provider.of<HomeCardsModel>(context, listen: false).removeCard(cardId),
              ),
              onTap: () => onTap(context),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the icon widget.
  IconData buildIcon(BuildContext context);

  /// Builds the card color.
  Color buildColor(BuildContext context);

  /// Builds the card title.
  String buildTitle(BuildContext context) => EzLocalization.of(context).get('home.${cardId}.title');

  /// Builds the card subtitle.
  String buildSubtitle(BuildContext context);

  /// Triggered when the user taps on the card.
  void onTap(BuildContext context);

  /// The card widget key.
  ValueKey get cardKey => ValueKey(cardId);
}

/// A card that uses remaining lessons of the day.
abstract class _RemainingLessonsCard extends MaterialCard {
  /// Creates the remaining lessons card.
  const _RemainingLessonsCard({
    @required String cardId,
  }) : super(cardId: cardId);

  @override
  Widget build(BuildContext context) {
    LessonModel lessonModel = Provider.of<LessonModel>(context);
    return FutureProvider<List<Lesson>>(
      create: (_) => lessonModel.remainingLessons.then((lessons) => lessons..sort()),
      child: Builder(builder: (context) => super.build(context)),
    );
  }
}

/// A card that shows the synchronization status.
class SynchronizationStatusCard extends MaterialCard {
  /// The card id.
  static const String ID = 'synchronization_status';

  /// Creates the synchronization status card.
  const SynchronizationStatusCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => isBad(context) ? Icons.sync_problem : Icons.sync;

  @override
  Color buildColor(BuildContext context) => isBad(context) ? Colors.red[700] : Colors.teal[700];

  @override
  String buildSubtitle(BuildContext context) {
    LessonModel lessonModel = Provider.of<LessonModel>(context);
    String date = lessonModel.lastModificationTime == null ? EzLocalization.of(context).get('home.synchronization_status.never') : DateFormat.yMd(EzLocalization.of(context).locale.languageCode).add_Hms().format(lessonModel.lastModificationTime);
    return date + '\n' + EzLocalization.of(context).get('home.synchronization_status.' + (isBad(context) ? 'bad' : 'good'));
  }

  @override
  void onTap(BuildContext context) {
    SynchronizeFloatingButton.onPressed(context);
  }

  bool isBad(BuildContext context) {
    SettingsModel settingsModel = Provider.of<SettingsModel>(context);
    LessonModel lessonModel = Provider.of<LessonModel>(context);

    return lessonModel.lastModificationTime == null || DateTime.now().difference(lessonModel.lastModificationTime).compareTo(Duration(days: settingsModel.getEntryByKey('server.interval').value) * 7) > 0;
  }
}

/// A card that allows to show the current lesson.
class CurrentLessonCard extends _RemainingLessonsCard {
  /// The card id.
  static const String ID = 'current_lesson';

  /// Creates a new current lesson card instance.
  const CurrentLessonCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => Icons.business_center;

  @override
  Color buildColor(BuildContext context) => Colors.pink[700];

  @override
  String buildSubtitle(BuildContext context) {
    List<Lesson> remainingLessons = Provider.of<List<Lesson>>(context) ?? [];
    DateTime now = DateTime.now();
    Lesson lesson = remainingLessons.firstWhere((lesson) => lesson.start.isBefore(now), orElse: () => null);
    return lesson?.toString(context) ?? EzLocalization.of(context).get('home.current_lesson.nothing');
  }

  @override
  void onTap(BuildContext context) {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.atMonday;
    }

    Provider.of<ValueNotifier<Page>>(context, listen: false).value = DayViewPage(weekDay: now.weekday);
  }
}

/// A card that allows to show the next lesson of today.
class NextLessonCard extends _RemainingLessonsCard {
  /// The card id.
  static const String ID = 'next_lesson';

  /// Creates a new next lesson card instance.
  const NextLessonCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => Icons.arrow_forward;

  @override
  Color buildColor(BuildContext context) => Colors.purple;

  @override
  String buildSubtitle(BuildContext context) {
    List<Lesson> remainingLessons = Provider.of<List<Lesson>>(context) ?? [];
    DateTime now = DateTime.now();
    Lesson lesson = remainingLessons.firstWhere((lesson) => now.isBefore(lesson.start), orElse: () => null);
    return lesson?.toString(context) ?? EzLocalization.of(context).get('home.next_lesson.nothing');
  }

  @override
  void onTap(BuildContext context) {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.atMonday;
    }

    Provider.of<ValueNotifier<Page>>(context, listen: false).value = DayViewPage(weekDay: now.weekday);
  }
}

/// A card that allows to change the app theme.
class ThemeCard extends MaterialCard {
  /// The card id.
  static const String ID = 'current_theme';

  /// Creates a new theme card instance.
  const ThemeCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => isDarkMode(context) ? Icons.brightness_3 : Icons.wb_sunny;

  @override
  Color buildColor(BuildContext context) => Colors.indigo[400];

  @override
  String buildSubtitle(BuildContext context) {
    return EzLocalization.of(context).get('home.current_theme.' + (isDarkMode(context) ? 'dark' : 'light'));
  }

  @override
  void onTap(BuildContext context) {
    SettingsModel settingsModel = Provider.of<SettingsModel>(context, listen: false);
    SettingsEntry<UnicaenTimetableTheme> themeEntry = settingsModel.getEntryByKey('application.theme');
    themeEntry.value = themeEntry.value.opposite;
    themeEntry.flush();
  }

  /// Returns whether the app is in dark mode.
  bool isDarkMode(BuildContext context) => Provider.of<SettingsModel>(context).theme is DarkTheme;
}
