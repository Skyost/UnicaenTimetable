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

abstract class MaterialCard extends StatelessWidget {
  final String cardId;

  const MaterialCard({
    @required this.cardId,
  });

  @override
  Widget build(BuildContext context) {
    AppTheme theme = Provider.of<SettingsModel>(context).theme;
    Color color = buildColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Handle(
        delay: const Duration(milliseconds: 500),
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

  IconData buildIcon(BuildContext context);

  Color buildColor(BuildContext context);

  String buildTitle(BuildContext context) => EzLocalization.of(context).get('home.${cardId}.title');

  String buildSubtitle(BuildContext context);

  void onTap(BuildContext context);

  ValueKey get cardKey => ValueKey(cardId);
}

abstract class _RemainingLessonsCard extends MaterialCard {
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

class SynchronizationStatusCard extends MaterialCard {
  static const String ID = 'synchronization_status';

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

class CurrentLessonCard extends _RemainingLessonsCard {
  static const String ID = 'current_lesson';

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

class NextLessonCard extends _RemainingLessonsCard {
  static const String ID = 'next_lesson';

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

class ThemeCard extends MaterialCard {
  static const String ID = 'current_theme';

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
    SettingsEntry<AppTheme> themeEntry = settingsModel.getEntryByKey('application.theme');
    themeEntry.value = themeEntry.value.opposite;
    themeEntry.flush();
  }

  bool isDarkMode(BuildContext context) => Provider.of<SettingsModel>(context).theme is DarkAppTheme;
}
