import 'package:dio/dio.dart';
import '../domain/product_model.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/student_config.dart';

class ProductRepository {
  final ApiClient _apiClient = locator<ApiClient>();

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiClient.dio.get('/products');
      final List<dynamic> jsonList = response.data;

      // 🔥 Logika Personal Anti-AI UTS: Manipulasi nama produk di layer Repository
      // NIM 20123074 → digit terakhir = 4 (GENAP) → label [Promo Ongkir]
      return jsonList.map((json) {
        final Product p = Product.fromJson(json);
        final bool isEven = StudentConfig.isNimEven();
        final String label = isEven ? '[Promo Ongkir]' : '[Diskon 10%]';
        final String modifiedName = '${p.name} $label';
        return Product(id: p.id, name: modifiedName, image: p.image);
      }).toList();

    } on DioException catch (e) {
      throw Exception('Gagal memuat jaringan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem: $e');
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await _apiClient.dio.get('/products/$id');
      return Product.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
