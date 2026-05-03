import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/todo_model.dart';
import '../../bookmark/domain/bookmark_model.dart';

class IsarService {
  static Isar? _db;

  /// Dipanggil sekali dari main() sebelum runApp().
  /// Memakai nama DB 'utd_store' agar tidak konflik dengan DB lama ('default').
  static Future<void> init() async {
    if (_db != null && _db!.isOpen) return;

    final dir = await getApplicationDocumentsDirectory();

    // Coba buka dengan nama baru untuk menghindari konflik skema
    _db = await Isar.open(
      [TodoSchema, BookmarkModelSchema],
      directory: dir.path,
      name: 'utd_store', // 🔑 Nama baru → tidak konflik dengan DB lama
    );
  }

  /// Getter aman — hanya dipanggil setelah init() sukses
  Isar get _isar {
    assert(_db != null && _db!.isOpen,
        'Panggil IsarService.init() di main() terlebih dahulu!');
    return _db!;
  }

  // ===================== TODO METHODS =====================

  Future<void> saveTodo(Todo newTodo) async {
    await _isar.writeTxn(() async => _isar.todos.put(newTodo));
  }

  Future<void> updateTodoStatus(Id id, bool isCompleted) async {
    final todo = await _isar.todos.get(id);
    if (todo != null) {
      todo.isCompleted = isCompleted;
      await _isar.writeTxn(() async => _isar.todos.put(todo));
    }
  }

  Future<void> deleteTodo(Id id) async {
    await _isar.writeTxn(() async => _isar.todos.delete(id));
  }

  Stream<List<Todo>> listenToTodos() {
    return _isar.todos.where().watch(fireImmediately: true);
  }

  // ===================== BOOKMARK METHODS =====================

  Future<void> saveBookmark(BookmarkModel bookmark) async {
    await _isar.writeTxn(() async => _isar.bookmarkModels.put(bookmark));
  }

  Future<void> removeBookmark(String productId) async {
    final items = await _isar.bookmarkModels
        .filter()
        .productIdEqualTo(productId)
        .findAll();
    final ids = items.map((e) => e.id).toList();
    await _isar.writeTxn(() async => _isar.bookmarkModels.deleteAll(ids));
  }

  Future<bool> isBookmarked(String productId) async {
    final item = await _isar.bookmarkModels
        .filter()
        .productIdEqualTo(productId)
        .findFirst();
    return item != null;
  }

  // 🔥 UTS Poin 3: Reactive Stream tanpa setState — pakai watch() dari Isar
  Stream<List<BookmarkModel>> listenToBookmarks() {
    return _isar.bookmarkModels
        .where()
        .sortBySavedAtDesc()
        .watch(fireImmediately: true);
  }
}
