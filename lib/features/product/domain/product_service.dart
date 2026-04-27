import '../data/product_repository.dart';
import 'product_model.dart';

class ProductService {
  // Perhatikan: Service membutuhkan Repository untuk bekerja!
  final ProductRepository repository;

  // Constructor Service akan meminta Repository saat diciptakan
  ProductService(this.repository);

  // Fungsi yang akan dipanggil oleh UI (Halaman) nantinya
  Future<List<Product>> fetchProducts() async {
    // Service tinggal menyuruh Repository mengambil data
    return await repository.getAllProducts();
  }

  Future<Product?> fetchProductDetail(String id) async {
    return await repository.getProductById(id);
  }
}
