import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativePage extends StatefulWidget {
  const NativePage({super.key});

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  // 1. MEMBUAT JEMBATAN (MethodChannel)
  static const platform = MethodChannel('utd.ac.id/native_jembatan');
  String _batteryLevel = 'Baterai belum dicek.';

  // 2. Fungsi Dart -> Kotlin: Ambil Baterai
  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Sisa Baterai Anda: $result %';
    } on PlatformException catch (e) {
      batteryLevel = "Gagal membaca baterai: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  // 3. Fungsi Dart -> Kotlin: Tampilkan Toast (POST-TEST 1)
  Future<void> _showNativeToast() async {
    try {
      await platform.invokeMethod('showToast', {
        // Jawaban Post-Test 1: Mengirimkan Nama & NIM
        "pesan": "WILDAN HANIF - 12345678"
      });
    } on PlatformException catch (e) {
      debugPrint("Gagal Toast: \${e.message}");
    }
  }

  // 4. Fungsi Dart -> Kotlin: Tampilkan Native Dialog (POST-TEST 2)
  Future<void> _showNativeDialog() async {
    try {
      await platform.invokeMethod('showDialogNative', {
        "title": "Peringatan Sistem",
        "message": "Ini adalah dialog OS murni dari Android, bukan widget Flutter!"
      });
    } on PlatformException catch (e) {
      debugPrint("Gagal Dialog: \${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Integrasi Native Kotlin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade200, width: 2)
                ),
                child: Column(
                  children: [
                    const Icon(Icons.battery_charging_full, size: 48, color: Colors.teal),
                    const SizedBox(height: 12),
                    Text(
                      _batteryLevel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Tombol Baterai
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bolt),
                  label: const Text('Cek Baterai (Via Kotlin)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _getBatteryLevel,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tombol Toast (Post-Test 1)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Munculkan Native Toast'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _showNativeToast,
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Dialog (Post-Test 2)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Tampilkan Native Dialog'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _showNativeDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
