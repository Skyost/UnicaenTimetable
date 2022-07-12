import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info/package_info.dart';
import 'package:unicaen_timetable/pages/about.dart';
import 'package:unicaen_timetable/pages/page_container.dart';
import 'package:unicaen_timetable/utils/utils.dart';
import 'package:unicaen_timetable/widgets/cards/card.dart';

/// A card that contains some app & devices info.
class InfoCard extends MaterialCard<InfoCardData> {
  /// The card id.
  static const String id = 'info';

  /// Creates a new info card instance.
  InfoCard({
    super.onRemove,
  }) : super(
          cardId: id,
        );

  @override
  Future<InfoCardData> requestData(BuildContext context, WidgetRef ref) async {
    InfoCardData infoCardData = InfoCardData();
    await infoCardData.initialize(context);
    return infoCardData;
  }

  @override
  Color buildColor(BuildContext context, WidgetRef ref) => Colors.blue[700]!;

  @override
  IconData buildIcon(BuildContext context, WidgetRef ref) => Icons.info_outline;

  @override
  void onTap(BuildContext context, WidgetRef ref) => ref.read(currentPageProvider).value = AboutPage.id;
}

/// Contains some info about the app.
class InfoCardData {
  /// The app name.
  String? name;

  /// The app version.
  String? version;

  /// The device brand.
  String? brand;

  /// The device model.
  String? model;

  /// The device OS name.
  String? osName;

  /// The device OS version.
  String? osVersion;

  /// Initializes this class.
  Future<InfoCardData> initialize(BuildContext context) async {
    name = context.getString('app_name');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = 'v${packageInfo.version}';

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
    return this;
  }

  @override
  String toString() => '$name $version\n$brand $model, $osName $osVersion';
}
