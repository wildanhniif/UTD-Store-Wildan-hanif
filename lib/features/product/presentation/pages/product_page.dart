import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../todo/data/isar_service.dart';
import '../../bookmark/domain/bookmark_model.dart';
import '../domain/product_model.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog BLoC UTD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            color: Colors.pink,
            onPressed: () {
              context.push('/bookmark');
            },
          ),
          IconButton(
            icon: const Icon(Icons.android),
            onPressed: () {
              context.push('/native'); // Navigasi ke halaman Native Kotlin
            },
          ),
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              context.push('/todo'); // Navigasi ke halaman Catatan Reaktif!
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/crypto');
        },
        icon: const Icon(Icons.show_chart),
        label: const Text('Live Crypto'),
        backgroundColor: Colors.orange,
      ),

      // KEAJAIBAN BLOC BUILDER DIMULAI DI SINI
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          // 1. JIKA STATE = LOADING (Tampilkan indikator putar)
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. JIKA STATE = ERROR (Tampilkan pesan error)
          else if (state is ProductError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          // 3. JIKA STATE = SUKSES (Tampilkan ListView)
          else if (state is ProductLoaded) {
            final products = state.products; // Keluarkan data dari kotaknya!

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    // Kita gunakan Image.network untuk me-load gambar URL
                    leading: Image.network(
                      item.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                    title: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Agar judul panjang dipotong
                    ),
                    subtitle: Text('ID: ${item.id}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BookmarkButton(product: item),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      context.push('/detail/${item.id}');
                    },
                  ),
                );
              },
            );
          }

          // Fallback (jika state tidak dikenali)
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// Widget tombol Favorite yang memiliki state mandiri (Terkoneksi dengan Isar)
class BookmarkButton extends StatefulWidget {
  final Product product;
  const BookmarkButton({super.key, required this.product});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  final IsarService _isarService = IsarService();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await _isarService.isBookmarked(widget.product.id);
    if (mounted) {
      setState(() => _isBookmarked = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isBookmarked ? Icons.favorite : Icons.favorite_border,
        color: _isBookmarked ? Colors.pink : Colors.grey,
      ),
      onPressed: () async {
        if (_isBookmarked) {
          await _isarService.removeBookmark(widget.product.id);
        } else {
          final bookmark = BookmarkModel()
            ..productId = widget.product.id
            ..name = widget.product.name
            ..image = widget.product.image
            ..savedAt = DateTime.now(); // 🔥 UTS Logic: Menyisipkan Timestamp saat ditekan!
          await _isarService.saveBookmark(bookmark);
        }
        _checkStatus();
      },
    );
  }
}
