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
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart' as lxfc;
import 'package:firebase_auth/firebase_auth.dart' as lxfa;

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
    // Essai terminé sans Léxi Pro : 1 seul créneau (voir 'planifier').
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
        'lexi_urgence',
        'lexi_creneaux',
        'lexi_actifs',
        'lexi_ecran',
        'lexi_creneau_actif'
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
    // Après l'essai sans Léxi Pro : 1 seul créneau. Essai ou Pro : jusqu'à 5.
    final acces = await lexiAcces();
    final limite = acces < 0 ? 1 : 5;
    final defi = (d['lastChallengeDate'] ?? '').toString();

    final a = await db.collection('apps').where('uid', isEqualTo: uid).get();
    final distrait = <String>{};
    final coches = <String>{};
    for (final doc in a.docs) {
      final x = doc.data();
      final p = (x['packageId'] ?? '').toString();
      if (p.isEmpty) continue;
      final cat = (x['category'] ?? '').toString();
      if (cat == 'Social Networking' ||
          cat == 'Gaming Platform' ||
          cat == 'Video Streaming') distrait.add(p);
      if (x['isBlocked'] == true) coches.add(p);
    }

    // Rappel après X minutes sur les applis qui distraient (hors blocage).
    try {
      final veillePk = <String>{};
      for (final p in {...distrait, ...coches}) {
        if (!_lexiEssentiel(p)) veillePk.add(p);
      }
      final veilleOn = d['rappelUsage'] != false;
      final minutesV = int.tryParse('${d['rappelUsageMin'] ?? 15}') ?? 15;
      await st.lexiVeille(
          actif: veilleOn && veillePk.isNotEmpty,
          minutes: minutesV,
          packages: veillePk.toList());
    } catch (_) {}

    // Tout le téléphone sauf Téléphone, Messages, Horloge (et Réglages,
    // pour ne jamais rester coincé) : Mode Focus complet et mode Sommeil.
    Set<String>? toutCache;
    Future<Set<String>> toutLeTel() async {
      if (toutCache != null) return toutCache!;
      final r = <String>{};
      try {
        final installees = await InstalledApps.getInstalledApps(
          excludeSystemApps: false,
          excludeNonLaunchableApps: true,
          withIcon: false,
          detectPlatformType: false,
        );
        for (final x in installees) {
          final pk = x.packageName;
          if (pk.isNotEmpty && !_lexiEssentiel(pk)) r.add(pk);
        }
      } catch (_) {}
      for (final doc in a.docs) {
        final pk = (doc.data()['packageId'] ?? '').toString();
        if (pk.isNotEmpty && !_lexiEssentiel(pk)) r.add(pk);
      }
      toutCache = r;
      return r;
    }

    final focusComplet = d['focusComplet'] == true;
    final crens = _lexiCreneauxDe(d);
    final liste = <Map<String, dynamic>>[];
    for (var i = 0; i < crens.length && i < limite; i++) {
      final c = crens[i];
      final m = c['mode'] as String;
      final ap = c['applis'];
      final perso = (ap is List && ap.isNotEmpty)
          ? ap.map((e) => '$e').toSet()
          : null;
      final pk = <String>{};
      if (m == 'sommeil') {
        pk.addAll(await toutLeTel());
      } else {
        if (m == 'temp') {
          pk.addAll(perso ?? distrait);
        } else if (m == 'deux') {
          pk.addAll(distrait);
          pk.addAll(perso ?? coches);
        } else {
          pk.addAll(perso ?? coches);
        }
        if (focusComplet && m != 'lexi') pk.addAll(await toutLeTel());
      }
      pk.removeWhere((p) => p.contains('lexi') && p.contains('veroli'));
      liste.add({
        'nom': c['nom'],
        'debut': _lexiMinutes(c['debut'] as String),
        'fin': _lexiMinutes(c['fin'] as String),
        'jours': c['jours'],
        'mode': m,
        'paquets': pk.toList(),
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lexi_creneaux', jsonEncode(liste));
    // Anciennes clés (1er créneau), gardées pour compatibilité.
    if (crens.isNotEmpty) {
      await prefs.setStringList(
          'lexi_jours', (crens.first['jours'] as List).cast<String>());
      await prefs.setString('lexi_debut', crens.first['debut'] as String);
      await prefs.setString('lexi_fin', crens.first['fin'] as String);
      await prefs.setString('lexi_plan_mode', crens.first['mode'] as String);
    }
    final tous = <String>{};
    for (final c in liste) {
      tous.addAll((c['paquets'] as List).cast<String>());
    }
    await prefs.setStringList('lexi_paquets', tous.toList());
    if (defi.isNotEmpty) await prefs.setString('lexi_defi', defi);
    await prefs.setBool('lexi_rappels', d['remindersOn'] != false);
    await prefs.setString(
        'lexi_rappel_heure', (d['reminderTime'] ?? '19:00').toString());
    // Force la mise à jour de l'écran de blocage au prochain passage.
    await prefs.remove('lexi_ecran');

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
    return tous.isNotEmpty;
  } catch (e) {
    return false;
  }
}

/// Créneaux du planning (liste `planCreneaux` de user_stats, ou ancien
/// planning unique). Chaque créneau : nom, debut, fin ('HH:MM'), jours,
/// mode ('lexi' | 'temp' | 'deux' | 'sommeil'), applis (liste ou null).
List<Map<String, dynamic>> _lexiCreneauxDe(Map<String, dynamic> d) {
  final r = <Map<String, dynamic>>[];
  final h = RegExp(r'^\d{2}:\d{2}$');
  const modes = ['lexi', 'temp', 'deux', 'sommeil'];
  const tousJours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  List<String> joursDe(dynamic j) => (j is List && j.isNotEmpty)
      ? tousJours.where((x) => j.map((e) => '$e').contains(x)).toList()
      : <String>['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];
  final l = d['planCreneaux'];
  if (l is List && l.isNotEmpty) {
    for (final e in l) {
      if (e is! Map) continue;
      final deb = '${e['debut'] ?? ''}';
      final fin = '${e['fin'] ?? ''}';
      if (!h.hasMatch(deb) || !h.hasMatch(fin) || deb == fin) continue;
      final m = '${e['mode'] ?? 'lexi'}';
      final ap = e['applis'];
      r.add({
        'nom': '${e['nom'] ?? ''}'.trim().isEmpty
            ? 'Créneau ${r.length + 1}'
            : '${e['nom']}'.trim(),
        'debut': deb,
        'fin': fin,
        'jours': joursDe(e['jours']),
        'mode': modes.contains(m) ? m : 'lexi',
        'applis': ap is List ? ap.map((x) => '$x').toList() : null,
      });
    }
    return r;
  }
  final m = '${d['planMode'] ?? 'lexi'}';
  final deb = '${d['planStart'] ?? '09:00'}';
  final fin = '${d['planEnd'] ?? '12:00'}';
  r.add({
    'nom': 'Mon créneau',
    'debut': h.hasMatch(deb) ? deb : '09:00',
    'fin': h.hasMatch(fin) ? fin : '12:00',
    'jours': joursDe(d['planDays']),
    'mode': modes.contains(m) ? m : 'lexi',
    'applis': null,
  });
  return r;
}

String _lexiJour(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

int _lexiMinutes(String h) {
  final p = h.split(':');
  final hh = int.tryParse(p[0]) ?? 0;
  final mm = p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0;
  return hh * 60 + mm;
}


String _lexiHHMM(int m) =>
    '${(m ~/ 60 % 24).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

String _lexiDuree(int min) {
  final h = min ~/ 60;
  final r = min % 60;
  if (h == 0) return '$r min';
  return r == 0 ? '$h h' : '$h h ${r.toString().padLeft(2, '0')}';
}

// Créneaux enregistrés dans le téléphone (ou ancien planning unique).
List<Map<String, dynamic>> _lexiLire(SharedPreferences prefs) {
  final r = <Map<String, dynamic>>[];
  final t = prefs.getString('lexi_creneaux');
  if (t != null && t.isNotEmpty) {
    try {
      for (final e in jsonDecode(t) as List) {
        final c = Map<String, dynamic>.from(e as Map);
        r.add({
          'nom': '${c['nom'] ?? ''}',
          'debut': (c['debut'] as num).toInt(),
          'fin': (c['fin'] as num).toInt(),
          'jours': (c['jours'] as List).map((x) => '$x').toList(),
          'mode': '${c['mode'] ?? 'lexi'}',
          'paquets': (c['paquets'] as List).map((x) => '$x').toList(),
        });
      }
      return r;
    } catch (_) {
      r.clear();
    }
  }
  final paquets = prefs.getStringList('lexi_paquets') ?? <String>[];
  if (paquets.isEmpty) return r;
  r.add({
    'nom': 'Mon créneau',
    'debut': _lexiMinutes(prefs.getString('lexi_debut') ?? '09:00'),
    'fin': _lexiMinutes(prefs.getString('lexi_fin') ?? '12:00'),
    'jours': prefs.getStringList('lexi_jours') ?? <String>[],
    'mode': prefs.getString('lexi_plan_mode') ?? 'lexi',
    'paquets': paquets,
  });
  return r;
}

// Appelée par le réveil Android toutes les minutes (et par l'appli).
@pragma('vm:entry-point')
Future<bool> lexiTick() async {
  try {
    DartPluginRegistrant.ensureInitialized();
  } catch (_) {}
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final crens = _lexiLire(prefs);
  final now = DateTime.now();
  const noms = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final auj = _lexiJour(now);
  final hier = _lexiJour(now.subtract(const Duration(days: 1)));
  final demain = _lexiJour(now.add(const Duration(days: 1)));
  final nAuj = noms[now.weekday - 1];
  final nHier = noms[(now.weekday + 5) % 7];
  final nDemain = noms[now.weekday % 7];
  final m = now.hour * 60 + now.minute;
  final defiFait = prefs.getString('lexi_defi') == auj;
  final urgence = prefs.getString('lexi_urgence');

  // Créneaux en cours (un créneau qui passe minuit appartient au jour
  // où il commence).
  final actifs = <String>[];
  final paquets = <String>{};
  int? principal;
  var principalDefi = false;
  for (var i = 0; i < crens.length; i++) {
    final c = crens[i];
    final deb = c['debut'] as int;
    final fin = c['fin'] as int;
    final jours = c['jours'] as List<String>;
    final mode = c['mode'] as String;
    final sansDefi = mode == 'temp' || mode == 'sommeil';
    String? jour;
    var attenteDefi = false;
    if (fin > deb) {
      if (jours.contains(nAuj) && m >= deb) {
        if (m < fin) {
          jour = auj;
        } else if (!sansDefi && !defiFait) {
          jour = auj;
          attenteDefi = true;
        }
      }
    } else {
      if (jours.contains(nAuj) && m >= deb) {
        jour = auj;
      } else if (jours.contains(nHier) && m < fin) {
        jour = hier;
      }
    }
    if (jour == null) continue;
    if (urgence == auj || urgence == jour) continue;
    final pk = c['paquets'] as List<String>;
    if (pk.isEmpty) continue;
    actifs.add('$i@$jour');
    paquets.addAll(pk);
    if (principal == null || (principalDefi && !attenteDefi)) {
      principal = i;
      principalDefi = attenteDefi;
    }
  }
  final actif = paquets.isNotEmpty;
  const st = FlutterScreentime();

  // Écran de blocage adapté au créneau en cours.
  try {
    final p = principal;
    if (p != null) {
      final c = crens[p];
      final mode = c['mode'] as String;
      final nom = c['nom'] as String;
      final fin = _lexiHHMM(c['fin'] as int);
      final cle = '$p|$mode|$fin|$nom';
      if (prefs.getString('lexi_ecran') != cle) {
        await st.configureBlockScreen(mode == 'sommeil'
            ? ScreenTimeBlockScreenConfig(
                title: '🌙\nBonne nuit',
                message: 'C\'est l\'heure de dormir.'
                    '\nTes applis reviennent à $fin.'
                    '\n\nTéléphone, messages et réveil restent disponibles.',
                backgroundColorHex: '#0E0B24',
                textColorHex: '#FFFFFF',
              )
            : mode == 'temp'
                ? ScreenTimeBlockScreenConfig(
                    title: '🔒\nConcentration en cours',
                    message: '$nom · Tes applis reviennent automatiquement'
                        ' à $fin.\n\nCourage, tu y es presque ! 💪',
                    backgroundColorHex: '#14112B',
                    textColorHex: '#FFFFFF',
                  )
                : ScreenTimeBlockScreenConfig(
                    title: '🔒\nPas encore !',
                    message:
                        'Passe ta leçon et ton défi Léxi pour débloquer cette appli.'
                        '\n\nBloquée au moins jusqu\'à $fin',
                    backgroundColorHex: '#14112B',
                    textColorHex: '#FFFFFF',
                    primaryButtonLabel: 'Ouvrir Léxi 🦊',
                  ));
        await prefs.setString('lexi_ecran', cle);
      }
    }
  } catch (_) {}

  // Notifications (même appli fermée).
  try {
    if (prefs.getBool('lexi_rappels') ?? true) {
      final avant = prefs.getStringList('lexi_actifs') ?? <String>[];
      // Début d'un créneau.
      for (final k in actifs) {
        if (avant.contains(k)) continue;
        final i = int.parse(k.split('@').first);
        final c = crens[i];
        final mode = c['mode'] as String;
        final nom = c['nom'] as String;
        final fin = _lexiHHMM(c['fin'] as int);
        if (mode == 'sommeil') {
          await st.lexiNotifier(201, '🌙 Bonne nuit !',
              'C\'est l\'heure de dormir. Tes applis reviennent à $fin. Téléphone, messages et réveil restent disponibles.');
        } else if (mode == 'temp') {
          await st.lexiNotifier(201, '🔒 $nom : c\'est parti',
              'Tes applis sont bloquées jusqu\'à $fin. Courage ! 🦊');
        } else {
          await st.lexiNotifier(201, '🔒 $nom : c\'est l\'heure',
              'Tes applis sont bloquées au moins jusqu\'à $fin. Courage ! 🦊');
        }
      }
      // Fin d'un créneau : « Bravo ! » (Focus) ou bilan du matin (Sommeil).
      for (final k in avant) {
        if (actifs.contains(k)) continue;
        final i = int.tryParse(k.split('@').first) ?? -1;
        if (i < 0 || i >= crens.length) continue;
        final c = crens[i];
        final mode = c['mode'] as String;
        final deb = c['debut'] as int;
        final fin = c['fin'] as int;
        // Seulement si le créneau s'est fini à son heure (pas modifié).
        if ((m - fin + 1440) % 1440 > 30) continue;
        if (urgence == auj) continue;
        final duree = (fin - deb + 1440) % 1440;
        if (mode == 'temp') {
          await prefs.setInt(
              'lexi_bravo_jusqua',
              DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch);
          await prefs.setInt('lexi_bravo_minutes', duree);
          await st.lexiNotifier(204, '🎉 Bravo ! ${c['nom']} terminé',
              'Tu as tenu jusqu\'au bout (${_lexiDuree(duree)}). Tu peux retrouver tes applis 💪');
        } else if (mode == 'sommeil') {
          await prefs.setString('lexi_nuit_jour', auj);
          await prefs.setInt('lexi_nuit_minutes', duree);
          await st.lexiNotifier(206, '☀️ Bonjour !',
              'Nuit sans écran réussie : ${_lexiDuree(duree)} de ${_lexiHHMM(deb)} à ${_lexiHHMM(fin)}. Bravo ! 🦊');
        }
      }
      // Défi Léxi à faire pour débloquer.
      final p = principal;
      if (p != null &&
          principalDefi &&
          prefs.getString('lexi_notif_fin') != auj) {
        await prefs.setString('lexi_notif_fin', auj);
        await st.lexiNotifier(202, '⏰ C\'est l\'heure de ta leçon !',
            'Fais ta leçon et ton défi Léxi pour débloquer tes applis 🦊');
      }
      // Rappel 10 minutes avant chaque créneau.
      for (var i = 0; i < crens.length; i++) {
        final c = crens[i];
        if ((c['paquets'] as List).isEmpty) continue;
        final deb = c['debut'] as int;
        final dans = (deb - m + 1440) % 1440;
        if (dans < 1 || dans > 10) continue;
        final leJour = deb > m ? auj : demain;
        final nom = deb > m ? nAuj : nDemain;
        if (!(c['jours'] as List).contains(nom)) continue;
        if (urgence == leJour) continue;
        final cle = '$i@$leJour';
        if (prefs.getString('lexi_notif_avant_$i') == cle) continue;
        await prefs.setString('lexi_notif_avant_$i', cle);
        final mode = c['mode'] as String;
        await st.lexiNotifier(
            220 + i,
            mode == 'sommeil'
                ? '🌙 Bientôt l\'heure de dormir'
                : '⏰ ${c['nom']} dans $dans min',
            mode == 'sommeil'
                ? 'À ${_lexiHHMM(deb)}, ton téléphone passe en mode nuit. Prépare-toi 😴'
                : 'À ${_lexiHHMM(deb)}, tes applis seront bloquées. Finis ce que tu fais 🦊');
      }
      // Rappel quotidien de la leçon (s'il y a un créneau Léxi).
      final aLecon =
          crens.any((c) => c['mode'] == 'lexi' || c['mode'] == 'deux');
      final rappel =
          _lexiMinutes(prefs.getString('lexi_rappel_heure') ?? '19:00');
      if (aLecon &&
          m >= rappel &&
          m < rappel + 120 &&
          !defiFait &&
          prefs.getString('lexi_notif_rappel') != auj) {
        await prefs.setString('lexi_notif_rappel', auj);
        await st.lexiNotifier(203, '🦊 Ta leçon d\'anglais t\'attend',
            'Quelques minutes suffisent pour garder ta série !');
      }
    }
  } catch (_) {}
  try {
    await _lexiDefisRecus(prefs, st);
  } catch (_) {}
  try {
    await prefs.setStringList('lexi_actifs', actifs);
    await prefs.setBool('lexi_actif_avant', actif);
    final p = principal;
    await prefs.setString(
        'lexi_creneau_actif', p == null ? '' : crens[p]['nom'] as String);
  } catch (_) {}
  try {
    // Liste vide = tout bloquer pour le plugin : on met une appli fictive.
    await st.setBlockedPackages(
        actif ? paquets.toList() : const <String>['lexi.aucune.appli']);
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

// ---------------------------------------------------------------------------
// Défis reçus : notification même quand Léxi est fermée.
// Vérifie au plus toutes les 10 minutes (2 petites lectures Firestore).

Future<void> _lexiDefisRecus(SharedPreferences prefs, FlutterScreentime st) async {
  if (!(prefs.getBool('lexi_notif_defis') ?? true)) return;
  final maintenant = DateTime.now().millisecondsSinceEpoch;
  final dernier = prefs.getInt('lexi_defis_verif') ?? 0;
  if (maintenant - dernier < 10 * 60000) return;
  await prefs.setInt('lexi_defis_verif', maintenant);

  try {
    if (lxfc.Firebase.apps.isEmpty) await lxfc.Firebase.initializeApp();
  } catch (_) {}
  var user = lxfa.FirebaseAuth.instance.currentUser;
  if (user == null) {
    try {
      user = await lxfa.FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((u) => u != null)
          .timeout(const Duration(seconds: 8));
    } catch (_) {}
  }
  final uid = user?.uid ?? '';
  if (uid.isEmpty) return;

  final db = FirebaseFirestore.instance;
  final vus = (prefs.getStringList('lexi_defis_vus') ?? <String>[]).toSet();
  final premiereFois = !prefs.containsKey('lexi_defis_vus');
  final nouveaux = <String, String>{};

  int ms(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  // Défis de jeu et Duels du Silence (Concours / Jouer).
  try {
    final s = await db
        .collection('duels')
        .where('pour', isEqualTo: uid)
        .where('statut', isEqualTo: 'attente')
        .get();
    for (final d in s.docs) {
      final x = d.data();
      if (maintenant - ms(x['cree']) > 2 * 86400000) continue;
      final nom = (x['deNom'] ?? 'Un ami').toString();
      if (x['type'] == 'silence') {
        nouveaux[d.id] = '$nom te lance un Duel du Silence ⏳';
      } else {
        nouveaux[d.id] = '$nom te défie à un jeu 🎮';
      }
    }
  } catch (_) {}

  // Duels du Silence (page Amis).
  try {
    final s = await db
        .collection('duels')
        .where('b', isEqualTo: uid)
        .where('statut', isEqualTo: 'propose')
        .get();
    for (final d in s.docs) {
      final x = d.data();
      if (maintenant - ms(x['cree']) > 2 * 86400000) continue;
      final nom = (x['pseudoA'] ?? 'Un ami').toString();
      nouveaux[d.id] = '$nom te lance un Duel du Silence ⏳';
    }
  } catch (_) {}

  final aMontrer = nouveaux.keys.where((k) => !vus.contains(k)).toList();
  vus.addAll(nouveaux.keys);
  // Garde seulement les défis encore en attente (la liste reste petite).
  await prefs.setStringList(
      'lexi_defis_vus', vus.where(nouveaux.containsKey).toList());
  // La toute première vérification sert juste à mémoriser l'existant.
  if (premiereFois || aMontrer.isEmpty) return;

  if (aMontrer.length == 1) {
    await st.lexiNotifier(230, '⚔️ ' + nouveaux[aMontrer.first]!,
        'Ouvre Léxi pour relever le défi 🦊');
  } else {
    await st.lexiNotifier(230, '⚔️ ${aMontrer.length} nouveaux défis !',
        nouveaux[aMontrer.first]! + '… Ouvre Léxi pour les relever 🦊');
  }
}
