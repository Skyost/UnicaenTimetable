import 'package:hive/hive.dart';
import 'package:unicaen_timetable/model/app_model.dart';
import 'package:unicaen_timetable/pages/home/cards.dart';
import 'package:unicaen_timetable/utils/utils.dart';

class HomeCardsModel extends AppModel {
  static const String _HIVE_BOX = 'home_cards';

  Box<String> _homeCardsBox;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    _homeCardsBox = await Hive.openBox<String>(_HIVE_BOX);
    markInitialized();
  }

  Future<void> addCard(String id) async {
    await _homeCardsBox.add(id);
    notifyListeners();
  }

  Future<void> removeCard(String id) async {
    await _homeCardsBox.delete(_homeCardsBox.toMap().getByValue(id));
    notifyListeners();
  }

  bool hasCard(String id) => _homeCardsBox.values.contains(id);

  Future<void> reorder(List<MaterialCard> cards) async {
    await _homeCardsBox.clear();
    await _homeCardsBox.addAll(cards.map((card) => card.cardId).toList());
    notifyListeners();
  }

  List<MaterialCard> get cardsList {
    List<MaterialCard> cardsList = [];
    for (String cardId in _homeCardsBox.values) {
      MaterialCard card = createCardById(cardId);
      if (card != null) {
        cardsList.add(card);
      }
    }
    return cardsList;
  }

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
      default:
        return null;
    }
  }
}
