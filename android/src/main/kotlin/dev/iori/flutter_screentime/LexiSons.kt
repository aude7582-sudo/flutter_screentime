package dev.iori.flutter_screentime

import android.annotation.TargetApi
import android.media.AudioAttributes
import android.os.Build
import android.media.AudioFormat
import android.media.AudioTrack
import kotlin.math.PI
import kotlin.math.exp
import kotlin.math.min
import kotlin.math.sin

/**
 * Léxi : petits sons fabriqués à la volée (aucun fichier audio).
 * Types : "bon", "faux", "victoire", "niveau", "clic", "defaite".
 */
internal object LexiSons {
    private const val TAUX = 22050

    // Chaque note : fréquence (Hz, 0 = silence) et durée (ms).
    private fun melodie(type: String): List<Pair<Double, Int>> = when (type) {
        "bon" -> listOf(880.0 to 90, 1318.5 to 140)
        "faux" -> listOf(311.1 to 120, 233.1 to 220)
        "victoire" -> listOf(523.3 to 110, 659.3 to 110, 784.0 to 110, 1046.5 to 320)
        "niveau" -> listOf(659.3 to 90, 784.0 to 90, 987.8 to 90, 1318.5 to 260)
        "defaite" -> listOf(392.0 to 180, 349.2 to 180, 293.7 to 360)
        else -> listOf(1200.0 to 35) // clic
    }

    private fun fabriquer(type: String): ShortArray {
        val notes = melodie(type)
        val total = notes.sumOf { it.second } * TAUX / 1000
        val pcm = ShortArray(total)
        var pos = 0
        for ((f, ms) in notes) {
            val n = ms * TAUX / 1000
            for (i in 0 until n) {
                if (pos >= total) break
                val t = i.toDouble() / TAUX
                // Attaque douce + extinction, avec une harmonique pour un son « clochette ».
                val env = min(1.0, i / (TAUX * 0.006)) * exp(-3.2 * i / n.toDouble())
                val v = if (f <= 0) 0.0 else
                    (sin(2 * PI * f * t) + 0.25 * sin(4 * PI * f * t)) * env * 0.42
                pcm[pos++] = (v * Short.MAX_VALUE).toInt().toShort()
            }
        }
        return pcm
    }

    fun jouer(type: String): Boolean =
        if (Build.VERSION.SDK_INT < 23) false else jouer23(type)

    @TargetApi(23)
    private fun jouer23(type: String): Boolean = try {
        val pcm = fabriquer(type)
        val piste = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(TAUX)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setTransferMode(AudioTrack.MODE_STATIC)
            .setBufferSizeInBytes(pcm.size * 2)
            .build()
        piste.write(pcm, 0, pcm.size)
        piste.play()
        val dureeMs = pcm.size * 1000L / TAUX + 200
        Thread {
            try {
                Thread.sleep(dureeMs)
                piste.release()
            } catch (e: Exception) {
            }
        }.start()
        true
    } catch (e: Exception) {
        false
    }
}
