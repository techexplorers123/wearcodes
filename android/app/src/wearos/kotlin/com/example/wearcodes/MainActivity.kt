package com.example.wearcodes

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import android.view.MotionEvent
import com.samsung.wearable_rotary.WearableRotaryPlugin
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
class MainActivity : FlutterActivity(){
    private var updatesChannel: EventChannel? = null
    private var updatesSink: EventChannel.EventSink? = null
    private val ACTION_CODES_UPDATED = "com.example.wearcodes.CODES_UPDATED"

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            updatesSink?.success(null) // payload not needed; Dart reloads prefs
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        updatesChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "wear_sync/updates"
        )

        updatesChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                updatesSink = events
                registerReceiver(receiver, IntentFilter(ACTION_CODES_UPDATED))
            }

            override fun onCancel(args: Any?) {
                updatesSink = null
                unregisterReceiver(receiver)
            }
        })
    }
    override fun onGenericMotionEvent(event: MotionEvent?): Boolean {
        return when {
            WearableRotaryPlugin.onGenericMotionEvent(event) -> true
            else -> super.onGenericMotionEvent(event)
        }
    }
}
