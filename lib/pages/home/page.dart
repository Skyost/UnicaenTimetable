import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/pages/home/cards/current_lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/info.dart';
import 'package:unicaen_timetable/pages/home/cards/next_lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/synchronization_status.dart';
import 'package:unicaen_timetable/pages/home/cards/theme.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/widgets.dart';
import 'package:unicaen_timetable/widgets/drawer/list_title.dart';

/// The home page list tile.
class HomePageListTile extends StatelessWidget {
  /// Creates a new home page list tile.
  const HomePageListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PageListTitle(
        page: HomePage(),
        title: translations.home.title,
        icon: Icons.home,
      );
}

/// The home page app bar.
class HomePageAppBar extends ConsumerWidget {
  /// Creates a new home page app bar.
  const HomePageAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppBar(
        title: Text(translations.home.title),
        actions: [
          _AddButton(),
        ],
      );
}

/// The add button.
class _AddButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<HomeCard>> cards = ref.read(homeCardsProvider);
    return cards.valueOrNull == null || cards.value!.length == HomeCard.values.length
        ? const SizedBox.shrink()
        : PopupMenuButton<HomeCard>(
            icon: const Icon(Icons.add),
            itemBuilder: (context) => [
              for (HomeCard card in HomeCard.values)
                if (!cards.value!.contains(card))
                  PopupMenuItem<HomeCard>(
                    value: card,
                    child: Text(translations['home.${card.name}.name']),
                  ),
            ],
            onSelected: (card) async => await ref.read(homeCardsProvider.notifier).addCard(card),
          );
  }
}

/// The home page widget.
class HomePageWidget extends ConsumerWidget {
  /// Creates a new home page widget instance.
  const HomePageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<HomeCard>> homeCards = ref.watch(homeCardsProvider);
    if (homeCards.isLoading) {
      return const CenteredCircularProgressIndicator();
    }

    List<HomeCard> cards = homeCards.valueOrNull ?? [];
    return cards.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                translations.home.noCard,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.withAlpha(200),
                ),
              ),
            ),
          )
        : ReorderableListView.builder(
            padding: const EdgeInsets.all(20),
            onReorder: (oldIndex, newIndex) => ref.read(homeCardsProvider.notifier).reorder(oldIndex, newIndex),
            itemCount: cards.length,
            itemBuilder: (context, index) => switch (cards[index]) {
              HomeCard.synchronizationStatus => SynchronizationStatusCard(
                  key: ValueKey(cards[index]),
                ),
              HomeCard.currentLesson => CurrentLessonCard(
                  key: ValueKey(cards[index]),
                ),
              HomeCard.nextLesson => NextLessonCard(
                  key: ValueKey(cards[index]),
                ),
              HomeCard.theme => ThemeCard(
                  key: ValueKey(cards[index]),
                ),
              HomeCard.info => InfoCard(
                  key: ValueKey(cards[index]),
                ),
            },
            proxyDecorator: (widget, index, animation) => widget,
          );
  }
}
