import 'package:dio/dio.dart';
import '../domain/product_model.dart';
import '../../../core/di/injection.dart'; // Import locator
import '../../../core/network/api_client.dart'; // Import ApiClient
import '../../../core/config/student_config.dart'; // Import konfigurasi NIM

class ProductRepository {
  // Ambil ApiClient (Dio) dari Pelayan (get_it)
  final ApiClient _apiClient = locator<ApiClient>();

  // Fungsi kini menjadi Future (Asynchronous) karena butuh waktu internet
  Future<List<Product>> getAllProducts() async {
    try {
      // Menembak URL: https://fakestoreapi.com/products
      final response = await _apiClient.dio.get('/products');

      // Dio otomatis membaca response sebagai List (Array JSON)
      final List<dynamic> jsonList = response.data;

      // Mengubah List JSON menjadi List Objek Product
      return jsonList.map((json) {
        Product p = Product.fromJson(json);
        
        // 🔥 Logika Personal Anti-AI UTS: Manipulasi nama produk di layer Data/Repository
        bool isEven = StudentConfig.isNimEven();
        String modifiedName = isEven ? "\${p.name} [Promo Ongkir]" : "\${p.name} [Diskon 10%]";
        
        return Product(id: p.id, name: modifiedName, image: p.image);
      }).toList();

    } on DioException catch (e) {
      // Jika internet mati atau API down, lemparkan error ke atas (ke Cubit)
      throw Exception('Gagal memuat jaringan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem: $e');
    }
  }

  // Ambil 1 produk
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _apiClient.dio.get('/products/$id');
      return Product.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
