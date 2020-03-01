import 'package:admob_flutter/admob_flutter.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/admob.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/pages/home/cards.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

class HomePage extends StaticTitlePage {
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
          icon: Icon(Icons.add),
          itemBuilder: (context) => [SynchronizationStatusCard.ID, CurrentLessonCard.ID, NextLessonCard.ID, ThemeCard.ID]
              .map(
                (id) => PopupMenuItem<String>(
                  child: Text(EzLocalization.of(context).get('home.${id}.name')),
                  value: id,
                ),
              )
              .toList(),
          onSelected: (id) async {
            HomeCardsModel homeCardsModel = Provider.of<HomeCardsModel>(context, listen: false);
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

class _HomePageState extends State<HomePage> {
  AdmobBannerController admobBannerController;

  @override
  Widget build(BuildContext context) {
    HomeCardsModel homeCardsModel = Provider.of<HomeCardsModel>(context);
    if (!homeCardsModel.isInitialized) {
      return const CenteredCircularProgressIndicator();
    }

    List<MaterialCard> items = homeCardsModel.cardsList;
    if (items.isEmpty) {
      return _MainStack(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              EzLocalization.of(context).get('home.no_card'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Provider.of<SettingsModel>(context).theme.textColor ?? Colors.black.withAlpha(150),
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
            builder: (context, dragAnimation, inDrag) {
              return card;
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    admobBannerController?.dispose();
    super.dispose();
  }

  EdgeInsetsGeometry get listPadding => const EdgeInsets.all(20);
}

class _MainStack extends StatelessWidget {
  final Widget child;

  const _MainStack({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    AdMobSettingsEntry adMobSettingsEntry = Provider.of<SettingsModel>(context).adMobEntry;
    double paddingBottom = adMobSettingsEntry.calculatePaddingBottom(context);
    if (paddingBottom == 0) {
      return child;
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: paddingBottom),
          child: child,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: paddingBottom,
          child: adMobSettingsEntry.createBannerAd(),
        ),
      ],
    );
  }
}