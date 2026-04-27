import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiClient {
  final Dio dio;
  final Logger logger = Logger(); // Alat cetak log keren

  ApiClient() : dio = Dio() {
    // 1. Konfigurasi Dasar (Global)
    // fakestoreapi.com sedang down/error, kita pakai Platzi API yang struktur datanya mirip
    dio.options.baseUrl = 'https://api.escuelajs.co/api/v1'; 
    dio.options.connectTimeout = const Duration(seconds: 10); // Maksimal tunggu 10 detik
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // 2. Menambahkan Interceptor (Satpam)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.i('🌐 MENGIRIM REQUEST: [${options.method}] ${options.uri}');
          // Di sinilah nanti Anda memasukkan Token jika API butuh login
          return handler.next(options); // Lanjutkan request
        },
        onResponse: (response, handler) {
          logger.i('✅ BERHASIL [${response.statusCode}]: ${response.requestOptions.uri}');
          return handler.next(response); // Lanjutkan response ke aplikasi
        },
        onError: (DioException e, handler) {
          logger.e('❌ ERROR [${e.response?.statusCode}]: ${e.requestOptions.uri}');
          logger.e('PESAN: ${e.message}');
          return handler.next(e); // Lanjutkan error agar ditangkap oleh aplikasi
        },
      ),
    );
  }
}
