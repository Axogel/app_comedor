import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart'; // Asegúrate de tener el archivo api_client.dart que creamos antes

class AuthRepository {
  // Instancia de Dio configurada con tu IP local
  final Dio _dio = ApiClient.dio; 
  // Herramienta para guardar el token de forma segura
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Ruta: POST /login ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      // Si el backend responde bien, extraemos el token.
      // (Asegúrate de que tu API de Node devuelva algo como { "token": "eyJhbG..." })
      final String token = response.data['token'];

      // Guardamos el token en la bóveda segura del teléfono
      await _storage.write(key: 'jwt_token', value: token);
      
      return true; // Login exitoso
      
    } on DioException catch (e) {
      // Si el correo o clave son incorrectos, mostramos el error
      throw _handleError(e);
    }
  }

  // --- Ruta: POST /register ---
  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _dio.post('/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      return true; // Registro exitoso
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Función extra: Cerrar Sesión ---
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token'); // Borramos el token del teléfono
  }

  // Manejador de errores
  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'Error al procesar la solicitud';
    }
    return 'No hay conexión con el servidor.';
  }
}