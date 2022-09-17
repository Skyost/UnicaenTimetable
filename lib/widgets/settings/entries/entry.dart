import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/entries/entry.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';

/// A widget that shows a settings entry.
class SettingsEntryWidget<T> extends ConsumerWidget {
  /// The settings entry.
  final SettingsEntry<T> entry;

  /// Whether this entry should trigger a synchronization after being tapped on.
  final bool synchronizeOnTap;

  /// Whether the tapped on callback should be disabled.
  final bool disableOnTap;

  /// Creates a new settings entry widget instance.
  SettingsEntryWidget({
    super.key,
    required this.entry,
    bool? synchronizeOnTap,
    this.disableOnTap = false,
  }) : synchronizeOnTap = synchronizeOnTap ?? entry.key.startsWith('server.');

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
        onTap: disableOnTap ? null : () => onTap(context, ref),
        title: createTitle(context, ref),
        subtitle: createSubtitle(context, ref),
        trailing: createController(context, ref),
      );

  /// Creates the title widget.
  Widget createTitle(BuildContext context, WidgetRef ref) => Text(
        context.getString('settings.${entry.key}'),
        style: const TextStyle(fontWeight: FontWeight.w500),
      );

  /// Creates the subtitle widget.
  Widget? createSubtitle(BuildContext context, WidgetRef ref) => null;

  /// Creates the controller widget.
  Widget? createController(BuildContext context, WidgetRef ref) => null;

  /// Triggered when the user has tapped the controller.
  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    if (synchronizeOnTap) {
      LessonRepository lessonRepository = ref.read(lessonRepositoryProvider);
      await lessonRepository.downloadLessonsFromWidget(context, ref);
    }
  }

  /// Flushes settings.
  @protected
  Future<void> flush(WidgetRef ref) async {
    await ref.read(settingsModelProvider).flush();
  }
}
