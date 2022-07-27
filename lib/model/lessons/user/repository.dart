import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
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
abstract class UserRepository extends UnicaenTimetableModel {
  /// The password encryption key.
  dynamic _encryptionKey;

  /// The cached user.
  User? _cachedUser;

  /// Creates a new user repository according to the platform.
  factory UserRepository() => Platform.isAndroid ? _AndroidUserRepository() : _IOSUserRepository();

  /// The internal constructor.
  UserRepository._internal();

  /// Returns the user.
  Future<User?> getUser() async {
    if (_cachedUser == null) {
      _cachedUser = await _read();
      if (await isTestUser(_cachedUser)) {
        _cachedUser = TestUser(_cachedUser!);
      }

      notifyListeners();
    }
    return _cachedUser;
  }

  /// Updates the user.
  @mustCallSuper
  Future<void> updateUser(User user) async => _cachedUser = user;

  /// Reads the user.
  Future<User?> _read();

  /// Returns whether this is the test user.
  Future<bool> isTestUser(User? user) async => await TestUser(user).login(const CalendarUrl()) == RequestResultState.success;
}

/// The android user repository.
class _AndroidUserRepository extends UserRepository {
  /// The version.
  static const int _version = 1;

  /// The initialization vector.
  IV? _initializationVector;

  /// Creates a new android user repository.
  _AndroidUserRepository() : super._internal();

  @override
  Key? get _encryptionKey => super._encryptionKey as Key?;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? rawEncryptionKey = await storage.read(key: 'encryption_key');
    String? rawInitializationVector = await storage.read(key: 'initialization_vector');

    if (!_testValidity(rawEncryptionKey, rawInitializationVector)) {
      await removeUser();
      rawEncryptionKey = null;
      rawInitializationVector = null;
    }

    if (rawEncryptionKey == null) {
      _encryptionKey = Key.fromLength(32);
      await storage.write(key: 'encryption_key', value: _encryptionKey!.base64);
    } else {
      _encryptionKey = Key.fromBase64(rawEncryptionKey);
    }

    if (rawInitializationVector == null) {
      _initializationVector = IV.fromLength(16);
      await storage.write(key: 'initialization_vector', value: _initializationVector!.base64);
    } else {
      _initializationVector = IV.fromBase64(rawInitializationVector);
    }

    markInitialized();
  }

  @override
  Future<User?> _read() async {
    try {
      Map<dynamic, dynamic>? response = await UnicaenTimetableRoot.channel.invokeMethod<Map<dynamic, dynamic>>('account.get');
      if (response == null) {
        return null;
      }

      Encrypter? encrypter = this.encrypter;
      if (encrypter == null) {
        return null;
      }

      String password = response['password'];
      if (password.startsWith((_version - 1).toString())) {
        return null;
      }

      return User(
        username: response['username'],
        password: encrypter.decrypt64(password.substring(accountVersionPrefix.length), iv: _initializationVector),
      );
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    Encrypter? encrypter = this.encrypter;
    if (encrypter != null) {
      await super.updateUser(user);

      await removeUser();
      await UnicaenTimetableRoot.channel.invokeMethod('account.create', {
        'username': user.username,
        'password': accountVersionPrefix + encrypter.encrypt(user.password, iv: _initializationVector).base64,
      });

      notifyListeners();
    }
  }

  /// Removes the current user.
  Future<void> removeUser() => UnicaenTimetableRoot.channel.invokeMethod('account.remove');

  /// Tests the data validity.
  bool _testValidity(String? encryptionKey, String? initializationVector) {
    try {
      if (encryptionKey != null) {
        base64.decode(encryptionKey);
      }
      if (initializationVector != null) {
        base64.decode(initializationVector);
      }
      return true;
    } catch (_) {}
    return false;
  }

  /// Allows to encrypt strings using the AES algorithm.
  Encrypter? get encrypter => _encryptionKey == null ? null : Encrypter(AES(_encryptionKey!, mode: AESMode.ofb64));

  /// Returns the account version prefix.
  String get accountVersionPrefix => '{$_version}';
}

/// The iOS user repository.
class _IOSUserRepository extends UserRepository {
  /// The user hive box.
  static const String _hiveBox = 'user';

  /// Creates a new iOS user repository.
  _IOSUserRepository() : super._internal();

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    FlutterSecureStorage storage = const FlutterSecureStorage();

    Hive.registerAdapter(UserAdapter());
    String? rawEncryptionKey = await storage.read(key: 'encryption_key');
    if (rawEncryptionKey == null) {
      _encryptionKey = Hive.generateSecureKey();
      await storage.write(key: 'encryption_key', value: jsonEncode(_encryptionKey));
    } else {
      List<int> result = [];
      List<dynamic> jsonKey = jsonDecode(rawEncryptionKey);
      for (dynamic value in jsonKey) {
        result.add(value);
      }
      _encryptionKey = result;
    }

    markInitialized();
  }

  @override
  Future<User?> _read() async {
    Box<User> box = await Hive.openBox<User>(_hiveBox, encryptionCipher: HiveAesCipher(_encryptionKey));
    return box.get(0);
  }

  @override
  Future<void> updateUser(User user) async {
    await super.updateUser(user);

    Box<User> box = await Hive.openBox<User>(_hiveBox, encryptionCipher: HiveAesCipher(_encryptionKey));
    await box.put(0, user);
  }
}
