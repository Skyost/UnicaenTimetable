import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:unicaen_timetable/model/user/user.dart';

/// The drawer header.
class DrawerHeader extends ConsumerWidget {
  /// Creates a new drawer header instance.
  const DrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = ref.watch(userProvider).valueOrNull;
    if (user == null) {
      return const SizedBox.shrink();
    }

    String username = user.username;
    if (username.endsWith('@etu.unicaen.fr')) {
      username = username.split('@').first;
    }
    String email = '$username@etu.unicaen.fr';
    return UserAccountsDrawerHeader(
      accountName: Text(username),
      accountEmail: Text(email),
      currentAccountPicture: ScalableImageWidget.fromSISource(
        si: ScalableImageSource.fromSI(rootBundle, 'assets/icon.si'),
      ),
      decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
    );
  }
}
