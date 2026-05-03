import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/todo_model.dart';
import '../../bookmark/domain/bookmark_model.dart';

// Singleton global — satu instance Isar untuk seluruh aplikasi
Isar? _isarInstance;

class IsarService {
  // Gunakan Completer agar openDB hanya dipanggil sekali meski banyak caller
  static Future<Isar>? _dbFuture;

  Future<Isar> get db async {
    _dbFuture ??= _openDB();
    return _dbFuture!;
  }

  // Membuka koneksi database secara async (tidak memblokir main thread)
  static Future<Isar> _openDB() async {
    if (_isarInstance != null && _isarInstance!.isOpen) return _isarInstance!;

    final dir = await getApplicationDocumentsDirectory();
    _isarInstance = await Isar.open(
      [TodoSchema, BookmarkModelSchema],
      directory: dir.path,
    );
    return _isarInstance!;
  }

  // ===================== TODO METHODS =====================

  Future<void> saveTodo(Todo newTodo) async {
    final isar = await db;
    await isar.writeTxn(() async => isar.todos.put(newTodo));
  }

  Future<void> updateTodoStatus(Id id, bool isCompleted) async {
    final isar = await db;
    final todo = await isar.todos.get(id);
    if (todo != null) {
      todo.isCompleted = isCompleted;
      await isar.writeTxn(() async => isar.todos.put(todo));
    }
  }

  Future<void> deleteTodo(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async => isar.todos.delete(id));
  }

  Stream<List<Todo>> listenToTodos() async* {
    final isar = await db;
    yield* isar.todos.where().watch(fireImmediately: true);
  }

  // ===================== BOOKMARK METHODS =====================

  Future<void> saveBookmark(BookmarkModel bookmark) async {
    final isar = await db;
    await isar.writeTxn(() async => isar.bookmarkModels.put(bookmark));
  }

  Future<void> removeBookmark(String productId) async {
    final isar = await db;
    final items = await isar.bookmarkModels
        .filter()
        .productIdEqualTo(productId)
        .findAll();
    final ids = items.map((e) => e.id).toList();
    await isar.writeTxn(() async => isar.bookmarkModels.deleteAll(ids));
  }

  Future<bool> isBookmarked(String productId) async {
    final isar = await db;
    final item = await isar.bookmarkModels
        .filter()
        .productIdEqualTo(productId)
        .findFirst();
    return item != null;
  }

  Stream<List<BookmarkModel>> listenToBookmarks() async* {
    final isar = await db;
    yield* isar.bookmarkModels
        .where()
        .sortBySavedAtDesc()
        .watch(fireImmediately: true);
  }
}
