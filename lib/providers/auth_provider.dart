import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../services/camera_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _storageService = SecureStorageService();
  final CameraService _cameraService = CameraService();

  bool _isAuthenticated = false;
  String? _userName;
  bool _requiresFacialAuth = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  bool get requiresFacialAuth => _requiresFacialAuth;

  // Verificar estado de sesión al iniciar la app
  Future<void> checkSession() async {
    final token = await _storageService.getToken();
    final user = await _storageService.getUser();

    if (token != null && user != null) {
      _isAuthenticated = true;
      _userName = user;
      notifyListeners();
    }
  }

  // Simulación de Login Tradicional
  Future<bool> login(String user, String password) async {
    // Para pruebas, asumiremos que si existe un usuario registrado o es el admin por defecto
    if ((user == "admin" && password == "123456") || (user.isNotEmpty && password.isNotEmpty)) {
      _isAuthenticated = true;
      _userName = user;
      _requiresFacialAuth = false;
      
      await _storageService.saveSession("secure_token_xyz_999", user);
      notifyListeners();
      return true;
    } else {
      _requiresFacialAuth = true;
      notifyListeners();
      return false;
    }
  }

  // Método de Registro con validación de cámara (Biometría)
  Future<bool> registerUser(String user, String password) async {
    // 1. Validar e invocar el permiso de la cámara para la captura facial de seguridad
    bool permissionGranted = await _cameraService.requestCameraPermission();
    if (!permissionGranted) {
      return false; // Si deniega la cámara, el registro de seguridad falla
    }

    // Inicializar y capturar la cámara de forma segura
    await _cameraService.initCamera();

    // 2. Guardar las credenciales cifradas localmente en el SecureStorage
    await _storageService.saveSession("secure_token_registered_${user.hashCode}", user);

    // 3. Actualizar el estado global de la sesión
    _isAuthenticated = true;
    _userName = user;
    _requiresFacialAuth = false;
    notifyListeners();

    return true;
  }

  // Cierre de sesión seguro y limpieza de recursos de hardware
  Future<void> logout() async {
    await _storageService.clearSession();
    _cameraService.disposeCamera(); // Libera la cámara para ahorrar batería y memoria
    _isAuthenticated = false;
    _userName = null;
    _requiresFacialAuth = false;
    notifyListeners();
  }
}