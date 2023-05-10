mixin StorageInterface {
  Future<String> buildPathPrefix();

  Future<String> readFile(String file);

  Future<void> saveFile(String file, String content);

  Future<void> deleteFile(String file);

  Future<bool> fileExists(String file);

  Future<DateTime?> getLastModificationTime(String file);
}
