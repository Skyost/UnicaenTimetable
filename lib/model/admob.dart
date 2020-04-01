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
  /// The AdMob app identifier.
  String appId;

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

  /// Sets AdMob enabled (and loads it if needed).
  Future<void> _setAdMobEnabled(bool enabled) async {
    if (enabled && adUnitId == null) {
      Map<String, dynamic> data = jsonDecode(await rootBundle.loadString('assets/admob.json'))[Platform.isAndroid ? 'android' : 'ios'];
      appId = data['app_id'];
      adUnitId = kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : data['ad_unit'];
    }
  }

  /// Calculates the padding bottom.
  double calculatePaddingBottom(BuildContext context) {
    if (!value) {
      return 0;
    }

    MediaQueryData mediaScreen = MediaQuery.of(context);
    double dpHeight = mediaScreen.orientation == Orientation.portrait ? mediaScreen.size.height : mediaScreen.size.width;
    if (dpHeight <= 400) {
      return 32;
    }
    if (dpHeight > 720) {
      return 90;
    }

    return 50;
  }

  /// Creates the banner ad.
  AdmobBanner createBanner() => !value || adUnitId == null ? null : AdmobBanner(
    adUnitId: adUnitId,
    adSize: AdmobBannerSize.SMART_BANNER,
  );
}
