import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.32.1:3000/api', // Pon la IP de tu PC si pruebas en celular/emulador
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Antes de cada lol petición, buscamos el token guardado
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'jwt_token');
          
          // Si hay token, lo inyectamos en la cabecera (Header)
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
}