import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/widgets/cards/synchronization_status.dart';

final homeCardsModelProvider = ChangeNotifierProvider((ref) {
  HomeCardsModel model = HomeCardsModel();
  model.initialize();
  return model;
});

/// The home cards model.
class HomeCardsModel extends UnicaenTimetableModel {
  /// The file name.
  static const String _homeCardsFilename = 'home_cards.json';

  /// The home cards list.
  List<String>? _homeCardsList;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    bool boxExists = await UnicaenTimetableModel.storage.fileExists(_homeCardsFilename);
    _homeCardsList = jsonDecode(await UnicaenTimetableModel.storage.readFile(_homeCardsFilename));
    if (!boxExists) {
      _addInitialData();
    }
    markInitialized();
  }

  /// Adds initial data to the model.
  void _addInitialData() {
    if (!Platform.isIOS) {
      return;
    }

    addCard(SynchronizationStatusCard.id);
    _save();
  }

  /// Adds a card to this model.
  Future<void> addCard(String id) async {
    if (isInitialized) {
      _homeCardsList!.add(id);
      notifyListeners();
      _save();
    }
  }

  /// Removes a card from this model.
  Future<void> removeCard(String id) async {
    if (isInitialized) {
      _homeCardsList!.remove(id);
      notifyListeners();
      _save();
    }
  }

  /// Returns whether this model has the specified card.
  bool hasCard(String id) => isInitialized ? _homeCardsList!.contains(id) : false;

  /// Reorders the cards.
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (isInitialized) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      String card = _homeCardsList!.removeAt(oldIndex);
      _homeCardsList!.insert(newIndex, card);
      notifyListeners();
      _save();
    }
  }

  /// Returns all added cards, in order.
  Iterable<String> get cards {
    if (!isInitialized) {
      return [];
    }

    return _homeCardsList!;
  }

  Future<void> _save() async {
    if (!isInitialized) {
      return;
    }
    await UnicaenTimetableModel.storage.saveFile(_homeCardsFilename, jsonEncode(_homeCardsList));
  }
}
