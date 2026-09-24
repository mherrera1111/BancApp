import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _secureStorage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyActiveUser = 'active_user';
  static const _keyRegUser = 'reg_user';
  static const _keyRegPass = 'reg_pass';

  // Guardar el usuario registrado permanentemente
  Future<void> saveRegisteredUser(String username, String password) async {
    await _secureStorage.write(key: _keyRegUser, value: username);
    await _secureStorage.write(key: _keyRegPass, value: password);
  }

  // Guardar únicamente la sesión activa actual
  Future<void> saveActiveSession(String token, String username) async {
    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(key: _keyActiveUser, value: username);
  }

  Future<String?> getToken() async => await _secureStorage.read(key: _keyToken);
  Future<String?> getActiveUser() async => await _secureStorage.read(key: _keyActiveUser);
  Future<String?> getRegisteredUser() async => await _secureStorage.read(key: _keyRegUser);
  Future<String?> getRegisteredPass() async => await _secureStorage.read(key: _keyRegPass);

  // Cierre de sesión seguro: SOLO borra el token y la sesión activa, MANTIENE el registro del usuario
  Future<void> clearActiveSession() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyActiveUser);
  }
}