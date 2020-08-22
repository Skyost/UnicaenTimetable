import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:unicaen_timetable/credentials.dart';
import 'package:unicaen_timetable/model/settings.dart';

/// The AdMob settings entry.
class AdMobSettingsEntry extends SettingsEntry<bool> {
  /// The AdMob banner identifier.
  String adUnitId;

  /// Creates a new AdMob settings entry instance.
  AdMobSettingsEntry({
    String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
          key: 'enable_ads',
          value: true,
        );

  @override
  Future<bool> load([Box settingsBox]) async {
    adUnitId = kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : Credentials.adUnit;
    return await super.load(settingsBox);
  }

  /// Creates the banner ad.
  AdmobBanner createBanner(BuildContext context) => !value || adUnitId == null
      ? null
      : AdmobBanner(
          adUnitId: adUnitId,
          adSize: _getAdMobBannerSize(context),
        );

  /// Calculates the banner size.
  Future<Size> calculateSize(BuildContext context) => !value || adUnitId == null ? Future<Size>.value(Size.zero) : Admob.bannerSize(_getAdMobBannerSize(context));

  /// Returns the AdMob banner size.
  AdmobBannerSize _getAdMobBannerSize(BuildContext context) => AdmobBannerSize.ADAPTIVE_BANNER(width: MediaQuery.of(context).size.width.ceil());
}
