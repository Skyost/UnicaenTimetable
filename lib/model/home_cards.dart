import 'dart:io';

import 'package:hive/hive.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/pages/home/cards/card.dart';
import 'package:unicaen_timetable/pages/home/cards/current_lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/info.dart';
import 'package:unicaen_timetable/pages/home/cards/next_lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/synchronization_status.dart';
import 'package:unicaen_timetable/pages/home/cards/theme.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The home cards model.
class HomeCardsModel extends UnicaenTimetableModel {
  /// The hive box.
  static const String _HIVE_BOX = 'home_cards';

  /// The home cards box.
  Box<String> _homeCardsBox;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    bool boxExists = await Hive.boxExists(_HIVE_BOX);
    _homeCardsBox = await Hive.openBox<String>(_HIVE_BOX);
    if(!boxExists) {
      _addInitialData();
    }
    markInitialized();
  }

  /// Adds initial data to the Hive box.
  void _addInitialData() {
    if(!Platform.isIOS) {
      return;
    }

    addCard(SynchronizationStatusCard.ID);
  }

  /// Adds a card to this model.
  Future<void> addCard(String id) async {
    await _homeCardsBox.add(id);
    notifyListeners();
  }

  /// Removes a card from this model.
  Future<void> removeCard(String id) async {
    await _homeCardsBox.delete(_homeCardsBox.toMap().getByValue(id));
    notifyListeners();
  }

  /// Returns whether this model has the specified card.
  bool hasCard(String id) => _homeCardsBox.values.contains(id);

  /// Reorders the cards.
  Future<void> reorder(List<MaterialCard> cards) async {
    await _homeCardsBox.clear();
    await _homeCardsBox.addAll(cards.map((card) => card.cardId).toList());
    notifyListeners();
  }

  /// Returns all added cards, in order.
  List<MaterialCard> get cards {
    List<MaterialCard> cardsList = [];
    for (String cardId in _homeCardsBox.values) {
      MaterialCard card = createCardById(cardId);
      if (card != null) {
        cardsList.add(card);
      }
    }
    return cardsList;
  }

  /// Creates a card instance by its id.
  MaterialCard createCardById(String cardId) {
    switch (cardId) {
      case SynchronizationStatusCard.ID:
        return const SynchronizationStatusCard();
      case CurrentLessonCard.ID:
        return const CurrentLessonCard();
      case NextLessonCard.ID:
        return const NextLessonCard();
      case ThemeCard.ID:
        return const ThemeCard();
      case InfoCard.ID:
        return const InfoCard();
      default:
        return null;
    }
  }
}
