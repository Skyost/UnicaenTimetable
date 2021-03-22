import 'dart:io';

import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';

/// The app lesson notification mode settings entry that defines the notification mode.
class LessonNotificationModeSettingsEntry extends SettingsEntry<int> {
  /// Creates a new app notification mode settings entry instance.
  LessonNotificationModeSettingsEntry({
    required String keyPrefix,
  }) : super(
          keyPrefix: keyPrefix,
          key: 'lesson_notification_mode',
          value: -1,
          enabled: Platform.isAndroid,
        );

  @override
  Widget render(BuildContext context) => _LessonNotificationModeSettingsEntryWidget(entry: this);
}

/// Allows to display the lesson notification mode settings entry.
class _LessonNotificationModeSettingsEntryWidget extends StatelessWidget {
  /// The entry.
  final LessonNotificationModeSettingsEntry entry;

  /// Creates a new lesson notification mode settings entry widget instance.
  const _LessonNotificationModeSettingsEntryWidget({
    required this.entry,
  });

  @override
  Widget build(BuildContext context) => SettingsDropdownButton<int>(
        titleKey: 'settings.${entry.key}',
        onChanged: (value) async {
          if (value == null) {
            return;
          }

          bool? result = await UnicaenTimetableApp.CHANNEL.invokeMethod<bool>('activity.lesson_notification_mode_changed', {'value': value});
          if (result != null && result) {
            entry.value = value;
            await entry.flush();
          }
        },
        items: [
          DropdownMenuItem<int>(
            value: -1,
            child: Text(context.getString('other.lesson_notification_mode.disabled')),
          ),
          DropdownMenuItem<int>(
            value: 0,
            child: Text(context.getString('other.lesson_notification_mode.alarms_only')),
          ),
        ],
        value: entry.value,
      );
}
