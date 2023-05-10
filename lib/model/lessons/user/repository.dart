import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lessons/authentication/state.dart';
import 'package:unicaen_timetable/model/lessons/user/test.dart';
import 'package:unicaen_timetable/model/lessons/user/user.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/utils/calendar_url.dart';

final userRepositoryProvider = ChangeNotifierProvider((ref) {
  UserRepository userRepository = UserRepository();
  userRepository.initialize();
  return userRepository;
});

/// The user repository.
class UserRepository extends UnicaenTimetableModel {
  /// The cached user.
  User? _cachedUser;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    Map<dynamic, dynamic>? response = await UnicaenTimetableRoot.channel.invokeMethod<Map<dynamic, dynamic>>('account.get');
    if (response == null) {
      return;
    }

    _cachedUser = User(username: response['username'], password: response['password']);
    if (await isTestUser(_cachedUser)) {
      _cachedUser = TestUser(_cachedUser!);
    }
    if (_isUserAccountDeprecated) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      if (!preferences.containsKey('user.has-migrated-account')) {
        await removeUser();
        await preferences.setBool('user.has-migrated-account', true);
      }
    }
    markInitialized();
  }

  /// Updates the user.
  Future<void> updateUser(User user) async {
    _cachedUser = await isTestUser(user) ? TestUser(user) : user;
    await removeUser();
    await UnicaenTimetableRoot.channel.invokeMethod('account.create', {
      'username': user.username,
      'password': user.password,
    });
  }

  /// Removes the current user.
  Future<void> removeUser() => UnicaenTimetableRoot.channel.invokeMethod('account.remove');

  /// Returns whether this is the test user.
  Future<bool> isTestUser(User? user) async => await TestUser(user).login(const CalendarUrl()) == RequestResultState.success;

  /// Returns the user.
  User? get user => _cachedUser;

  /// Returns whether the account is deprecated and should be deleted.
  bool get _isUserAccountDeprecated => Platform.isAndroid && user != null && user!.password.startsWith('{0}');
}
