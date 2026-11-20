package dev.iori.flutter_screentime

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews

/**
 * Widget Léxi pour l'écran d'accueil du téléphone.
 * Grand format : temps d'écran du jour, comparaison avec hier, ouvertures,
 * appli la plus utilisée, série de jours Léxi et état du blocage.
 * Petit format (widget réduit) : temps du jour, comparaison et barre.
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

    override fun onAppWidgetOptionsChanged(
        ctx: Context,
        manager: AppWidgetManager,
        id: Int,
        options: Bundle,
    ) {
        // Le widget a été agrandi ou réduit : on le redessine.
        majTous(ctx)
    }

    private class Donnees(
        val autorise: Boolean,
        val total: Long = 0L,
        val hier: Long = -1L,
        val ouvertures: Int = 0,
        val topNom: String? = null,
        val topSec: Long = 0L,
    )

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

        private fun lire(ctx: Context): Donnees {
            val jours = LexiTempsEcran.calculer(ctx, 2) ?: return Donnees(autorise = false)
            fun somme(j: Map<String, Any>?): Triple<Long, Int, Map<String, Any>?> {
                @Suppress("UNCHECKED_CAST")
                val apps = (j?.get("apps") as? List<Map<String, Any>>) ?: emptyList()
                var total = 0L
                var ouv = 0
                var top: Map<String, Any>? = null
                for (a in apps) {
                    val s = (a["s"] as? Number)?.toLong() ?: 0L
                    total += s
                    ouv += (a["o"] as? Number)?.toInt() ?: 0
                    if (top == null || s > ((top["s"] as? Number)?.toLong() ?: 0L)) top = a
                }
                return Triple(total, ouv, top)
            }
            val auj = somme(jours.lastOrNull())
            val hier = if (jours.size >= 2) somme(jours[jours.size - 2]).first else -1L
            val top = auj.third
            return Donnees(
                autorise = true,
                total = auj.first,
                hier = hier,
                ouvertures = auj.second,
                topNom = top?.get("n")?.toString(),
                topSec = (top?.get("s") as? Number)?.toLong() ?: 0L,
            )
        }

        /** Série de jours Léxi, enregistrée par l'appli (0 si inconnue). */
        private fun serie(ctx: Context): Long {
            return try {
                val p = ctx.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                when (val v = p.all["flutter.lexi_w_serie"]) {
                    is Number -> v.toLong()
                    is String -> v.toLongOrNull() ?: 0L
                    else -> 0L
                }
            } catch (_: Exception) {
                0L
            }
        }

        private fun texteCompare(d: Donnees): Pair<String, Int> {
            if (d.hier < 0 || d.hier < 60) return Pair("", 0xFF86EFAC.toInt())
            val diff = d.total - d.hier
            return if (diff <= 0) {
                Pair("▼ ${duree(-diff)} vs hier", 0xFF86EFAC.toInt())
            } else {
                Pair("▲ ${duree(diff)} vs hier", 0xFFFDBA74.toInt())
            }
        }

        private fun remplir(
            ctx: Context,
            layout: Int,
            d: Donnees,
            serie: Long,
            bloque: Boolean,
            grand: Boolean,
        ): RemoteViews {
            val v = RemoteViews(ctx.packageName, layout)
            val etat = when {
                bloque -> "🔒 Concentration en cours"
                serie > 0 -> "🔥 Série de $serie jour${if (serie > 1) "s" else ""}"
                else -> "🦊 Ton coach Léxi"
            }
            v.setTextViewText(R.id.lexi_widget_etat, etat)

            if (!d.autorise) {
                v.setTextViewText(R.id.lexi_widget_temps, "—")
                v.setTextViewText(R.id.lexi_widget_compare, "")
                v.setViewVisibility(R.id.lexi_widget_compare, View.GONE)
                v.setViewVisibility(R.id.lexi_widget_barre, View.GONE)
                if (grand) {
                    v.setTextViewText(R.id.lexi_widget_objectif, "")
                    v.setViewVisibility(R.id.lexi_widget_stats, View.GONE)
                    v.setTextViewText(
                        R.id.lexi_widget_renard,
                        "Touche ici et autorise « Accès à l'utilisation » 🦊",
                    )
                } else {
                    v.setTextViewText(R.id.lexi_widget_etat, "Touche pour autoriser 🦊")
                }
                return v
            }

            v.setTextViewText(R.id.lexi_widget_temps, duree(d.total))
            val (cmp, couleur) = texteCompare(d)
            v.setTextViewText(R.id.lexi_widget_compare, cmp)
            v.setTextColor(R.id.lexi_widget_compare, couleur)
            v.setViewVisibility(R.id.lexi_widget_compare, if (cmp.isEmpty()) View.GONE else View.VISIBLE)
            v.setViewVisibility(R.id.lexi_widget_barre, View.VISIBLE)
            v.setProgressBar(
                R.id.lexi_widget_barre,
                100,
                (d.total * 100 / OBJECTIF_SECONDES).coerceIn(0L, 100L).toInt(),
                false,
            )
            if (!grand) return v

            v.setTextViewText(R.id.lexi_widget_objectif, "sur ${duree(OBJECTIF_SECONDES)} max")
            v.setViewVisibility(R.id.lexi_widget_stats, View.VISIBLE)
            v.setTextViewText(
                R.id.lexi_widget_stat1,
                "📱 ${d.ouvertures}\nouverture${if (d.ouvertures > 1) "s" else ""}",
            )
            val nomTop = d.topNom
            v.setTextViewText(
                R.id.lexi_widget_stat2,
                if (nomTop != null && d.topSec >= 60) "🏆 $nomTop\n${duree(d.topSec)}" else "🏆 —\nappli n°1",
            )
            v.setTextViewText(
                R.id.lexi_widget_stat3,
                if (serie > 0) "🔥 $serie\njour${if (serie > 1) "s" else ""} de suite" else "🎯 ${duree(OBJECTIF_SECONDES)}\nobjectif max",
            )
            v.setTextViewText(
                R.id.lexi_widget_renard,
                when {
                    d.total < OBJECTIF_SECONDES / 2 -> "Super, continue comme ça ! 🦊"
                    d.total < OBJECTIF_SECONDES -> "Ça va, reste attentif 🦊"
                    else -> "Pose le téléphone et révise 3 mots 🦊"
                },
            )
            return v
        }

        /** Message du renard (change toutes les 30 minutes) et image associée. */
        private fun message(d: Donnees, serie: Long, bloque: Boolean): Pair<String, Int> {
            if (!d.autorise) return Pair("Touche ici pour voir tes stats 🦊", R.drawable.lexi_renard_bloque)
            if (bloque) return Pair("C'est l'heure de te concentrer 🔒", R.drawable.lexi_renard_bloque)
            if (d.total >= OBJECTIF_SECONDES) {
                return Pair("Objectif dépassé ! Pose le téléphone 📵", R.drawable.lexi_renard_bloque)
            }
            val liste = ArrayList<String>()
            liste.add("Allez, on s'y met ? 🦊")
            liste.add("Viens apprendre 3 mots !")
            liste.add("Ton défi du jour t'attend 🎯")
            if (serie > 1) liste.add("$serie jours de suite, bravo ! 🔥")
            if (d.ouvertures > 0) liste.add("${d.ouvertures} ouvertures aujourd'hui 📱")
            val nomTop = d.topNom
            if (nomTop != null && d.topSec >= 300) liste.add("$nomTop : ${duree(d.topSec)} aujourd'hui")
            liste.add("Moins d'écran, plus de progrès 💪")
            val i = ((System.currentTimeMillis() / (30 * 60_000L)) % liste.size).toInt()
            return Pair(liste[i], R.drawable.lexi_renard_bravo)
        }

        private fun remplirCarre(ctx: Context, d: Donnees, serie: Long, bloque: Boolean): RemoteViews {
            val v = RemoteViews(ctx.packageName, R.layout.lexi_widget_carre)
            v.setTextViewText(R.id.lexi_widget_temps, if (d.autorise) "⏱ ${duree(d.total)}" else "⏱ —")
            val (texte, image) = message(d, serie, bloque)
            v.setTextViewText(R.id.lexi_widget_message, texte)
            v.setImageViewResource(R.id.lexi_widget_image, image)
            return v
        }

        private fun clic(ctx: Context, v: RemoteViews) {
            ctx.packageManager.getLaunchIntentForPackage(ctx.packageName)?.let { i ->
                i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                i.putExtra("lexi_ouvrir", "temps")
                v.setOnClickPendingIntent(
                    R.id.lexi_widget_racine,
                    PendingIntent.getActivity(
                        ctx,
                        304,
                        i,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    ),
                )
            }
        }

        private fun dessiner(ctx: Context, manager: AppWidgetManager, ids: IntArray) {
            val d = lire(ctx)
            val s = serie(ctx)
            val bloque = ScreenTimePreferences.blocageActif(ctx)
            val grand = remplir(ctx, R.layout.lexi_widget, d, s, bloque, true)
            clic(ctx, grand)
            val carre = remplirCarre(ctx, d, s, bloque)
            clic(ctx, carre)
            val vues = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val petit = remplir(ctx, R.layout.lexi_widget_petit, d, s, bloque, false)
                clic(ctx, petit)
                RemoteViews(
                    mapOf(
                        SizeF(100f, 100f) to carre,
                        SizeF(230f, 50f) to petit,
                        SizeF(230f, 150f) to grand,
                    ),
                )
            } else {
                carre
            }
            manager.updateAppWidget(ids, vues)
        }
    }
}
