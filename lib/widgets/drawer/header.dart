import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/model/settings/username.dart';
import 'package:unicaen_timetable/widgets/dialogs/input.dart';

/// The drawer header.
class DrawerHeader extends ConsumerWidget {
  /// Creates a new drawer header instance.
  const DrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DisplayedUsername? username = ref.watch(displayedUsernameSettingsEntryProvider).value;
    if (username == null) {
      return const SizedBox.shrink();
    }

    return UserAccountsDrawerHeader(
      accountName: GestureDetector(
        onTap: () async {
          String? newUsername = await TextInputDialog.getValue(
            context,
            initialValue: username.displayedUsername,
            hint: username.autoUsername,
            validator: TextInputDialog.validateNotEmpty,
          );
          if (newUsername != null) {
            ref.read(displayedUsernameSettingsEntryProvider.notifier).manuallyChangeUsername(newUsername);
          }
        },
        child: Text(username.displayedUsername),
      ),
      accountEmail: Text(username.displayedEmail),
      currentAccountPicture: CircleAvatar(
        child: ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvgHttpUrl(
            Uri.parse('https://api.dicebear.com/9.x/thumbs/svg?seed=${username.displayedUsername}&radius=50'),
          ),
          onError: (context) => ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSI(rootBundle, 'assets/icon.si'),
          ),
        ),
      ),
      decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
    );
  }
}
