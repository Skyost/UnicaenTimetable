import 'dart:convert';
import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicaen_timetable/credentials.dart';

/// Contains the user consent info.
class ConsentInformation {
  /// Cached consent information instance.
  static ConsentInformation? _cached;

  /// The preferences key for the "should display" parameter.
  static const String preferencesShouldDisplay = 'consent.should-display';

  /// Whether the user wants (or no) personalized ads.
  static const String preferencesWantsNonPersonalizedAds = 'consent.wants-non-personalized-ads';

  /// Whether an explicit consent should be given.
  final bool isRequestLocationInEeaOrUnknown;

  /// Whether the explicit consent has been given for personalized ads.
  final bool wantsNonPersonalizedAds;

  /// Creates a new consent information instance.
  const ConsentInformation._internal({
    this.isRequestLocationInEeaOrUnknown = true,
    this.wantsNonPersonalizedAds = true,
  });

  /// Reads the consent information from the shared preferences.
  static Future<ConsentInformation?> read() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(preferencesShouldDisplay) && preferences.containsKey(preferencesWantsNonPersonalizedAds)) {
      _cached = ConsentInformation._internal(
        isRequestLocationInEeaOrUnknown: preferences.getBool(preferencesShouldDisplay)!,
        wantsNonPersonalizedAds: preferences.getBool(preferencesWantsNonPersonalizedAds)!,
      );
      return _cached;
    }
    return null;
  }

  /// Asks for the consent information if required.
  static Future<ConsentInformation?> ask({
    required BuildContext context,
    required String appMessageKey,
    required String questionKey,
    required String privacyPolicyMessageKey,
    required String personalizedAdsButtonKey,
    required String nonPersonalizedAdsButtonKey,
  }) async {
    Uri uri = Uri.https('adservice.google.com', '/getconfig/pubvendors', {
      'pubs': Credentials.publisherId,
      'es': '2',
      'plat': Platform.isAndroid ? 'android' : 'ios',
      'v': '1.0.8', // Should be v1.0.5 on iOS.
      if (kDebugMode) 'debug_geo': '1'
    });
    Map<String, dynamic> data = jsonDecode(await http.read(uri));
    bool needToAsk = data['is_request_in_eea_or_unknown'] ?? false;
    bool wantsNonPersonalizedAds = false;
    if (needToAsk && context.mounted) {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (context) => _PersonalizedAdsConsentDialog(
          appMessageKey: appMessageKey,
          questionMessageKey: questionKey,
          privacyPolicyMessageKey: privacyPolicyMessageKey,
          personalizedAdsButtonKey: personalizedAdsButtonKey,
          nonPersonalizedAdsButtonKey: nonPersonalizedAdsButtonKey,
        ),
        barrierDismissible: false,
      );
      wantsNonPersonalizedAds = result ?? false;
    }

    _cached = ConsentInformation._internal(
      isRequestLocationInEeaOrUnknown: needToAsk,
      wantsNonPersonalizedAds: wantsNonPersonalizedAds,
    );
    await _cached?.write();
    return _cached;
  }

  /// Reads or asks for the consent information if required.
  static Future<ConsentInformation?> askIfNeeded({
    required BuildContext context,
    required String appMessageKey,
    required String questionKey,
    required String privacyPolicyMessageKey,
    required String personalizedAdsButtonKey,
    required String nonPersonalizedAdsButtonKey,
  }) async {
    try {
      if (_cached != null) {
        return _cached!;
      }

      ConsentInformation? result = await read();
      if (context.mounted) {
        result ??= await ask(
          context: context,
          appMessageKey: appMessageKey,
          questionKey: questionKey,
          privacyPolicyMessageKey: privacyPolicyMessageKey,
          personalizedAdsButtonKey: personalizedAdsButtonKey,
          nonPersonalizedAdsButtonKey: nonPersonalizedAdsButtonKey,
        );
      }

      if (result != null) {
        return result;
      }
    } catch (exception, stacktrace) {
      if (kDebugMode) {
        print(exception);
        print(stacktrace);
      }
    }
    return const ConsentInformation._internal();
  }

  /// Writes the current data to shared preferences.
  Future<void> write() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(preferencesShouldDisplay, isRequestLocationInEeaOrUnknown);
    await preferences.setBool(preferencesWantsNonPersonalizedAds, wantsNonPersonalizedAds);
  }

  /// Resets the data that was stored into shared preferences.
  static Future<void> reset() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(preferencesShouldDisplay);
    await preferences.remove(preferencesWantsNonPersonalizedAds);
  }
}

/// The personalized ads consent dialog widget.
class _PersonalizedAdsConsentDialog extends StatelessWidget {
  /// The app message.
  final String appMessageKey;

  /// The question message.
  final String questionMessageKey;

  /// The privacy policy HTML message.
  final String privacyPolicyMessageKey;

  /// The personalized ads button.
  final String personalizedAdsButtonKey;

  /// The non personalized ads button.
  final String nonPersonalizedAdsButtonKey;

  /// Creates a new personalized ads consent dialog instance.
  const _PersonalizedAdsConsentDialog({
    required this.appMessageKey,
    required this.questionMessageKey,
    required this.privacyPolicyMessageKey,
    required this.personalizedAdsButtonKey,
    required this.nonPersonalizedAdsButtonKey,
  });

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => Future<bool>.value(false),
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: _createLogo(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _createAppMessage(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _createQuestionMessage(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _createPrivacyPolicyMessage(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: _createPersonalizedAdsButton(context),
                ),
                _createNonPersonalizedAdsButton(context),
              ],
            ),
          ),
        ),
      );

  /// Creates the logo widget.
  Widget _createLogo() => Align(
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icon.svg',
          semanticsLabel: 'Logo',
          width: 70,
        ),
      );

  /// Creates the app message widget.
  Widget _createAppMessage(BuildContext context) => Text(
        context.getString(appMessageKey),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      );

  /// Creates the question message widget.
  Widget _createQuestionMessage(BuildContext context) => Text(
        context.getString(questionMessageKey),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  /// Creates the privacy policy message widget.
  Widget _createPrivacyPolicyMessage(BuildContext context) => HtmlWidget(
        '<div style="text-align: center;">${context.getString(privacyPolicyMessageKey)}</div>',
        textStyle: const TextStyle(fontSize: 12),
      );

  /// Creates the personalized ads button widget.
  Widget _createPersonalizedAdsButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            overlayColor: MaterialStateProperty.all(Colors.white12),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            context.getString(personalizedAdsButtonKey).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );

  /// Creates the non personalized ads button widget.
  Widget _createNonPersonalizedAdsButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
            overlayColor: MaterialStateProperty.all(Colors.white12),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            context.getString(nonPersonalizedAdsButtonKey).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
}
