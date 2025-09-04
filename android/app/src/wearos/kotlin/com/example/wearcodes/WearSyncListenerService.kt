package com.example.wearcodes

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable

class WearSyncListenerService : Service(), MessageClient.OnMessageReceivedListener {

    override fun onCreate() {
        super.onCreate()
        // Register when service starts
        Wearable.getMessageClient(this).addListener(this)
        Log.d("WearSyncService", "Listener registered")
    }

    override fun onMessageReceived(event: MessageEvent) {
        if (event.path == "/sync_codes") {
            val data = String(event.data)
            Log.d("WearSyncService", "Received sync data: $data")

            // TODO: Store locally in SharedPreferences/DB
        }
    }

    override fun onDestroy() {
        // Cleanup
        Wearable.getMessageClient(this).removeListener(this)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
