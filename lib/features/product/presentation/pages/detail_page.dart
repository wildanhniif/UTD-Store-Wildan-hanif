import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart'; // Import pelayan
import '../../domain/product_service.dart'; // Import service
import '../../domain/product_model.dart'; // Import model

class DetailPage extends StatelessWidget {
  final String productId;

  // Halaman ini menerima productId dari AppRouter sebelumnya
  const DetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // UI tidak perlu buat 'new ProductService()', cukup panggil locator!
    final service = locator<ProductService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<Product?>(
        future: service.fetchProductDetail(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final product = snapshot.data;
          
          // Jika produk tidak ditemukan (ID salah atau kembalian null)
          if (product == null) {
            return const Center(child: Text('Maaf, produk tidak ditemukan!'));
          }

          // Jika produk ditemukan, tampilkan UI-nya
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  product.image,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 150),
                ),
                const SizedBox(height: 20),
                Text(
                  'ID Produk: ${product.id}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  // CARA KEMBALI MENGGUNAKAN GO_ROUTER
                  onPressed: () => context.pop(),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
