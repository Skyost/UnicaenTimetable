import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/pages/about.dart';
import 'package:unicaen_timetable/pages/home/cards/card.dart';
import 'package:unicaen_timetable/pages/page.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// A card that contains some app & devices info.
class InfoCard extends MaterialCard {
  /// The card id.
  static const String ID = 'info';

  /// Creates a new info card instance.
  const InfoCard() : super(cardId: ID);

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          FutureProvider<_AppInfo>(create: (_) => _AppInfo().initialize(context)),
          FutureProvider<_DeviceInfo>(create: (_) => _DeviceInfo().initialize()),
        ],
        child: Builder(builder: (context) => super.build(context)),
      );

  @override
  Color buildColor(BuildContext context) => Colors.blue[700];

  @override
  IconData buildIcon(BuildContext context) => Icons.info_outline;

  @override
  String buildSubtitle(BuildContext context) {
    _AppInfo appInfo = context.watch<_AppInfo>();
    _DeviceInfo deviceInfo = context.watch<_DeviceInfo>();
    if (appInfo == null || deviceInfo == null) {
      return context.getString('home.loading');
    }

    return appInfo.toString() + '\n' + deviceInfo.toString();
  }

  @override
  void onTap(BuildContext context) => context.get<ValueNotifier<Page>>().value = const AboutPage();
}

/// Contains some info about the app.
class _AppInfo {
  /// The app name.
  String name;

  /// The app version.
  String version;

  /// Initializes this class.
  Future<_AppInfo> initialize(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    name = context.getString('app_name');
    version = 'v' + packageInfo.version;
    return this;
  }

  @override
  String toString() => '${name} ${version}';
}

/// Contains some info about the current device.
class _DeviceInfo {
  /// The device brand.
  String brand;

  /// The device model.
  String model;

  /// The device OS name.
  String osName;

  /// The device OS version.
  String osVersion;

  /// Initializes this class.
  Future<_DeviceInfo> initialize() async {
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
  String toString() => '${brand} ${model}, ${osName} ${osVersion}';
}
