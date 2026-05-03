import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection.dart';
import 'features/todo/data/isar_service.dart';

void main() async {
  // WAJIB: Pastikan binding Flutter siap sebelum kode async/native dijalankan
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Isar Database sebelum runApp (cegah crash di UI)
  try {
    await IsarService.init();
  } catch (e) {
    // Jika init gagal (misal emulator tidak kompatibel), app tetap berjalan
    debugPrint('[IsarService] Gagal init: $e');
  }

  // Setup Dependency Injection (GetIt)
  setupLocator();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'UTD Store - Wildan',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
