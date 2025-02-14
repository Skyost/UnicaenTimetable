import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicaen_timetable/main.dart';

/// The user provider.
final userProvider = AsyncNotifierProvider<UserNotifier, User?>(UserNotifier.new);

/// The user notifier.
class UserNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    Map<dynamic, dynamic>? response = await UnicaenTimetableRoot.channel.invokeMethod<Map<dynamic, dynamic>>('account.get');
    return response == null || !response.containsKey('username') || !response.containsKey('password')
        ? null
        : User(
            username: response['username'],
            password: response['password'],
          );
  }

  /// Updates the user.
  Future<void> updateUser(User user) async {
    await removeUser();
    await UnicaenTimetableRoot.channel.invokeMethod('account.create', user._toMap());
    state = AsyncData(user);
  }

  /// Removes the current user.
  Future<void> removeUser() async {
    await UnicaenTimetableRoot.channel.invokeMethod('account.remove');
    state = const AsyncData(null);
  }
}

/// Represents an user.
sealed class User {
  /// Returns the username.
  String get username;

  /// Returns the password.
  String get password;

  /// Creates a new user instance.
  const User._();

  /// Creates a new user instance.
  factory User({
    required String username,
    required String password,
  }) =>
      username == TestUser._kUsername && password == TestUser._kPassword
          ? TestUser._()
          : CredentialsUser._(
              username: username,
              password: password,
            );

  @override
  bool operator ==(Object other) {
    if (other is! User) {
      return super == other;
    }
    return username == other.username && other.password == password;
  }

  @override
  int get hashCode => Object.hash(username, password);

  /// Converts this user to a map.
  Map<String, dynamic> _toMap() => {
        'username': username,
        'password': password,
      };
}

/// Represents an user with an username and a password.
class CredentialsUser extends User {
  @override
  final String username;

  @override
  final String password;

  /// Creates a new user instance.
  const CredentialsUser._({
    required this.username,
    required this.password,
  }) : super._();

  /// Copies the user instance with the given parameters.
  User copyWith({
    String? username,
    String? password,
  }) =>
      User(
        username: username ?? this.username,
        password: password ?? this.password,
      );
}

/// The test user (for Apple Store review).
class TestUser extends User {
  /// The username to use during tests.
  static const String _kUsername = 'test';

  /// The password to use during tests.
  static const String _kPassword = 'test';

  @override
  String get username => _kUsername;

  @override
  String get password => _kPassword;

  /// Creates a new test user instance.
  TestUser._() : super._();
}
