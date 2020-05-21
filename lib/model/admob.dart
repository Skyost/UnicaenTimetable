import 'dart:convert';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pedantic/pedantic.dart';
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
    bool enabled = await super.load(settingsBox);
    if (enabled) {
      unawaited(_setAdMobEnabled(enabled));
    }
    return enabled;
  }

  @override
  set value(bool value) {
    super.value = value;
    _setAdMobEnabled(value);
  }

  /// Returns the AdMob app id.
  static Future<String> getAdMobAppId() async => (await _decodeAdMobData())['app_id'];

  /// Sets AdMob enabled (and loads it if needed).
  Future<void> _setAdMobEnabled(bool enabled) async {
    if (enabled && adUnitId == null) {
      Map<String, dynamic> data = await _decodeAdMobData();
      adUnitId = kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : data['ad_unit'];
    }
  }

  static Future<Map<String, dynamic>> _decodeAdMobData() async => jsonDecode(await rootBundle.loadString('assets/admob.json'))[Platform.isAndroid ? 'android' : 'ios'];

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
