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
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import org.webrtc.ThreadUtils

private val TAG = ForegroundCallService::class.java.simpleName

private const val FG_CALL_NOTIFICATION_ID: Int = 874213596
private const val NOTIFICATION_CHAN_ID: String = "FOREGROUND_CALL_CHAN"
private const val NOTIFICATION_CHAN_NAME: String = "Ongoing call"

class ForegroundCallService : Service() {
  /** [ForegroundCallService] configuration received from Dart-side. */
  class Config {
    /**
     * Indicates whether [ForegroundCallService] is enabled, meaning that it will be started
     * whenever [ForegroundCallService.start] is called.
     */
    var enabled: Boolean = true

    /** [NotificationCompat.Builder.setOngoing] value. */
    var notificationOngoing: Boolean = true

    /** [NotificationCompat.Builder.setContentTitle] value. */
    var notificationTitle: String = "Ongoing call"

    /** [NotificationCompat.Builder.setContentText] value. */
    var notificationText: String = "Ongoing text"

    /** [NotificationCompat.Builder.setSmallIcon] value. */
    var notificationIcon: String = ""

    companion object {
      /** Creates a new [Config] object based on the data received from Flutter. */
      fun fromMap(map: Map<String, Any>): Config {
        val config = Config()
        val notification = map["notification"] as Map<String, Any>

        config.enabled = map["enabled"] as Boolean
        config.notificationOngoing = notification["ongoing"] as Boolean
        config.notificationTitle = notification["title"] as String
        config.notificationText = notification["text"] as String
        config.notificationIcon = notification["icon"] as String

        return config
      }
    }

    override fun equals(other: Any?): Boolean {
      if (this === other) return true
      if (javaClass != other?.javaClass) return false

      other as Config

      if (enabled != other.enabled) return false
      if (notificationOngoing != other.notificationOngoing) return false
      if (notificationTitle != other.notificationTitle) return false
      if (notificationText != other.notificationText) return false
      if (notificationIcon != other.notificationIcon) return false

      return true
    }

    override fun hashCode(): Int {
      var result = enabled.hashCode()
      result = 31 * result + notificationOngoing.hashCode()
      result = 31 * result + notificationTitle.hashCode()
      result = 31 * result + notificationText.hashCode()
      result = 31 * result + notificationIcon.hashCode()
      return result
    }
  }

