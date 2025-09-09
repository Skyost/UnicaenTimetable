import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicaen_timetable/model/settings/entry.dart';
import 'package:unicaen_timetable/model/user/user.dart';

/// The displayed username settings entry provider.
final displayedUsernameSettingsEntryProvider = AsyncNotifierProvider.autoDispose<DisplayedUsernameSettingsEntry, DisplayedUsername?>(DisplayedUsernameSettingsEntry.new);

/// The displayed username entry that defines which server to use.
class DisplayedUsernameSettingsEntry extends SettingsEntry<DisplayedUsername?> {
  /// Creates a new server settings entry instance.
  DisplayedUsernameSettingsEntry()
    : super(
        key: 'displayedUsername',
        defaultValue: null,
      );

  @override
  FutureOr<DisplayedUsername?> build() async {
    ref.listen(userProvider, _onUserChange, fireImmediately: true);
    return await super.build();
  }

  @override
  DisplayedUsername? loadFromPreferences(SharedPreferencesWithCache preferences) {
    String? json = preferences.getString(key);
    return json == null ? null : DisplayedUsername._fromJson(jsonDecode(json));
  }

  @override
  Future<void> saveToPreferences(SharedPreferencesWithCache preferences, DisplayedUsername? value) async {
    if (value == null) {
      await preferences.remove(key);
    } else {
      await preferences.setString(key, jsonEncode(value.toJson()));
    }
  }

  /// Changes the current username manually.
  Future<void> manuallyChangeUsername(String manualUsername) async {
    DisplayedUsername? username = await future;
    if (username != null) {
      await changeValue(
        username.copyWith(
          manualUsername: manualUsername,
        ),
      );
    }
  }

  /// Triggered when the user has changed.
  Future<void> _onUserChange(AsyncValue<User?>? oldUser, AsyncValue<User?> newUser) async {
    DisplayedUsername? username = await future;
    User? user = newUser.valueOrNull;
    if (user != null) {
      String autoUsername = DisplayedUsername.deduceFromUser(user);
      if (username?.autoUsername != autoUsername) {
        await changeValue(
          DisplayedUsername._(
            autoUsername: autoUsername,
          ),
        );
      }
    }
  }
}

/// Represents an username.
class DisplayedUsername {
  /// Automatically deduced username.
  final String autoUsername;

  /// Manually entered username.
  final String? manualUsername;

  /// Creates a new username instance.
  const DisplayedUsername._({
    required this.autoUsername,
    this.manualUsername,
  });

  /// Creates a new username instance from a JSON map.
  DisplayedUsername._fromJson(Map<String, dynamic> json)
    : this._(
        autoUsername: json['autoUsername'],
        manualUsername: json['manualUsername'],
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'autoUsername': autoUsername,
    'manualUsername': manualUsername,
  };

  /// Deduces username from [user].
  static String deduceFromUser(User user) {
    String username = user.username;
    if (username.endsWith('@etu.unicaen.fr')) {
      username = username.split('@').first;
    }
    return username;
  }

  /// Returns the username to display.
  String get displayedUsername => manualUsername ?? autoUsername;

  /// Returns the email to display.
  String get displayedEmail => '$autoUsername@etu.unicaen.fr';

  /// Copies this instance with the given parameters.
  DisplayedUsername copyWith({
    String? autoUsername,
    String? manualUsername,
  }) => DisplayedUsername._(
    autoUsername: autoUsername ?? this.autoUsername,
    manualUsername: manualUsername ?? this.manualUsername,
  );

  @override
  bool operator ==(Object other) {
    if (other is! DisplayedUsername) {
      return super == other;
    }
    return autoUsername == other.autoUsername && other.manualUsername == manualUsername;
  }

  @override
  int get hashCode => Object.hash(autoUsername, manualUsername);
}
