import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';

/// Allows to display the AdMob settings entry.
class AdMobSettingsEntryWidget extends SettingsEntryWidget<bool> {
  /// Creates a new AdMob settings entry widget instance.
  AdMobSettingsEntryWidget({
    super.key,
    required super.entry,
  });

  @override
  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    bool? result = await BoolInputDialog.getValue(
      context,
      titleKey: 'dialogs.enable_ads.title',
      messageKey: 'dialogs.enable_ads.message',
      yesButtonKey: 'dialogs.enable_ads.enable',
      noButtonKey: 'dialogs.enable_ads.disable',
    );
    if (result != null && result != entry.value) {
      await super.onTap(context, ref);
    }
  }
}
