import 'package:equatable/equatable.dart';
import '../../domain/product_model.dart';

// Kita gunakan Equatable agar memori aplikasi lebih hemat
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

// 1. Indikator Awal (Kosong/Loading)
class ProductLoading extends ProductState {}

// 2. Indikator Sukses (Membawa kotak berisi data List Produk)
class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products]; // Wajib didaftarkan di props
}

// 3. Indikator Error (Membawa kotak berisi pesan error)
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
