
// ===========================================================================
// TUTEUR LÉXI : niveau + test de placement, choix du prof, 5 niveaux × 10
// leçons (lues sur GitHub : lexi_bibliotheque/<langue>/tuteur/), examens.
// Progression gardée sur le téléphone, séparée par langue.

const String _lxtBase =
    'https://raw.githubusercontent.com/aude7582-sudo/flutter_screentime/main/lexi_bibliotheque/';

const List<String> _lxtNiveaux = [
  'Débutant',
  'Intermédiaire',
  'Difficile',
  'Avancé',
  'Expert'
];

// id, prénom, âge (0 = animal), emoji, 'f' / 'm', niveau
const List<List<Object>> _lxtProfs = [
  ['kenza', 'Kenza', 18, '👩🏾', 'f', 1],
  ['kevin', 'Kevin', 18, '👦🏾', 'm', 1],
  ['lexi', 'Léxi', 0, '🦊', 'm', 1],
  ['koko', 'Koko', 0, '🦜', 'm', 1],
  ['zeynab', 'Zeynab', 22, '👩🏿', 'f', 2],
  ['abdul', 'Abdul', 24, '🧔🏿', 'm', 2],
  ['doudou', 'Doudou', 0, '🐘', 'm', 2],
  ['letty', 'Letty', 26, '👩🏽', 'f', 3],
  ['nassis', 'Nassis', 29, '👨🏾', 'm', 3],
  ['karine', 'Karine', 30, '👩🏾‍💼', 'f', 4],
  ['sagesse', 'Sagesse', 0, '🦉', 'f', 4],
  ['malika', 'Malika', 35, '👩🏽‍🏫', 'f', 5],
  ['malik', 'Malik', 35, '👨🏿‍🏫', 'm', 5],
];

const Map<String, String> _lxtNomsLangues = {
  'en': 'anglais',
  'es': 'espagnol',
  'pt': 'portugais',
  'zh': 'mandarin',
};

const Map<String, String> _lxtVoix = {
  'en': 'en-US',
  'es': 'es-ES',
  'pt': 'pt-BR',
  'zh': 'zh-CN',
};

class _LxtCouleurs {
  _LxtCouleurs() : s = FFAppState().isDarkMode;
  final bool s;
  Color get fond => s ? const Color(0xFF14112B) : const Color(0xFFF6F3FF);
  Color get carte => s ? const Color(0xFF221D3D) : Colors.white;
  Color get texte => s ? Colors.white : const Color(0xFF1E1640);
  Color get gris => s ? const Color(0xFFB8B2D6) : const Color(0xFF6B6490);
  Color get bord => s ? const Color(0xFF3A3460) : const Color(0xFFE2DBF5);
  Color get doux => s ? const Color(0xFF2E2852) : const Color(0xFFEDE9FE);
  static const orange = Color(0xFFF97316);
  static const violet = Color(0xFF7C3AED);
  static const vert = Color(0xFF16A34A);
  static const rouge = Color(0xFFDC2626);
}

class _LxTuteur extends StatefulWidget {
  const _LxTuteur({super.key, required this.langue, this.prenom = ''});
  final String langue;
  final String prenom;

  @override
  State<_LxTuteur> createState() => _LxTuteurState();
}

class _LxTuteurState extends State<_LxTuteur> {
  final FlutterTts _tts = FlutterTts();
  bool _parle = false;
  Timer? _bouche; // fait bouger la bouche du prof pendant qu'il parle
  bool _charge = false;
  String? _erreur;

  // Progression : niveau max débloqué (0 = pas encore choisi), leçons faites,
  // prof choisi par niveau.
  int _max = 0;
  int _niveau = 1;
  Map<String, List<int>> _faites = {};
  Map<String, String> _prof = {};
  bool _salue = false;

  // Écran : 'choix', 'test', 'profs', 'accueil', 'lecon', 'examen'.
  String _ecran = 'choix';
  int _niveauVise = 1; // niveau demandé (test de placement)
  Map<String, dynamic>? _programme;
  Map<String, dynamic>? _doc; // leçon ou examen en cours
  int _etape = 0;
  int _bonnes = 0;
  int _total = 0;

  String get _cle => 'lexi_tuteur_' + widget.langue;

  @override
  void initState() {
    super.initState();
    _tts.setStartHandler(() {
      _bouche?.cancel();
      _bouche = Timer.periodic(const Duration(milliseconds: 180), (_) {
        if (mounted) setState(() {});
      });
      if (mounted) setState(() => _parle = true);
    });
    _tts.setCompletionHandler(_finParole);
    _tts.setCancelHandler(_finParole);
    _charger();
  }

