import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:unicaen_timetable/model/storage/storage_interface.dart';

class Storage with StorageInterface {
  String? _pathPrefix;

  @override
  Future<String> buildPathPrefix() async {
    _pathPrefix ??= '${(await getApplicationDocumentsDirectory()).path}/';
    return _pathPrefix!;
  }

  @override
  Future<String> readFile(String file) async => (await _getFile(file)).readAsStringSync();

  @override
  Future<void> saveFile(String file, String content) async => (await _getFile(file)).writeAsStringSync(content);

  @override
  Future<void> deleteFile(String file) async => (await _getFile(file)).deleteSync();

  @override
  Future<bool> fileExists(String file) async => (await _getFile(file)).existsSync();

  @override
  Future<DateTime?> getLastModificationTime(String file) async => await fileExists(file) ? (await _getFile(file)).lastModifiedSync() : null;

  Future<File> _getFile(String file) async => File((await buildPathPrefix()) + file);
}
