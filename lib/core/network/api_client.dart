import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiClient {
  final Dio dio;
  final Logger logger = Logger();

  ApiClient() : dio = Dio() {
    // Menggunakan Platzi API (fakestoreapi.com sedang tidak stabil)
    dio.options.baseUrl = 'https://api.escuelajs.co/api/v1';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // Interceptor Logger — Wajib per kriteria UTS Poin 2
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.i('🌐 REQUEST → [${options.method}] ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i('✅ RESPONSE ← [${response.statusCode}] ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          logger.e('❌ ERROR [${e.response?.statusCode}] ${e.requestOptions.uri}');
          logger.e('PESAN: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}
