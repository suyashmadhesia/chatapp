package com.example.Inbox

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.app.NotificationManager

class MainActivity: FlutterActivity() {

    override fun onResume() {
        super.onResume()
        closeAllNotification();
    }

    private fun closeAllNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }

}
