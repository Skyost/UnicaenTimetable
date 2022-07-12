import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/cards/synchronization_status.dart';

final homeCardsModelProvider = ChangeNotifierProvider((ref) {
  HomeCardsModel model = HomeCardsModel();
  model.initialize();
  return model;
});

/// The home cards model.
class HomeCardsModel extends UnicaenTimetableModel {
  /// The hive box.
  static const String _hiveBox = 'home_cards';

  /// The home cards box.
  Box<String>? _homeCardsBox;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    bool boxExists = await Hive.boxExists(_hiveBox);
    _homeCardsBox = await Hive.openBox<String>(_hiveBox);
    if (!boxExists) {
      _addInitialData();
    }
    markInitialized();
  }

  /// Adds initial data to the Hive box.
  void _addInitialData() {
    if (!Platform.isIOS) {
      return;
    }

    addCard(SynchronizationStatusCard.id);
  }

  /// Adds a card to this model.
  Future<void> addCard(String id) async {
    if (isInitialized) {
      await _homeCardsBox!.add(id);
      notifyListeners();
    }
  }

  /// Removes a card from this model.
  Future<void> removeCard(String id) async {
    if (isInitialized) {
      await _homeCardsBox!.delete(_homeCardsBox!.toMap().getByValue(id));
      notifyListeners();
    }
  }

  /// Returns whether this model has the specified card.
  bool hasCard(String id) => isInitialized ? _homeCardsBox!.values.contains(id) : false;

  /// Reorders the cards.
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (isInitialized) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      List<String> cards = _homeCardsBox!.values.toList();
      String card = cards.removeAt(oldIndex);
      cards.insert(newIndex, card);
      await _homeCardsBox!.clear();
      await _homeCardsBox!.addAll(cards);
      notifyListeners();
    }
  }

  /// Returns all added cards, in order.
  Iterable<String> get cards {
    if (!isInitialized) {
      return [];
    }

    return _homeCardsBox!.values;
  }
}
