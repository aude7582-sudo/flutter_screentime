package dev.iori.flutter_screentime

import android.app.Activity
import android.app.AppOpsManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.pm.PackageManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterScreentimePlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_screentime")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        lireIntention(binding.activity.intent)
        binding.addOnNewIntentListener { intent ->
            lireIntention(intent)
            false
        }
    }

    // Léxi : une notification de Léxi peut demander d'ouvrir le défi ou la leçon.
    private fun lireIntention(intent: Intent?) {
        val cible = intent?.getStringExtra("lexi_ouvrir") ?: return
        if (cible.isNotEmpty()) {
            ScreenTimePreferences.demanderOuverture(applicationContext, cible)
            intent.removeExtra("lexi_ouvrir")
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "checkAuthorization" -> result.success(currentAuthorizationStatus())
            "requestAuthorization" -> requestAuthorization(result)
            "setSharedContainerId" -> result.success(null)
            "configureBlockScreen" -> {
                val arguments = call.arguments as? Map<*, *>
                if (arguments == null) {
                    result.error("invalid_args", "Expected a configuration map.", null)
                    return
                }
                ScreenTimePreferences.saveOverlayConfiguration(applicationContext, arguments)
                result.success(null)
            }
            "setBlockedPackages" -> {
                val packageNames = (call.arguments as? List<*>)?.filterIsInstance<String>()
                if (packageNames == null) {
                    result.error("invalid_args", "Expected a list of package names.", null)
                    return
                }
                ScreenTimePreferences.prefs(applicationContext)
                    .edit()
                    .putStringSet(
                        ScreenTimePreferences.keyBlockedPackages,
                        packageNames.toSet(),
                    )
                    .apply()
                result.success(null)
            }
            "selectBlockedApps" -> {
                result.error(
                    "unsupported",
                    "Android does not expose a native blocked apps picker. Use setBlockedPackages instead.",
                    null,
                )
            }
            "startBlocking" -> {
                ScreenTimePreferences.prefs(applicationContext)
                    .edit()
                    .putBoolean(ScreenTimePreferences.keyBlockingEnabled, true)
                    .apply()
                val intent = Intent(applicationContext, BlockAppService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    applicationContext.startForegroundService(intent)
                } else {
                    applicationContext.startService(intent)
                }
                result.success(null)
            }
            "stopBlocking" -> {
                ScreenTimePreferences.prefs(applicationContext)
                    .edit()
                    .putBoolean(ScreenTimePreferences.keyBlockingEnabled, false)
                    .apply()
                lexiServiceSelonEtat()
                result.success(null)
            }
            // Léxi : rappel « 15 minutes de TikTok aujourd'hui ».
            "lexiVeille" -> {
                val args = call.arguments as? Map<*, *>
                val actif = args?.get("actif") as? Boolean ?: false
                val minutes = (args?.get("minutes") as? Number)?.toInt() ?: 15
                val paquets = (args?.get("packages") as? List<*>)
                    ?.filterIsInstance<String>()?.toSet() ?: emptySet()
                ScreenTimePreferences.prefs(applicationContext)
                    .edit()
                    .putBoolean(ScreenTimePreferences.keyVeilleEnabled, actif)
                    .putInt(ScreenTimePreferences.keyVeilleMinutes, minutes)
                    .putStringSet(ScreenTimePreferences.keyVeillePackages, paquets)
                    .apply()
                lexiServiceSelonEtat()
                result.success(currentAuthorizationStatus() == "approved")
            }
            // Léxi : notifications de rappel (leçon, début du blocage…).
            "lexiNotifier" -> {
                val args = call.arguments as? Map<*, *>
                val ok = lexiNotifier(
                    (args?.get("id") as? Number)?.toInt() ?: 100,
                    args?.get("titre") as? String ?: "Léxi",
                    args?.get("texte") as? String ?: "",
                )
                result.success(ok)
            }
            "lexiTempsEcran" -> {
                val jours = ((call.arguments as? Map<*, *>)?.get("jours") as? Number)?.toInt() ?: 14
                val ctx = applicationContext
                Thread {
                    val donnees = try {
                        LexiTempsEcran.calculer(ctx, jours)
                    } catch (_: Exception) {
                        null
                    }
                    android.os.Handler(android.os.Looper.getMainLooper()).post {
                        result.success(donnees)
                    }
                }.start()
            }
            "lexiOuverture" -> result.success(
                ScreenTimePreferences.lireOuverture(applicationContext),
            )
            "lexiNotificationsOk" -> result.success(
                NotificationManagerCompat.from(applicationContext).areNotificationsEnabled(),
            )
            "lexiDemanderNotifications" -> {
                val a = activity
                if (Build.VERSION.SDK_INT >= 33 && a != null &&
                    a.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) !=
                    PackageManager.PERMISSION_GRANTED
                ) {
                    a.requestPermissions(
                        arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                        7311,
                    )
                }
                result.success(
                    NotificationManagerCompat.from(applicationContext).areNotificationsEnabled(),
                )
            }
            else -> result.notImplemented()
        }
    }

    // Léxi : le service tourne si le blocage OU la veille est actif.
    private fun lexiServiceSelonEtat() {
        val ctx = applicationContext
        val intent = Intent(ctx, BlockAppService::class.java)
        if (ScreenTimePreferences.blocageActif(ctx) || ScreenTimePreferences.veilleActive(ctx)) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ctx.startForegroundService(intent)
                } else {
                    ctx.startService(intent)
                }
            } catch (_: Exception) {
            }
        } else {
            ctx.stopService(intent)
        }
    }

    private fun lexiNotifier(id: Int, titre: String, texte: String): Boolean {
        val ctx = applicationContext
        if (!NotificationManagerCompat.from(ctx).areNotificationsEnabled()) return false
        val canal = "lexi_rappels"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = ctx.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(
                NotificationChannel(canal, "Rappels Léxi", NotificationManager.IMPORTANCE_DEFAULT),
            )
        }
        val ouvrir = ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            // 201 / 202 : blocage → défi ; 203 : rappel de leçon → leçon.
            when (id) {
                201, 202 -> putExtra("lexi_ouvrir", "defi")
                203 -> putExtra("lexi_ouvrir", "lecon")
            }
        }
        val pi = ouvrir?.let {
            PendingIntent.getActivity(
                ctx,
                id,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
        val notif = NotificationCompat.Builder(ctx, canal)
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle(titre)
            .setContentText(texte)
            .setStyle(NotificationCompat.BigTextStyle().bigText(texte))
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .apply { if (pi != null) setContentIntent(pi) }
            .build()
        return try {
            NotificationManagerCompat.from(ctx).notify(id, notif)
            true
        } catch (_: SecurityException) {
            false
        }
    }

    private fun requestAuthorization(result: MethodChannel.Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error(
                "no_activity",
                "requestAuthorization requires a foreground activity.",
                null,
            )
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.canDrawOverlays(currentActivity)
        ) {
            val overlayIntent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${currentActivity.packageName}"),
            )
            currentActivity.startActivity(overlayIntent)
        }

        if (!hasUsageStatsPermission(currentActivity)) {
            currentActivity.startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
        }

        result.success(currentAuthorizationStatus())
    }

    private fun currentAuthorizationStatus(): String {
        val hasOverlayPermission =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                Settings.canDrawOverlays(applicationContext)

        return if (hasOverlayPermission && hasUsageStatsPermission(applicationContext)) {
            "approved"
        } else {
            "denied"
        }
    }

    private fun hasUsageStatsPermission(context: Context): Boolean {
        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
