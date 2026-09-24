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

  // Verificar estado al iniciar la app
  Future<void> checkSession() async {
    final token = await _storageService.getToken();
    final user = await _storageService.getActiveUser();

    if (token != null && user != null) {
      _isAuthenticated = true;
      _userName = user;
      notifyListeners();
    }
  }

  // Validación de Login (Valida Admin o el Usuario Registrado)
  Future<bool> login(String user, String password) async {
    if (user.isEmpty || password.isEmpty) {
      _isAuthenticated = false;
      _requiresFacialAuth = false;
      notifyListeners();
      return false;
    }

    // Consultar el usuario y contraseña registrados en el almacenamiento seguro
    String? regUser = await _storageService.getRegisteredUser();
    String? regPass = await _storageService.getRegisteredPass();

    bool isValidAdmin = (user == "admin" && password == "123456");
    bool isValidRegisteredUser = (user == regUser && password == regPass);

    if (isValidAdmin || isValidRegisteredUser) {
      _isAuthenticated = true;
      _userName = user;
      _requiresFacialAuth = false;
      
      // Creamos la sesión activa para este usuario
      await _storageService.saveActiveSession("token_${user.hashCode}", user);
      notifyListeners();
      return true;
    } else {
      _isAuthenticated = false;
      _userName = null;
      _requiresFacialAuth = true;
      notifyListeners();
      return false;
    }
  }

  // Método de Registro 
  Future<bool> registerUser(String user, String password) async {
    if (user.isEmpty || password.isEmpty) return false;

    // Solicitar permiso explícito de cámara para la biometría
    bool permissionGranted = await _cameraService.requestCameraPermission();
    if (!permissionGranted) {
      return false; 
    }

    await _cameraService.initCamera();
    
    // 1. Guardar las credenciales permanentemente
    await _storageService.saveRegisteredUser(user, password);
    // 2. Iniciar la sesión activa inmediatamente
    await _storageService.saveActiveSession("token_${user.hashCode}", user);

    _isAuthenticated = true;
    _userName = user;
    _requiresFacialAuth = false;
    notifyListeners();

    return true;
  }

  // Cierre de sesión seguro que preserva la cuenta registrada
  Future<void> logout() async {
    await _storageService.clearActiveSession(); // Borra la sesión pero mantiene el registro
    _cameraService.disposeCamera(); // Libera hardware de la cámara
    _isAuthenticated = false;
    _userName = null;
    _requiresFacialAuth = false;
    notifyListeners();
  }
}