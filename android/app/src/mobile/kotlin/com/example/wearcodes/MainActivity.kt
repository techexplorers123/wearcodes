package com.example.wearcodes

import android.os.Bundle
import androidx.annotation.NonNull
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity: FlutterActivity() {
    private val CHANNEL = "wear_sync"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result ->
                when (call.method) {
                    "sendCodes" -> {
                        @Suppress("UNCHECKED_CAST")
                        val map = call.arguments as Map<String, Any?>
                        val codes = (map["codes"] as List<*>).map { it as String }
                        sendCodesToWatch(codes)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun sendCodesToWatch(codesJsonStrings: List<String>) {
        val request = PutDataMapRequest.create("/codes").apply {
            // We’ll store as an ArrayList<String> of JSON objects: [{"name":"..","code":".."}, ...]
            dataMap.putStringArrayList("codes", ArrayList(codesJsonStrings))
            // Change this to force a sync even if content is same (optional):
            dataMap.putLong("timestamp", System.currentTimeMillis())
        }.asPutDataRequest()

        Wearable.getDataClient(this).putDataItem(request)
    }
}
