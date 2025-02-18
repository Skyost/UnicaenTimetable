import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/calendar.dart';
import 'package:unicaen_timetable/pages/settings/entries/widgets.dart';

/// Allows to configure [additionalParametersSettingsEntryProvider].
class CalendarAdditionalParametersSettingsEntryWidget extends StringSettingsEntryWidget<AdditionalParametersSettingsEntry> {
  /// Creates a new calendar additional parameters settings entry widget instance.
  CalendarAdditionalParametersSettingsEntryWidget({
    super.key,
  }) : super(
          provider: additionalParametersSettingsEntryProvider,
          title: translations.settings.calendar.additionalParameters,
          hint: kDefaultAdditionalParameters,
        );
}
