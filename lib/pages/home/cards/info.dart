import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/pages/home/cards/card_content.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A card that allows to show some info.
class InfoCard extends ConsumerWidget {
  /// Creates a new info card instance.
  const InfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
        future: _InfoCardData.load(),
        builder: (context, snapshot) => MaterialCardContent(
          color: Colors.blue.shade700,
          icon: Icons.info_outline,
          title: translations.home.currentLesson.title,
          subtitle: snapshot.data?.toString() ?? translations.common.other.pleaseWait,
          onTap: () => ref.read(pageProvider.notifier).changePage(AboutPage()),
          onRemove: () => ref.read(homeCardsProvider.notifier).removeCard(HomeCard.info),
        ),
      );
}

/// Contains some info about the app.
class _InfoCardData {
  /// The app name.
  final String name;

  /// The app version.
  final String version;

  /// The device brand.
  final String brand;

  /// The device model.
  final String model;

  /// The device OS name.
  final String osName;

  /// The device OS version.
  final String osVersion;

  /// Creates a new info card data instance.
  _InfoCardData({
    required this.name,
    required this.version,
    required this.brand,
    required this.model,
    required this.osName,
    required this.osVersion,
  });

  /// Loads this class with info from the system.
  static Future<_InfoCardData> load() async {
    String name = translations.common.appName;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = 'v${packageInfo.version}';

    String brand;
    String model;
    String osName;
    String osVersion;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      brand = androidDeviceInfo.brand.capitalize();
      model = androidDeviceInfo.model;
      osName = 'Android';
      osVersion = androidDeviceInfo.version.release;
    } else {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      brand = 'Apple';
      model = iosDeviceInfo.localizedModel;
      osName = 'iOS';
      osVersion = iosDeviceInfo.systemVersion;
    }
    return _InfoCardData(
      name: name,
      version: version,
      brand: brand,
      model: model,
      osName: osName,
      osVersion: osVersion,
    );
  }

  @override
  String toString() => '$name $version\n$brand $model, $osName $osVersion';
}
