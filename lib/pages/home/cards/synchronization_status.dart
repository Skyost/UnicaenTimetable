import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unicaen_timetable/i18n/translations.g.dart';
import 'package:unicaen_timetable/model/home_cards.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/calendar.dart';
import 'package:unicaen_timetable/pages/home/cards/card_content.dart';
import 'package:unicaen_timetable/utils/lesson_download.dart';

/// A card that allows to show the synchronization status.
class SynchronizationStatusCard extends ConsumerWidget {
  /// Creates a new synchronization status card instance.
  const SynchronizationStatusCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime? lastModification = ref.watch(lessonRepositoryProvider).valueOrNull;
    int interval = ref.watch(intervalSettingsEntryProvider).valueOrNull ?? 0;
    bool isBad = lastModification == null || DateTime.now().difference(lastModification).compareTo(Duration(days: interval) * 7) > 0;
    return MaterialCardContent(
      color: isBad ? Colors.red.shade700 : Colors.teal.shade700,
      icon: isBad ? Icons.sync_problem : Icons.sync,
      title: translations.home.currentLesson.title,
      subtitle: '${lastModification == null ? translations.home.synchronizationStatus.never : DateFormat.yMd(TranslationProvider.of(context).locale.languageCode).add_Hms().format(lastModification)}\n${isBad ? translations.home.synchronizationStatus.bad : translations.home.synchronizationStatus.good}',
      onTap: () async => await downloadLessons(ref),
      onRemove: () => ref.read(homeCardsProvider.notifier).removeCard(HomeCard.synchronizationStatus),
    );
  }
}
