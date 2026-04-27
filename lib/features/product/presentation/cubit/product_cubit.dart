import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_state.dart';
import '../../domain/product_service.dart';

class ProductCubit extends Cubit<ProductState> {
  // Cubit ini butuh Service untuk mengambil data (ingat konsep DI!)
  final ProductService _service;

  // Saat pertama kali diciptakan, set lampu ke 'ProductLoading'
  ProductCubit(this._service) : super(ProductLoading());

  // Fungsi yang nanti dipanggil dari UI
  Future<void> fetchAllProducts() async {
    // 1. Ubah state ke Loading
    emit(ProductLoading());

    try {
      // Hapus delay buatan, tambah await di sini
      final data = await _service.fetchProducts();

      // 4. Jika berhasil, pancarkan state Sukses beserta datanya!
      emit(ProductLoaded(data));
    } catch (e) {
      // 5. Jika gagal/error, pancarkan state Error
      emit(ProductError('Gagal memuat produk: $e'));
    }
  }
}
