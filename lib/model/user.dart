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
import 'package:unicaen_timetable/model/app_model.dart';
import 'package:unicaen_timetable/model/http_client.dart';
import 'package:unicaen_timetable/model/settings.dart';
import 'package:unicaen_timetable/utils/utils.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;
  @HiveField(1)
  String password;

  User({
    @required this.username,
    @required this.password,
  });

  String get usernameWithoutAt => username.split('@').first;

  Future<bool> get isTestUser async {
    Map<String, dynamic> data = jsonDecode(await rootBundle.loadString('assets/test_data.json'));
    return data['username'] == username && data['password'] == password;
  }

  Future<Response> requestCalendar(SettingsModel model) async {
    UnicaenTimetableHttpClient client = const UnicaenTimetableHttpClient();
    Response response = await client.connect(await getCalendarAddressFromSettings(model), this);
    if (response?.statusCode == 401 || response?.statusCode == 404) {
      username = username.endsWith('@etu.unicaen.fr') ? username.substring(0, username.lastIndexOf('@etu.unicaen.fr')) : (username + '@etu.unicaen.fr');
      response = await client.connect(await getCalendarAddressFromSettings(model), this);
    }

    return response;
  }

  Future<LoginResult> login(SettingsModel model) async {
    if (await isTestUser) {
      return LoginResult.SUCCESS;
    }

    return getLoginResultFromResponse(await requestCalendar(model));
  }

  Future<Uri> getCalendarAddressFromSettings(SettingsModel model) async {
    String url = (await model.getEntryByKey('server.server')).value;
    url += '/home/';
    url += username;
    url += '/';
    url += Uri.encodeFull((await model.getEntryByKey('server.calendar')).value);
    url += '?auth=ba&fmt=json';

    String additionalParameters = (await model.getEntryByKey('server.additional_parameters')).value;
    if (additionalParameters.isNotEmpty) {
      url += '&';
      url += additionalParameters;
    }

    int interval = (await model.getEntryByKey('server.interval')).value;
    if (interval > 0) {
      DateTime now = DateTime.now().atMonday.yearMonthDay;
      DateTime min = now.subtract(Duration(days: interval * 7));
      DateTime max = now.add(Duration(days: interval * 7)).add(Duration(days: DateTime.friday));

      url += '&start=' + min.year.toString() + '/' + min.month.withLeadingZero + '/' + min.day.withLeadingZero;
      url += '&end=' + max.year.toString() + '/' + max.month.withLeadingZero + '/' + max.day.withLeadingZero;
    }

    return Uri.parse(url);
  }

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

enum LoginResult {
  SUCCESS,
  NOT_FOUND,
  UNAUTHORIZED,
  GENERIC_ERROR,
}

abstract class UserRepository<K> extends AppModel {
  K _encryptionKey;
  User _cachedUser;

  factory UserRepository() => Platform.isAndroid ? AndroidUserRepository() : IOSUserRepository();

  UserRepository._internal();

  Future<User> get() async {
    if (_cachedUser == null) {
      _cachedUser = await _read();
      notifyListeners();
    }

    return _cachedUser;
  }

  Future<User> _read();

  @mustCallSuper
  Future<void> update(User user) async {
    _cachedUser = user;
  }
}

class AndroidUserRepository extends UserRepository<String> {
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
      await update(User(
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
  Future<void> update(User user) async {
    await super.update(user);

    await UnicaenTimetableApp.CHANNEL.invokeMethod('account.remove');
    await UnicaenTimetableApp.CHANNEL.invokeMethod('account.create', {
      'username': user.username,
      'password': await AesCrypt(_encryptionKey, 'ofb-64', 'pkcs7').encrypt(user.password),
    });

    notifyListeners();
  }
}

class IOSUserRepository extends UserRepository<List<int>> {
  static const String _HIVE_BOX = 'user';

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
  Future<void> update(User user) async {
    await super.update(user);

    Box<User> box = await Hive.openBox<User>(_HIVE_BOX, encryptionCipher: HiveAesCipher(_encryptionKey));
    await box.putAt(0, user);
    return user;
  }
}
