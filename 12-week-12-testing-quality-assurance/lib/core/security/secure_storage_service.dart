import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageService {
  Future<String?> readApiKey();
  Future<void> saveApiKey(String key);
  Future<void> clearApiKey();
}

class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _keyName = 'gemini_api_key_v1';

  @override
  Future<String?> readApiKey() => _storage.read(key: _keyName);

  @override
  Future<void> saveApiKey(String key) =>
      _storage.write(key: _keyName, value: key.trim());

  @override
  Future<void> clearApiKey() => _storage.delete(key: _keyName);
}
