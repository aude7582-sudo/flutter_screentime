package dev.iori.flutter_screentime

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import java.util.Calendar

/**
 * Léxi : temps passé et nombre d'ouvertures par appli, jour par jour.
 * Renvoie une liste (du plus ancien au plus récent) de
 * { "jour": "2026-11-10", "apps": [ { "p": paquet, "n": nom, "s": secondes, "o": ouvertures } ] }
 * ou null si l'accès aux données d'utilisation n'est pas autorisé.
 */
internal object LexiTempsEcran {
    private const val ECRAN_ETEINT = 16 // UsageEvents.Event.SCREEN_NON_INTERACTIVE

    fun calculer(ctx: Context, jours: Int): List<Map<String, Any>>? {
        if (!autorise(ctx)) return null
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val pm = ctx.packageManager
        val accueil = pm.resolveActivity(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME),
            PackageManager.MATCH_DEFAULT_ONLY,
        )?.activityInfo?.packageName
        val ouvrables = HashMap<String, Boolean>()
        val noms = HashMap<String, String>()
        fun garder(p: String): Boolean {
            if (p == ctx.packageName || p == accueil || p == "com.android.systemui") return false
            return ouvrables.getOrPut(p) { pm.getLaunchIntentForPackage(p) != null }
        }
        fun nom(p: String): String = noms.getOrPut(p) {
            try {
                pm.getApplicationLabel(pm.getApplicationInfo(p, 0)).toString()
            } catch (_: Exception) {
                p
            }
        }

        val resultat = ArrayList<Map<String, Any>>()
        val maintenant = System.currentTimeMillis()
        for (k in jours - 1 downTo 0) {
            val c = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                add(Calendar.DAY_OF_YEAR, -k)
            }
            val debut = c.timeInMillis
            val fin = minOf(debut + 24L * 3600_000L, maintenant)
            val jour = String.format(
                java.util.Locale.US,
                "%04d-%02d-%02d",
                c.get(Calendar.YEAR),
                c.get(Calendar.MONTH) + 1,
                c.get(Calendar.DAY_OF_MONTH),
            )
            val temps = HashMap<String, Long>()
            val ouvertures = HashMap<String, Int>()
            var actuel: String? = null
            var depuis = 0L
            var dernier: String? = null
            val events = usm.queryEvents(debut, fin)
            val e = UsageEvents.Event()
            fun fermer(t: Long) {
                val a = actuel ?: return
                if (t > depuis) temps[a] = (temps[a] ?: 0L) + (t - depuis)
                actuel = null
            }
            while (events.hasNextEvent()) {
                events.getNextEvent(e)
                when (e.eventType) {
                    UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                        val p = e.packageName
                        if (p != actuel) {
                            fermer(e.timeStamp)
                            if (p != dernier) ouvertures[p] = (ouvertures[p] ?: 0) + 1
                            actuel = p
                            depuis = e.timeStamp
                        }
                        dernier = p
                    }
                    UsageEvents.Event.MOVE_TO_BACKGROUND ->
                        if (e.packageName == actuel) fermer(e.timeStamp)
                    ECRAN_ETEINT -> {
                        fermer(e.timeStamp)
                        dernier = null
                    }
                }
            }
            fermer(fin)
            val apps = ArrayList<Map<String, Any>>()
            for (p in (temps.keys + ouvertures.keys).toSet()) {
                if (!garder(p)) continue
                val sec = (temps[p] ?: 0L) / 1000L
                val o = ouvertures[p] ?: 0
                if (sec < 5 && o == 0) continue
                apps.add(mapOf("p" to p, "n" to nom(p), "s" to sec, "o" to o))
            }
            resultat.add(mapOf("jour" to jour, "apps" to apps))
        }
        return resultat
    }

    /** Nombre d'ouvertures d'applis (hors Léxi et accueil) entre [debut] et [fin]. */
    fun ouvertures(ctx: Context, debut: Long, fin: Long): Int {
        if (!autorise(ctx)) return -1
        val usm = ctx.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val pm = ctx.packageManager
        val accueil = pm.resolveActivity(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME),
            PackageManager.MATCH_DEFAULT_ONLY,
        )?.activityInfo?.packageName
        val ouvrables = HashMap<String, Boolean>()
        var total = 0
        var dernier: String? = null
        val events = usm.queryEvents(debut, minOf(fin, System.currentTimeMillis()))
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (e.eventType == ECRAN_ETEINT) {
                dernier = null
                continue
            }
            if (e.eventType != UsageEvents.Event.MOVE_TO_FOREGROUND) continue
            val p = e.packageName
            if (p == dernier) continue
            dernier = p
            if (p == ctx.packageName || p == accueil || p == "com.android.systemui") continue
            if (ouvrables.getOrPut(p) { pm.getLaunchIntentForPackage(p) != null }) total++
        }
        return total
    }

    private fun autorise(ctx: Context): Boolean {
        val ops = ctx.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        @Suppress("DEPRECATION")
        val mode = ops.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            ctx.packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
