import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/open_today_automatically.dart';
import 'package:unicaen_timetable/pages/settings/entries/widgets.dart';

/// Allows to configure [openTodayAutomaticallyEntryProvider].
class OpenTodayAutomaticallySettingsEntryWidget extends BoolSettingsEntryWidget {
  /// Creates a new automatically open today settings entry widget instance.
  OpenTodayAutomaticallySettingsEntryWidget({
    super.key,
  }) : super(
          provider: openTodayAutomaticallyEntryProvider,
          title: translations.settings.application.openTodayAutomatically,
        );
}
