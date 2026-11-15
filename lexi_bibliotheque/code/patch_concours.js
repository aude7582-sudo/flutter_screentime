// Applique les jeux des concours dans LexiConcours (exécuté dans FlutterFlow)
async function patchConcours(c, cx) {
  const r = [];
  const rep = (re, f, nom) => { const ok = re.test(c); r.push(nom + ':' + ok); if (ok) c = c.replace(re, f); };
  rep(/import 'dart:math' as math;/, "import 'dart:math' as math;\nimport 'dart:async';\nimport 'package:flutter/services.dart';", 'imports');
  rep(/(final coach = _entier\(d\['coachTotal'\]\);)/, "$1\n      final cpts = _entier(d['concoursPts']);\n      var cptsDebut = _entier(d['concoursPtsDebut']);", 'cpts');
  rep(/(coachDebut = coach;)/, "$1\n        cptsDebut = cpts;", 'debut');
  rep(/('coachDebut': coachDebut,)/, "$1\n          'concoursPtsDebut': cptsDebut,", 'maj');
  rep(/(\(coach - coachDebut\) \* 30 \+)/, "$1\n          (cpts - cptsDebut) +", 'points');
  rep(/_vue = 'course'\)/, "_vue = 'jeu_course')", 'course');
  rep(/_vue = 'duel'\)/, "_vue = 'jeu_silence')", 'duel');
  rep(/'Défi Famille ou Classe',(\s*)'Un objectif commun pour toute l\\'équipe, un badge pour tous.',(\s*)_vert,(\s*)onTap: \(\) => setState\(\(\) => _vue = 'equipe'\)\),/,
    "'Défi Famille ou Classe',$1'Passe le téléphone, mime le mot, qui prononce le mieux ?',$2_vert,$3onTap: () => setState(() => _vue = 'jeu_famille')),\n                  _carteConcours('🪢', 'Le Pendu',\n                      'Trouve le mot lettre par lettre grâce à sa traduction.',\n                      const Color(0xFF0891B2),\n                      onTap: () => setState(() => _vue = 'jeu_pendu')),\n                  _carteConcours('🧩', 'Construis la phrase',\n                      'Remets les mots dans le bon ordre.',\n                      const Color(0xFFDB2777),\n                      onTap: () => setState(() => _vue = 'jeu_phrase')),", 'famille');
  rep(/'Ton renard avance quand tu apprends, recule quand tu scrolles.'/, "'Ton renard avance à chaque bonne réponse. Premier arrivé à 30 !'", 'txtcourse');
  rep(/'Défie un ami : celui qui touche le moins son téléphone gagne.'/, "'Défie un ami : 30 min, 1 h ou 2 h sans téléphone, puis quiz bonus.'", 'txtduel');
  // boutons « Jouer » dans les vues pays, ligue, accent
  for (const [vue, mode] of [['_vuePays()', 'pays'], ['_vueLigue()', 'ligue'], ['_vueAccent()', 'accent']]) {
    const i = c.indexOf('Widget ' + vue);
    const j = c.indexOf('ListView(', i);
    const k = c.indexOf('children: [', j);
    const ok = i > 0 && j > i && k > j;
    r.push(mode + 'btn:' + ok);
    if (ok) c = c.slice(0, k + 11) + "\n            _boutonJeu('" + mode + "'),\n            const SizedBox(height: 14)," + c.slice(k + 11);
  }
  // méthodes + écran de jeu dans build
  rep(/(\n  @override\n  Widget build\(BuildContext context\) \{)/,
    "\n  Future<void> _ajouterPoints(int p) async {\n    _points += p;\n    if (_pseudo.isNotEmpty) {\n      try {\n        await _publier();\n        await _chargerScores();\n      } catch (_) {}\n    }\n  }\n\n  Widget _boutonJeu(String mode) {\n    final info = _cxModes[mode]!;\n    final c = info[3] as Color;\n    return SizedBox(\n      height: 54,\n      child: ElevatedButton.icon(\n        onPressed: () => setState(() => _vue = 'jeu_' + mode),\n        icon: const Icon(Icons.sports_esports_rounded),\n        label: const Text('Jouer · 10 niveaux',\n            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),\n        style: ElevatedButton.styleFrom(\n          backgroundColor: c,\n          foregroundColor: Colors.white,\n          elevation: 0,\n          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),\n        ),\n      ),\n    );\n  }\n\n  Widget _ecranJeu(String mode) {\n    const amis = {'course': 'course', 'silence': 'duel', 'famille': 'equipe'};\n    const textes = {\n      'course': 'Course avec mes amis',\n      'silence': 'Duel de points avec mes amis',\n      'famille': 'Défi d\\'équipe ou de classe',\n    };\n    final retour = const {'pays': 'pays', 'ligue': 'ligue', 'accent': 'accent'}[mode] ?? 'hub';\n    return Container(\n      width: widget.width ?? double.infinity,\n      height: widget.height ?? double.infinity,\n      color: _fond,\n      child: Column(children: [\n        Expanded(\n          child: SafeArea(\n            bottom: false,\n            child: _CxConcours(\n              key: ValueKey('cx_' + mode),\n              mode: mode,\n              langue: _langue,\n              pseudo: _pseudo.isEmpty ? 'Moi' : _pseudo,\n              drapeau: _infoPays[1],\n              onRetour: () => setState(() => _vue = retour),\n              onPoints: _ajouterPoints,\n              onAmis: amis[mode] == null\n                  ? null\n                  : () => setState(() => _vue = amis[mode]!),\n              texteAmis: textes[mode] ?? '',\n            ),\n          ),\n        ),\n        const LexiNav(actif: 8),\n      ]),\n    );\n  }\n$1", 'methodes');
  rep(/(context\.watch<FFAppState>\(\);)(\s*if \(const \['amis')/, "$1\n    if (_vue.startsWith('jeu_')) return _ecranJeu(_vue.substring(4));$2", 'build');
  c = c.replace(/\s*$/, '\n') + cx;
  return [c, r];
}