  companion object {
    /** Current [ForegroundCallService] configuration. */
    private var currentConfig: Config? = null

    /**
     * Indicator whether [ForegroundCallService] should be running. However it can still be disabled
     * with [Config.enabled].
     *
     * This exists because [ForegroundCallService.start] might be called before it is allowed by the
     * [Config]. In this case [ForegroundCallService] will be started in
     * [ForegroundCallService.setup] when [Config] update is handled.
     */
    private var shouldBeRunning: Boolean = false

    /**
     * [NotificationChannel] that [Notification] will be posted on.
     *
     * It is created with [NOTIFICATION_CHAN_ID] and [NOTIFICATION_CHAN_NAME] on the first
     * [ForegroundCallService.start] call if API level >= 26.
     */
    private var notificationChannel: NotificationChannel? = null

    /**
     * [Permissions.Companion.GrantedObserver] that updates foreground service type if new
     * permission has been granted after initial start.
     */
    private var grantedObserver: Permissions.Companion.GrantedObserver? = null

    /** Latest foreground service type provided to [startForeground]. */
    private var currentForegroundServiceType: Int? = null

    /**
     * Update [ForegroundCallService] current [Config]. Might [ForegroundCallService.start] or
     * [ForegroundCallService.stop] if [Config.enabled] has changed .
     */
    suspend fun setup(newConfig: Config, context: Context, permissions: Permissions) {
      ThreadUtils.checkIsOnMainThread()

      if (currentConfig == newConfig) {
        return
      }

      if (shouldBeRunning && newConfig.enabled) {
        start(context, permissions)
      } else if (shouldBeRunning && !newConfig.enabled) {
        stop(context, permissions)
      }

      currentConfig = newConfig
    }

    /**
     * Starts [ForegroundCallService] and its [Notification] but only if it is enabled by current
     * [Config].
     */
    suspend fun start(context: Context, permissions: Permissions) {
      Log.v(TAG, "Start")
      ThreadUtils.checkIsOnMainThread()

      shouldBeRunning = true

      if (currentConfig?.enabled == false) {
        return
      }

      // POST_NOTIFICATIONS permission is only required since API level 33
      if (Build.VERSION.SDK_INT >= 33) {
        permissions.requestPermission(Manifest.permission.POST_NOTIFICATIONS)
      }

      if (notificationChannel == null && Build.VERSION.SDK_INT >= 26) {
        notificationChannel =
            NotificationChannel(
                NOTIFICATION_CHAN_ID,
                NOTIFICATION_CHAN_NAME,
                NotificationManager.IMPORTANCE_DEFAULT)
        NotificationManagerCompat.from(context).createNotificationChannel(notificationChannel!!)
      }

      // foregroundServiceType was added in API 29
      if (Build.VERSION.SDK_INT >= 29 && grantedObserver == null) {
        // If the foreground service needs new permissions after you launch it, you should call
        // startForeground() again and add the new service types.
        grantedObserver =
            object : Permissions.Companion.GrantedObserver {
              override fun onGranted(granted: String) {
                if (granted == Manifest.permission.RECORD_AUDIO ||
                    granted == Manifest.permission.CAMERA &&
                        currentForegroundServiceType != serviceType(context)) {
                  ContextCompat.startForegroundService(
                      context, Intent(context, ForegroundCallService::class.java))
                }
              }
            }
        permissions.addObserver(grantedObserver!!)
      }

      ContextCompat.startForegroundService(
          context, Intent(context, ForegroundCallService::class.java))
    }

    /** Stops [ForegroundCallService] if it is running. */
    fun stop(context: Context, permissions: Permissions) {
      Log.v(TAG, "Stop")

      ThreadUtils.checkIsOnMainThread()

      shouldBeRunning = false

      if (grantedObserver != null) {
        permissions.removeObserver(grantedObserver!!)
        grantedObserver = null
      }

      val intent = Intent(context, ForegroundCallService::class.java)
      context.stopService(intent)
    }

    /**
     * Returns service type that should be provided to [startForeground] based on granted
     * permissions.
     */
    private fun serviceType(ctx: Context): Int {
      // foregroundServiceType was added in API 29
      return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        var serviceType = ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK

        // FOREGROUND_SERVICE_TYPE_CAMERA and FOREGROUND_SERVICE_TYPE_MICROPHONE were added in
        // API 30
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
          if (ctx.checkSelfPermission(Manifest.permission.CAMERA) ==
              PackageManager.PERMISSION_GRANTED) {
            serviceType = serviceType or ServiceInfo.FOREGROUND_SERVICE_TYPE_CAMERA
          }
          if (ctx.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
              PackageManager.PERMISSION_GRANTED) {
            serviceType = serviceType or ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
          }
        }

        serviceType
      } else {
        0
      }
    }
  }

  override fun onCreate() {
    Log.v(TAG, "onCreate")

    super.onCreate()
  }

  override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
    Log.v(TAG, "Started with startId = $startId")

    if (currentConfig == null || !currentConfig!!.enabled) {
      stopSelf()
    }

    val notification =
        NotificationCompat.Builder(this, NOTIFICATION_CHAN_ID)
            .setOngoing(currentConfig!!.notificationOngoing)
            .setContentTitle(currentConfig!!.notificationTitle)
            .setContentText(currentConfig!!.notificationText)
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .build()

    currentForegroundServiceType = serviceType(this)

    // Once the service has been created, the service must call its startForeground() method within
    // five seconds.
    ServiceCompat.startForeground(
        this, FG_CALL_NOTIFICATION_ID, notification, currentForegroundServiceType!!)

    return START_NOT_STICKY
  }

  override fun onDestroy() {
    Log.v(TAG, "onDestroy")
    super.onDestroy()
    ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
  }

  override fun onBind(intent: Intent?): IBinder? {
    return null
  }

  override fun onTaskRemoved(rootIntent: Intent?) {
    Log.v(TAG, "onTaskRemoved")
    (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(
        FG_CALL_NOTIFICATION_ID)
  }
}
