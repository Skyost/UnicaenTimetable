
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/settings/entries/application/admob.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/pages/home.dart';
import 'package:unicaen_timetable/pages/page_container.dart';

/// The floating button that allows to synchronize the app.
class SynchronizeFloatingButton extends ConsumerWidget {
  /// Creates a new synchronize floating button instance.
  const SynchronizeFloatingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget button = FloatingActionButton(
      onPressed: () async {
        LessonRepository lessonRepository = ref.read(lessonRepositoryProvider);
        await lessonRepository.downloadLessonsFromWidget(context, ref);
      },
      tooltip: context.getString('scaffold.floating_button_tooltip'),
      elevation: 1,
      child: const Icon(Icons.sync),
    );

    if (ref.watch(currentPageProvider).value != HomePage.id) {
      return button;
    }

    AdMobSettingsEntry adMobSettingsEntry = ref.watch(settingsModelProvider.select((settings) => settings.adMobEntry));
    BannerAd? banner = adMobSettingsEntry.createBanner(context);
    if (banner == null) {
      return button;
    }

    double bannerHeight = banner.size.height.toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: bannerHeight + 10),
      child: button,
    );
  }
}
