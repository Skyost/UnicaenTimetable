import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/settings/color_lessons_automatically.dart';
import 'package:unicaen_timetable/pages/settings/entries/widgets.dart';

/// Allows to configure [colorLessonsAutomaticallyEntryProvider].
class ColorLessonsAutomaticallySettingsEntryWidget extends BoolSettingsEntryWidget {
  /// Creates a new automatically color lessons settings entry widget instance.
  ColorLessonsAutomaticallySettingsEntryWidget({
    super.key,
  }) : super(
          provider: colorLessonsAutomaticallyEntryProvider,
          title: translations.settings.application.colorLessonsAutomatically,
        );
}