  void _finParole() {
    _bouche?.cancel();
    _bouche = null;
    if (mounted) setState(() => _parle = false);
  }

  @override
  void dispose() {
    _bouche?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final pr = await SharedPreferences.getInstance();
      final t = pr.getString(_cle);
      if (t != null) {
        final d = jsonDecode(t) as Map<String, dynamic>;
        _max = (d['max'] as num?)?.toInt() ?? 0;
        _niveau = (d['niveau'] as num?)?.toInt() ?? 1;
        _salue = d['salue'] == true;
        _faites = {
          for (final e in ((d['faites'] as Map?) ?? {}).entries)
            e.key.toString(): ((e.value as List?) ?? [])
                .map((x) => (x as num).toInt())
                .toList()
        };
        _prof = {
          for (final e in ((d['prof'] as Map?) ?? {}).entries)
            e.key.toString(): e.value.toString()
        };
      }
    } catch (_) {}
    try {
      final r = await http.get(Uri.parse(
          _lxtBase + widget.langue + '/tuteur/programme.json'));
      if (r.statusCode == 200) {
        _programme =
            jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      } else {
        _erreur = 'bientot';
      }
    } catch (_) {
      _erreur = 'reseau';
    }
    if (_max > 0) {
      _ecran = _prof[_niveau.toString()] == null ? 'profs' : 'accueil';
    }
    if (mounted) setState(() => _charge = true);
    if (_ecran == 'accueil' && !_salue) _saluer();
  }

  Future<void> _sauver() async {
    try {
      final pr = await SharedPreferences.getInstance();
      await pr.setString(
          _cle,
          jsonEncode({
            'max': _max,
            'niveau': _niveau,
            'salue': _salue,
            'faites': _faites,
            'prof': _prof,
          }));
    } catch (_) {}
  }

  Future<void> _dire(String t, {bool francais = false}) async {
    if (t.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setLanguage(
          francais ? 'fr-FR' : (_lxtVoix[widget.langue] ?? 'en-US'));
      await _tts.setSpeechRate(francais ? 0.5 : 0.42);
      await _tts.speak(t);
    } catch (_) {}
  }

  List<Object> get _profActuel {
    final id = _prof[_niveau.toString()];
    return _lxtProfs.firstWhere((p) => p[0] == id,
        orElse: () => _lxtProfs.firstWhere((p) => p[5] == _niveau));
  }

  Future<Map<String, dynamic>?> _lire(String chemin) async {
    try {
      final r = await http
          .get(Uri.parse(_lxtBase + widget.langue + '/tuteur/' + chemin));
      if (r.statusCode != 200) return null;
      return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _message(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  // ---------------- Choix du niveau / test ----------------

  Future<void> _choisirNiveau(int n) async {
    if (n == 1) {
      _max = 1;
      _niveau = 1;
      await _sauver();
      setState(() => _ecran = 'profs');
      return;
    }
    final d = await _lire('n' + (n - 1).toString() + '/examen.json');
    if (d == null) {
      _message('Vérifie ta connexion internet et réessaie.');
      return;
    }
    setState(() {
      _niveauVise = n;
      _doc = d;
      _etape = 0;
      _bonnes = 0;
      _total = 0;
      _ecran = 'test';
    });
  }

  // ---------------- Leçons ----------------

  bool _faite(int n, int l) => (_faites[n.toString()] ?? []).contains(l);

  bool _ouverte(int n, int l) =>
      n < _max || (n == _max && (l == 1 || _faite(n, l - 1)));

  Future<void> _ouvrirLecon(int l) async {
    final d = await _lire('n' + _niveau.toString() + '/l' +
        l.toString().padLeft(2, '0') +
        '.json');
    if (d == null) {
      _message('Vérifie ta connexion internet et réessaie.');
      return;
    }
    setState(() {
      _doc = d;
      _etape = 0;
      _bonnes = 0;
      _total = 0;
      _ecran = 'lecon';
    });
    _direEtape();
  }

  Future<void> _ouvrirExamen() async {
    final d = await _lire('n' + _niveau.toString() + '/examen.json');
    if (d == null) {
      _message('Vérifie ta connexion internet et réessaie.');
      return;
    }
    setState(() {
      _doc = d;
      _etape = 0;
      _bonnes = 0;
      _total = 0;
      _ecran = 'examen';
    });
  }

  List<dynamic> get _etapes => (_doc?['etapes'] as List?) ?? [];

  void _direEtape() {
    if (_etape >= _etapes.length) return;
    final e = _etapes[_etape] as Map;
    if (e['type'] == 'explication') {
      final fr = (e['fr'] ?? '').toString();
      final en = (e['en'] ?? '').toString();
      if (_niveau <= 2 && fr.isNotEmpty) {
        _dire(fr, francais: true);
      } else if (en.isNotEmpty) {
        _dire(en);
      } else {
        _dire(fr, francais: true);
      }
    }
  }

  void _suivant() {
    _tts.stop();
    if (_etape + 1 < _etapes.length) {
      setState(() => _etape++);
      _direEtape();
    } else {
      _terminer();
    }
  }

  Future<void> _terminer() async {
    final doc = _doc!;
    if (_ecran == 'lecon') {
      final l = (doc['lecon'] as num?)?.toInt() ?? 0;
      final k = _niveau.toString();
      final liste = _faites[k] ?? <int>[];
      if (!liste.contains(l)) liste.add(l);
      _faites[k] = liste;
      await _sauver();
      try {
        await const FlutterScreentime().lexiSon('victoire');
      } catch (_) {}
      setState(() => _ecran = 'fin');
      return;
    }
    final reussite = (doc['reussite'] as num?)?.toInt() ?? 9;
    final ok = _bonnes >= reussite;
    if (_ecran == 'test') {
      if (ok) {
        _max = _niveauVise;
        _niveau = _niveauVise;
        await _sauver();
      }
    } else if (_ecran == 'examen' && ok && _niveau >= _max && _max < 5) {
      _max = _niveau + 1;
      await _sauver();
    }
    try {
      await const FlutterScreentime().lexiSon(ok ? 'niveau' : 'defaite');
    } catch (_) {}
    setState(() => _ecran = _ecran == 'test' ? 'finTest' : 'finExamen');
  }

  void _noter(bool juste) {
    _total++;
    if (juste) _bonnes++;
    try {
      const FlutterScreentime().lexiSon(juste ? 'bon' : 'faux');
    } catch (_) {}
  }

  Future<void> _saluer() async {
    final p = _profActuel;
    final nom = p[1].toString();
    final f = p[4] == 'f';
    final langue = _lxtNomsLangues[widget.langue] ?? 'anglais';
    final h = DateTime.now().hour;
    final bonjourFr = h < 18 ? 'Bonjour' : 'Bonsoir';
    final prenom = widget.prenom.isEmpty ? '' : ' ' + widget.prenom;
    await _dire(
        bonjourFr +
            prenom +
            ' ! Je suis ' +
            nom +
            ', ' +
            (f ? 'ta professeure' : 'ton professeur') +
            ' de ' +
            langue +
            '. On va apprendre ensemble, pas à pas.',
        francais: true);
    _salue = true;
    _sauver();
  }

  // ---------------- Interface ----------------

  @override
  Widget build(BuildContext context) {
    final c = _LxtCouleurs();
    if (!_charge) {
      return const Center(
          child: CircularProgressIndicator(color: _LxtCouleurs.orange));
    }
    if (_erreur != null || _programme == null) {
      return _vide(
          c,
          _erreur == 'reseau'
              ? 'Pas de connexion internet. Réessaie dans un instant.'
              : 'Le Tuteur arrive bientôt dans cette langue 🦊');
    }
    switch (_ecran) {
      case 'choix':
        return _ecranChoix(c);
      case 'profs':
        return _ecranProfs(c);
      case 'test':
      case 'lecon':
      case 'examen':
        return _ecranEtapes(c);
      case 'fin':
      case 'finTest':
      case 'finExamen':
        return _ecranFin(c);
      default:
        return _ecranAccueil(c);
    }
  }

  Widget _vide(_LxtCouleurs c, String t) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(t,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.gris, fontSize: 16)),
        ),
      );

  Widget _carte(_LxtCouleurs c, Widget enfant,
          {Color? bord, VoidCallback? onTap, double opacite = 1}) =>
      Opacity(
        opacity: opacite,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.carte,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bord ?? c.bord, width: 1.5),
            ),
            child: enfant,
          ),
        ),
      );

  Widget _bouton(String t, Color coul, VoidCallback? f) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: f,
          style: ElevatedButton.styleFrom(
            backgroundColor: coul,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(t,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      );

  /// Avatar du prof : image bouche fermée / ouverte (alterne quand il parle),
  /// sinon son emoji.
  Widget _avatar(List<Object> p, double taille) {
    final id = p[0].toString();
    final ouverte = _parle && (DateTime.now().millisecondsSinceEpoch ~/ 180).isEven;
    final url = _lxtBase + 'profs/' + id + (ouverte ? '_ouvert' : '_ferme') + '.png';
    return _LxtRespire(
      actif: _parle,
      child: SizedBox(
        width: taille,
        height: taille,
        child: ClipOval(
          child: Image.network(url,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (c, e, s) => Container(
                    color: _LxtCouleurs.orange.withOpacity(0.15),
                    alignment: Alignment.center,
                    child: Text(p[3].toString(),
                        style: TextStyle(fontSize: taille * 0.55)),
                  )),
        ),
      ),
    );
  }

  Widget _bulle(_LxtCouleurs c, String texte, {String? sous}) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _avatar(_profActuel, 64),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.carte,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                    color: _LxtCouleurs.orange.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(texte,
                        style: TextStyle(
                            color: c.texte,
                            fontSize: 15.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600)),
                    if (sous != null && sous.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(sous,
                          style: TextStyle(
                              color: c.gris,
                              fontSize: 14,
                              fontStyle: FontStyle.italic)),
                    ],
                  ]),
            ),
          ),
        ],
      );

  Widget _ecranChoix(_LxtCouleurs c) {
    final langue = _lxtNomsLangues[widget.langue] ?? 'anglais';
    const emojis = ['🌱', '🌿', '🌳', '🏔️', '👑'];
    const cecrl = ['A1', 'A2', 'B1', 'B2', 'C1'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        Text('Ton tuteur de ' + langue + ' 🎓',
            style: TextStyle(
                color: c.texte, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
            'Tu as quel niveau ? Si tu choisis plus haut que Débutant, je te fais passer un petit test pour vérifier.',
            style: TextStyle(color: c.gris, fontSize: 15, height: 1.35)),
        const SizedBox(height: 16),
        for (var i = 0; i < 5; i++)
          _carte(
            c,
            Row(children: [
              Text(emojis[i], style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_lxtNiveaux[i],
                          style: TextStyle(
                              color: c.texte,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      Text(
                          'Niveau ' +
                              cecrl[i] +
                              (i == 0 ? ' · on commence tout de suite' : ' · petit test'),
                          style: TextStyle(color: c.gris, fontSize: 13)),
                    ]),
              ),
              Icon(Icons.chevron_right, color: c.gris),
            ]),
            onTap: () => _choisirNiveau(i + 1),
          ),
      ],
    );
  }

  Widget _ecranProfs(_LxtCouleurs c) {
    final profs = _lxtProfs.where((p) => p[5] == _niveau).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        Text('Choisis ton prof 👋',
            style: TextStyle(
                color: c.texte, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Niveau ' + _lxtNiveaux[_niveau - 1] + ' · tu pourras changer quand tu veux.',
            style: TextStyle(color: c.gris, fontSize: 15)),
        const SizedBox(height: 16),
        for (final p in profs)
          _carte(
            c,
            Row(children: [
              _avatar(p, 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p[1].toString(),
                          style: TextStyle(
                              color: c.texte,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text(
                          (p[2] as int) > 0
                              ? p[2].toString() + ' ans'
                              : 'Mascotte Léxi',
                          style: TextStyle(color: c.gris, fontSize: 13.5)),
                    ]),
              ),
              Icon(Icons.chevron_right, color: c.gris),
            ]),
            bord: _prof[_niveau.toString()] == p[0] ? _LxtCouleurs.orange : null,
            onTap: () async {
              _prof[_niveau.toString()] = p[0].toString();
              _salue = false;
              await _sauver();
              setState(() => _ecran = 'accueil');
              _saluer();
            },
          ),
        const SizedBox(height: 8),
        Text('🔒 Les autres profs t\'attendent aux niveaux suivants.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.gris, fontSize: 13)),
      ],
    );
  }

  Widget _ecranAccueil(_LxtCouleurs c) {
    final niveaux = (_programme?['niveaux'] as List?) ?? [];
    final infos = niveaux.length >= _niveau
        ? niveaux[_niveau - 1] as Map
        : <String, dynamic>{};
    final lecons = (infos['lecons'] as List?) ?? [];
    final p = _profActuel;
    final f = p[4] == 'f';
    final langue = _lxtNomsLangues[widget.langue] ?? 'anglais';
    final toutes = List.generate(10, (i) => i + 1).every((l) => _faite(_niveau, l));
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
      children: [
        _bulle(
            c,
            (DateTime.now().hour < 18 ? 'Bonjour' : 'Bonsoir') +
                (widget.prenom.isEmpty ? '' : ' ' + widget.prenom) +
                ' ! Je suis ' +
                p[1].toString() +
                ', ' +
                (f ? 'ta professeure' : 'ton professeur') +
                ' de ' +
                langue +
                '.',
            sous: widget.langue == 'en'
                ? 'Hello! Today, I\'m your teacher. Let\'s learn together!'
                : null),
        const SizedBox(height: 12),
        Row(children: [
          TextButton.icon(
            onPressed: () => _dire(
                'Hello! I\'m ' + p[1].toString() + '. I\'m your teacher today.'),
            icon: const Icon(Icons.volume_up_rounded, color: _LxtCouleurs.orange),
            label: const Text('Écouter',
                style: TextStyle(color: _LxtCouleurs.orange)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _ecran = 'profs'),
            child: Text('Changer de prof', style: TextStyle(color: c.gris)),
          ),
        ]),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (var n = 1; n <= 5; n++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text((n > _max ? '🔒 ' : '') + _lxtNiveaux[n - 1]),
                  selected: _niveau == n,
                  selectedColor: _LxtCouleurs.orange.withOpacity(0.3),
                  backgroundColor: c.doux,
                  labelStyle:
                      TextStyle(color: c.texte, fontWeight: FontWeight.w700),
                  onSelected: (_) {
                    if (n > _max) {
                      final prof = _lxtProfs.firstWhere((x) => x[5] == n);
                      _message(prof[1].toString() +
                          ' t\'attend au niveau ' +
                          _lxtNiveaux[n - 1] +
                          ' 🔒 Termine l\'examen du niveau d\'avant.');
                      return;
                    }
                    setState(() {
                      _niveau = n;
                      _ecran = _prof[n.toString()] == null ? 'profs' : 'accueil';
                    });
                    _sauver();
                  },
                ),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < lecons.length; i++)
          () {
            final l = i + 1;
            final x = lecons[i] as Map;
            final ouverte = _ouverte(_niveau, l);
            final faite = _faite(_niveau, l);
            return _carte(
              c,
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: faite
                        ? _LxtCouleurs.vert
                        : (ouverte ? _LxtCouleurs.orange : c.doux),
                  ),
                  child: Text(faite ? '✓' : (ouverte ? l.toString() : '🔒'),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((x['titre'] ?? '').toString(),
                            style: TextStyle(
                                color: c.texte,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        Text((x['grammaire'] ?? '').toString(),
                            maxLines: 2,
                            style: TextStyle(color: c.gris, fontSize: 13)),
                      ]),
                ),
              ]),
              opacite: ouverte ? 1 : 0.5,
              bord: ouverte && !faite ? _LxtCouleurs.orange : null,
              onTap: ouverte
                  ? () => _ouvrirLecon(l)
                  : () => _message('Termine la leçon ' +
                      (l - 1).toString() +
                      ' pour débloquer celle-ci 🔒'),
            );
          }(),
        _carte(
          c,
          Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Examen du niveau ' + _lxtNiveaux[_niveau - 1],
                        style: TextStyle(
                            color: c.texte,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    Text(
                        toutes
                            ? 'Réussis-le pour débloquer le niveau suivant.'
                            : '🔒 Termine les 10 leçons d\'abord.',
                        style: TextStyle(color: c.gris, fontSize: 13)),
                  ]),
            ),
          ]),
          opacite: toutes ? 1 : 0.5,
          bord: toutes ? _LxtCouleurs.violet : null,
          onTap: toutes
              ? _ouvrirExamen
              : () => _message('Termine les 10 leçons pour passer l\'examen 🔒'),
        ),
      ],
    );
  }

  // ---------------- Les étapes d'une leçon / d'un examen ----------------

  Widget _ecranEtapes(_LxtCouleurs c) {
    if (_etapes.isEmpty) return _vide(c, 'Leçon vide.');
    final e = Map<String, dynamic>.from(_etapes[_etape] as Map);
    final titre = _ecran == 'test'
        ? 'Petit test · niveau ' + _lxtNiveaux[_niveauVise - 1]
        : _ecran == 'examen'
            ? 'Examen · ' + _lxtNiveaux[_niveau - 1]
            : (_doc?['titre'] ?? '').toString();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 18, 6),
        child: Row(children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: c.gris),
            onPressed: () {
              _tts.stop();
              setState(() => _ecran = _max == 0 ? 'choix' : 'accueil');
            },
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_etape + 1) / _etapes.length,
                minHeight: 10,
                backgroundColor: c.doux,
                color: _LxtCouleurs.orange,
              ),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(titre,
            style: TextStyle(
                color: c.gris, fontSize: 14, fontWeight: FontWeight.w700)),
      ),
      Expanded(
        child: _LxtEtape(
          key: ValueKey('etape' + _ecran + _etape.toString()),
          etape: e,
          niveau: _ecran == 'test' ? _niveauVise - 1 : _niveau,
          couleurs: c,
          bulle: (t, {String? sous}) => _bulle(c, t, sous: sous),
          dire: _dire,
          noter: _noter,
          suivant: _suivant,
        ),
      ),
    ]);
  }

  Widget _ecranFin(_LxtCouleurs c) {
    final doc = _doc ?? {};
    if (_ecran == 'fin') {
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
        children: [
          const Center(child: Text('🎉', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 8),
          Text('Leçon terminée !',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: c.texte, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _bulle(c, 'Bravo ! Voici ce qu\'il faut retenir :',
              sous: (doc['resume'] ?? '').toString()),
          const SizedBox(height: 16),
          _carte(
              c,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('📝 Devoir pour demain',
                    style: TextStyle(
                        color: c.texte,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text((doc['devoir'] ?? '').toString(),
                    style: TextStyle(color: c.gris, fontSize: 14.5)),
              ])),
          _bouton('Continuer', _LxtCouleurs.orange,
              () => setState(() => _ecran = 'accueil')),
        ],
      );
    }
    final reussite = (doc['reussite'] as num?)?.toInt() ?? 9;
    final total = _total == 0 ? _etapes.length : _total;
    final ok = _bonnes >= reussite;
    final test = _ecran == 'finTest';
    String titre;
    String texte;
    if (test) {
      titre = ok ? 'Test réussi ! 🎉' : 'Pas encore… 💪';
      texte = ok
          ? 'Tu as eu ' + _bonnes.toString() + '/' + total.toString() + '. Tu peux commencer au niveau ' + _lxtNiveaux[_niveauVise - 1] + ' !'
          : 'Tu as eu ' + _bonnes.toString() + '/' + total.toString() + '. Ton niveau n\'est pas encore ' + _lxtNiveaux[_niveauVise - 1] + '. Je te propose de commencer au niveau ' + _lxtNiveaux[_niveauVise - 2] + ', tu y arriveras vite !';
    } else {
      titre = ok ? 'Examen réussi ! 🏆' : 'Examen raté… 💪';
      texte = ok
          ? 'Tu as eu ' + _bonnes.toString() + '/' + total.toString() + '. ' + (_niveau < 5 ? 'Le niveau ' + _lxtNiveaux[_niveau] + ' est débloqué !' : 'Tu as terminé tout le programme. Tu es un expert !')
          : 'Tu as eu ' + _bonnes.toString() + '/' + total.toString() + '. Il faut ' + reussite.toString() + ' bonnes réponses. Révise un peu et réessaie !';
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
      children: [
        Center(child: Text(ok ? '🏆' : '📚', style: const TextStyle(fontSize: 64))),
        const SizedBox(height: 8),
        Text(titre,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: c.texte, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(texte,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.gris, fontSize: 15.5, height: 1.4)),
        const SizedBox(height: 24),
        if (test && ok)
          _bouton('Choisir mon prof', _LxtCouleurs.orange,
              () => setState(() => _ecran = 'profs')),
        if (test && !ok) ...[
          _bouton('Commencer au niveau ' + _lxtNiveaux[_niveauVise - 2],
              _LxtCouleurs.orange, () async {
            if (_niveauVise - 1 == 1) {
              await _choisirNiveau(1);
            } else {
              await _choisirNiveau(_niveauVise - 1);
            }
          }),
          const SizedBox(height: 10),
          _bouton('Réessayer le test', _LxtCouleurs.violet,
              () => _choisirNiveau(_niveauVise)),
        ],
        if (!test) ...[
          if (ok && _niveau < 5)
            _bouton('Aller au niveau ' + _lxtNiveaux[_niveau], _LxtCouleurs.orange, () {
              setState(() {
                _niveau = _niveau + 1;
                _ecran = _prof[_niveau.toString()] == null ? 'profs' : 'accueil';
              });
              _sauver();
            }),
          const SizedBox(height: 10),
          _bouton('Retour aux leçons', _LxtCouleurs.violet,
              () => setState(() => _ecran = 'accueil')),
        ],
      ],
    );
  }
}

