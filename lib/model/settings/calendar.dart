import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';

/// The default server.
const String kDefaultServer = 'https://webmail.unicaen.fr';

/// The default calendar name.
const String kDefaultCalendarName = 'Emploi du temps';

/// The default additional parameters.
const String kDefaultAdditionalParameters = '';

/// The interval settings entry provider.
final intervalSettingsEntryProvider = AsyncNotifierProvider.autoDispose<IntervalSettingsEntry, int>(IntervalSettingsEntry.new);

/// The interval entry that defines how many weeks to download.
class IntervalSettingsEntry extends SettingsEntry<int> {
  /// Creates a new server settings entry instance.
  IntervalSettingsEntry()
      : super(
          key: 'calendarInterval',
          defaultValue: 2,
        );
}

/// The server settings entry provider.
final serverSettingsEntryProvider = AsyncNotifierProvider.autoDispose<ServerSettingsEntry, String>(ServerSettingsEntry.new);

/// The settings entry that defines which server to use.
class ServerSettingsEntry extends SettingsEntry<String> {
  /// Creates a new server settings entry instance.
  ServerSettingsEntry()
      : super(
          key: 'calendarServer',
          defaultValue: kDefaultServer,
        );
}

/// The calendar name settings entry provider.
final calendarNameSettingsEntryProvider = AsyncNotifierProvider.autoDispose<CalendarNameSettingsEntry, String>(CalendarNameSettingsEntry.new);

/// The settings entry that defines which calendar to use.
class CalendarNameSettingsEntry extends SettingsEntry<String> {
  /// Creates a new calendar settings entry instance.
  CalendarNameSettingsEntry()
      : super(
          key: 'calendarName',
          defaultValue: kDefaultCalendarName,
        );
}

/// The additional parameters entry provider.
final additionalParametersSettingsEntryProvider = AsyncNotifierProvider.autoDispose<AdditionalParametersSettingsEntry, String>(AdditionalParametersSettingsEntry.new);

/// The settings entry that defines the additional parameters to use.
class AdditionalParametersSettingsEntry extends SettingsEntry<String> {
  /// Creates a new additional parameters settings entry instance.
  AdditionalParametersSettingsEntry()
      : super(
          key: 'calendarAdditionalParameters',
          defaultValue: kDefaultAdditionalParameters,
        );
}
