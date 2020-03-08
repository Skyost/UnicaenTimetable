import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/pages/home/cards/card.dart';
import 'package:unicaen_timetable/pages/scaffold.dart';

/// A card that shows the synchronization status.
class SynchronizationStatusCard extends MaterialCard {
  /// The card id.
  static const String ID = 'synchronization_status';

  /// Creates the synchronization status card.
  const SynchronizationStatusCard() : super(cardId: ID);

  @override
  IconData buildIcon(BuildContext context) => isBad(context) ? Icons.sync_problem : Icons.sync;

  @override
  Color buildColor(BuildContext context) => isBad(context) ? Colors.red[700] : Colors.teal[700];

  @override
  String buildSubtitle(BuildContext context) {
    LessonModel lessonModel = Provider.of<LessonModel>(context);
    String date = lessonModel.lastModificationTime == null ? EzLocalization.of(context).get('home.synchronization_status.never') : DateFormat.yMd(EzLocalization.of(context).locale.languageCode).add_Hms().format(lessonModel.lastModificationTime);
    return date + '\n' + EzLocalization.of(context).get('home.synchronization_status.' + (isBad(context) ? 'bad' : 'good'));
  }

  @override
  void onTap(BuildContext context) => SynchronizeFloatingButton.onPressed(context);

  bool isBad(BuildContext context) {
    SettingsModel settingsModel = Provider.of<SettingsModel>(context);
    LessonModel lessonModel = Provider.of<LessonModel>(context);

    return lessonModel.lastModificationTime == null || DateTime.now().difference(lessonModel.lastModificationTime).compareTo(Duration(days: settingsModel.getEntryByKey('server.interval').value) * 7) > 0;
  }
}
