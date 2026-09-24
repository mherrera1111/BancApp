import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/camera_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final CameraService _cameraService = CameraService();
  
  bool _isRegistering = false; // Alterna entre vista de Login y Registro

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'BancApp - Registro Biométrico' : 'BancApp - Seguridad y Acceso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRegistering ? Icons.face_retouching_natural : Icons.security, 
              size: 80, 
              color: Colors.blue
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _userController, 
              decoration: const InputDecoration(labelText: 'Usuario', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController, 
              obscureText: true, 
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            
            // Botón Dinámico según el modo (Login o Registro)
            // Botón de Login Tradicional
            if (!_isRegistering) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () async {
                  // Validar campos vacíos antes de procesar
                  if (_userController.text.isEmpty || _passController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor ingrese usuario y contraseña.')),
                    );
                    return;
                  }

                  bool success = await authProvider.login(_userController.text, _passController.text);
                  
                  if (!mounted) return;

                  if (!success) {
                    // Credenciales incorrectas: Denegamos acceso y activamos seguridad por cámara
                    bool permissionGranted = await _cameraService.requestCameraPermission();
                    if (!mounted) return;

                    if (permissionGranted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Acceso Denegado: Credenciales incorrectas. Verificación por cámara requerida.')),
                      );
                    }
                  }
                  // Si 'success' es true, el AuthWrapper redirige automáticamente al HomeScreen de forma segura.
                },
                child: const Text('Ingresar con Contraseña'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegistering = true;
                    _userController.clear();
                    _passController.clear();
                  });
                },
                child: const Text('¿No estás registrado? Crear cuenta con Biometría'),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (_userController.text.isEmpty || _passController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor completa todos los campos')),
                    );
                    return;
                  }

                  // Ejecuta el registro seguro solicitando la cámara y guardando credenciales
                  bool registered = await authProvider.registerUser(_userController.text, _passController.text);
                  
                  if (!mounted) return;

                  if (registered) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Registro exitoso! Rostro autenticado y sesión iniciada.')),
                    );
                    // La redirección al HomeScreen ocurre automáticamente por el AuthWrapper al cambiar el estado
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: Se requiere permiso de cámara para el registro.')),
                    );
                  }
                },
                child: const Text('Registrar y Validar con Cámara'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegistering = false;
                    _userController.clear();
                    _passController.clear();
                  });
                },
                child: const Text('Volver al Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}