/// Le prof « respire » doucement, et bouge plus quand il parle.
class _LxtRespire extends StatefulWidget {
  const _LxtRespire({required this.child, required this.actif});
  final Widget child;
  final bool actif;

  @override
  State<_LxtRespire> createState() => _LxtRespireState();
}

class _LxtRespireState extends State<_LxtRespire>
    with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (c, e) {
          final t = Curves.easeInOut.transform(_a.value);
          final fort = widget.actif;
          return Transform.translate(
            offset: Offset(0, fort ? -5 * t : -2 * t),
            child: Transform.scale(
                scale: 1 + (fort ? 0.05 : 0.02) * t,
                child: Transform.rotate(
                    angle: fort ? 0.05 * (t - 0.5) : 0, child: e)),
          );
        },
        child: widget.child,
      );
}

/// Une étape : explication, vocabulaire, dialogue, qcm, ordre, traduire,
/// répéter, écoute.
class _LxtEtape extends StatefulWidget {
  const _LxtEtape({
    super.key,
    required this.etape,
    required this.niveau,
    required this.couleurs,
    required this.bulle,
    required this.dire,
    required this.noter,
    required this.suivant,
  });
  final Map<String, dynamic> etape;
  final int niveau;
  final _LxtCouleurs couleurs;
  final Widget Function(String, {String? sous}) bulle;
  final Future<void> Function(String, {bool francais}) dire;
  final void Function(bool) noter;
  final VoidCallback suivant;

