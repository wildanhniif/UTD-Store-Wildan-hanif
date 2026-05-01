import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/student_config.dart';
import '../domain/splash_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashService _splashService = SplashService();

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  Future<void> _startDelay() async {
    // Tunggu sesuai digit terakhir NIM
    await _splashService.initializeApp();
    if (mounted) {
      context.go('/'); // Pindah ke Beranda menggunakan GoRouter (bukan Navigator.push)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "UTD Store",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            // 🔥 Logika Personal Anti-AI: Menampilkan Nama dan NIM
            Text(
              "${StudentConfig.studentName}\nNIM: ${StudentConfig.studentNim}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              "Loading ${StudentConfig.getLastDigit()} detik...",
              style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}
