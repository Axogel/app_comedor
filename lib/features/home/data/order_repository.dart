import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart'; // Importa el archivo del paso 2

class OrderRepository {
  final Dio _dio = ApiClient.dio;

  // Ruta: POST /order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/order', data: orderData);
      return response.data; // Retorna la respuesta de tu API
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Ruta: PATCH /order/:orderId/call
  Future<void> callOrder(String orderId) async {
    try {
      await _dio.patch('/order/$orderId/call');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Ruta: PATCH /order/:orderId/attend
  Future<void> attendOrder(String orderId) async {
    try {
      await _dio.patch('/order/$orderId/attend');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Método centralizado para manejar errores de la API
  String _handleError(DioException e) {
    if (e.response != null) {
      // Tu API devolvió un error (ej. 400 o 500)
      return e.response?.data['message'] ?? 'Error desconocido del servidor';
    } else {
      // Error de red (sin internet o servidor apagado)
      return 'No se pudo conectar al servidor. Revisa tu internet.';
    }
  }
}