  @override
  State<_LxtEtape> createState() => _LxtEtapeState();
}

class _LxtEtapeState extends State<_LxtEtape> {
  int? _choix;
  bool? _juste; // null = pas encore vérifié
  final _champ = TextEditingController();
  List<String> _melange = [];
  final List<int> _pris = [];

  Map<String, dynamic> get e => widget.etape;
  _LxtCouleurs get c => widget.couleurs;
  String get _type => (e['type'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    if (_type == 'ordre') {
      _melange = (e['en'] ?? '').toString().split(' ').where((x) => x.isNotEmpty).toList()
        ..shuffle();
    }
    if (_type == 'ecoute') {
      Future.delayed(const Duration(milliseconds: 400),
          () => widget.dire((e['en'] ?? '').toString()));
    }
  }

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  String _norm(String s) => s
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll(RegExp(r"[^a-z0-9' ]"), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  void _verifier() {
    bool juste = false;
    switch (_type) {
      case 'qcm':
      case 'ecoute':
        if (_choix == null) return;
        juste = _choix == (e['bonne'] as num?)?.toInt();
        break;
      case 'ordre':
        final rep = _pris.map((i) => _melange[i]).join(' ');
        juste = _norm(rep) == _norm((e['en'] ?? '').toString());
        break;
      case 'traduire':
        final r = _norm(_champ.text);
        if (r.isEmpty) return;
        juste = ((e['reponses'] as List?) ?? []).any((x) => _norm(x.toString()) == r);
        break;
    }
    widget.noter(juste);
    setState(() => _juste = juste);
  }

  Widget _titre(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t,
            style: TextStyle(
                color: c.texte, fontSize: 19, fontWeight: FontWeight.w900)),
      );

  Widget _ligneSon(String en, String fr) => GestureDetector(
        onTap: () => widget.dire(en),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.carte,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.bord),
          ),
          child: Row(children: [
            const Icon(Icons.volume_up_rounded,
                color: _LxtCouleurs.orange, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(en,
                        style: TextStyle(
                            color: c.texte,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    if (fr.isNotEmpty)
                      Text(fr, style: TextStyle(color: c.gris, fontSize: 14)),
                  ]),
            ),
          ]),
        ),
      );

  Widget _option(int i, String t) {
    final bonne = (e['bonne'] as num?)?.toInt();
    Color bord = c.bord;
    if (_juste != null) {
      if (i == bonne) bord = _LxtCouleurs.vert;
      if (i == _choix && i != bonne) bord = _LxtCouleurs.rouge;
    } else if (i == _choix) {
      bord = _LxtCouleurs.orange;
    }
    return GestureDetector(
      onTap: _juste != null ? null : () => setState(() => _choix = i),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.carte,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: bord, width: 2),
        ),
        child: Text(t,
            style: TextStyle(
                color: c.texte, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _corps() {
    switch (_type) {
      case 'explication':
        final fr = (e['fr'] ?? '').toString();
        final en = (e['en'] ?? '').toString();
        final exemples = (e['exemples'] as List?) ?? [];
        final principal = widget.niveau <= 2 && fr.isNotEmpty ? fr : (en.isNotEmpty ? en : fr);
        final aide = widget.niveau <= 2 ? en : (widget.niveau <= 4 ? fr : '');
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          widget.bulle(principal, sous: aide == principal ? null : aide),
          const SizedBox(height: 14),
          for (final x in exemples)
            _ligneSon((x as Map)['en'].toString(), (x['fr'] ?? '').toString()),
        ]);
      case 'vocabulaire':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titre('📖 Vocabulaire'),
          for (final m in (e['mots'] as List? ?? []))
            _ligneSon(
                (m as Map)['en'].toString(),
                (m['fr'] ?? '').toString() +
                    ((m['pron'] ?? '').toString().isEmpty
                        ? ''
                        : '  ·  « ' + m['pron'].toString() + ' »')),
        ]);
      case 'dialogue':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titre('💬 Dialogue'),
          for (final l in (e['lignes'] as List? ?? []))
            Align(
              alignment: (l as Map)['qui'] == 'eleve'
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.88,
                child: _ligneSon(l['en'].toString(), (l['fr'] ?? '').toString()),
              ),
            ),
        ]);
      case 'qcm':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titre((e['question'] ?? '').toString()),
          for (var i = 0; i < (e['choix'] as List? ?? []).length; i++)
            _option(i, (e['choix'] as List)[i].toString()),
        ]);
      case 'ecoute':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titre('🎧 Écoute et choisis le bon sens'),
          Center(
            child: IconButton(
              iconSize: 64,
              icon: const Icon(Icons.play_circle_fill_rounded,
                  color: _LxtCouleurs.orange),
              onPressed: () => widget.dire((e['en'] ?? '').toString()),
            ),
          ),
          for (var i = 0; i < (e['choix'] as List? ?? []).length; i++)
            _option(i, (e['choix'] as List)[i].toString()),
        ]);
      case 'ordre':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titre('🧩 Remets les mots dans l\'ordre'),
          Text((e['fr'] ?? '').toString(),
              style: TextStyle(color: c.gris, fontSize: 15)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.doux,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final i in _pris)
                ActionChip(
                  label: Text(_melange[i]),
                  onPressed: _juste != null
                      ? null
                      : () => setState(() => _pris.remove(i)),
                ),
            ]),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < _melange.length; i++)
              if (!_pris.contains(i))
                ActionChip(
                  label: Text(_melange[i]),
                  onPressed: _juste != null
                      ? null
                      : () => setState(() => _pris.add(i)),
                ),
          ]),
          if (_juste == false) ...[
            const SizedBox(height: 12),
            Text('Bonne réponse : ' + (e['en'] ?? '').toString(),
                style: const TextStyle(
                    color: _LxtCouleurs.vert, fontWeight: FontWeight.w700)),
          ],
        ]);
      case 'traduire':
        final reps = (e['reponses'] as List?) ?? [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titre('✍️ Traduis'),
          Text((e['fr'] ?? '').toString(),
              style: TextStyle(
                  color: c.texte, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _champ,
            enabled: _juste == null,
            minLines: 2,
            maxLines: 3,
            style: TextStyle(color: c.texte, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Écris ta réponse…',
              hintStyle: TextStyle(color: c.gris),
              filled: true,
              fillColor: c.carte,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: c.bord)),
            ),
          ),
          if (_juste == false && reps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Bonne réponse : ' + reps.first.toString(),
                style: const TextStyle(
                    color: _LxtCouleurs.vert, fontWeight: FontWeight.w700)),
          ],
        ]);
      case 'repeter':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _titre('🗣️ Écoute et répète à voix haute'),
          _ligneSon((e['en'] ?? '').toString(), (e['fr'] ?? '').toString()),
          const SizedBox(height: 6),
          Text('Appuie pour écouter, puis répète 2 ou 3 fois.',
              style: TextStyle(color: c.gris, fontSize: 14)),
        ]);
      default:
        return const SizedBox();
    }
  }

  bool get _aVerifier =>
      _type == 'qcm' || _type == 'ecoute' || _type == 'ordre' || _type == 'traduire';

  @override
  Widget build(BuildContext context) {
    final explication = (e['explication'] ?? '').toString();
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          children: [
            _corps(),
            if (_juste != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (_juste! ? _LxtCouleurs.vert : _LxtCouleurs.rouge)
                      .withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                    (_juste! ? '✅ Bravo !' : '❌ Pas tout à fait.') +
                        (explication.isEmpty ? '' : ' ' + explication),
                    style: TextStyle(
                        color: c.texte,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _aVerifier && _juste == null ? _verifier : widget.suivant,
            style: ElevatedButton.styleFrom(
              backgroundColor: _aVerifier && _juste == null
                  ? _LxtCouleurs.violet
                  : _LxtCouleurs.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(_aVerifier && _juste == null ? 'VÉRIFIER' : 'CONTINUER',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    ]);
  }
}
