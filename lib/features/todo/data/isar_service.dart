import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/todo_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  // 1. Membuka koneksi ke Database
  Future<Isar> openDB() async {
    // Jika sudah pernah dibuka, pakai yang sudah ada
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory(); // Cari folder HP
      return await Isar.open(
        [TodoSchema], // Masukkan skema yang dihasilkan Build Runner
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // 2. CREATE: Menyimpan data baru
  Future<void> saveTodo(Todo newTodo) async {
    final isar = await db;
    // Transaksi sinkron (writeTxnSync) untuk operasi tulis data
    // Perhatikan isar.todos (todos dihasilkan secara otomatis oleh Isar Generator)
    isar.writeTxnSync<int>(() => isar.todos.putSync(newTodo));
  }

  // 3. UPDATE: Mengubah status selesai/belum
  Future<void> updateTodoStatus(Id id, bool isCompleted) async {
    final isar = await db;
    final todo = await isar.todos.get(id); // Cari datanya dulu
    if (todo != null) {
      todo.isCompleted = isCompleted;
      isar.writeTxnSync(() => isar.todos.putSync(todo)); // Timpa datanya
    }
  }

  // 4. DELETE: Menghapus data
  Future<void> deleteTodo(Id id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.todos.deleteSync(id));
  }

  // 5. READ & REACTIVE (Paling Keren!):
  // Memancarkan Stream otomatis setiap kali ada data berubah di database
  Stream<List<Todo>> listenToTodos() async* {
    final isar = await db;
    // watch(fireImmediately: true) artinya pancarkan data saat ini juga,
    // lalu pantau terus perubahannya ke depan!
    yield* isar.todos.where().watch(fireImmediately: true);
  }
}
