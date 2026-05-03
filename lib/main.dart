import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection.dart';
import 'features/todo/data/isar_service.dart';

void main() async {
  // WAJIB: Inisialisasi Flutter binding sebelum kode native/async berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Isar Database SEBELUM runApp — ini mencegah crash
  await IsarService.init();

  // Inisialisasi Dependency Injection (GetIt)
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
