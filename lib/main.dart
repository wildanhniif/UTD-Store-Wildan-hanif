import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection.dart';

void main() {
  // SANGAT PENTING: Inisialisasi binding Flutter sebelum plugin native berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // SANGAT PENTING: Panggil Pelayan (GetIt) sebelum aplikasi berjalan!
  // Jika ini lupa dipanggil, aplikasi akan error layar merah.
  setupLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ubah dari MaterialApp biasa menjadi MaterialApp.router
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'UTD Advanced App',
      theme: AppTheme.lightTheme,
      // Masukkan konfigurasi rute yang sudah kita buat di Step 6
      routerConfig: AppRouter.router,
    );
  }
}
