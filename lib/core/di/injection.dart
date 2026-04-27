import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart'; // Import ApiClient
import '../../features/product/data/product_repository.dart';
import '../../features/product/domain/product_service.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';

final locator = GetIt.instance;

void setupLocator() {
  // DAFTARKAN API CLIENT DI SINI (Sebagai Singleton / 1 instance seumur hidup aplikasi)
  locator.registerLazySingleton<ApiClient>(() => ApiClient());

  // Sisanya biarkan sama seperti minggu lalu
  locator.registerLazySingleton<ProductRepository>(() => ProductRepository());
  locator.registerFactory<ProductService>(() => ProductService(locator()));
  locator.registerFactory<ProductCubit>(() => ProductCubit(locator()));
}
