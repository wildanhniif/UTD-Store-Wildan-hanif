package com.example.utd_advanced_app

import android.app.AlertDialog
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // 1. Pastikan nama CHANNEL INI PERSIS SAMA dengan yang ada di file Dart!
    private val CHANNEL = "utd.ac.id/native_jembatan"

    // 2. Fungsi ini dijalankan pertama kali saat mesin Flutter dihidupkan
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 3. Kita dirikan pos penjagaan di ujung jembatan MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            
            // a. Jika Dart teriak minta "getBatteryLevel"
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel) // Berhasil! Lempar angkanya ke Dart
                } else {
                    result.error("UNAVAILABLE", "Baterai tidak terbaca.", null)
                }
            }
            
            // b. Jika Dart teriak minta "showToast" (POST TEST 1)
            else if (call.method == "showToast") {
                // Tangkap data yang dititipkan Dart
                val pesanDariDart = call.argument<String>("pesan")
                // Gunakan class bawaan OS Android (Toast)
                Toast.makeText(this, pesanDariDart, Toast.LENGTH_SHORT).show()
                result.success(true) // Lapor ke Dart bahwa sukses
            }
            
            // c. JAWABAN POST TEST 2: Menampilkan Dialog Native Android murni
            else if (call.method == "showDialogNative") {
                val title = call.argument<String>("title")
                val message = call.argument<String>("message")

                // Ini adalah Alert Dialog buatan Kotlin (bukan buatan Flutter)
                val builder = AlertDialog.Builder(this)
                builder.setTitle(title)
                builder.setMessage(message)
                builder.setPositiveButton("Siap Laksanakan!") { dialog, _ -> 
                    dialog.dismiss()
                }
                val dialog: AlertDialog = builder.create()
                dialog.show()

                result.success(true)
            }
            
            // d. Jika Dart minta fungsi yang belum kita buat
            else {
                result.notImplemented()
            }
        }
    }

    // 4. Fungsi asli Android untuk membaca sensor baterai mesin HP
    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel
    }
}
