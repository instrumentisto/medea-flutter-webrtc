package com.instrumentisto.medea_flutter_webrtc

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

private val TAG = ForegroundCallService::class.java.simpleName

class ForegroundCallService : Service() {

  companion object {
    fun start(context: Context) {
      Log.v(TAG, "ForegroundCallService::start")

      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
        // Foreground services not required before SDK 28
        return
      }

      val intent = Intent(context, ForegroundCallService::class.java)
      intent.putExtra("inputExtra", "Foreground Service Example in Android")

      // TODO: block if no permission?
      ContextCompat.startForegroundService(context, intent)
    }

    fun stop(context: Context) {
      Log.v(TAG, "ForegroundCallService::stop")

      val serviceIntent = Intent(context, ForegroundCallService::class.java)
      context.stopService(serviceIntent)
    }
  }

  override fun onCreate() {
    Log.d(TAG, "onCreate")
    super.onCreate()
  }

  override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
    Log.d(TAG, "Started")
    createNotificationChannel()

    val notification: Notification =
        Notification.Builder(this, "ForegroundServiceChannel")
            .setContentTitle("AZAZAZAZAZAZAZAZAZAZAZAZ")
            .setContentText(
                "AZAZAZAZAZAZAZAZAZAZAZAZAZ") //            .setContentIntent(pendingIntent)
            .build()

    var serviceType = 0
    if (this.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
        PackageManager.PERMISSION_GRANTED) {
      serviceType = serviceType or ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
    }
    if (this.checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
      serviceType = serviceType or ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
    }

    ServiceCompat.startForeground(this, 1863424652, notification, serviceType)

    return START_NOT_STICKY
  }

  override fun onDestroy() {
    Log.d(TAG, "Destroyed")
    super.onDestroy()
    ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
  }

  override fun onBind(intent: Intent?): IBinder? {
    return null
  }

  override fun onTaskRemoved(rootIntent: Intent?) {
    Log.e(TAG, "onTaskRemoved")
  }

  private fun createNotificationChannel() {
    Log.e(TAG, "createNotificationChannel")
    if (Build.VERSION.SDK_INT >= 26) {
      val serviceChannel =
          NotificationChannel(
              "ForegroundServiceChannel",
              "Foreground Service Channel",
              NotificationManager.IMPORTANCE_DEFAULT)

      val manager: NotificationManager =
          getSystemService<NotificationManager>(NotificationManager::class.java)
      manager.createNotificationChannel(serviceChannel)
    }
  }
}
