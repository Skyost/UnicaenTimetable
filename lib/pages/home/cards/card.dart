import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/theme.dart';

/// A home material card, draggable and with an id.
abstract class MaterialCard extends StatelessWidget {
  /// The card identifier.
  final String cardId;

  /// Creates a new material card instance.
  const MaterialCard({
    required this.cardId,
  });

  @override
  Widget build(BuildContext context) {
    UnicaenTimetableTheme theme = context.watch<SettingsModel>().resolveTheme(context);
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
              contentPadding: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
              leading: LayoutBuilder(
                builder: (_, constraints) => Padding(
                  padding: EdgeInsets.only(left: 0.03 * constraints.maxWidth + 20),
                  child: Icon(
                    buildIcon(context),
                    color: theme.cardsTextColor ?? color,
                    size: constraints.maxHeight,
                  ),
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
                onPressed: () => context.read<HomeCardsModel>().removeCard(cardId),
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
  String buildTitle(BuildContext context) => context.getString('home.$cardId.title');

  /// Builds the card subtitle.
  String buildSubtitle(BuildContext context);

  /// Triggered when the user taps on the card.
  void onTap(BuildContext context);

  /// The card widget key.
  ValueKey get cardKey => ValueKey(cardId);
}

/// A card that uses remaining lessons of the day.
abstract class RemainingLessonsCard extends MaterialCard {
  /// Creates the remaining lessons card.
  const RemainingLessonsCard({
    required String cardId,
  }) : super(cardId: cardId);

  @override
  Widget build(BuildContext context) {
    LessonModel lessonModel = context.watch<LessonModel>();
    return FutureProvider<List<Lesson>?>(
      initialData: null,
      create: (_) => lessonModel.remainingLessons.then((lessons) => lessons..sort()),
      child: Builder(builder: (context) => super.build(context)),
    );
  }
}