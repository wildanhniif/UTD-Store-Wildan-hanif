// Ini adalah cetakan (Blueprint) untuk objek Produk kita.
class Product {
  // ID dari FakeStoreAPI berupa angka (int), nama produk disebut 'title'
  final String id;
  final String name;
  final String image; // Kita tambah gambar biar keren

  Product({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Platzi API menggunakan array "images" bukan string tunggal "image"
    String imageUrl = '';
    if (json['image'] != null) {
      imageUrl = json['image'].toString();
    } else if (json['images'] != null && json['images'] is List && json['images'].isNotEmpty) {
      // Membersihkan string gambar platzi API bila tidak format sempurna
      String rawUrl = json['images'][0].toString();
      imageUrl = rawUrl.replaceAll('\"', '').replaceAll('[', '').replaceAll(']', '');
    }

    return Product(
      id: json['id'].toString(),
      name: json['title'] ?? 'Tanpa Nama',
      image: imageUrl,
    );
  }
}

