// Notification « Ton ami te défie » même appli fermée (vérifié par le réveil Léxi toutes les 10 min).
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`import 'dart:convert';
`,`import 'dart:convert';
import 'package:firebase_core/firebase_core.dart' as lxfc;
import 'package:firebase_auth/firebase_auth.dart' as lxfa;
`);
  rep(`  try {
    await prefs.setStringList('lexi_actifs', actifs);`,`  try {
    await _lexiDefisRecus(prefs, st);
  } catch (_) {}
  try {
    await prefs.setStringList('lexi_actifs', actifs);`);
  c = c.replace(/\s*$/, '\n') + `
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

  int ms(dynamic v) => v is num ? v.toInt() : int.tryParse('\$v') ?? 0;

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
        nouveaux[d.id] = '\$nom te lance un Duel du Silence ⏳';
      } else {
        nouveaux[d.id] = '\$nom te défie à un jeu 🎮';
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
      nouveaux[d.id] = '\$nom te lance un Duel du Silence ⏳';
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
    await st.lexiNotifier(230, '⚔️ \${aMontrer.length} nouveaux défis !',
        nouveaux[aMontrer.first]! + '… Ouvre Léxi pour les relever 🦊');
  }
}
`;
  window._ndR=R; return c;
})
