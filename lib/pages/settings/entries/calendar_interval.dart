import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/calendar.dart';
import 'package:unicaen_timetable/pages/settings/entries/widgets.dart';

/// Allows to configure [intervalSettingsEntryProvider].
class CalendarIntervalSettingsEntryWidget extends IntegerSettingsEntryWidget<IntervalSettingsEntry> {
  /// Creates a new calendar interval settings entry widget instance.
  CalendarIntervalSettingsEntryWidget({
    super.key,
  }) : super(
          provider: intervalSettingsEntryProvider,
          title: translations.settings.calendar.interval,
          min: 1,
          max: 52,
          divisions: 52,
        );
}
