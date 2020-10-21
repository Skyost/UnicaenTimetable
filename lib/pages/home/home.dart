import 'package:admob_flutter/admob_flutter.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/model/settings/entries/application/admob.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/home/cards/card.dart';
import 'package:unicaen_timetable/pages/home/cards/current_lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/info.dart';
import 'package:unicaen_timetable/pages/home/cards/next_lesson.dart';
import 'package:unicaen_timetable/pages/home/cards/synchronization_status.dart';
import 'package:unicaen_timetable/pages/home/cards/theme.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/utils/widgets.dart';

/// The home page widget.
class HomePage extends StaticTitlePage {
  /// Creates a new home page widget instance.
  const HomePage()
      : super(
          titleKey: 'home.title',
          icon: Icons.home,
        );

  @override
  _HomePageState createState() => _HomePageState();

  @override
  List<Widget> buildActions(BuildContext context) => [
        PopupMenuButton<String>(
          icon: const Icon(Icons.add),
          itemBuilder: (context) => [SynchronizationStatusCard.ID, CurrentLessonCard.ID, NextLessonCard.ID, ThemeCard.ID, InfoCard.ID]
              .map(
                (id) => PopupMenuItem<String>(
                  child: Text(context.getString('home.${id}.name')),
                  value: id,
                ),
              )
              .toList(),
          onSelected: (id) async {
            HomeCardsModel homeCardsModel = context.get<HomeCardsModel>();
            if (homeCardsModel.hasCard(id)) {
              Utils.showSnackBar(
                context: context,
                icon: Icons.close,
                textKey: 'widget_already_present',
                color: Colors.red[800],
              );
              return;
            }

            unawaited(homeCardsModel.addCard(id));
          },
        )
      ];
}

/// The home page state.
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    HomeCardsModel homeCardsModel = context.watch<HomeCardsModel>();
    if (!homeCardsModel.isInitialized) {
      return const CenteredCircularProgressIndicator();
    }

    List<MaterialCard> items = homeCardsModel.cards;
    if (items.isEmpty) {
      return _MainStack(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.getString('home.no_card'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: context.watch<SettingsModel>().resolveTheme(context).textColor ?? Colors.black.withAlpha(150),
              ),
            ),
          ),
        ),
      );
    }

    return _MainStack(
      child: ImplicitlyAnimatedReorderableList<MaterialCard>(
        padding: listPadding,
        items: items,
        areItemsTheSame: (first, second) => first.cardId == second.cardId,
        onReorderFinished: (card, from, to, cards) => homeCardsModel.reorder(cards),
        itemBuilder: (context, itemAnimation, card, position) {
          return Reorderable(
            key: card.cardKey,
            child: card,
          );
        },
      ),
    );
  }

  /// Returns the list padding.
  EdgeInsetsGeometry get listPadding => const EdgeInsets.all(20);
}

/// The home page stack that shows a banner ad at the bottom.
class _MainStack extends StatelessWidget {
  /// The stack child (the list).
  final Widget child;

  /// Creates a new main stack instance.
  const _MainStack({
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    AdMobSettingsEntry adMobSettingsEntry = context.watch<SettingsModel>().adMobEntry;
    AdmobBanner banner = adMobSettingsEntry.createBanner(context);
    if (banner == null) {
      return child;
    }

    return FutureBuilder<Size>(
      initialData: Size.zero,
      future: adMobSettingsEntry.calculateSize(context),
      builder: (context, sizeSnapshot) => Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: sizeSnapshot.data.height),
            child: child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: banner,
          ),
        ],
      ),
    );
  }
}
