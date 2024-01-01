import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/model/settings/entries/application/admob.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/utils/widgets.dart';
import 'package:unicaen_timetable/widgets/cards/card.dart';
import 'package:unicaen_timetable/widgets/cards/current_lesson.dart';
import 'package:unicaen_timetable/widgets/cards/info.dart';
import 'package:unicaen_timetable/widgets/cards/next_lesson.dart';
import 'package:unicaen_timetable/widgets/cards/synchronization_status.dart';
import 'package:unicaen_timetable/widgets/cards/theme.dart';

/// The home page widget.
class HomePage extends Page {
  /// The page identifier.
  static const String id = 'home';

  /// Creates a new home page widget instance.
  const HomePage({
    super.key,
  }) : super(
          pageId: id,
          icon: Icons.home,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    HomeCardsModel homeCardsModel = ref.watch(homeCardsModelProvider);
    if (!homeCardsModel.isInitialized) {
      return const CenteredCircularProgressIndicator();
    }

    List<String> cards = homeCardsModel.cards.toList();
    Widget child = cards.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                context.getString('home.no_card'),
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
            onReorder: (oldIndex, newIndex) => homeCardsModel.reorder(oldIndex, newIndex),
            itemCount: cards.length,
            itemBuilder: (context, index) => MaterialCard.createFromId(cards[index], () => homeCardsModel.removeCard(cards[index])),
            proxyDecorator: (widget, index, animation) => widget,
          );

    return _HomeWidgetStack(
      child: child,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context, WidgetRef ref) => [
        PopupMenuButton<String>(
          icon: const Icon(Icons.add),
          itemBuilder: (context) => [SynchronizationStatusCard.id, CurrentLessonCard.id, NextLessonCard.id, ThemeCard.id, InfoCard.id]
              .map(
                (id) => PopupMenuItem<String>(
                  value: id,
                  child: Text(context.getString('home.$id.name')),
                ),
              )
              .toList(),
          onSelected: (id) async {
            HomeCardsModel homeCardsModel = ref.read(homeCardsModelProvider);
            if (homeCardsModel.hasCard(id)) {
              Utils.showSnackBar(
                context: context,
                icon: Icons.close,
                textKey: 'widget_already_present',
                color: Colors.red[800]!,
              );
              return;
            }

            homeCardsModel.addCard(id);
          },
        )
      ];
}

/// The home page stack that shows a banner ad at the bottom.
class _HomeWidgetStack extends ConsumerStatefulWidget {
  /// The stack child (the list).
  final Widget child;

  /// Creates a new main stack instance.
  const _HomeWidgetStack({
    required this.child,
  });

  @override
  ConsumerState createState() => _HomeWidgetStackState();
}

/// The home widget stack state.
class _HomeWidgetStackState extends ConsumerState<_HomeWidgetStack> {
  /// The consent information.
  ConsentStatus? consentStatus;

  /// The banner ad.
  BannerAd? banner;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      initializeAdBanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (consentStatus == null || banner == null) {
      return widget.child;
    }

    double bannerHeight = banner!.size.height.toDouble();
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: bannerHeight),
          child: widget.child,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: bannerHeight,
          child: AdWidget(ad: banner!),
        ),
      ],
    );
  }

  /// Initializes the ad banner.
  Future<void> initializeAdBanner() async {
    await requestConsents();
    AdMobSettingsEntry adMobSettingsEntry = ref.watch(settingsModelProvider.select((settings) => settings.adMobEntry));
    if (mounted) {
      AdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(MediaQuery.of(context).orientation, MediaQuery.of(context).size.width.truncate());
      if (mounted) {
        BannerAd? banner = adMobSettingsEntry.createBanner(context, size: size);
        await banner?.load();
        if (mounted) {
          setState(() => this.banner = banner);
        }
      }
    }
  }

  /// Requests various consents.
  Future<void> requestConsents() async {
    ConsentRequestParameters parameters = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      parameters,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadForm();
        }
      },
      (_) {},
    );
  }

  /// Loads the UMP form and displays it.
  void _loadForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        ConsentStatus status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((_) => _loadForm());
        }
        if (mounted) {
          setState(() => consentStatus = status);
        }
      },
      (_) {},
    );
  }
}
