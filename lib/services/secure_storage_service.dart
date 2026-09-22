import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Instancia con opciones seguras por defecto
  final _secureStorage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  // Guardar credenciales cifradas
  Future<void> saveSession(String token, String username) async {
    await _secureStorage.write(key: _keyToken, value: token);
    await _secureStorage.write(key: _keyUser, value: username);
  }

  // Leer token cifrado
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  // Leer usuario guardado
  Future<String?> getUser() async {
    return await _secureStorage.read(key: _keyUser);
  }

  // Destruir sesión (Cierre de sesión seguro)
  Future<void> clearSession() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyUser);
  }
}