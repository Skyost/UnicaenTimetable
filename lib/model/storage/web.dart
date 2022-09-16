import 'dart:html' as html;

import 'package:unicaen_timetable/model/storage/storage_interface.dart';

class Storage with StorageInterface {
  html.Storage get localStorage => html.window.localStorage;

  @override
  Future<String> buildPathPrefix() async => '';

  @override
  Future<String> readFile(String file) async => localStorage[file]!;

  @override
  Future<void> saveFile(String file, String content) async {
    localStorage.update(file, (value) => content, ifAbsent: () => content);
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    localStorage.update('${file}_last_mod', (value) => timestamp, ifAbsent: () => timestamp);
  }

  @override
  Future<void> deleteFile(String file) async => localStorage.remove(file);

  @override
  Future<bool> fileExists(String file) async => localStorage.containsKey(file);

  @override
  Future<DateTime?> getLastModificationTime(String file) async {
    String? timestamp = localStorage['${file}_last_mod'];
    return timestamp == null ? null : DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
  }
}