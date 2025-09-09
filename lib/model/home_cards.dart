import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The home cards provider.
final homeCardsProvider = AsyncNotifierProvider<HomeCardsNotifier, List<HomeCard>>(HomeCardsNotifier.new);

/// The home cards model.
class HomeCardsNotifier extends AsyncNotifier<List<HomeCard>> {
  /// The home cards key.
  static const String _homeCardsKey = 'homeCards';

  @override
  FutureOr<List<HomeCard>> build() async {
    SharedPreferencesWithCache sharedPreferences = await ref.watch(sharedPreferencesProvider.future);
    List<String> cards = sharedPreferences.getStringList(_homeCardsKey) ?? [HomeCard.synchronizationStatus.name];
    return [
      for (String card in cards) HomeCard.values.byNameOrNull(card) ?? HomeCard.info,
    ];
  }

  /// Adds a card to this model.
  Future<void> addCard(HomeCard homeCard) async {
    List<HomeCard> cards = await future;
    _saveAndUse([...cards, homeCard]);
  }

  /// Removes a card from this model.
  Future<void> removeCard(HomeCard homeCard) async {
    List<HomeCard> cards = await future;
    _saveAndUse([
      for (HomeCard card in cards)
        if (card != homeCard) card,
    ]);
  }

  /// Returns whether this model has the specified card.
  Future<bool> hasCard(HomeCard homeCard) async => (await future).contains(homeCard);

  /// Reorders the cards.
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    List<HomeCard> cards = List.of(await future);
    HomeCard card = cards.removeAt(oldIndex);
    cards.insert(newIndex, card);
    _saveAndUse(cards);
  }

  /// Saves the [cards] and use it as [state].
  Future<void> _saveAndUse(List<HomeCard> cards) async {
    state = AsyncData(cards);
    SharedPreferencesWithCache sharedPreferences = await ref.read(sharedPreferencesProvider.future);
    await sharedPreferences.setStringList(
      _homeCardsKey,
      [
        for (HomeCard card in cards) card.name,
      ],
    );
  }
}

/// Represents a home card.
enum HomeCard {
  /// Displays the synchronization status.
  synchronizationStatus,

  /// Displays the current lesson.
  currentLesson,

  /// Displays the next lesson.
  nextLesson,

  /// Displays the theme.
  theme,

  /// Displays various info.
  info,
}
