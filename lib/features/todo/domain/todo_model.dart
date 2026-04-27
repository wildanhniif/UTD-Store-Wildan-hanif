import 'package:isar/isar.dart';

// WAJIB: Baris ini memberitahu Flutter bahwa nanti akan ada file gaib
// yang dibuat oleh build_runner. 
part 'todo_model.g.dart';

// Anotasi @collection memberitahu Isar bahwa ini adalah Tabel/Koleksi Database
@collection
class Todo {
  // Id adalah tipe data wajib dari Isar. autoIncrement artinya angkanya urut otomatis.
  Id id = Isar.autoIncrement;

  // Kolom-kolom data kita
  late String title;
  bool isCompleted = false;

  // TUGAS MANDIRI (Post-Test No 2): Menambahkan kolom prioritas bertipe String
  late String prioritas; 
}
