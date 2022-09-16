import 'package:unicaen_timetable/model/storage/storage_interface.dart';

class Storage with StorageInterface {
  @override
  Future<String> buildPathPrefix() async => '';

  @override
  Future<String> readFile(String file) async => '[]';

  @override
  Future<void> saveFile(String file, String content) async {}

  @override
  Future<void> deleteFile(String file) async {}

  @override
  Future<bool> fileExists(String file) async => true;

  @override
  Future<DateTime?> getLastModificationTime(String file) async => null;
}
