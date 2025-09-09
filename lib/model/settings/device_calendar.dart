import 'dart:async';

import 'package:eventide/eventide.dart';
import 'package:flutter/foundation.dart';
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
  Future<void> changeValue(bool value) async {
    if (value) {
      try {
        await ref.read(unicaenDeviceCalendarProvider.notifier).createCalendarOnDeviceIfNotExist();
        await super.changeValue(value);
      } catch (ex, stacktrace) {
        if (kDebugMode) {
          print(ex);
          print(stacktrace);
        }
        if (ex is ETPermissionException) {}
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

  /// The Eventide account.
  static final String accountName = 'Unicaen';

  /// The settings key.
  static const String settingsKey = 'unicaenDeviceCalendar';

  @override
  FutureOr<ETCalendar?> build() async {
    SharedPreferencesWithCache preferences = await ref.read(sharedPreferencesProvider.future);
    String? calendarId = preferences.getString(settingsKey);
    if (calendarId == null) {
      return null;
    }
    Eventide eventide = Eventide();
    List<ETCalendar> calendars = await eventide.retrieveCalendars(fromLocalAccountName: accountName);
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
      localAccountName: accountName,
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
