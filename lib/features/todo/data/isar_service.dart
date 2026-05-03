import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/todo_model.dart';
import '../../bookmark/domain/bookmark_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  // 1. Membuka koneksi ke Database
  Future<Isar> openDB() async {
    // Jika sudah ada instance yang terbuka (dengan skema yang sama), pakai itu
    if (Isar.instanceNames.isNotEmpty) {
      final existing = Isar.getInstance();
      if (existing != null) return existing;
    }
    
    final dir = await getApplicationDocumentsDirectory();
    try {
      return await Isar.open(
        [TodoSchema, BookmarkModelSchema],
        directory: dir.path,
      );
    } catch (e) {
      // Jika skema konflik (database lama), hapus dan buka ulang
      await Isar.open(
        [TodoSchema, BookmarkModelSchema],
        directory: dir.path,
        name: 'utd_db',
      );
      return Isar.getInstance('utd_db')!;
    }
  }


  // 2. CREATE: Menyimpan data baru (TODO)
  Future<void> saveTodo(Todo newTodo) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.todos.putSync(newTodo));
  }

  // 3. UPDATE: Mengubah status selesai/belum (TODO)
  Future<void> updateTodoStatus(Id id, bool isCompleted) async {
    final isar = await db;
    final todo = await isar.todos.get(id); 
    if (todo != null) {
      todo.isCompleted = isCompleted;
      isar.writeTxnSync(() => isar.todos.putSync(todo)); 
    }
  }

  // 4. DELETE: Menghapus data (TODO)
  Future<void> deleteTodo(Id id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.todos.deleteSync(id));
  }

  // 5. READ & REACTIVE: (TODO)
  Stream<List<Todo>> listenToTodos() async* {
    final isar = await db;
    yield* isar.todos.where().watch(fireImmediately: true);
  }

  // ===================== UTS BOOKMARK METHODS =====================

  // 6. BOOKMARK: Simpan produk
  Future<void> saveBookmark(BookmarkModel bookmark) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.bookmarkModels.putSync(bookmark));
  }

  // 7. BOOKMARK: Hapus berdasarkan productId
  Future<void> removeBookmark(String productId) async {
    final isar = await db;
    isar.writeTxnSync(() {
      isar.bookmarkModels.filter().productIdEqualTo(productId).deleteAllSync();
    });
  }

  // 8. BOOKMARK: Cek status
  Future<bool> isBookmarked(String productId) async {
    final isar = await db;
    final item = await isar.bookmarkModels.filter().productIdEqualTo(productId).findFirst();
    return item != null;
  }

  // 9. BOOKMARK: Reactive Stream (Akan urut dari yang paling baru disimpan)
  Stream<List<BookmarkModel>> listenToBookmarks() async* {
    final isar = await db;
    yield* isar.bookmarkModels.where().sortBySavedAtDesc().watch(fireImmediately: true);
  }
}
