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
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.widget.LinearLayout
import java.util.Calendar
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
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            android.graphics.PixelFormat.TRANSLUCENT,
        ).apply {
            // Léxi : l'écran couvre aussi la barre du haut (sinon on voit
            // encore un bout de la vidéo).
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }
    }

    // Léxi : après avoir renvoyé l'appli bloquée à l'accueil, on garde
    // l'écran du renard jusqu'à ce que la personne touche un bouton.
    private var gardeEcran = false
    private var dernierRenvoi = 0L

    private fun renvoyerAccueil() {
        val maintenant = System.currentTimeMillis()
        if (maintenant - dernierRenvoi < 1500) return
        dernierRenvoi = maintenant
        try {
            startActivity(
                Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                },
            )
        } catch (_: Exception) {
        }
    }

    private fun accueilDuTelephone(): String? =
        packageManager.resolveActivity(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME),
            PackageManager.MATCH_DEFAULT_ONLY,
        )?.activityInfo?.packageName

    private fun fermerEcran() {
        gardeEcran = false
        removeOverlay()
    }

    private val pollingRunnable =
        object : Runnable {
            override fun run() {
                val ctx = this@BlockAppService
                val blocage = ScreenTimePreferences.blocageActif(ctx)
                val veille = ScreenTimePreferences.veilleActive(ctx)
                if (!blocage && !veille) {
                    removeOverlay()
                    cacherCarte()
                    stopSelf()
                    return
                }
                majNotification(blocage)

                if (!hasOverlayPermission() || !hasUsageStatsPermission()) {
                    removeOverlay()
                    cacherCarte()
                    handler.postDelayed(this, 1000)
                    return
                }

                if (!blocage) {
                    gardeEcran = false
                    removeOverlay()
                    verifierVeille()
                    handler.postDelayed(this, 1000)
                    return
                }

                cacherCarte()
                val shouldDisplayOverlay =
                    !isDeviceLocked() && isBlockedPackageInForeground()

                if (shouldDisplayOverlay) {
                    // L'appli bloquée part en arrière-plan : sa vidéo et
                    // son son s'arrêtent.
                    renvoyerAccueil()
                    prendreLeSon()
                    gardeEcran = true
                    showOverlay()
                } else if (gardeEcran && !isDeviceLocked()) {
                    val devant = lastForegroundPackage()
                    if (devant == null || devant == accueilDuTelephone()) {
                        showOverlay()
                    } else {
                        fermerEcran()
                    }
                } else {
                    gardeEcran = false
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
        dernierModeNotif = null
        startForeground(notificationId, construireNotification(ScreenTimePreferences.blocageActif(this)))
        dernierModeNotif = ScreenTimePreferences.blocageActif(this)

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
        cacherCarte()
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
            setOnClickListener {
                fermerEcran()
                ScreenTimePreferences.demanderOuverture(this@BlockAppService, "defi")
                openHostApp()
            }
        }
        view.findViewById<Button>(R.id.block_overlay_secondary_button).apply {
            // Léxi : bouton « Fermer » pour revenir à l'accueil du téléphone.
            val label = configuration.secondaryButtonLabel
            visibility = View.VISIBLE
            text = if (label.isNullOrBlank()) "Fermer" else label
            setTextColor(configuration.textColor)
            setOnClickListener { fermerEcran() }
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

    // ---------------------------------------------------------------------
    // Léxi : veille (« 15 minutes de TikTok aujourd'hui »)
    // ---------------------------------------------------------------------
    private var dernierModeNotif: Boolean? = null

    private fun construireNotification(blocage: Boolean) =
        NotificationCompat.Builder(this, channelId)
            .setContentTitle("Léxi veille sur ta concentration 🦊")
            .setContentText(
                if (blocage) "Le blocage de tes applis est actif."
                else "Léxi te prévient quand tu passes trop de temps sur une appli.",
            )
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .apply { intentionOuvrir(if (blocage) "defi" else "lecon")?.let { setContentIntent(it) } }
            .build()

    // Toucher la notification ouvre Léxi directement sur le défi (ou la leçon).
    private fun intentionOuvrir(cible: String): android.app.PendingIntent? {
        val i = packageManager.getLaunchIntentForPackage(packageName) ?: return null
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        i.putExtra("lexi_ouvrir", cible)
        return android.app.PendingIntent.getActivity(
            this,
            if (cible == "defi") 301 else 302,
            i,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun majNotification(blocage: Boolean) {
        if (dernierModeNotif == blocage) return
        dernierModeNotif = blocage
        try {
            val manager = getSystemService(NotificationManager::class.java)
            manager.notify(notificationId, construireNotification(blocage))
        } catch (_: Exception) {
        }
    }

    private var carteView: View? = null
    private var carteAffichee = false
    private var cartePaquet: String? = null
    private var compteurVeille = 0

    private fun debutDuJour(): Long =
        Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

    private fun cleJour(): String {
        val c = Calendar.getInstance()
        return "${c.get(Calendar.YEAR)}-${c.get(Calendar.DAY_OF_YEAR)}"
    }

    /** Minutes passées aujourd'hui sur [paquet] (au premier plan). */
    private fun minutesAujourdhui(paquet: String): Long {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val fin = System.currentTimeMillis()
        val events = usm.queryEvents(debutDuJour(), fin)
        var total = 0L
        var debut = -1L
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (e.packageName != paquet) {
                if (e.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND && debut >= 0) {
                    total += e.timeStamp - debut
                    debut = -1L
                }
                continue
            }
            when (e.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> if (debut < 0) debut = e.timeStamp
                UsageEvents.Event.MOVE_TO_BACKGROUND -> if (debut >= 0) {
                    total += e.timeStamp - debut
                    debut = -1L
                }
            }
        }
        if (debut >= 0) total += fin - debut
        return total / 60_000L
    }

    private fun nomAppli(paquet: String): String =
        try {
            packageManager.getApplicationLabel(
                packageManager.getApplicationInfo(paquet, 0),
            ).toString()
        } catch (_: Exception) {
            paquet
        }

    private fun verifierVeille() {
        if (isDeviceLocked()) {
            cacherCarte()
            return
        }
        val devant = lastForegroundPackage()
        val surveilles = ScreenTimePreferences.veillePackages(this)
        if (devant == null || devant == packageName || !surveilles.contains(devant)) {
            cacherCarte()
            compteurVeille = 0
            return
        }
        if (carteAffichee) {
            if (cartePaquet != devant) cacherCarte() else return
        }
        // On recalcule le temps toutes les 5 secondes seulement.
        compteurVeille++
        if (compteurVeille % 5 != 1) return

        val limite = ScreenTimePreferences.veilleMinutes(this)
        val minutes = minutesAujourdhui(devant)
        val prefs = ScreenTimePreferences.prefs(this)
        val cle = "lexi_veille_prochain_${cleJour()}_$devant"
        val prochain = prefs.getLong(cle, limite.toLong())
        if (minutes >= prochain) {
            prefs.edit().putLong(cle, (minutes / limite + 1) * limite).apply()
            montrerCarte(devant, minutes)
        }
    }

    private fun dp(v: Int): Int = (v * resources.displayMetrics.density).toInt()

    private fun montrerCarte(paquet: String, minutes: Long) {
        cacherCarte()
        val orange = Color.parseColor("#F97316")
        val nom = nomAppli(paquet)

        val carte = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(18), dp(20), dp(14))
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                cornerRadius = dp(26).toFloat()
            }
            elevation = dp(12).toFloat()
        }
        val haut = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        haut.addView(
            android.widget.ImageView(this).apply {
                setImageResource(R.drawable.lexi_renard_bloque)
                scaleType = android.widget.ImageView.ScaleType.FIT_CENTER
            },
            LinearLayout.LayoutParams(dp(54), dp(54)).apply { rightMargin = dp(14) },
        )
        val textes = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        textes.addView(
            TextView(this).apply {
                text = "$minutes minutes de $nom aujourd'hui"
                setTextColor(Color.parseColor("#1E1640"))
                textSize = 17f
                setTypeface(typeface, Typeface.BOLD)
            },
        )
        textes.addView(
            TextView(this).apply {
                text = "Continuer, ou t'arrêter ici ?"
                setTextColor(Color.parseColor("#6B6490"))
                textSize = 14f
                setPadding(0, dp(3), 0, 0)
            },
        )
        haut.addView(textes, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))
        carte.addView(haut)

        val boutons = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.END or Gravity.CENTER_VERTICAL
            setPadding(0, dp(14), 0, 0)
        }
        fun bouton(t: String, plein: Boolean, action: () -> Unit) =
            TextView(this).apply {
                text = t
                textSize = 15f
                setTypeface(typeface, Typeface.BOLD)
                gravity = Gravity.CENTER
                setPadding(dp(18), dp(11), dp(18), dp(11))
                if (plein) {
                    setTextColor(Color.WHITE)
                    background = GradientDrawable().apply {
                        setColor(orange)
                        cornerRadius = dp(24).toFloat()
                    }
                } else {
                    setTextColor(Color.parseColor("#1E1640"))
                }
                setOnClickListener { action() }
            }
        boutons.addView(
            bouton("3 mots 🦊", false) {
                cacherCarte()
                ScreenTimePreferences.demanderOuverture(this, "lecon")
                openHostApp()
            },
        )
        boutons.addView(bouton("Continuer", false) { cacherCarte() })
        boutons.addView(
            bouton("Arrêter ici", true) {
                cacherCarte()
                dernierRenvoi = 0L
                renvoyerAccueil()
            },
        )
        carte.addView(boutons)

        val conteneur = android.widget.FrameLayout(this).apply {
            setPadding(dp(14), dp(14), dp(14), dp(22))
            addView(carte)
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            android.graphics.PixelFormat.TRANSLUCENT,
        ).apply { gravity = Gravity.BOTTOM }
        try {
            windowManager.addView(conteneur, params)
            carteView = conteneur
            carteAffichee = true
            cartePaquet = paquet
        } catch (_: Exception) {
        }
    }

    private fun cacherCarte() {
        val v = carteView ?: return
        try {
            if (v.windowToken != null) windowManager.removeView(v)
        } catch (_: Exception) {
        }
        carteView = null
        carteAffichee = false
        cartePaquet = null
    }
}
