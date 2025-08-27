package com.example.mobile

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Xiaomi MIUI için splash screen düzeltmesi
        super.onCreate(savedInstanceState)
        
        // MIUI cihazlarda splash screen görünürlüğünü artırmak için
        window.statusBarColor = resources.getColor(android.R.color.transparent, theme)
        window.navigationBarColor = resources.getColor(android.R.color.transparent, theme)
    }
}
