
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unicaen_timetable/model/lessons/user/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/theme.dart';

/// The drawer header.
class DrawerHeader extends ConsumerWidget {
  /// Creates a new drawer header instance.
  const DrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserRepository userRepository = ref.watch(userRepositoryProvider);
    return FutureBuilder<User?>(
      future: userRepository.getUser(),
      builder: (context, snapshot) {
        User? user = snapshot.data;
        if (user == null) {
          return const SizedBox.shrink();
        }

        UnicaenTimetableTheme theme = ref.watch(settingsModelProvider).resolveTheme(context);
        return UserAccountsDrawerHeader(
          accountName: Text(user.usernameWithoutAt),
          accountEmail: Text(user.username.contains('@') ? user.username : ('${user.username}@etu.unicaen.fr')),
          currentAccountPicture: SvgPicture.asset('assets/icon.svg'),
          decoration: BoxDecoration(color: theme.actionBarColor),
        );
      },
    );
  }
}
