package dev.iori.flutter_screentime

import android.app.AppOpsManager
import android.app.KeyguardManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.core.app.NotificationCompat

private const val channelId = "flutter_screentime.blocking"
private const val notificationId = 1

class BlockAppService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val windowManager by lazy {
        getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    private var overlayView: View? = null
    private var isOverlayDisplayed = false

    // Léxi : coupe le son de l'appli bloquée (TikTok, YouTube…) pendant
    // que l'écran de blocage est affiché.
    private val audioManager by lazy {
        getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }
    private val focusListener = AudioManager.OnAudioFocusChangeListener { }
    private var focusRequest: AudioFocusRequest? = null

    private fun prendreLeSon() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val req = focusRequest ?: AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                            .build(),
                    )
                    .setOnAudioFocusChangeListener(focusListener)
                    .build()
                focusRequest = req
                audioManager.requestAudioFocus(req)
            } else {
                @Suppress("DEPRECATION")
                audioManager.requestAudioFocus(
                    focusListener,
                    AudioManager.STREAM_MUSIC,
                    AudioManager.AUDIOFOCUS_GAIN,
                )
            }
        } catch (_: Exception) {
        }
    }

    private fun rendreLeSon() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                focusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager.abandonAudioFocus(focusListener)
            }
        } catch (_: Exception) {
        }
    }

    private val overlayParams by lazy {
        WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            android.graphics.PixelFormat.TRANSLUCENT,
        )
    }

    private val pollingRunnable =
        object : Runnable {
            override fun run() {
                if (!ScreenTimePreferences.prefs(this@BlockAppService)
                        .getBoolean(ScreenTimePreferences.keyBlockingEnabled, false)
                ) {
                    removeOverlay()
                    stopSelf()
                    return
                }

                if (!hasOverlayPermission() || !hasUsageStatsPermission()) {
                    removeOverlay()
                    handler.postDelayed(this, 1000)
                    return
                }

                val shouldDisplayOverlay =
                    !isDeviceLocked() && isBlockedPackageInForeground()

                if (shouldDisplayOverlay) {
                    showOverlay()
                    // Redemande le son à chaque passage : si l'appli bloquée
                    // relance sa vidéo, elle est remise en pause.
                    prendreLeSon()
                } else {
                    removeOverlay()
                }

                handler.postDelayed(this, 500)
            }
        }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
        ensureNotificationChannel()
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Léxi veille sur ta concentration 🦊")
            .setContentText("Le blocage de tes applis est actif.")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .build()

        startForeground(notificationId, notification)

        if (overlayView == null) {
            overlayView = LayoutInflater.from(this).inflate(R.layout.block_overlay, null)
            bindOverlayConfiguration()
        }

        handler.removeCallbacksAndMessages(null)
        handler.post(pollingRunnable)

        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        removeOverlay()
        super.onDestroy()
    }

    private fun bindOverlayConfiguration() {
        val configuration = ScreenTimePreferences.overlayConfiguration(this)
        val view = overlayView ?: return

        view.setBackgroundColor(configuration.backgroundColor)
        view.findViewById<TextView>(R.id.block_overlay_title).apply {
            text = configuration.title
            setTextColor(configuration.textColor)
        }
        view.findViewById<TextView>(R.id.block_overlay_message).apply {
            text = configuration.message
            setTextColor(configuration.textColor)
        }
        view.findViewById<Button>(R.id.block_overlay_primary_button).apply {
            val label = configuration.primaryButtonLabel
            visibility = if (label.isNullOrBlank()) View.GONE else View.VISIBLE
            text = label
            setOnClickListener { openHostApp() }
        }
        view.findViewById<Button>(R.id.block_overlay_secondary_button).apply {
            val label = configuration.secondaryButtonLabel
            visibility = if (label.isNullOrBlank()) View.GONE else View.VISIBLE
            text = label
            setOnClickListener {
                startActivity(
                    Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    },
                )
            }
        }
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Blocage Léxi",
                NotificationManager.IMPORTANCE_LOW,
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun showOverlay() {
        val view = overlayView ?: return
        if (!isOverlayDisplayed && view.windowToken == null) {
            bindOverlayConfiguration()
            windowManager.addView(view, overlayParams)
            isOverlayDisplayed = true
        }
    }

    private fun removeOverlay() {
        val view = overlayView ?: return
        if (isOverlayDisplayed && view.windowToken != null) {
            windowManager.removeView(view)
            isOverlayDisplayed = false
            rendreLeSon()
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isDeviceLocked(): Boolean {
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        return keyguardManager.isKeyguardLocked
    }

    private fun isBlockedPackageInForeground(): Boolean {
        val packageName = lastForegroundPackage() ?: return false
        if (packageName == this.packageName) {
            return false
        }

        val blockedPackages = ScreenTimePreferences.blockedPackages(this)
        if (blockedPackages.isNotEmpty()) {
            return blockedPackages.contains(packageName)
        }

        return isLaunchableUserApp(packageName)
    }

    private fun lastForegroundPackage(): String? {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val beginTime = endTime - 60_000

        val usageEvents = usageStatsManager.queryEvents(beginTime, endTime)
        var lastForegroundPackage: String? = null
        while (usageEvents.hasNextEvent()) {
            val event = UsageEvents.Event()
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lastForegroundPackage = event.packageName
            }
        }

        return lastForegroundPackage
    }

    private fun isLaunchableUserApp(targetPackage: String): Boolean {
        val launchIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val defaultHome = packageManager.resolveActivity(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME),
            PackageManager.MATCH_DEFAULT_ONLY,
        )?.activityInfo?.packageName

        return packageManager.queryIntentActivities(launchIntent, 0).any { resolveInfo ->
            val packageName = resolveInfo.activityInfo.packageName
            val flags = resolveInfo.activityInfo.applicationInfo.flags
            packageName == targetPackage &&
                packageName != defaultHome &&
                packageName != this.packageName &&
                flags and ApplicationInfo.FLAG_SYSTEM == 0
        }
    }

    private fun openHostApp() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: return
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        startActivity(launchIntent)
    }
}
