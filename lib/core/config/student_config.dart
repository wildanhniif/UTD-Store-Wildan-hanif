class StudentConfig {
  static const String studentName = "Wildan Hanif";
  static const String studentNim = "20123074";

  // Helpers untuk mengambil Digit Terakhir
  static int getLastDigit() {
    if (studentNim.isEmpty) return 5;
    int digit = int.tryParse(studentNim[studentNim.length - 1]) ?? 5;
    return digit == 0 ? 5 : digit;
  }

  // Cek apakah NIM Genap (Untuk logika promo produk)
  static bool isNimEven() {
    return getLastDigit() % 2 == 0;
  }

  // Mengambil 2 Digit terakhir (Untuk loop Isolate)
  static int getLastTwoDigits() {
    if (studentNim.length < 2) return 10;
    return int.tryParse(studentNim.substring(studentNim.length - 2)) ?? 10;
  }
}
