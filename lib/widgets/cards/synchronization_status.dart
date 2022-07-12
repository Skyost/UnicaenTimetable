import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/widgets/cards/card.dart';

/// A card that shows the synchronization status.
class SynchronizationStatusCard extends MaterialCard<String> {
  /// The card id.
  static const String id = 'synchronization_status';

  /// Creates the synchronization status card.
  SynchronizationStatusCard({
    super.onRemove,
  }) : super(
          cardId: id,
        );

  @override
  IconData buildIcon(BuildContext context, WidgetRef ref) => _isBad(ref) ? Icons.sync_problem : Icons.sync;

  @override
  Color buildColor(BuildContext context, WidgetRef ref) => _isBad(ref) ? Colors.red[700]! : Colors.teal[700]!;

  @override
  Future<String> requestData(BuildContext context, WidgetRef ref) async {
    LessonRepository lessonRepository = ref.watch(lessonRepositoryProvider);
    String date = lessonRepository.lastModificationTime == null
        ? context.getString('home.synchronization_status.never')
        : DateFormat.yMd(EzLocalization.of(context)?.locale.languageCode).add_Hms().format(lessonRepository.lastModificationTime!);
    String status = _isBad(ref) ? 'bad' : 'good';
    String statusString = context.getString('home.synchronization_status.$status');
    return '$date\n$statusString';
  }

  @override
  void onTap(BuildContext context, WidgetRef ref) async {
    LessonRepository lessonRepository = ref.read(lessonRepositoryProvider);
    await lessonRepository.downloadLessonsFromWidget(context, ref);
  }

  /// Whether we should display the "bad" color.
  bool _isBad(WidgetRef ref) {
    SettingsModel settingsModel = ref.watch(settingsModelProvider);
    LessonRepository lessonRepository = ref.watch(lessonRepositoryProvider);

    return lessonRepository.lastModificationTime == null ||
        DateTime.now().difference(lessonRepository.lastModificationTime!).compareTo(Duration(days: settingsModel.getEntryByKey('server.interval')!.value) * 7) > 0;
  }
}
