import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../domain/product_model.dart';
import '../../../todo/data/isar_service.dart';
import '../../../bookmark/domain/bookmark_model.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UTD Store - Wildan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Tombol ke halaman Bookmark (Favorites)
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Bookmark',
            onPressed: () => context.push('/bookmark'),
          ),
          // Tombol ke Native Integration
          IconButton(
            icon: const Icon(Icons.android),
            tooltip: 'Native',
            onPressed: () => context.push('/native'),
          ),
          // Tombol ke To-Do List
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'To-Do',
            onPressed: () => context.push('/todo'),
          ),
        ],
      ),
      // FAB untuk ke halaman Crypto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/crypto'),
        icon: const Icon(Icons.currency_bitcoin),
        label: const Text('Live Crypto'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ProductCubit>().fetchAllProducts(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (state is ProductLoaded) {
            final products = state.products;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
                    ),
                    title: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text('ID: ${item.id}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol bookmark setiap item — IsarService diambil dari state, BUKAN dibuat baru
                        BookmarkButton(product: item),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                    onTap: () => context.push('/detail/${item.id}'),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// Widget tombol Bookmark — pakai IsarService yang sudah diinit di main()
class BookmarkButton extends StatefulWidget {
  final Product product;
  const BookmarkButton({super.key, required this.product});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  // IsarService aman dibuat di sini karena static _db sudah diinit sebelum runApp
  final _isarService = IsarService();
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await _isarService.isBookmarked(widget.product.id);
    if (mounted) setState(() => _isBookmarked = status);
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
          // 🔥 UTS Poin 3: Timestamp disimpan di layer data, bukan UI
          final bookmark = BookmarkModel()
            ..productId = widget.product.id
            ..name = widget.product.name
            ..image = widget.product.image
            ..savedAt = DateTime.now();
          await _isarService.saveBookmark(bookmark);
        }
        _checkStatus();
      },
    );
  }
}
