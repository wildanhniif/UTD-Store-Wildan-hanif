import 'package:isar/isar.dart';

part 'bookmark_model.g.dart';

@collection
class BookmarkModel {
  Id id = Isar.autoIncrement;
  
  late String productId;
  late String name;
  late String image;

  // 🔥 Logika Personal Anti-AI UTS: Wajib menyisipkan Timestamp
  late DateTime savedAt;
}
