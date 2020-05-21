import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/*
TODO
[VERBOSE-2:ui_dart_state.cc(157)] Unhandled Exception: Unable to load asset: assets/admob.json
#0      PlatformAssetBundle.load (package:flutter/src/services/asset_bundle.dart:221:7)
<asynchronous suspension>
#1      AssetBundle.loadString (package:flutter/src/services/asset_bundle.dart:67:33)
#2      CachingAssetBundle.loadString.<anonymous closure> (package:flutter/src/services/asset_bundle.dart:162:56)
#3      _LinkedHashMapMixin.putIfAbsent (dart:collection-patch/compact_hash.dart:293:23)
#4      CachingAssetBundle.loadString (package:flutter/src/services/asset_bundle.dart:162:27)
#5      AdMobSettingsEntry._setAdMobEnabled (package:unicaen_timetable/model/admob.dart:47:63)
#6      AdMobSettingsEntry.load (package:unicaen_timetable/model/admob.dart:33:17)
<asynchronous suspension>
#7      SettingsCategory.load (package:unicaen_timetable/model/settings.dart:153:34)
<asynchronous suspension>
#8      SettingsModel.initialize (package:unicaen_timetable/model/settings.dart:39:22)
<asynchronous suspens<…>
[VERBOSE-2:ui_dart_state.cc(157)] Unhandled Exception: MissingPluginException(No implementation found for method activity.extract_date on channel fr.skyost.timetable)
#0      MethodChannel.invokeMethod (package:flutter/src/services/platform_channel.dart:319:7)
<asynchronous suspension>
#1      _AppScaffoldState.goToDateIfNeeded.<anonymous closure> (package:unicaen_timetable/pages/scaffold.dart:108:60)
#2      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1102:15)
#3      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1049:9)
#4      SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:957:5)
#5      _rootRun (dart:async/zone.dart:1126:13)
#6      _CustomZone.run (dart:async/zone.dart:1023:19)
#7      _CustomZone.runGuarded (dart:async/zone.dart:925:7)
#8      _invoke (dart:ui/hooks.dart:259:10)
#9      _drawFrame (dart:ui/hooks.dart:217:3)
[VERBOSE-2:ui_dart_state.cc(157)] Unhandled Exception: MissingPluginException(No implementation found for method activity.extract_should_sync on channel fr.skyost.timetable)
#0      MethodChannel.invokeMethod (package:flutter/src/services/platform_channel.dart:319:7)
<asynchronous suspension>
#1      _SynchronizeFloatingButtonState.syncIfNeeded.<anonymous closure> (package:unicaen_timetable/pages/scaffold.dart:228:59)
#2      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1102:15)
#3      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1049:9)
#4      SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:957:5)
#5      _rootRun (dart:async/zone.dart:1126:13)
#6      _CustomZone.run (dart:async/zone.dart:1023:19)
#7      _CustomZone.runGuarded (dart:async/zone.dart:925:7)
#8      _invoke (dart:ui/hooks.dart:259:10)
#9      _drawFrame (dart:ui/hooks.dart:217:3)
[VERBOSE-2:ui_dart_state.cc(157)] Unhandled Exception: RangeError (index): Index out of range: no indices are valid: 0
#0      RangeError.checkValidIndex (dart:core/errors.dart:304:7)
#1      IndexableSkipList._getNodeAt (package:hive/src/util/indexable_skip_list.dart:196:16)
#2      IndexableSkipList.getAt (package:hive/src/util/indexable_skip_list.dart:188:25)
#3      Keystore.getAt (package:hive/src/box/keystore.dart:112:19)
#4      BoxImpl.getAt (package:hive/src/box/box_impl.dart:53:21)
#5      IOSUserRepository._read (package:unicaen_timetable/model/user.dart:308:16)
<asynchronous suspension>
#6      UserRepository.getUser (package:unicaen_timetable/model/user.dart:184:27)
#7      _AppMainWidgetState.initState.<anonymous closure> (package:unicaen_timetable/pages/main_widget.dart:31:40)
#8      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1102:15)
#9      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1049:9)
#10     SchedulerBin<…>
Syncing files to device iPhone SE (2nd generation)...
16 163ms (!)

🔥  To hot reload changes while running, press "r". To hot restart (and rebuild
state), press "R".
An Observatory debugger and profiler on iPhone SE (2nd generation) is available
at: http://127.0.0.1:49695/kIzPVhELz5I=/
For a more detailed help message, press "h". To detach, press "d"; to quit,
press "q".
*/