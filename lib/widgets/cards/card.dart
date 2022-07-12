import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/lesson.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/theme.dart';
import 'package:unicaen_timetable/widgets/cards/current_lesson.dart';
import 'package:unicaen_timetable/widgets/cards/dumb.dart';
import 'package:unicaen_timetable/widgets/cards/info.dart';
import 'package:unicaen_timetable/widgets/cards/next_lesson.dart';
import 'package:unicaen_timetable/widgets/cards/synchronization_status.dart';
import 'package:unicaen_timetable/widgets/cards/theme.dart';

/// A home material card, draggable and with an id.
abstract class MaterialCard<T> extends ConsumerWidget {
  /// The card identifier.
  final String cardId;

  /// Triggered when the card should be removed.
  final VoidCallback? onRemove;

  /// Creates a new material card instance.
  MaterialCard({
    required this.cardId,
    this.onRemove,
  }) : super(
          key: ValueKey('material-card-$cardId'),
        );

  /// Creates a card instance by its id.
  static MaterialCard createFromId(String cardId, VoidCallback onRemove) {
    switch (cardId) {
      case SynchronizationStatusCard.id:
        return SynchronizationStatusCard(onRemove: onRemove);
      case CurrentLessonCard.id:
        return CurrentLessonCard(onRemove: onRemove);
      case NextLessonCard.id:
        return NextLessonCard(onRemove: onRemove);
      case ThemeCard.id:
        return ThemeCard(onRemove: onRemove);
      case InfoCard.id:
        return InfoCard(onRemove: onRemove);
      case DumbCard.id:
      default:
        return DumbCard(id: cardId, onRemove: onRemove);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UnicaenTimetableTheme theme = ref.watch(settingsModelProvider).resolveTheme(context);
    Color color = buildColor(context, ref);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              stops: const [0.03, 0.03],
              colors: [color, theme.cardsBackgroundColor ?? color.withAlpha(40)],
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
            leading: LayoutBuilder(
              builder: (_, constraints) => Padding(
                padding: EdgeInsets.only(left: 0.03 * constraints.maxWidth + 20),
                child: Icon(
                  buildIcon(context, ref),
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
            subtitle: FutureBuilder<T>(
              initialData: null,
              future: requestData(context, ref),
              builder: (context, snapshot) => Text(
                snapshot.hasData ? buildSubtitle(context, snapshot.requireData) : context.getString('home.loading'),
                style: TextStyle(color: theme.cardsTextColor?.withAlpha(200) ?? color),
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.close,
                color: theme.cardsTextColor ?? color,
              ),
              onPressed: onRemove,
            ),
            onTap: () => onTap(context, ref),
          ),
        ),
      ),
    );
  }

  /// Requests data needed to show the card.
  Future<T> requestData(BuildContext context, WidgetRef ref);

  /// Builds the icon widget.
  IconData buildIcon(BuildContext context, WidgetRef ref);

  /// Builds the card color.
  Color buildColor(BuildContext context, WidgetRef ref);

  /// Builds the card title.
  String buildTitle(BuildContext context) => context.getString('home.$cardId.title');

  /// Builds the card subtitle.
  String buildSubtitle(BuildContext context, T data) => data.toString();

  /// Triggered when the user taps on the card.
  void onTap(BuildContext context, WidgetRef ref);
}

/// A card that uses remaining lessons of the day.
abstract class RemainingLessonsCard extends MaterialCard<List<Lesson>> {
  /// Creates the remaining lessons card.
  RemainingLessonsCard({
    required super.cardId,
    super.onRemove,
  });

  @override
  Future<List<Lesson>> requestData(BuildContext context, WidgetRef ref) {
    LessonRepository lessonRepository = ref.watch(lessonRepositoryProvider);
    return lessonRepository.remainingLessons.then((lessons) => lessons..sort());
  }

  @override
  String buildSubtitle(BuildContext context, List<Lesson> data);
}
