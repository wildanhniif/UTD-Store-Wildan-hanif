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
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/bookmark/presentation/pages/bookmark_page.dart';

class AppRouter {
  // Flag untuk memastikan Splash selalu tampil di awal (fresh launch)
  static bool _splashShown = false;
  static bool get splashShown => _splashShown;
  static set splashShown(bool v) => _splashShown = v;

  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Jika splash belum ditampilkan dan user bukan di /splash, paksa ke /splash
      if (!_splashShown && state.uri.path != '/splash') {
        return '/splash';
      }
      return null; // Tidak ada redirect
    },
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
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/bookmark',
        builder: (context, state) => const BookmarkPage(),
      ),
    ],
    // errorBuilder akan terpanggil jika User membuka path yang tidak terdaftar
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error 404')),
      body: const Center(child: Text('Halaman tidak ditemukan!')),
    ),
  );
}
