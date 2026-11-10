package dev.iori.flutter_screentime

import android.content.Context
import android.graphics.Color

internal data class OverlayConfiguration(
    val title: String,
    val message: String,
    val backgroundColor: Int,
    val textColor: Int,
    val primaryButtonLabel: String?,
    val secondaryButtonLabel: String?,
)

internal object ScreenTimePreferences {
    private const val preferencesName = "flutter_screentime"
    private const val keyTitle = "overlay_title"
    private const val keyMessage = "overlay_message"
    private const val keyBackgroundColor = "overlay_background_color"
    private const val keyTextColor = "overlay_text_color"
    private const val keyPrimaryButtonLabel = "overlay_primary_button_label"
    private const val keySecondaryButtonLabel = "overlay_secondary_button_label"

    const val keyBlockingEnabled = "blocking_enabled"
    const val keyBlockedPackages = "blocked_packages"

    // Léxi : rappel après X minutes sur une appli (hors blocage).
    const val keyVeilleEnabled = "lexi_veille"
    const val keyVeilleMinutes = "lexi_veille_minutes"
    const val keyVeillePackages = "lexi_veille_packages"

    fun veilleActive(context: Context): Boolean =
        prefs(context).getBoolean(keyVeilleEnabled, false)

    fun blocageActif(context: Context): Boolean =
        prefs(context).getBoolean(keyBlockingEnabled, false)

    fun veillePackages(context: Context): Set<String> =
        prefs(context).getStringSet(keyVeillePackages, emptySet()) ?: emptySet()

    // Léxi : quelle page ouvrir quand on arrive depuis l'écran de blocage,
    // la carte de rappel ou une notification ('defi' ou 'lecon').
    fun demanderOuverture(context: Context, cible: String) {
        prefs(context).edit()
            .putString("lexi_ouvrir", cible)
            .putLong("lexi_ouvrir_t", System.currentTimeMillis())
            .apply()
    }

    fun lireOuverture(context: Context): String {
        val p = prefs(context)
        val cible = p.getString("lexi_ouvrir", "") ?: ""
        val t = p.getLong("lexi_ouvrir_t", 0L)
        p.edit().remove("lexi_ouvrir").remove("lexi_ouvrir_t").apply()
        return if (cible.isNotEmpty() && System.currentTimeMillis() - t < 5 * 60_000L) cible else ""
    }

    fun veilleMinutes(context: Context): Int =
        prefs(context).getInt(keyVeilleMinutes, 15).coerceAtLeast(1)

    fun prefs(context: Context) =
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)

    fun saveOverlayConfiguration(
        context: Context,
        arguments: Map<*, *>,
    ) {
        prefs(context)
            .edit()
            .putString(keyTitle, arguments["title"] as? String ?: "Blocked")
            .putString(
                keyMessage,
                arguments["message"] as? String
                    ?: "This app is unavailable right now.",
            )
            .putString(
                keyBackgroundColor,
                arguments["backgroundColorHex"] as? String ?: "#111827",
            )
            .putString(
                keyTextColor,
                arguments["textColorHex"] as? String ?: "#FFFFFF",
            )
            .putString(
                keyPrimaryButtonLabel,
                arguments["primaryButtonLabel"] as? String,
            )
            .putString(
                keySecondaryButtonLabel,
                arguments["secondaryButtonLabel"] as? String,
            )
            .apply()
    }

    fun overlayConfiguration(context: Context): OverlayConfiguration {
        val prefs = prefs(context)
        return OverlayConfiguration(
            title = prefs.getString(keyTitle, "Blocked") ?: "Blocked",
            message = prefs.getString(
                keyMessage,
                "This app is unavailable right now.",
            ) ?: "This app is unavailable right now.",
            backgroundColor = parseColor(
                prefs.getString(keyBackgroundColor, "#111827"),
                Color.parseColor("#111827"),
            ),
            textColor = parseColor(
                prefs.getString(keyTextColor, "#FFFFFF"),
                Color.WHITE,
            ),
            primaryButtonLabel = prefs.getString(keyPrimaryButtonLabel, null),
            secondaryButtonLabel = prefs.getString(keySecondaryButtonLabel, null),
        )
    }

    fun blockedPackages(context: Context): Set<String> {
        return prefs(context).getStringSet(keyBlockedPackages, emptySet()) ?: emptySet()
    }

    private fun parseColor(
        colorValue: String?,
        fallback: Int,
    ): Int {
        return try {
            Color.parseColor(colorValue)
        } catch (_: IllegalArgumentException) {
            fallback
        }
    }
}
