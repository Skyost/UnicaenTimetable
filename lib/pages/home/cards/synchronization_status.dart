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
    AsyncValue<DateTime?> lastModification = ref.watch(lessonRepositoryProvider);
    int interval = ref.watch(intervalSettingsEntryProvider).valueOrNull ?? 0;
    _Status status = _Status.resolve(lastModification, interval);
    return MaterialCardContent(
      color: status.resolveColor(),
      icon: status.icon,
      title: translations.home.synchronizationStatus.title,
      subtitle: switch (status) {
        _Status.never => translations.home.synchronizationStatus.never,
        _Status.loading => translations.common.other.pleaseWait,
        _Status.bad || _Status.good =>
          '${DateFormat.yMd(TranslationProvider.of(context).locale.languageCode).add_Hms().format(lastModification.value!)}\n${status == _Status.bad ? translations.home.synchronizationStatus.bad : translations.home.synchronizationStatus.good}',
      },
      onTap: () async => await downloadLessons(ref),
      onRemove: () => ref.read(homeCardsProvider.notifier).removeCard(HomeCard.synchronizationStatus),
    );
  }
}

/// The synchronization status.
enum _Status {
  /// When the lesson repository has never been synchronized.
  never(
    resolveColor: _greyColorResolver,
    icon: Icons.sync_problem,
  ),

  /// When the lesson repository is loading.
  loading(
    resolveColor: _greyColorResolver,
    icon: Icons.sync,
  ),

  /// When the synchronization status is bad.
  bad(
    resolveColor: _redColorResolver,
    icon: Icons.sync_problem,
  ),

  /// When the synchronization status is good.
  good(
    resolveColor: _tealColorResolver,
    icon: Icons.sync,
  );

  /// The card icon.
  final IconData icon;

  /// The card color.
  final Color Function() resolveColor;

  /// Creates a new status instance.
  const _Status({
    required this.icon,
    required this.resolveColor,
  });

  /// Resolves to [Colors.grey.shade700].
  static Color _greyColorResolver() => Colors.grey.shade700;

  /// Resolves to [Colors.red.shade700].
  static Color _redColorResolver() => Colors.red.shade700;

  /// Resolves to [Colors.teal.shade700].
  static Color _tealColorResolver() => Colors.teal.shade700;

  /// Resolves the status from the given [lastModification] and [interval].
  static _Status resolve(AsyncValue<DateTime?> lastModification, int interval) {
    if (lastModification is AsyncLoading<DateTime?> || lastModification is AsyncError<DateTime?>) {
      return loading;
    }
    DateTime? date = lastModification.value;
    if (date == null) {
      return never;
    }
    return DateTime.now().difference(date).compareTo(Duration(days: interval) * 7) > 0 ? bad : good;
  }
}
