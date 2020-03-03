import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/utils/http_client.dart';

part 'user.g.dart';

/// Represents an user with an username and a password.
@HiveType(typeId: 0)
class User extends HiveObject {
  /// The username.
  @HiveField(0)
  String username;

  /// The password.
  @HiveField(1)
  String password;

  /// Creates a new username instance.
  User({
    @required this.username,
    @required this.password,
  });

  /// Returns the username without the @.
  String get usernameWithoutAt => username.split('@').first;

  /// Returns whether this is the test user.
  Future<bool> get isTestUser async {
    Map<String, dynamic> data = jsonDecode(await rootBundle.loadString('assets/test_data.json'));
    return data['username'] == username && data['password'] == password;
  }

  /// Requests the calendar according to the specified settings model.
  Future<Response> requestCalendar(SettingsModel model) async {
    UnicaenTimetableHttpClient client = const UnicaenTimetableHttpClient();
    Response response = await client.connect(model.getCalendarAddressFromSettings(this), this);
    if (response?.statusCode == 401 || response?.statusCode == 404) {
      username = username.endsWith('@etu.unicaen.fr') ? username.substring(0, username.lastIndexOf('@etu.unicaen.fr')) : (username + '@etu.unicaen.fr');
      response = await client.connect(model.getCalendarAddressFromSettings(this), this);
    }

    return response;
  }

  /// Tries to login this user.
  Future<LoginResult> login(SettingsModel model) async {
    if (await isTestUser) {
      return LoginResult.SUCCESS;
    }

    return getLoginResultFromResponse(await requestCalendar(model));
  }

  /// Returns the login result corresponding to the given response.
  static LoginResult getLoginResultFromResponse(Response response) {
    if (response == null) {
      return LoginResult.GENERIC_ERROR;
    }

    switch (response.statusCode) {
      case 200:
        return LoginResult.SUCCESS;
      case 401:
        return LoginResult.UNAUTHORIZED;
      case 404:
        return LoginResult.NOT_FOUND;
      default:
        return LoginResult.GENERIC_ERROR;
    }
  }
}

/// Represents a login result.
enum LoginResult {
  /// Login success.
  SUCCESS,

  /// Calendar not found.
  NOT_FOUND,

  /// Unauthorized.
  UNAUTHORIZED,

  /// Generic error (no connection, catch error, ...).
  GENERIC_ERROR,
}

/// The user repository.
abstract class UserRepository<K> extends UnicaenTimetableModel {
  /// The password encryption key.
  K _encryptionKey;

  /// The cached user.
  User _cachedUser;

  /// Creates a new user repository according to the platform.
  factory UserRepository() => Platform.isAndroid ? AndroidUserRepository() : IOSUserRepository();

  /// The internal constructor.
  UserRepository._internal();

  /// Returns the user.
  Future<User> getUser() async {
    if (_cachedUser == null) {
      _cachedUser = await _read();
      notifyListeners();
    }

    return _cachedUser;
  }

  /// Updates the user.
  @mustCallSuper
  Future<void> updateUser(User user) async {
    _cachedUser = user;
  }

  /// Reads the user.
  Future<User> _read();
}

/// The android user repository.
class AndroidUserRepository extends UserRepository<String> {
  /// Creates a new android user repository.
  AndroidUserRepository() : super._internal();

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    FlutterSecureStorage storage = const FlutterSecureStorage();
    String encryptionKey = await storage.read(key: 'encryption_key');
    if (encryptionKey == null) {
      encryptionKey = await CryptKey().genFortuna();
      await storage.write(key: 'encryption_key', value: encryptionKey);
    }

    _encryptionKey = encryptionKey;
    markInitialized();
  }

  @override
  Future<User> _read() async {
    Map<dynamic, dynamic> response = await UnicaenTimetableApp.CHANNEL.invokeMethod('account.get');
    if (response == null) {
      return null;
    }

    if (response['base64_encoded']) {
      await updateUser(User(
        username: response['username'],
        password: response['password'],
      ));
      return _read();
    }

    return User(
      username: response['username'],
      password: await AesCrypt(_encryptionKey, 'ofb-64', 'pkcs7').decrypt(response['password']),
    );
  }

  @override
  Future<void> updateUser(User user) async {
    await super.updateUser(user);

    await UnicaenTimetableApp.CHANNEL.invokeMethod('account.remove');
    await UnicaenTimetableApp.CHANNEL.invokeMethod('account.create', {
      'username': user.username,
      'password': await AesCrypt(_encryptionKey, 'ofb-64', 'pkcs7').encrypt(user.password),
    });

    notifyListeners();
  }
}

/// The iOS user repository.
class IOSUserRepository extends UserRepository<List<int>> {
  /// The user hive box.
  static const String _HIVE_BOX = 'user';

  /// Creates a new iOS user repository.
  IOSUserRepository() : super._internal();

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    FlutterSecureStorage storage = const FlutterSecureStorage();

    Hive.registerAdapter(UserAdapter());
    String rawEncryptionKey = await storage.read(key: 'encryption_key');
    if (rawEncryptionKey == null) {
      _encryptionKey = Hive.generateSecureKey();
      await storage.write(key: 'encryption_key', value: jsonEncode(_encryptionKey));
    } else {
      _encryptionKey = jsonDecode(rawEncryptionKey);
    }

    markInitialized();
  }

  @override
  Future<User> _read() async {
    Box<User> box = await Hive.openBox<User>(_HIVE_BOX, encryptionCipher: HiveAesCipher(_encryptionKey));
    return box.getAt(0);
  }

  @override
  Future<void> updateUser(User user) async {
    await super.updateUser(user);

    Box<User> box = await Hive.openBox<User>(_HIVE_BOX, encryptionCipher: HiveAesCipher(_encryptionKey));
    await box.putAt(0, user);
    return user;
  }
}
