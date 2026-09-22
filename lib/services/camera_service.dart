import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  bool _isPermissionGranted = false;

  // Solicitar permiso de cámara de forma explícita solo cuando se requiera
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status.isGranted;
    return _isPermissionGranted;
  }

  // Inicializar la cámara para capturar el rostro (Fallback de seguridad)
  Future<CameraController?> initCamera() async {
    if (!_isPermissionGranted) {
      bool granted = await requestCameraPermission();
      if (!granted) return null;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      // Seleccionamos la cámara frontal para autenticación facial
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      return _controller;
    } catch (e) {
      return null;
    }
  }

  // Optimización: Destruir recursos de cámara para liberar memoria y batería
  void disposeCamera() {
    _controller?.dispose();
    _controller = null;
  }
}