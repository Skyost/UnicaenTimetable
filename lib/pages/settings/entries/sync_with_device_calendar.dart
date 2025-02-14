import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/color_lessons_automatically.dart';
import 'package:unicaen_timetable/model/settings/device_calendar.dart';
import 'package:unicaen_timetable/pages/settings/entries/widgets.dart';

/// Allows to configure [syncWithDeviceCalendarSettingsEntryProvider].
class SyncWithDeviceCalendarSettingsEntryWidget extends BoolSettingsEntryWidget {
  /// Creates a new sync with device calendar settings entry widget instance.
  SyncWithDeviceCalendarSettingsEntryWidget({
    super.key,
  }) : super(
          provider: colorLessonsAutomaticallyEntryProvider,
          title: translations.settings.application.syncWithDeviceCalendar,
        );
}
