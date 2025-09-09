import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/calendar.dart';
import 'package:unicaen_timetable/pages/settings/entries/widgets.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';

/// Allows to configure [calendarSettingsEntryProvider].
class CalendarNameSettingsEntryWidget extends StringSettingsEntryWidget<CalendarNameSettingsEntry> {
  /// Creates a new calendar name settings entry widget instance.
  CalendarNameSettingsEntryWidget({
    super.key,
  }) : super(
         provider: calendarNameSettingsEntryProvider,
         title: translations.settings.calendar.name,
         validator: TextInputDialog.validateNotEmpty,
         hint: kDefaultCalendarName,
       );
}
