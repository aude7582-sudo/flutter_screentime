// Rappel 10 min avant le créneau : fenêtre élargie + réveil précis pour le prochain rappel.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,()=>b);}
  rep(`        if (dans < 1 || dans > 10) continue;`, `        if (dans < 1 || dans > 15) continue;`);
  rep(`    // Liste vide = tout bloquer pour le plugin : on met une appli fictive.`, `    // Réveil précis pour le prochain rappel (10 min avant le prochain
    // créneau) : le réveil « toutes les minutes » peut être retardé par Android.
    DateTime? prochain;
    for (final cr in crens) {
      if ((cr['paquets'] as List).isEmpty) continue;
      final deb = cr['debut'] as int;
      final jours = cr['jours'] as List<String>;
      for (var j = 0; j < 8; j++) {
        final minuit = DateTime(now.year, now.month, now.day).add(Duration(days: j));
        final rappel = minuit.add(Duration(minutes: deb - 10));
        if (!rappel.isAfter(now.add(const Duration(seconds: 30)))) continue;
        final debut = minuit.add(Duration(minutes: deb));
        if (!jours.contains(noms[debut.weekday - 1])) continue;
        if (prochain == null || rappel.isBefore(prochain)) prochain = rappel;
        break;
      }
    }
    if (prochain != null) {
      await AndroidAlarmManager.oneShotAt(prochain, 7311, lexiTick,
          exact: true,
          wakeup: true,
          allowWhileIdle: true,
          rescheduleOnReboot: true);
    }
  } catch (_) {}
  try {
    // Liste vide = tout bloquer pour le plugin : on met une appli fictive.`);
  window._rapR=R; return c;
})
