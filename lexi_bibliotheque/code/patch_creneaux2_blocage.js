// Créneaux phase 2 (lexiBlocage) : pause de 5 min, stats par créneau, XP à gagner.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`  final urgence = prefs.getString('lexi_urgence');
`,`  final urgence = prefs.getString('lexi_urgence');
  // Pause de 5 min : « nom du créneau|fin de la pause (ms) ».
  final pauseTxt = prefs.getString('lexi_pause') ?? '';
  final pauseNom = pauseTxt.contains('|') ? pauseTxt.split('|').first : '';
  final pauseJusqua =
      pauseTxt.contains('|') ? int.tryParse(pauseTxt.split('|').last) ?? 0 : 0;
  final maintenantMs = now.millisecondsSinceEpoch;
`);
  rep(`    if (urgence == auj || urgence == jour) continue;
`,`    if (urgence == auj || urgence == jour) continue;
    if (pauseNom.isNotEmpty &&
        pauseNom == c['nom'] &&
        maintenantMs < pauseJusqua) continue;
`);
  rep(`        final i = int.parse(k.split('@').first);
        final c = crens[i];
`,`        final i = int.parse(k.split('@').first);
        final c = crens[i];
        if (pauseNom.isNotEmpty &&
            pauseNom == c['nom'] &&
            pauseJusqua > 0 &&
            maintenantMs >= pauseJusqua) {
          await prefs.remove('lexi_pause');
          await st.lexiNotifier(201, '▶️ Fin de la pause',
              'Tes applis sont de nouveau bloquées. Courage ! 🦊');
          continue;
        }
`);
  rep(`        // Seulement si le créneau s'est fini à son heure (pas modifié).
        if ((m - fin + 1440) % 1440 > 30) continue;
        if (urgence == auj) continue;
        final duree = (fin - deb + 1440) % 1440;
`,`        // Pendant une pause, le créneau n'est pas fini.
        if (pauseNom.isNotEmpty &&
            pauseNom == c['nom'] &&
            maintenantMs < pauseJusqua) continue;
        // Seulement si le créneau s'est fini à son heure (pas modifié),
        // ou si le défi Léxi a été réussi.
        final finiALHeure = (m - fin + 1440) % 1440 <= 30;
        final defiReussi = (mode == 'lexi' || mode == 'deux') && defiFait;
        if (!finiALHeure && !defiReussi) continue;
        if (urgence == auj) continue;
        final duree = (fin - deb + 1440) % 1440;
        final gain =
            await _lexiNoterCreneau(prefs, c['nom'] as String, k, duree);
`);
  rep(`'Tu as tenu jusqu\\'au bout (\${_lexiDuree(duree)}). Tu peux retrouver tes applis 💪');`,
      `'Tu as tenu jusqu\\'au bout (\${_lexiDuree(duree)}). Tu peux retrouver tes applis 💪' +
                  (gain > 0 ? ' +\$gain XP 🎁' : ''));`);
  c = c.replace(/\s*$/, '\n') + `
// ---------------------------------------------------------------------------
// Créneau réussi : statistiques par créneau + XP gagnés (ajoutés au profil
// à la prochaine ouverture du Planning).
Future<int> _lexiNoterCreneau(
    SharedPreferences prefs, String nom, String cle, int duree) async {
  try {
    final deja = prefs.getStringList('lexi_stats_vus') ?? <String>[];
    if (deja.contains(cle)) return 0;
    deja.add(cle);
    await prefs.setStringList('lexi_stats_vus',
        deja.length > 40 ? deja.sublist(deja.length - 40) : deja);
    final stats = Map<String, dynamic>.from(
        jsonDecode(prefs.getString('lexi_stats_cren') ?? '{}') as Map);
    final s = Map<String, dynamic>.from((stats[nom] as Map?) ?? {});
    s['n'] = ((s['n'] as num?) ?? 0).toInt() + 1;
    s['min'] = ((s['min'] as num?) ?? 0).toInt() + duree;
    stats[nom] = s;
    await prefs.setString('lexi_stats_cren', jsonEncode(stats));
    final gain = 10 + (duree ~/ 6).clamp(0, 40).toInt();
    await prefs.setInt(
        'lexi_xp_attente', (prefs.getInt('lexi_xp_attente') ?? 0) + gain);
    return gain;
  } catch (_) {
    return 0;
  }
}
`;
  window._c2bR=R; return c;
})
