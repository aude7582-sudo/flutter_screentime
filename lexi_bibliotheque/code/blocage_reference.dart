// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/auth/firebase_auth/auth_util.dart';
import '/app_state.dart';
import 'dart:ui' show DartPluginRegistrant;
import 'package:flutter_screentime/flutter_screentime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:installed_apps/installed_apps.dart';

// Blocage Léxi.
// mode :
//  'verifier'  : les autorisations Android sont-elles accordées ?
//  'autoriser' : ouvre les réglages Android pour les accorder
//  'demarrer'  : comme 'planifier', mais demande les autorisations si besoin
//  'planifier' : relit le planning + les applis et programme le blocage
//  'arreter'   : défi réussi aujourd'hui (débloque après l'heure de fin)
//  'urgence'   : débloque tout de suite, pour aujourd'hui
//
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Blocage Léxi.
///
/// mode : 'verifier'  : les autorisations Android sont-elles accordées ?
/// 'autoriser' : ouvre les réglages Android pour les accorder 'demarrer'  :
/// comme 'planifier', mais demande les autorisations si besoin 'planifier' :
/// relit le planning + les applis et programme le blocage 'arreter'   : défi
/// réussi aujourd'hui (débloque après l'heure de fin) 'urgence'   : débloque
/// tout de suite, pour aujourd'hui
///
/// Règle (les 3 modes) : les jours choisis, à partir de l'heure de début, les
/// applis sont bloquées. Elles ne se débloquent que quand l'heure de fin est
/// passée ET que le défi du jour est réussi. - Mode Léxi ('lexi')  : applis
/// cochées par l'utilisateur - Mode Focus ('temp') : jeux, vidéos et réseaux
/// sociaux, d'office - Les deux ('deux')   : jeux, vidéos, réseaux sociaux +
/// applis cochées
Future<bool> lexiBlocage(String? mode) async {
  const st = FlutterScreentime();
  try {
    // Essai gratuit termine et pas Pro : plus de blocage des applis.
    if (mode != 'verifier' &&
        mode != 'autoriser' &&
        mode != 'supprimer' &&
        mode != 'theme') {
      if (await lexiAcces() < 0) {
        if (mode == 'etat') {
          await lexiBlocage('supprimer');
          return false;
        }
        mode = 'supprimer';
      }
    }
    if (mode == 'verifier') {
      final s = await st.checkAuthorization();
      return s == ScreenTimeAuthorizationStatus.approved;
    }
    if (mode == 'autoriser') {
      final s = await st.requestAuthorization();
      return s == ScreenTimeAuthorizationStatus.approved;
    }
    if (mode == 'etat') {
      return await lexiTick();
    }
    if (mode == 'arreter' || mode == 'urgence') {
      final p = await SharedPreferences.getInstance();
      await p.setString(mode == 'arreter' ? 'lexi_defi' : 'lexi_urgence',
          _lexiJour(DateTime.now()));
      await lexiTick();
      return true;
    }

    if (mode == 'supprimer') {
      try {
        await st.lexiVeille(actif: false);
      } catch (_) {}
      // Compte supprimé : on arrête tout le blocage.
      final p = await SharedPreferences.getInstance();
      for (final k in [
        'lexi_paquets',
        'lexi_jours',
        'lexi_debut',
        'lexi_fin',
        'lexi_defi',
        'lexi_urgence'
      ]) {
        await p.remove(k);
      }
      try {
        await AndroidAlarmManager.cancel(7310);
      } catch (_) {}
      try {
        await st.setBlockedPackages(const <String>['lexi.aucune.appli']);
        await st.stopBlocking();
      } catch (_) {}
      return true;
    }

    if (mode == 'theme') {
      // Réapplique le thème choisi dans Réglages (auto / clair / sombre).
      final p = await SharedPreferences.getInstance();
      final t = p.getString('lexi_theme') ?? 'manuel';
      bool? sombre;
      if (t == 'auto') {
        sombre =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark;
      } else if (t == 'sombre') {
        sombre = true;
      } else if (t == 'clair') {
        sombre = false;
      }
      final s = sombre;
      if (s != null && FFAppState().isDarkMode != s) {
        FFAppState().update(() => FFAppState().isDarkMode = s);
      }
      return true;
    }

    // 'demarrer' ou 'planifier'
    final etat = await st.checkAuthorization();
    if (etat != ScreenTimeAuthorizationStatus.approved) {
      if (mode == 'demarrer') await st.requestAuthorization();
      return false;
    }
    if (mode == 'demarrer') {
      try {
        await st.lexiDemanderNotifications();
      } catch (_) {}
    }
    final uid = currentUserUid;
    if (uid.isEmpty) return false;
    final db = FirebaseFirestore.instance;

    final s = await db
        .collection('user_stats')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    final d = s.docs.isEmpty ? <String, dynamic>{} : s.docs.first.data();
    final modePlan = (d['planMode'] ?? 'lexi').toString();
    final j = d['planDays'];
    final jours = (j is List && j.isNotEmpty)
        ? j.map((e) => '$e').toList()
        : <String>['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];
    final debut = (d['planStart'] ?? '09:00').toString();
    final fin = (d['planEnd'] ?? '12:00').toString();
    final defi = (d['lastChallengeDate'] ?? '').toString();

    final a = await db.collection('apps').where('uid', isEqualTo: uid).get();
    final paquets = <String>{};
    for (final doc in a.docs) {
      final x = doc.data();
      final p = (x['packageId'] ?? '').toString();
      if (p.isEmpty) continue;
      final cat = (x['category'] ?? '').toString();
      final auto = cat == 'Social Networking' ||
          cat == 'Gaming Platform' ||
          cat == 'Video Streaming';
      final coche = x['isBlocked'] == true;
      final garder = modePlan == 'temp'
          ? auto
          : (modePlan == 'deux' ? (auto || coche) : coche);
      if (garder) paquets.add(p);
    }

    // Rappel après X minutes sur les applis qui distraient (hors blocage).
    try {
      final veillePk = <String>{};
      for (final doc in a.docs) {
        final x = doc.data();
        final p = (x['packageId'] ?? '').toString();
        if (p.isEmpty || _lexiEssentiel(p)) continue;
        final cat = (x['category'] ?? '').toString();
        if (x['isBlocked'] == true ||
            cat == 'Social Networking' ||
            cat == 'Gaming Platform' ||
            cat == 'Video Streaming') veillePk.add(p);
      }
      final veilleOn = d['rappelUsage'] != false;
      final minutesV = int.tryParse('${d['rappelUsageMin'] ?? 15}') ?? 15;
      await st.lexiVeille(
          actif: veilleOn && veillePk.isNotEmpty,
          minutes: minutesV,
          packages: veillePk.toList());
    } catch (_) {}

    // Mode Focus complet : tout le téléphone est bloqué sauf Téléphone,
    // Messages, Horloge (et Réglages, pour ne jamais rester coincé).
    final focusComplet = d['focusComplet'] == true && modePlan != 'lexi';
    if (focusComplet) {
      try {
        final installees = await InstalledApps.getInstalledApps(
          excludeSystemApps: false,
          excludeNonLaunchableApps: true,
          withIcon: false,
          detectPlatformType: false,
        );
        for (final a in installees) {
          final pk = a.packageName;
          if (pk.isNotEmpty && !_lexiEssentiel(pk)) paquets.add(pk);
        }
      } catch (_) {}
      for (final doc in a.docs) {
        final pk = (doc.data()['packageId'] ?? '').toString();
        if (pk.isNotEmpty && !_lexiEssentiel(pk)) paquets.add(pk);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('lexi_jours', jours);
    await prefs.setString('lexi_debut', debut);
    await prefs.setString('lexi_fin', fin);
    await prefs.setString('lexi_plan_mode', modePlan);
    await prefs.setStringList('lexi_paquets', paquets.toList());
    if (defi.isNotEmpty) await prefs.setString('lexi_defi', defi);
    await prefs.setBool('lexi_rappels', d['remindersOn'] != false);
    await prefs.setString(
        'lexi_rappel_heure', (d['reminderTime'] ?? '19:00').toString());

    await st.configureBlockScreen(modePlan == 'temp'
        ? ScreenTimeBlockScreenConfig(
            title: '🔒\nConcentration en cours',
            message: 'Tes applis reviennent automatiquement à $fin.'
                '\n\nCourage, tu y es presque ! 💪',
            backgroundColorHex: '#14112B',
            textColorHex: '#FFFFFF',
          )
        : ScreenTimeBlockScreenConfig(
            title: '🔒\nPas encore !',
            message: 'Passe ta leçon et ton défi Léxi pour débloquer cette appli.'
                '\n\nBloquée au moins jusqu\'à $fin',
            backgroundColorHex: '#14112B',
            textColorHex: '#FFFFFF',
            primaryButtonLabel: 'Ouvrir Léxi 🦊',
          ));

    await lexiTick();
    await st.startBlocking();

    // Vérifie toutes les minutes (même app fermée) s'il faut bloquer.
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 1),
      7310,
      lexiTick,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );
    return paquets.isNotEmpty;
  } catch (e) {
    return false;
  }
}

String _lexiJour(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

int _lexiMinutes(String h) {
  final p = h.split(':');
  final hh = int.tryParse(p[0]) ?? 0;
  final mm = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;
  return hh * 60 + mm;
}

// Appelée par le réveil Android toutes les minutes (et par l'appli).
@pragma('vm:entry-point')
Future<bool> lexiTick() async {
  try {
    DartPluginRegistrant.ensureInitialized();
  } catch (_) {}
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final paquets = prefs.getStringList('lexi_paquets') ?? <String>[];
  final jours = prefs.getStringList('lexi_jours') ?? <String>[];
  final debut = _lexiMinutes(prefs.getString('lexi_debut') ?? '09:00');
  final fin = _lexiMinutes(prefs.getString('lexi_fin') ?? '12:00');
  final now = DateTime.now();
  const noms = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final auj = _lexiJour(now);
  final m = now.hour * 60 + now.minute;
  final defiFait = prefs.getString('lexi_defi') == auj;
  final urgence = prefs.getString('lexi_urgence') == auj;
  // Mode Focus : pas de défi, tout se débloque à l'heure de fin.
  final sansDefi = prefs.getString('lexi_plan_mode') == 'temp';
  final actif = paquets.isNotEmpty &&
      !urgence &&
      jours.contains(noms[now.weekday - 1]) &&
      m >= debut &&
      (m < fin || (!defiFait && !sansDefi));
  // Notifications de rappel (même appli fermée).
  try {
    if (prefs.getBool('lexi_rappels') ?? true) {
      const st = FlutterScreentime();
      final heureFin = prefs.getString('lexi_fin') ?? '';
      final avant = prefs.getBool('lexi_actif_avant') ?? false;
      if (actif && !avant) {
        await st.lexiNotifier(201, '🔒 C\'est l\'heure de te concentrer',
            'Tes applis sont bloquées au moins jusqu\'à $heureFin. Courage ! 🦊');
      }
      // Fin d'une séance Focus : « Bravo ! » (notification + écran du renard).
      if (sansDefi &&
          avant &&
          !actif &&
          !urgence &&
          m >= fin &&
          prefs.getString('lexi_notif_bravo') != auj) {
        await prefs.setString('lexi_notif_bravo', auj);
        await prefs.setInt('lexi_bravo_jusqua',
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch);
        await prefs.setInt('lexi_bravo_minutes', fin - debut);
        await st.lexiNotifier(204, '🎉 Bravo ! Concentration terminée',
            'Tu as tenu jusqu\'au bout. Tu peux retrouver tes applis 💪');
      }
      if (actif &&
          !sansDefi &&
          m >= fin &&
          !defiFait &&
          prefs.getString('lexi_notif_fin') != auj) {
        await prefs.setString('lexi_notif_fin', auj);
        await st.lexiNotifier(202, '⏰ C\'est l\'heure de ta leçon !',
            'Fais ta leçon et ton défi Léxi pour débloquer tes applis 🦊');
      }
      final rappel =
          _lexiMinutes(prefs.getString('lexi_rappel_heure') ?? '19:00');
      if (!sansDefi &&
          m >= rappel &&
          m < rappel + 120 &&
          !defiFait &&
          prefs.getString('lexi_notif_rappel') != auj) {
        await prefs.setString('lexi_notif_rappel', auj);
        await st.lexiNotifier(203, '🦊 Ta leçon d\'anglais t\'attend',
            'Quelques minutes suffisent pour garder ta série !');
      }
    }
    await prefs.setBool('lexi_actif_avant', actif);
  } catch (_) {}
  try {
    const st = FlutterScreentime();
    // Liste vide = tout bloquer pour le plugin : on met une appli fictive.
    await st.setBlockedPackages(
        actif ? paquets : const <String>['lexi.aucune.appli']);
  } catch (_) {}
  return actif;
}

// Applis jamais bloquées en Mode Focus complet.
bool _lexiEssentiel(String p) {
  final x = p.toLowerCase();
  const garder = [
    'dialer',
    'phone',
    'contacts',
    'incallui',
    'telecom',
    'mms',
    'messaging',
    'message',
    'sms',
    'clock',
    'alarm',
    'launcher',
    'home',
    'settings',
    'lexi',
  ];
  return garder.any(x.contains);
}
