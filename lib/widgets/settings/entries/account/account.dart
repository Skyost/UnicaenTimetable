import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/model/lessons/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/repository.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/widgets/dialogs/login.dart';
import 'package:unicaen_timetable/widgets/settings/entries/entry.dart';

/// Allows to display the account settings entry.
class AccountSettingsEntryWidget extends SettingsEntryWidget {
  /// Creates a new account settings entry widget instance.
  AccountSettingsEntryWidget({
    super.key,
    required super.entry,
  });

  @override
  Widget createSubtitle(BuildContext context, WidgetRef ref) {
    UserRepository userRepository = ref.watch(userRepositoryProvider);
    return FutureBuilder<User?>(
      initialData: null,
      future: userRepository.getUser(),
      builder: (context, snapshot) => snapshot.data == null ? const SizedBox.shrink() : Text(snapshot.data!.usernameWithoutAt),
    );
  }

  @override
  Future<void> onTap(BuildContext context, WidgetRef ref) async {
    bool result = await LoginDialog.show(context);
    if (result && context.mounted) {
      LessonRepository lessonRepository = ref.read(lessonRepositoryProvider);
      await lessonRepository.downloadLessonsFromWidget(context, ref);
    }
  }
}
