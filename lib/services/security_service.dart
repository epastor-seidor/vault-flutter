import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecurityService {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'hive_encryption_key';

  static Future<Uint8List> _getOrCreateKey() async {
    final containsKey = await _secureStorage.containsKey(key: _keyName);
    if (!containsKey) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(key: _keyName, value: base64UrlEncode(key));
    }
    final keyString = await _secureStorage.read(key: _keyName);
    return base64Url.decode(keyString!);
  }

  static Future<Box> openEncryptedBox(String name) async {
    final encryptionKey = await _getOrCreateKey();
    return await Hive.openBox(name, encryptionCipher: HiveAesCipher(encryptionKey));
  }
}
