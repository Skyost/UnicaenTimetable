import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unicaen_timetable/credentials.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/widgets/settings/entries/application/admob.dart';

/// The AdMob settings entry.
class AdMobSettingsEntry extends SettingsEntry<bool> {
  /// The AdMob banner identifier.
  String? adUnitId;

  /// Creates a new AdMob settings entry instance.
  AdMobSettingsEntry({
    required String keyPrefix,
  }) : super(
          categoryKey: keyPrefix,
          key: 'enable_ads',
          value: true,
        );

  @override
  Future<void> load(Map<String, dynamic> json) {
    adUnitId = kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : Credentials.adUnit;
    return super.load(json);
  }

  /// Creates the banner ad.
  BannerAd? createBanner(
    BuildContext context, {
    AdSize? size,
    bool? nonPersonalizedAds,
  }) =>
      !value || adUnitId == null
          ? null
          : BannerAd(
              adUnitId: adUnitId!,
              size: size ?? AdSize.banner,
              request: AdRequest(
                keywords: ['caen', 'étudiant', 'université', 'unicaen'],
                nonPersonalizedAds: nonPersonalizedAds,
              ),
              listener: BannerAdListener(
                onAdFailedToLoad: (ad, error) {
                  ad.dispose();
                  if (kDebugMode) {
                    print(error);
                  }
                },
              ),
            );

  @override
  Widget render(BuildContext context) => AdMobSettingsEntryWidget(entry: this);
}
