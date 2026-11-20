// Mode Focus : pas de défi, déblocage à l'heure de fin + écran Bravo.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`    await prefs.setString('lexi_fin', fin);
`,`    await prefs.setString('lexi_fin', fin);
    await prefs.setString('lexi_plan_mode', modePlan);
`);
  rep(`    await st.configureBlockScreen(ScreenTimeBlockScreenConfig(
      title: '🔒\\nPas encore !',
      message: 'Passe ta leçon et ton défi Léxi pour débloquer cette appli.'
          '\\n\\nBloquée au moins jusqu\\'à $fin',
      backgroundColorHex: '#14112B',
      textColorHex: '#FFFFFF',
      primaryButtonLabel: 'Ouvrir Léxi 🦊',
    ));`,`    await st.configureBlockScreen(modePlan == 'temp'
        ? ScreenTimeBlockScreenConfig(
            title: '🔒\\nConcentration en cours',
            message: 'Tes applis reviennent automatiquement à $fin.'
                '\\n\\nCourage, tu y es presque ! 💪',
            backgroundColorHex: '#14112B',
            textColorHex: '#FFFFFF',
          )
        : ScreenTimeBlockScreenConfig(
            title: '🔒\\nPas encore !',
            message: 'Passe ta leçon et ton défi Léxi pour débloquer cette appli.'
                '\\n\\nBloquée au moins jusqu\\'à $fin',
            backgroundColorHex: '#14112B',
            textColorHex: '#FFFFFF',
            primaryButtonLabel: 'Ouvrir Léxi 🦊',
          ));`);
  rep(`  final urgence = prefs.getString('lexi_urgence') == auj;
  final actif = paquets.isNotEmpty &&
      !urgence &&
      jours.contains(noms[now.weekday - 1]) &&
      m >= debut &&
      (m < fin || !defiFait);`,`  final urgence = prefs.getString('lexi_urgence') == auj;
  // Mode Focus : pas de défi, tout se débloque à l'heure de fin.
  final sansDefi = prefs.getString('lexi_plan_mode') == 'temp';
  final actif = paquets.isNotEmpty &&
      !urgence &&
      jours.contains(noms[now.weekday - 1]) &&
      m >= debut &&
      (m < fin || (!defiFait && !sansDefi));`);
  rep(`      if (actif &&
          m >= fin &&
          !defiFait &&
          prefs.getString('lexi_notif_fin') != auj) {`,`      // Fin d'une séance Focus : « Bravo ! » (notification + écran du renard).
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
            'Tu as tenu jusqu\\'au bout. Tu peux retrouver tes applis 💪');
      }
      if (actif &&
          !sansDefi &&
          m >= fin &&
          !defiFait &&
          prefs.getString('lexi_notif_fin') != auj) {`);
  rep(`      if (m >= rappel &&
          m < rappel + 120 &&
          !defiFait &&`,`      if (!sansDefi &&
          m >= rappel &&
          m < rappel + 120 &&
          !defiFait &&`);
  window._focR=R; return c;
})
