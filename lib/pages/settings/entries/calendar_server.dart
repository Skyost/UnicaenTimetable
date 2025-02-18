import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/calendar.dart';
import 'package:unicaen_timetable/pages/settings/entries/widgets.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';

/// Allows to configure [serverSettingsEntryProvider].
class CalendarServerSettingsEntryWidget extends StringSettingsEntryWidget<ServerSettingsEntry> {
  /// Creates a new calendar server settings entry widget instance.
  CalendarServerSettingsEntryWidget({
    super.key,
  }) : super(
          provider: serverSettingsEntryProvider,
          title: translations.settings.calendar.server,
          validator: TextInputDialog.validateNotEmpty,
          hint: kDefaultServer,
        );
}
