import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:unicaen_timetable/main.dart';
import 'package:unicaen_timetable/model/lesson.dart';
import 'package:unicaen_timetable/model/model.dart';
import 'package:unicaen_timetable/model/settings/settings.dart';
import 'package:unicaen_timetable/utils/utils.dart';

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
    required this.username,
    required this.password,
  });

  /// Returns the username without the @.
  String get usernameWithoutAt => username.split('@').first;

  /// Tries to login this user.
  Future<LoginResult> login(SettingsModel model) async => LoginResult.fromResponse(await model.requestCalendar(this));

  /// Tries to synchronize this user from Zimbra.
  Future<dynamic> synchronizeFromZimbra({
    required LazyBox<List> lessonsBox,
    required SettingsModel settingsModel,
  }) async {
    Response? response = await settingsModel.requestCalendar(this);
    if (response?.statusCode != 200) {
      return response;
    }

    Map<String, dynamic> body = jsonDecode(utf8.decode(response!.bodyBytes));
    await lessonsBox.clear();

    if (body.isNotEmpty) {
      List<dynamic> appt = body['appt'];
      for (dynamic jsonData in appt) {
        if (!jsonData.containsKey('inv')) {
          continue;
        }

        Lesson lesson = Lesson.fromJson(jsonData['inv'].first);
        DateTime start = lesson.start.yearMonthDay;
        List lessons = List.from((await lessonsBox.get(start.yearMonthDay.toString())) ?? []);
        await lessonsBox.put(start.toString(), lessons..add(lesson));
      }
    }
  }
}

/// The test user (for Apple Store review).
class TestUser extends User {
  /// Creates a new test user instance.
  TestUser(User user)
      : super(
          username: user.username,
          password: user.password,
        );

  @override
  Future<LoginResult> login(SettingsModel model) async => LoginResult.SUCCESS;

  @override
  Future<dynamic> synchronizeFromZimbra({
    required LazyBox<List> lessonsBox,
    required SettingsModel settingsModel,
  }) async {
    DateTime now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      now = now.add(const Duration(days: 7));
    }
    DateTime monday = now.yearMonthDay.atMonday;

    Map<String, dynamic> calendar = jsonDecode(await rootBundle.loadString('assets/test_data.json'))['calendar'];
    List<String> days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    await lessonsBox.clear();
    for (int i = 0; i < days.length; i++) {
      DateTime date = monday.add(Duration(days: i));
      List<Lesson> lessons = _decodeDay(date, calendar, days[i]);

      await lessonsBox.put(date.toString(), lessons);
    }
  }

  /// Decodes the specified day from the test calendar.
  List<Lesson> _decodeDay(DateTime date, Map<String, dynamic> calendar, String day) {
    List<Lesson> result = [];
    List<dynamic> lessons = calendar[day];
    for (dynamic lesson in lessons) {
      result.add(Lesson.fromTestJson(date, lesson));
    }
    return result;
  }
}

/// Represents a login result.
class LoginResult {
  /// Login success.
  static const SUCCESS = LoginResult._internal(200);

  /// Calendar not found.
  static const NOT_FOUND = LoginResult._internal(401);

  /// Unauthorized.
  static const UNAUTHORIZED = LoginResult._internal(404);

  /// Generic error (no connection, catch error, ...).
  static const GENERIC_ERROR = LoginResult._internal(null);

  /// The http response code.
  final int? httpCode;

  /// Creates a new login result.
  const LoginResult._internal(this.httpCode);

  /// Returns the login result corresponding to the given response.
  LoginResult.fromResponse(Response? response) : httpCode = response?.statusCode;

  @override
  bool operator ==(other) {
    if (other is! LoginResult) {
      return false;
    }

    return toString() == other.toString();
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    if (httpCode == SUCCESS.httpCode) {
      return 'SUCCESS';
    }

    if (httpCode == NOT_FOUND.httpCode) {
      return 'NOT_FOUND';
    }

    if (httpCode == UNAUTHORIZED.httpCode) {
      return 'UNAUTHORIZED';
    }

    return 'GENERIC_ERROR';
  }
}

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
  Future<bool> isTestUser(User? user) async {
    Map<String, dynamic> data = jsonDecode(await rootBundle.loadString('assets/test_data.json'));
    return data['username'] == user?.username && data['password'] == user?.password;
  }
}

/// The android user repository.
class _AndroidUserRepository extends UserRepository {
  /// The version.
  static const int _VERSION = 1;

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
      Map<dynamic, dynamic>? response = await UnicaenTimetableApp.CHANNEL.invokeMethod<Map<dynamic, dynamic>>('account.get');
      if (response == null) {
        return null;
      }

      Encrypter? encrypter = this.encrypter;
      if (encrypter == null) {
        return null;
      }

      String username = response['username'];
      String password = response['password'];
      User? toUpdate = _needUpdate(username, password);
      if (toUpdate != null) {
        await updateUser(toUpdate);
        return toUpdate;
      }

      return User(
        username: username,
        password: encrypter.decrypt64(password.substring(accountVersionPrefix.length), iv: _initializationVector),
      );
    } catch (ex, stacktrace) {
      print(ex);
      print(stacktrace);
    }
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    Encrypter? encrypter = this.encrypter;
    if (encrypter != null) {
      await super.updateUser(user);

      await removeUser();
      await UnicaenTimetableApp.CHANNEL.invokeMethod('account.create', {
        'username': user.username,
        'password': accountVersionPrefix + encrypter.encrypt(user.password, iv: _initializationVector).base64,
      });

      notifyListeners();
    }
  }

  /// Removes the current user.
  Future<void> removeUser() => UnicaenTimetableApp.CHANNEL.invokeMethod('account.remove');

  /// Returns an user if the user should be updated.
  User? _needUpdate(String username, String password) {
    if (!password.startsWith(accountVersionPrefix)) {
      return User(
        username: username,
        password: utf8.decode(base64.decode(password)),
      );
    }
    return null;
  }

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
  String get accountVersionPrefix => '{$_VERSION}';
}

/// The iOS user repository.
class _IOSUserRepository extends UserRepository {
  /// The user hive box.
  static const String _HIVE_BOX = 'user';

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
    Box<User> box = await Hive.openBox<User>(_HIVE_BOX, encryptionCipher: HiveAesCipher(_encryptionKey));
    return box.get(0);
  }

  @override
  Future<void> updateUser(User user) async {
    await super.updateUser(user);

    Box<User> box = await Hive.openBox<User>(_HIVE_BOX, encryptionCipher: HiveAesCipher(_encryptionKey));
    await box.put(0, user);
  }
}
