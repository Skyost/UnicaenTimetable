import 'dart:async';
import 'dart:io';

import 'package:eventide/eventide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';
import 'package:unicaen_timetable/utils/utils.dart';

/// The sync with device calendar settings entry provider.
final syncWithDeviceCalendarSettingsEntryProvider = AsyncNotifierProvider.autoDispose<SyncWithDeviceCalendarSettingsEntry, bool>(SyncWithDeviceCalendarSettingsEntry.new);

/// The sync with device calendar settings entry that defines whether lessons are colored automatically or not.
class SyncWithDeviceCalendarSettingsEntry extends SettingsEntry<bool> {
  /// Creates a new device calendar settings entry instance.
  SyncWithDeviceCalendarSettingsEntry()
      : super(
          key: 'syncWithDeviceCalendar',
          defaultValue: false,
        );

  @override
  FutureOr<bool> build() async {
    bool result = await super.build();
    if (result) {
      Eventide eventide = Eventide();
      return await eventide.requestCalendarPermission();
    }
    return result;
  }

  @override
  Future<void> changeValue(bool value) async {
    Eventide eventide = Eventide();
    if (value) {
      bool result = await eventide.requestCalendarPermission();
      if (result) {
        await super.changeValue(value);
        await ref.read(unicaenDeviceCalendarProvider.notifier).createCalendarOnDeviceIfNotExist();
      }
    } else {
      await super.changeValue(value);
      await ref.read(unicaenDeviceCalendarProvider.notifier).deleteCalendarOnDevice();
    }
  }
}

/// The Unicaen device calendar settings entry provider.
final unicaenDeviceCalendarProvider = AsyncNotifierProvider.autoDispose<UnicaenDeviceCalendar, ETCalendar?>(UnicaenDeviceCalendar.new);

/// The Unicaen device calendar.
class UnicaenDeviceCalendar extends AutoDisposeAsyncNotifier<ETCalendar?> {
  /// The device calendar color.
  static const Color calendarColor = Colors.indigo;

  /// The device calendar name.
  static const String calendarName = 'Unicaen';

  /// The settings key.
  static const String settingsKey = 'unicaenDeviceCalendar';

  /// The Eventide account.
  static final ETAccount _account = ETAccount(
    name: 'Unicaen',
    type: Platform.isAndroid ? 'LOCAL' : 'local',
  );

  @override
  FutureOr<ETCalendar?> build() async {
    SharedPreferencesWithCache preferences = await ref.read(sharedPreferencesProvider.future);
    String? calendarId = preferences.getString(settingsKey);
    if (calendarId == null) {
      return null;
    }
    Eventide eventide = Eventide();
    List<ETCalendar> calendars = await eventide.retrieveCalendars();
    return calendars.firstWhereOrNull((calendar) => calendar.id == calendarId);
  }

  /// Creates and returns [ETCalendar].
  Future<ETCalendar> createCalendarOnDeviceIfNotExist() async {
    Eventide eventide = Eventide();
    ETCalendar? calendar = await future;
    if (calendar != null) {
      return calendar;
    }
    calendar = await eventide.createCalendar(
      title: calendarName,
      color: calendarColor,
      account: _account,
    );
    SharedPreferencesWithCache preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString(settingsKey, calendar.id);
    state = AsyncData(calendar);
    return calendar;
  }

  /// Deletes the [ETCalendar].
  Future<void> deleteCalendarOnDevice() async {
    ETCalendar? calendar = await future;
    if (calendar == null) {
      return;
    }
    Eventide eventide = Eventide();
    eventide.deleteCalendar(calendarId: calendar.id);
    SharedPreferencesWithCache preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.remove(settingsKey);
  }
}

/// Contains various useful methods for working with Eventide.
extension Events on ETCalendar? {
  /// Retrieves events from the calendar.
  Future<List<ETEvent>> retrieveEvents() async {
    if (this?.id == null) {
      return [];
    }
    DateTime today = DateTime.now().yearMonthDay;
    Eventide eventide = Eventide();
    return await eventide.retrieveEvents(
      calendarId: this!.id,
      startDate: today.subtract(const Duration(days: 365)),
      endDate: today.add(const Duration(days: 365)),
    );
  }
}
