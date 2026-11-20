// Jouer : « Comment jouer ? » expliqué avant la 1re partie de chaque jeu (+ bouton ❓).
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`import 'package:flutter_tts/flutter_tts.dart';
`,`import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
`);
  rep(`    setState(() {
      _jeu = id;
      _niveau = null;
    });
  }

  void _jouerNiveau(int n) {`,`    setState(() {
      _jeu = id;
      _niveau = null;
    });
    _lxReglesSiBesoin(context, id);
  }

  void _jouerNiveau(int n) {`);
  rep(`          Text('★ ' + _total(_jeu!).toString() + '/30',`,`          IconButton(
            tooltip: 'Comment jouer ?',
            onPressed: () => _lxMontrerRegles(context, _jeu!),
            icon: Icon(Icons.help_outline_rounded, color: p.texte, size: 24),
          ),
          Text('★ ' + _total(_jeu!).toString() + '/30',`);
  rep(`          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: widget.couleur.withOpacity(0.15),`,`          IconButton(
            tooltip: 'Comment jouer ?',
            onPressed: () => _lxMontrerRegles(context, widget.jeu),
            icon: Icon(Icons.help_outline_rounded, color: p.gris, size: 22),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: widget.couleur.withOpacity(0.15),`);
  rep(`    _graine = _entier(d['graine']);
`,`    await _lxReglesSiBesoin(context, d['jeu'].toString());
    if (!mounted) return;
    _graine = _entier(d['graine']);
`);
  c = c.replace(/\s*$/, '\n') + `
// ---------------------------------------------------------------------------
// Règles des jeux : montrées avant la 1re partie, et avec le bouton ❓.

const Map<String, List<Object>> _lxRegles = {
  'paires': [
    '🧩',
    'Paires',
    0xFF16A34A,
    [
      'À gauche, des mots dans la langue que tu apprends. À droite, leurs traductions, dans le désordre.',
      'Touche un mot, puis sa traduction. Si c\\'est juste, la paire devient verte.',
      'Relie toutes les paires. Moins tu fais d\\'erreurs, plus tu gagnes d\\'étoiles ⭐.',
    ],
    'Écoute bien : Léxi prononce le mot quand tu le touches.',
  ],
  'meles': [
    '🔤',
    'Mots mêlés',
    0xFF7C3AED,
    [
      'Des mots sont cachés dans la grille : en ligne, en colonne ou en diagonale, parfois à l\\'envers.',
      'Pour en entourer un, touche sa 1re lettre, puis sa dernière lettre.',
      'La liste en dessous te dit quels mots chercher. À partir du niveau 6, tu ne vois que leur traduction : à toi de trouver le mot !',
      'Trouve tous les mots. Plus tu es rapide, plus tu gagnes d\\'étoiles ⭐.',
    ],
    'Commence par les mots les plus longs, ils sont plus faciles à repérer.',
  ],
  'memoire': [
    '🃏',
    'Mémoire',
    0xFF0EA5E9,
    [
      'Au début, toutes les cartes sont montrées pendant 3 secondes (3, 2, 1) : mémorise-les !',
      'Ensuite elles se retournent. Chaque mot a une carte « traduction ».',
      'Retourne 2 cartes. Si c\\'est un mot et sa traduction, elles restent ouvertes. Sinon, elles se referment.',
      'Trouve toutes les paires en un minimum de coups pour gagner 3 étoiles ⭐.',
    ],
    'Retiens d\\'abord les cartes des coins, c\\'est plus facile.',
  ],
  'duel': [
    '⚡',
    'Duel éclair',
    0xFFF97316,
    [
      'Tu fais la course contre le renard 🦊 !',
      'Un mot s\\'affiche : touche sa bonne traduction parmi les réponses.',
      'Chaque bonne réponse te fait avancer. Le renard, lui, avance tout seul.',
      'Arrive au bout avant le renard et avant la fin du temps pour gagner.',
    ],
    'Ne réfléchis pas trop longtemps : la vitesse compte !',
  ],
  'lettres': [
    '🔠',
    'Lettres mélangées',
    0xFFDB2777,
    [
      'Les lettres d\\'un mot sont mélangées.',
      'Touche les lettres dans le bon ordre pour reformer le mot.',
      'Tu es bloqué ? Le bouton « Indice » t\\'aide (mais tu gagnes moins de points).',
    ],
    'Regarde la traduction : elle te dit quel mot chercher.',
  ],
  'vraifaux': [
    '✅',
    'Vrai ou Faux',
    0xFF059669,
    [
      'Un mot et une traduction s\\'affichent.',
      'Est-ce la bonne traduction ? Touche « Vrai » ou « Faux ».',
      'Réponds avant que la barre de temps se vide !',
      'Tu as 3 vies ❤️ : une erreur te fait perdre une vie.',
    ],
    'Plus le niveau monte, plus il faut aller vite.',
  ],
  'ecoute': [
    '👂',
    'Écoute et écris',
    0xFF2563EB,
    [
      'Léxi prononce un mot à voix haute. Monte le son 🔊 !',
      'Écris le mot que tu as entendu, puis valide.',
      'Touche 🔊 pour réécouter. À partir du niveau 6, tu n\\'as que 2 écoutes.',
      'Tu as 3 vies ❤️.',
    ],
    'Les accents ne comptent pas : concentre-toi sur les lettres.',
  ],
  'pluie': [
    '🌧️',
    'Pluie de mots',
    0xFF0891B2,
    [
      'Un mot tombe du haut de l\\'écran.',
      'En bas, plusieurs traductions : touche la bonne avant que le mot touche le sol !',
      'Si le mot tombe ou si tu te trompes, tu perds une vie ❤️ (tu en as 3).',
    ],
    'Les mots tombent de plus en plus vite à chaque niveau.',
  ],
  'motjour': [
    '🟩',
    'Le mot mystère',
    0xFF65A30D,
    [
      'Tu dois deviner un mot caché. Tu as 6 essais.',
      'Écris un mot avec le clavier et valide. Les cases changent de couleur :',
      '🟩 Vert : la lettre est dans le mot, à la bonne place.\\n🟨 Jaune : la lettre est dans le mot, mais pas à cette place.\\n⬜ Gris : la lettre n\\'est pas dans le mot.',
      'L\\'« Indice 🇫🇷 » en haut te donne la traduction du mot en français (niveaux 1 à 3, ou après 3 essais).',
      'Trouve le mot en moins d\\'essais possible pour gagner plus d\\'étoiles ⭐.',
    ],
    'Exemple : si le mot est CAT et que tu écris CAR, C et A seront verts, R sera gris.',
  ],
  'image': [
    '🖼️',
    'Devine l’image',
    0xFFEA580C,
    [
      'Une image s\\'affiche.',
      'Touche le mot (dans la langue que tu apprends) qui correspond à l\\'image.',
      'Tu as 3 vies ❤️ : une erreur te fait perdre une vie.',
    ],
    'Prononce le mot à voix haute en même temps, tu le retiendras mieux !',
  ],
};

/// Montre les règles la toute première fois qu'on ouvre un jeu.
Future<void> _lxReglesSiBesoin(BuildContext context, String id) async {
  try {
    final pr = await SharedPreferences.getInstance();
    final cle = 'lexi_regle_vue_' + id;
    if (pr.getBool(cle) == true) return;
    await pr.setBool(cle, true);
  } catch (_) {
    return;
  }
  if (!context.mounted) return;
  await _lxMontrerRegles(context, id);
}

Future<void> _lxMontrerRegles(BuildContext context, String id) async {
  final r = _lxRegles[id];
  if (r == null) return;
  final p = _lxP(context);
  final couleur = Color(r[2] as int);
  final etapes = (r[3] as List).cast<String>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.carte,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (c) => ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(c).size.height * 0.85),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: p.bord, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 14),
          Center(
              child: Text(r[0] as String,
                  style: const TextStyle(fontSize: 46))),
          const SizedBox(height: 4),
          Text('Comment jouer ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: couleur, fontSize: 14, fontWeight: FontWeight.w900)),
          Text(r[1] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: p.texte, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          for (var i = 0; i < etapes.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: couleur, shape: BoxShape.circle),
                  child: Text((i + 1).toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(etapes[i],
                      style: TextStyle(
                          color: p.texte, fontSize: 15.5, height: 1.35)),
                ),
              ]),
            ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 18),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: couleur.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('🦊 Astuce : ' + (r[4] as String),
                style: TextStyle(color: p.texte, fontSize: 14.5, height: 1.3)),
          ),
          _lxBouton('J\\'ai compris, je joue ! 🦊', couleur,
              () => Navigator.of(c).pop()),
          const SizedBox(height: 8),
          Text('Tu peux revoir ces règles avec le bouton ❓',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 13)),
        ],
      ),
    ),
  );
}
`;
  window._regR=R; return c;
})
