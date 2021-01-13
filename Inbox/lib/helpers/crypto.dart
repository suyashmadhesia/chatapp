import 'dart:convert';
import 'package:crypto/crypto.dart';

class Encrypt {
  static String encrypt(String data) {
    return md5.convert(utf8.encode(data)).toString();
  }

  static bool matchEncryption(String data, String encryptedData) {
    return encryptedData == Encrypt.encrypt(data);
  }
}
