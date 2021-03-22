import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:unicaen_timetable/credentials.dart';
import 'package:unicaen_timetable/dialogs/input.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';

/// The AdMob settings entry.
class AdMobSettingsEntry extends SettingsEntry<bool> {
  /// The AdMob banner identifier.
  String? adUnitId;

  /// Creates a new AdMob settings entry instance.
  AdMobSettingsEntry({
    required String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
          key: 'enable_ads',
          value: true,
        );

  @override
  Future<void> load([Box? settingsBox]) {
    adUnitId = kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : Credentials.adUnit;
    return super.load(settingsBox);
  }

  /// Creates the banner ad.
  AdmobBanner? createBanner(BuildContext context) => !value || adUnitId == null
      ? null
      : AdmobBanner(
          adUnitId: adUnitId!,
          adSize: _getAdMobBannerSize(context),
        );

  /// Calculates the banner size.
  Future<Size> calculateSize(BuildContext context) => !value || adUnitId == null ? Future<Size>.value(Size.zero) : Admob.bannerSize(_getAdMobBannerSize(context));

  /// Returns the AdMob banner size.
  AdmobBannerSize _getAdMobBannerSize(BuildContext context) => AdmobBannerSize.ADAPTIVE_BANNER(width: MediaQuery.of(context).size.width.ceil());

  @override
  Widget render(BuildContext context) => _AdMobSettingsEntryWidget(entry: this);
}

/// Allows to display the AdMob settings entry.
class _AdMobSettingsEntryWidget extends SettingsEntryWidget {
  /// Creates a new AdMob settings entry widget instance.
  const _AdMobSettingsEntryWidget({
    required AdMobSettingsEntry entry,
  }) : super(entry: entry);

  @override
  Future<bool> beforeOnTap(BuildContext context) async {
    bool? result = await BoolInputDialog.getValue(
      context,
      titleKey: 'dialogs.enable_ads.title',
      messageKey: 'dialogs.enable_ads.message',
      yesButtonKey: 'dialogs.enable_ads.enable',
      noButtonKey: 'dialogs.enable_ads.disable',
    );
    return result != null && result != entry.value;
  }
}
