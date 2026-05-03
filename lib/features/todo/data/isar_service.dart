import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/todo_model.dart';
import '../../bookmark/domain/bookmark_model.dart';

class IsarService {
  static Isar? _db;
  static bool _initFailed = false;

  /// Dipanggil dari main() sebelum runApp
  static Future<void> init() async {
    if (_db != null && _db!.isOpen) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _db = await Isar.open(
        [TodoSchema, BookmarkModelSchema],
        directory: dir.path,
        name: 'utd_store',
      );
      _initFailed = false;
    } catch (e) {
      _initFailed = true;
      // ignore: avoid_print
      print('[IsarService] Init gagal: $e');
    }
  }

  /// Cek apakah database tersedia
  bool get isAvailable => _db != null && _db!.isOpen;

  Isar? get _isar => (isAvailable) ? _db : null;

  // ===================== TODO =====================

  Future<void> saveTodo(Todo newTodo) async {
    if (_isar == null) return;
    await _isar!.writeTxn(() async => _isar!.todos.put(newTodo));
  }

  Future<void> updateTodoStatus(Id id, bool isCompleted) async {
    if (_isar == null) return;
    final todo = await _isar!.todos.get(id);
    if (todo != null) {
      todo.isCompleted = isCompleted;
      await _isar!.writeTxn(() async => _isar!.todos.put(todo));
    }
  }

  Future<void> deleteTodo(Id id) async {
    if (_isar == null) return;
    await _isar!.writeTxn(() async => _isar!.todos.delete(id));
  }

  Stream<List<Todo>> listenToTodos() {
    if (_isar == null) return const Stream.empty();
    return _isar!.todos.where().watch(fireImmediately: true);
  }

  // ===================== BOOKMARK =====================

  Future<void> saveBookmark(BookmarkModel bookmark) async {
    if (_isar == null) return;
    await _isar!.writeTxn(() async => _isar!.bookmarkModels.put(bookmark));
  }

  Future<void> removeBookmark(String productId) async {
    if (_isar == null) return;
    final items = await _isar!.bookmarkModels
        .filter()
        .productIdEqualTo(productId)
        .findAll();
    final ids = items.map((e) => e.id).toList();
    await _isar!.writeTxn(() async => _isar!.bookmarkModels.deleteAll(ids));
  }

  Future<bool> isBookmarked(String productId) async {
    if (_isar == null) return false;
    final item = await _isar!.bookmarkModels
        .filter()
        .productIdEqualTo(productId)
        .findFirst();
    return item != null;
  }

  /// 🔥 UTS Poin 3: Reactive Stream menggunakan watch() dari Isar — tanpa setState
  Stream<List<BookmarkModel>> listenToBookmarks() {
    if (_isar == null) return const Stream.empty();
    return _isar!.bookmarkModels
        .where()
        .sortBySavedAtDesc()
        .watch(fireImmediately: true);
  }
}
