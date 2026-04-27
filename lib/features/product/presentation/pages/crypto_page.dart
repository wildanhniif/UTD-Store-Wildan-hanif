import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert'; // Untuk jsonDecode
import 'package:flutter/foundation.dart'; // Untuk menggunakan fungsi compute()

// FUNGSI INI HARUS BERADA DI LUAR CLASS (TOP-LEVEL FUNCTION)
// Fungsi ini akan dieksekusi oleh Isolate. Parameter yang diterima hanya boleh 1.
int tugasMenghitungBerat(int jumlahLooping) {
  int hasil = 0;
  for (int i = 0; i < jumlahLooping; i++) {
    hasil += i;
  }
  return hasil;
}

class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  // 1. Siapkan variabel untuk menampung koneksi telepon (WebSocket)
  late WebSocketChannel _channel;
  
  // Variabel untuk Post-Test (menyimpan harga sebelumnya)
  double? _previousPrice;
  Color _priceColor = Colors.green; // Warna hijau sebagai default

  @override
  void initState() {
    super.initState();
    // wss:// adalah singkatan dari WebSocket Secure.
    // Karena stream.binance.com diblokir, kita gunakan domain .vision resmi dari Binance.
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://data-stream.binance.vision/ws/btcusdt@trade'),
    );
  }

  @override
  void dispose() {
    // 3. WAJIB! Tutup telepon saat halaman ditinggalkan agar memori tidak bocor
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Harga Bitcoin'),
        backgroundColor: Colors.orange.shade800, // Warna khas Bitcoin
      ),
      // 4. StreamBuilder adalah Widget sakti yang otomatis rebuild UI tiap kali
      // ada data baru masuk dari telepon (WebSocket).
      body: StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          // Jika masih loading koneksi atau stream kosong...
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyambungkan ke pasar kripto...'),
                ],
              ),
            );
          }
          // Jika terjadi error (misal internet mati)
          if (snapshot.hasError) {
            return const Center(child: Text('Koneksi Terputus!'));
          }

          // 5. Kita ambil datanya! Binance mengirim data berbentuk String JSON.
          final String dataString = snapshot.data.toString();
          
          double currentPrice = 0.0;
          String currentPriceString = "0.0";
          
          try {
            final Map<String, dynamic> dataJson = jsonDecode(dataString);
            
            // Cek apakah data json mengandung kunci 'p' (Price/Harga)
            if (dataJson.containsKey('p')) {
              // Kita paksa konversi ke double dulu
              currentPrice = double.tryParse(dataJson['p'].toString()) ?? 0.0;
              
              // Format ke 2 angka di belakang koma dan gunakan separator ribuan agar rapi
              currentPriceString = currentPrice.toStringAsFixed(2).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                (Match m) => '${m[1]},'
              );
            } else {
              // Jika ini adalah pesan handshake (bukan trade), kita pertahankan harga sebelumnya
              if (_previousPrice != null) {
                currentPrice = _previousPrice!;
                currentPriceString = currentPrice.toString();
              } else {
                // Jika belum pernah ada harga (awal mula) kembalikan UI loading
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menunggu data transaksi pertama...'),
                    ],
                  ),
                );
              }
            }
          } catch (e) {
            // Jika parsing error, pertahankan harga sebelumnya
            if (_previousPrice != null) {
              currentPrice = _previousPrice!;
              currentPriceString = currentPrice.toString();
            }
          }
          
          // LOGIKA POST-TEST: Bandingkan harga untuk pewarnaan
          if (_previousPrice != null) {
            if (currentPrice > _previousPrice!) {
              _priceColor = Colors.green; // Harga Naik (Hijau)
            } else if (currentPrice < _previousPrice!) {
              _priceColor = Colors.red; // Harga Turun (Merah)
            }
            // Jika harga sama, warna tetap memakai warna sebelumnya
          }
          
          // Update harga lama dengan harga saat ini (setelah pengecekan selesai)
          // Menggunakan Future.microtask agar tidak mengubah state saat proses build berlangsung (build phase)
          Future.microtask(() {
            _previousPrice = currentPrice;
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.currency_bitcoin, size: 100, color: Colors.orange),
                const SizedBox(height: 20),
                const Text('Harga BTC/USDT Saat Ini:', style: TextStyle(fontSize: 18)),
                Text(
                  '\$ $currentPriceString',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _priceColor, // Warna berubah sesuai tugas post-test
                  ),
                ),
                const SizedBox(height: 40),
                // Indikator ini harusnya berputar lancar 60 FPS
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                
                // TOMBOL UNTUK SIMULASI FREEZE MAIN THREAD
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // FUNGSI BERAT DI MAIN THREAD (KASIR)
                    if (kDebugMode) {
                      print("Mulai menghitung...");
                    }
                    int hasil = 0;
                    // Looping 4 Milyar kali! (Tergantung spek laptop/HP, ini butuh 2-5 detik)
                    for (int i = 0; i < 4000000000; i++) {
                      hasil += i;
                    }
                    if (kDebugMode) {
                      print("Selesai! Hasilnya: $hasil");
                    }
                  },
                  child: const Text('Siksa Main Thread (Layar akan Macet!)', style: TextStyle(color: Colors.white)),
                ),
                
                const SizedBox(height: 10),
                
                // TOMBOL UNTUK MENGGUNAKAN ISOLATE
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    if (kDebugMode) {
                      print("Mulai menghitung di Isolate...");
                    }
                    // MENGGUNAKAN PEKERJA GUDANG!
                    // compute(NamaFungsinya, Parameternya)
                    int hasil = await compute(tugasMenghitungBerat, 4000000000);
                    if (kDebugMode) {
                      print("Selesai dari Isolate! Hasilnya: $hasil");
                    }
                  },
                  child: const Text('Gunakan Isolate (Layar Tetap Lancar)', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
