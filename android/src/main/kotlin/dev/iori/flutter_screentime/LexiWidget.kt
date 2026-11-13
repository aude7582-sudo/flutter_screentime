package dev.iori.flutter_screentime

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

/**
 * Widget Léxi pour l'écran d'accueil du téléphone : temps d'écran du jour,
 * nombre d'ouvertures d'applis et appli la plus utilisée.
 * Toucher le widget ouvre Léxi sur l'écran « Temps d'écran ».
 */
class LexiWidget : AppWidgetProvider() {

    override fun onUpdate(ctx: Context, manager: AppWidgetManager, ids: IntArray) {
        val attente = goAsync()
        Thread {
            try {
                dessiner(ctx, manager, ids)
            } catch (_: Exception) {
            } finally {
                attente.finish()
            }
        }.start()
    }

    companion object {
        private const val OBJECTIF_SECONDES = 2 * 3600L
        private var derniereMaj = 0L

        /** Met à jour tous les widgets Léxi posés sur l'écran d'accueil. */
        fun majTous(ctx: Context) {
            val manager = AppWidgetManager.getInstance(ctx)
            val ids = manager.getAppWidgetIds(ComponentName(ctx, LexiWidget::class.java))
            if (ids.isEmpty()) return
            Thread {
                try {
                    dessiner(ctx.applicationContext, manager, ids)
                } catch (_: Exception) {
                }
            }.start()
        }

        /** Comme [majTous], au plus une fois toutes les 5 minutes. */
        fun majSiBesoin(ctx: Context) {
            val maintenant = System.currentTimeMillis()
            if (maintenant - derniereMaj < 5 * 60_000L) return
            derniereMaj = maintenant
            majTous(ctx)
        }

        private fun duree(sec: Long): String {
            val h = sec / 3600
            val m = (sec % 3600) / 60
            return when {
                h > 0 -> "$h h ${m.toString().padStart(2, '0')}"
                else -> "$m min"
            }
        }

        private fun dessiner(ctx: Context, manager: AppWidgetManager, ids: IntArray) {
            val vues = RemoteViews(ctx.packageName, R.layout.lexi_widget)
            val jour = LexiTempsEcran.calculer(ctx, 1)?.lastOrNull()
            if (jour == null) {
                vues.setTextViewText(R.id.lexi_widget_temps, "—")
                vues.setTextViewText(R.id.lexi_widget_detail, "Ouvre Léxi pour autoriser l'accès")
                vues.setTextViewText(R.id.lexi_widget_renard, "Touche ici 🦊")
                vues.setViewVisibility(R.id.lexi_widget_barre, View.GONE)
            } else {
                @Suppress("UNCHECKED_CAST")
                val apps = (jour["apps"] as? List<Map<String, Any>>) ?: emptyList()
                var total = 0L
                var ouvertures = 0
                var top: Map<String, Any>? = null
                for (a in apps) {
                    val s = (a["s"] as? Number)?.toLong() ?: 0L
                    total += s
                    ouvertures += (a["o"] as? Number)?.toInt() ?: 0
                    if (top == null || s > ((top["s"] as? Number)?.toLong() ?: 0L)) top = a
                }
                vues.setTextViewText(R.id.lexi_widget_temps, duree(total))
                val detail = StringBuilder("$ouvertures ouverture${if (ouvertures > 1) "s" else ""}")
                val t = top
                if (t != null && ((t["s"] as? Number)?.toLong() ?: 0L) >= 60) {
                    detail.append(" · ").append(t["n"]).append(" ")
                        .append(duree((t["s"] as Number).toLong()))
                }
                vues.setTextViewText(R.id.lexi_widget_detail, detail.toString())
                vues.setTextViewText(
                    R.id.lexi_widget_renard,
                    when {
                        total < OBJECTIF_SECONDES / 2 -> "Super, continue 🦊"
                        total < OBJECTIF_SECONDES -> "Ça va, reste attentif 🦊"
                        else -> "Pose le téléphone, révise 3 mots 🦊"
                    },
                )
                vues.setViewVisibility(R.id.lexi_widget_barre, View.VISIBLE)
                vues.setProgressBar(
                    R.id.lexi_widget_barre,
                    100,
                    (total * 100 / OBJECTIF_SECONDES).coerceIn(0L, 100L).toInt(),
                    false,
                )
            }
            ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)?.let { i ->
                i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                i.putExtra("lexi_ouvrir", "temps")
                vues.setOnClickPendingIntent(
                    R.id.lexi_widget_racine,
                    PendingIntent.getActivity(
                        ctx,
                        304,
                        i,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    ),
                )
            }
            manager.updateAppWidget(ids, vues)
        }
    }
}
