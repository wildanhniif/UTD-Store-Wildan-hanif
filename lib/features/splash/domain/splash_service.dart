import '../../../../core/config/student_config.dart';

class SplashService {
  // 🔥 Logika Personal Anti-AI: Menghitung Delay di level Domain/Service
  Future<void> initializeApp() async {
    int delaySeconds = StudentConfig.getLastDigit();
    await Future.delayed(Duration(seconds: delaySeconds));
  }
}
