package com.example.scheduler_app

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.provider.Settings
import android.util.Base64
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class AppLaunchService : Service() {

    companion object {
        const val FG_CHANNEL_ID = "scheduler_fg"
        const val ALERT_CHANNEL_ID = "scheduler_alert"
        const val EXTRA_PACKAGE = "packageName"
        const val EXTRA_APP_NAME = "appName"

        fun createChannels(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val nm = context.getSystemService(
                    Context.NOTIFICATION_SERVICE
                ) as NotificationManager

                // Delete old broken channels
                try {
                    nm.deleteNotificationChannel("scheduler_notify")
                } catch (e: Exception) {
                }
                try {
                    nm.deleteNotificationChannel("scheduler_launch")
                } catch (e: Exception) {
                }
                try {
                    nm.deleteNotificationChannel("scheduler_channel")
                } catch (e: Exception) {
                }

                // Foreground silent channel
                val fgChannel = NotificationChannel(
                    FG_CHANNEL_ID,
                    "Scheduler Background",
                    NotificationManager.IMPORTANCE_MIN
                ).apply {
                    setShowBadge(false)
                    setSound(null, null)
                }
                nm.createNotificationChannel(fgChannel)

                // Alert channel — HIGH importance
                val alertChannel = NotificationChannel(
                    ALERT_CHANNEL_ID,
                    "Scheduled App Alerts",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifications when scheduled apps are ready"
                    enableLights(true)
                    enableVibration(true)
                    setShowBadge(true)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                nm.createNotificationChannel(alertChannel)
            }
        }

        fun start(
            context: Context,
            packageName: String,
            appName: String,
            label: String? = null,
            scheduleId: String = ""
        ) {
            val intent = Intent(context, AppLaunchService::class.java).apply {
                putExtra(EXTRA_PACKAGE, packageName)
                putExtra(EXTRA_APP_NAME, appName)
                putExtra("label", label)
                putExtra("scheduleId", scheduleId)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createChannels(this)

        val fgNotif = NotificationCompat.Builder(this, FG_CHANNEL_ID)
            .setContentTitle("App Scheduler")
            .setContentText("Processing scheduled task...")
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSilent(true)
            .build()
        startForeground(999, fgNotif)

        val packageName = intent?.getStringExtra(EXTRA_PACKAGE)
        val appName = intent?.getStringExtra(EXTRA_APP_NAME) ?: ""
        val label = intent?.getStringExtra("label")

        if (!packageName.isNullOrEmpty()) {
            // Save to SharedPreferences so Flutter can read it
            val prefs = getSharedPreferences("scheduler_history", Context.MODE_PRIVATE)
            val existing = prefs.getString("pending_history", "")
            val entry = "$packageName|$appName|${label ?: ""}|${System.currentTimeMillis()}"
            prefs.edit().putString("pending_history",
                if (existing.isNullOrEmpty()) entry else "$existing\n$entry"
            ).apply()

            val launched = tryLaunch(packageName)
            if (!launched) {
                showAlertNotification(packageName, appName)
            }
        }

        stopSelf()
        return START_NOT_STICKY
    }

    private fun tryLaunch(packageName: String): Boolean {
        return try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            val wl = pm.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or
                        PowerManager.ACQUIRE_CAUSES_WAKEUP or
                        PowerManager.ON_AFTER_RELEASE,
                "AppScheduler::WL"
            )
            wl.acquire(10000L)

            val am = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            val isForegrounded = am.runningAppProcesses?.any { proc ->
                proc.importance == android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND &&
                        proc.processName == packageName
            } ?: false

            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
                )
                startActivity(launchIntent)
            }

            if (wl.isHeld) wl.release()
            // Return true only if our scheduler app was in foreground
            isOwnAppForegrounded()
        } catch (e: Exception) {
            false
        }
    }

    private fun isOwnAppForegrounded(): Boolean {
        return try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            am.runningAppProcesses?.any { proc ->
                proc.importance == android.app.ActivityManager.RunningAppProcessInfo
                    .IMPORTANCE_FOREGROUND &&
                        proc.processName == "com.example.scheduler_app"
            } ?: false
        } catch (e: Exception) {
            false
        }
    }


    private fun showAlertNotification(packageName: String, appName: String) {
        try {
            val launchIntent = packageManager
                .getLaunchIntentForPackage(packageName)?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                } ?: Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }

            val pi = PendingIntent.getActivity(
                this,
                System.currentTimeMillis().toInt(),
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notification = NotificationCompat.Builder(this, ALERT_CHANNEL_ID)
                .setContentTitle("⏰ Time to open $appName!")
                .setContentText("Your scheduled time has arrived. Tap to open.")
                .setStyle(
                    NotificationCompat.BigTextStyle()
                        .bigText("Your scheduled time has arrived.\nTap this notification to open $appName.")
                )
                .setSmallIcon(android.R.drawable.ic_popup_reminder)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setContentIntent(pi)
                .setAutoCancel(true)
                .setDefaults(
                    NotificationCompat.DEFAULT_SOUND or
                            NotificationCompat.DEFAULT_VIBRATE or
                            NotificationCompat.DEFAULT_LIGHTS
                )
                .setOnlyAlertOnce(false)
                .build()

            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(packageName.hashCode().and(0x7FFFFFFF), notification)

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}

class AppAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val packageName = intent.getStringExtra("packageName") ?: return
        val appName = intent.getStringExtra("appName") ?: packageName
        val label = intent.getStringExtra("label")
        val scheduleId = intent.getStringExtra("scheduleId") ?: ""
        AppLaunchService.createChannels(context)
        AppLaunchService.start(context, packageName, appName, label, scheduleId)
    }
}

class MainActivity : FlutterActivity() {

    private val appsChannel = "com.example.app_scheduler/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AppLaunchService.createChannels(this)
        requestNotificationPermission()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" ->
                        result.success(getInstalledApps())

                    "openApp" -> {
                        val pkg = call.argument<String>("packageName")
                        if (pkg != null) {
                            directLaunch(pkg)
                            result.success(true)
                        } else result.error("INVALID", "null package", null)
                    }

                    "scheduleAlarm" -> {
                        val pkg = call.argument<String>("packageName") ?: ""
                        val appName = call.argument<String>("appName") ?: pkg
                        val alarmId = call.argument<Int>("alarmId") ?: 0
                        val triggerMs = call.argument<Long>("triggerMs") ?: 0L
                        scheduleAlarm(alarmId, pkg, appName, triggerMs)
                        result.success(true)
                    }

                    "cancelAlarm" -> {
                        val alarmId = call.argument<Int>("alarmId") ?: 0
                        cancelAlarm(alarmId)
                        result.success(true)
                    }

                    "getPendingHistory" -> {
                        val prefs = getSharedPreferences("scheduler_history", Context.MODE_PRIVATE)
                        val pending = prefs.getString("pending_history", "") ?: ""
                        prefs.edit().remove("pending_history").apply()
                        result.success(pending)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(
                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 1001
            )
        }
    }

    private fun scheduleAlarm(
        alarmId: Int,
        packageName: String,
        appName: String,
        triggerMs: Long
    ) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AppAlarmReceiver::class.java).apply {
            putExtra("packageName", packageName)
            putExtra("appName", appName)
        }
        val pi = PendingIntent.getBroadcast(
            this, alarmId, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerMs, pi)
        } else {
            am.setExact(AlarmManager.RTC_WAKEUP, triggerMs, pi)
        }
    }

    private fun cancelAlarm(alarmId: Int) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = PendingIntent.getBroadcast(
            this, alarmId,
            Intent(this, AppAlarmReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        am.cancel(pi)
    }

    private fun directLaunch(packageName: String) {
        packageManager.getLaunchIntentForPackage(packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(this)
        }
    }

    private fun requestIgnoreBattery() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                try {
                    startActivity(
                        Intent(
                            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                            Uri.parse("package:$packageName")
                        )
                    )
                } catch (e: Exception) {
                    startActivity(
                        Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    )
                }
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, String?>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(intent, 0).map { info ->
            mapOf(
                "appName" to info.loadLabel(pm).toString(),
                "packageName" to info.activityInfo.packageName,
                "icon" to try {
                    drawableToBase64(info.loadIcon(pm))
                } catch (e: Exception) {
                    null
                }
            )
        }.sortedBy { it["appName"] }
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val w = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 48
        val h = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 48
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        drawable.setBounds(0, 0, w, h)
        drawable.draw(canvas)
        val out = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.PNG, 100, out)
        return Base64.encodeToString(out.toByteArray(), Base64.NO_WRAP)
    }
}