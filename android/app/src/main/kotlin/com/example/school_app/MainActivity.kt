package com.vivekanand.mobileapp55566

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // InAppWebView will automatically handle file chooser
    }

    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<String>,
            grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    // Override to ensure activity isn't destroyed when minimized
    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        // State is automatically saved by Flutter
    }

    // Ensure proper handling when returning from external activities (like camera)
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
