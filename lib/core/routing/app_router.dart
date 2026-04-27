import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import ini
import '../../features/product/presentation/pages/product_page.dart';
import '../../features/product/presentation/pages/detail_page.dart';
import '../../features/product/presentation/cubit/product_cubit.dart'; // Import ini
import '../di/injection.dart'; // Import ini
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/product/presentation/pages/crypto_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../../features/native/presentation/pages/native_page.dart';

class AppRouter {
  // Mendefinisikan konfigurasi Router utama
  static final router = GoRouter(
    initialLocation: '/', // Saat aplikasi dibuka, mulai dari path '/'
    // Daftar semua jalan yang ada di aplikasi
    routes: [
      GoRoute(
        path: '/', // Path beranda
        builder: (context, state) {
          // BUNGKUS PRODUCT PAGE DENGAN BLOC PROVIDER
          return BlocProvider(
            // Kita minta Cubit dari get_it, dan langsung suruh dia jalan (fetchAllProducts)
            create: (context) => locator<ProductCubit>()..fetchAllProducts(),
            child: const ProductPage(),
          );
        },
      ),
      GoRoute(
        // Perhatikan :id. Ini disebut Path Parameter.
        // Artinya nilai setelah /detail/ bisa berubah-ubah (misal /detail/P01)
        path: '/detail/:id',
        builder: (context, state) {
          // Menangkap ID dari URL yang diketik
          final productId = state.pathParameters['id'] ?? '';
          // Buka halaman detail, dan lemparkan ID tersebut
          return DetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/crypto',
        builder: (context, state) => const CryptoPage(),
      ),
      GoRoute(
        path: '/todo',
        builder: (context, state) => const TodoPage(),
      ),
      GoRoute(
        path: '/native',
        builder: (context, state) => const NativePage(),
      ),
    ],
    // errorBuilder akan terpanggil jika User membuka path yang tidak terdaftar
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error 404')),
      body: const Center(child: Text('Halaman tidak ditemukan!')),
    ),
  );
}
