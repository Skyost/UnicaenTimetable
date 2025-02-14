import 'dart:async';

import 'package:eventide/eventide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';

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
    Eventide eventide = Eventide();
    if (value) {
      bool result = await eventide.requestCalendarPermission();
      if (result) {
        await super.changeValue(value);
        await ref.read(unicaenDeviceCalendarProvider.notifier).createCalendarOnDevice();
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

  @override
  FutureOr<ETCalendar?> build() async {
    SharedPreferencesWithCache preferences = await ref.read(sharedPreferencesProvider.future);
    String? calendarId = preferences.getString('unicaenDeviceCalendar');
    if (calendarId == null) {
      return null;
    }
    Eventide eventide = Eventide();
    List<ETCalendar> calendars = await eventide.retrieveCalendars();
    for (ETCalendar calendar in calendars) {
      if (calendar.id == calendarId) {
        return calendar;
      }
    }
    return null;
  }

  /// Creates and returns [ETCalendar].
  Future<ETCalendar> createCalendarOnDevice() async {
    Eventide eventide = Eventide();
    ETCalendar calendar = await eventide.createCalendar(
      title: calendarName,
      color: calendarColor,
    );
    SharedPreferencesWithCache preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setString('unicaenDeviceCalendar', calendar.id);
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
    await preferences.remove('unicaenDeviceCalendar');
  }
}
