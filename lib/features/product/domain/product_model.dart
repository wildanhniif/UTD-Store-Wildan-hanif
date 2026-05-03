// Ini adalah cetakan (Blueprint) untuk objek Produk kita.
class Product {
  final String id;
  final String name;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Platzi API menggunakan array "images", FakeStore pakai string "image"
    String imageUrl = '';
    if (json['image'] != null) {
      imageUrl = json['image'].toString();
    } else if (json['images'] != null && json['images'] is List && json['images'].isNotEmpty) {
      String rawUrl = json['images'][0].toString();
      imageUrl = rawUrl.replaceAll('"', '').replaceAll('[', '').replaceAll(']', '');
    }

    return Product(
      id: json['id'].toString(),
      name: json['title'] ?? 'Tanpa Nama',
      image: imageUrl,
    );
  }
}
