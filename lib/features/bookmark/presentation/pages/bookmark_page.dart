import 'package:flutter/material.dart';
import '../../todo/data/isar_service.dart';
import '../domain/bookmark_model.dart';
import 'package:intl/intl.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final IsarService _isarService = IsarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Tersimpan'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      // 🔥 Logika Personal UTS: Stream Reactive (Tanpa SetState)
      body: StreamBuilder<List<BookmarkModel>>(
        stream: _isarService.listenToBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookmarks = snapshot.data ?? [];
          if (bookmarks.isEmpty) {
            return const Center(child: Text("Belum ada produk favorit."));
          }

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final item = bookmarks[index];
              // 🔥 Logika Personal UTS: Menampilkan jam
              final timeString = DateFormat('HH:mm').format(item.savedAt);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    item.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                  title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    'Disimpan pada $timeString',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.pink),
                    onPressed: () {
                      _isarService.removeBookmark(item.productId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
