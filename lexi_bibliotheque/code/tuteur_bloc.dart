
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
  ['narcisse', 'Narcisse', 29, '👨🏾', 'm', 3],
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

// Voix de chaque prof : hauteur (pitch), vitesse, et voix Google préférées
// (homme / femme). Si le téléphone n'a pas ces voix, on garde la hauteur.
const Map<String, List<Object>> _lxtVoixProfs = {
  // id : [pitch, vitesse, voix anglaises préférées, voix françaises préférées]
  'kenza': [1.15, 1.0, 'tpf,sfg,iob', 'fra,frc'],
  'kevin': [1.1, 1.0, 'iol,iom,tpd', 'frb,frd'],
  'lexi': [1.35, 1.05, 'iom,iol', 'frd,frb'],
  'koko': [1.65, 1.1, 'sfg,tpf', 'frc,fra'],
  'zeynab': [1.05, 1.0, 'sfg,iob,tpc', 'frc,fra'],
  'abdul': [0.95, 0.97, 'iom,tpd,iol', 'frb,frd'],
  'doudou': [0.7, 0.9, 'tpd,iom', 'frd,frb'],
  'letty': [1.0, 1.0, 'iob,tpc,sfg', 'fra,frc'],
  'narcisse': [0.9, 0.97, 'tpd,iol,iom', 'frd,frb'],
  'karine': [0.97, 1.0, 'tpc,iog,iob', 'frc,fra'],
  'sagesse': [0.82, 0.92, 'iog,tpc', 'fra,frc'],
  'malika': [0.92, 0.97, 'iog,tpc,sfg', 'fra,frc'],
  'malik': [0.8, 0.95, 'iol,tpd,iom', 'frb,frd'],
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
      _acces = await lexiAcces();
    } catch (_) {}
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
    if (_ecran == 'accueil') _saluer();
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

  List<Map<String, String>>? _voixDispo; // voix installées sur le téléphone

  Future<List<Map<String, String>>> _voixTel() async {
    if (_voixDispo != null) return _voixDispo!;
    final l = <Map<String, String>>[];
    try {
      final v = await _tts.getVoices;
      for (final x in (v as List? ?? [])) {
        if (x is Map) {
          l.add({
            'name': (x['name'] ?? '').toString(),
            'locale': (x['locale'] ?? '').toString(),
          });
        }
      }
    } catch (_) {}
    _voixDispo = l;
    return l;
  }

  // Choisit la voix du prof (homme / femme) pour la langue demandée.
  Future<void> _voixDuProf(String langue, bool francais) async {
    final p = _profActuel;
    final reglage = _lxtVoixProfs[p[0].toString()] ??
        [p[4] == 'f' ? 1.1 : 0.9, 1.0, '', ''];
    final pitch = (reglage[0] as num).toDouble();
    final femme = p[4] == 'f';
    try {
      await _tts.setPitch(pitch);
    } catch (_) {}
    final codes = (reglage[francais ? 3 : 2] as String)
        .split(',')
        .where((x) => x.isNotEmpty)
        .toList();
    final norme = langue.toLowerCase().replaceAll('_', '-');
    final voix = (await _voixTel())
        .where((v) =>
            v['locale']!.toLowerCase().replaceAll('_', '-') == norme)
        .toList();
    if (voix.isEmpty) return;
    Map<String, String>? choix;
    for (final code in codes) {
      for (final v in voix) {
        final n = v['name']!.toLowerCase();
        if (n.contains('-x-' + code) && n.contains('local')) choix ??= v;
      }
      for (final v in voix) {
        if (v['name']!.toLowerCase().contains('-x-' + code)) choix ??= v;
      }
      if (choix != null) break;
    }
    // Autres téléphones : on cherche « male » / « female » dans le nom.
    choix ??= voix.firstWhere(
        (v) {
          final n = v['name']!.toLowerCase();
          return femme
              ? n.contains('female')
              : (n.contains('male') && !n.contains('female'));
        },
        orElse: () => voix[femme ? 0 : (voix.length > 1 ? 1 : 0)]);
    try {
      await _tts.setVoice({'name': choix['name']!, 'locale': choix['locale']!});
    } catch (_) {}
  }

  Future<void> _dire(String t, {bool francais = false}) async {
    if (t.trim().isEmpty) return;
    try {
      await _tts.stop();
      final langue = francais ? 'fr-FR' : (_lxtVoix[widget.langue] ?? 'en-US');
      await _tts.setLanguage(langue);
      await _voixDuProf(langue, francais);
      final reglage = _lxtVoixProfs[_profActuel[0].toString()];
      final vitesse = reglage == null ? 1.0 : (reglage[1] as num).toDouble();
      await _tts.setSpeechRate((francais ? 0.5 : 0.42) * vitesse);
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
      if (_max < 1) _max = 1;
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

  bool get _bloque => _acces < 0;

  Future<void> _ouvrirLecon(int l) async {
    if (_bloque && !(_niveau == 1 && l == 1)) {
      _tts.stop();
      setState(() => _ecran = 'pro');
      _dire(
          _niveau <= 2
              ? 'Bravo ! Pour continuer à apprendre avec moi, passe à Léxi Pro.'
              : 'Well done! To keep learning with me, upgrade to Léxi Pro.',
          francais: _niveau <= 2);
      return;
    }
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
    if (_bloque) {
      setState(() => _ecran = 'pro');
      return;
    }
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
    _voirTrad = false;
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
      final suite = _prochaineLecon;
      final fr = _niveau <= 2;
      _dire(
          suite != null
              ? (fr
                  ? 'Bravo, leçon terminée ! Passons à la leçon numéro ' +
                      suite.toString() +
                      '. Tu es prêt ?'
                  : 'Well done! Let\'s move on to lesson ' +
                      suite.toString() +
                      '. Are you ready?')
              : (fr
                  ? 'Bravo ! Tu as fini les dix leçons. On passe l\'examen ?'
                  : 'Well done! You finished all ten lessons. Shall we take the exam?'),
          francais: fr);
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

  // Ce que le prof dit sur l'écran d'accueil, selon l'étape de la discussion :
  // [texte affiché, traduction, en français ?]
  int _dialogue = 0;
  // Accès Léxi : ≥ 999 = Pro, > 0 = jours d'essai, < 0 = essai fini.
  // Sans Pro, seule la leçon 1 du niveau Débutant est gratuite.
  int _acces = 999; // 0 = « Tu es prêt(e) ? », 1 = « Tu es sûr(e) ? », 2 = plus tard

  List<Object> _texteScene() {
    final p = _profActuel;
    final nom = p[1].toString();
    final f = p[4] == 'f';
    final prenom = widget.prenom.isEmpty ? '' : ' ' + widget.prenom;
    final bonjour = DateTime.now().hour < 18 ? 'Bonjour' : 'Bonsoir';
    final niveaux = (_programme?['niveaux'] as List?) ?? [];
    final infos = niveaux.length >= _niveau
        ? niveaux[_niveau - 1] as Map
        : <String, dynamic>{};
    final lecons = (infos['lecons'] as List?) ?? [];
    final l = _prochaineLecon;
    final titre = l != null && lecons.length >= l
        ? ((lecons[l - 1] as Map)['titre'] ?? '').toString()
        : '';
    final premiere = l == 1;
    String fr;
    String en;
    if (_dialogue == 1) {
      fr = 'Tu es sûr(e) de ne pas vouloir continuer ?';
      en = 'Are you sure you don\'t want to continue?';
    } else if (_dialogue == 2) {
      fr = 'D\'accord, à tout à l\'heure ! Reviens quand tu es prêt(e) 👋';
      en = 'Okay, see you later! Come back when you\'re ready.';
    } else {
      final presente = 'Je m\'appelle ' +
          nom +
          ', je suis ' +
          (f ? 'ta professeure' : 'ton professeur') +
          ' de niveau ' +
          _lxtNiveaux[_niveau - 1] +
          '. ';
      if (l != null) {
        fr = bonjour +
            prenom +
            ' ! ' +
            presente +
            (premiere
                ? 'Nous allons commencer par la leçon 1'
                : 'On continue avec la leçon ' + l.toString()) +
            ' : « ' +
            titre +
            ' ». Est-ce que tu es prêt(e) ?';
        en = 'Hi' +
            prenom +
            '! My name is ' +
            nom +
            ', I\'m your teacher. ' +
            (premiere
                ? 'Let\'s start with lesson 1'
                : 'Let\'s continue with lesson ' + l.toString()) +
            ': "' +
            titre +
            '". Are you ready?';
      } else if (_max > _niveau) {
        fr = 'Bravo' +
            prenom +
            ' ! Tu as réussi l\'examen. On passe au niveau ' +
            _lxtNiveaux[_niveau] +
            ' ?';
        en = 'Well done' +
            prenom +
            '! You passed the exam. Shall we move to the next level?';
      } else {
        fr = bonjour +
            prenom +
            ' ! Tu as fini les 10 leçons. On passe le grand examen ? Est-ce que tu es prêt(e) ?';
        en = 'Hi' +
            prenom +
            '! You finished all 10 lessons. Shall we take the final exam? Are you ready?';
      }
    }
    final francais = _niveau <= 2;
    return francais ? [fr, en, true] : [en, fr, false];
  }

  Future<void> _saluer() async {
    final t = _texteScene();
    await _dire(t[0] as String, francais: t[2] as bool);
    _salue = true;
    _sauver();
  }

  void _repondre(bool oui) {
    _tts.stop();
    if (_dialogue == 2 && oui) {
      setState(() => _dialogue = 0);
      _saluer();
      return;
    }
    if ((_dialogue == 0 && oui) || (_dialogue == 1 && !oui)) {
      // On y va !
      setState(() => _dialogue = 0);
      final l = _prochaineLecon;
      if (l != null) {
        _ouvrirLecon(l);
      } else if (_max > _niveau) {
        setState(() {
          _niveau = _niveau + 1;
          _ecran = _prof[_niveau.toString()] == null ? 'profs' : 'accueil';
        });
        _sauver();
        if (_ecran == 'accueil') _saluer();
      } else {
        _ouvrirExamen();
      }
      return;
    }
    setState(() => _dialogue = _dialogue == 0 ? 1 : 2);
    _saluer();
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
      case 'pro':
        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: c.texte),
                onPressed: () {
                  _tts.stop();
                  setState(() {
                    _ecran = 'accueil';
                    _dialogue = 2;
                  });
                },
              ),
              _avatar(_profActuel, 48),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    'Pour continuer avec moi, passe à Léxi Pro 🧡',
                    style: TextStyle(
                        color: c.texte,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
          Expanded(child: LexiPro(width: MediaQuery.of(context).size.width)),
        ]);
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

  String _imageProf(List<Object> p) {
    final ouverte =
        _parle && (DateTime.now().millisecondsSinceEpoch ~/ 180).isEven;
    return _lxtBase +
        'profs/' +
        p[0].toString() +
        (ouverte ? '_ouvert' : '_ferme') +
        '.png';
  }

  /// Avatar rond du prof (bouche qui bouge quand il parle).
  Widget _avatar(List<Object> p, double taille) {
    return _LxtRespire(
      actif: _parle,
      child: SizedBox(
        width: taille,
        height: taille,
        child: ClipOval(
          child: Container(
            color: _LxtCouleurs.orange.withOpacity(0.16),
            child: Image.network(_imageProf(p),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                gaplessPlayback: true,
                errorBuilder: (c, e, s) => Container(
                      color: _LxtCouleurs.orange.withOpacity(0.15),
                      alignment: Alignment.center,
                      child: Text(p[3].toString(),
                          style: TextStyle(fontSize: taille * 0.55)),
                    )),
          ),
        ),
      ),
    );
  }

  /// Le prof en grand, qui flotte doucement (et bouge la bouche en parlant).
  Widget _grandProf(List<Object> p) {
    return _LxtRespire(
      actif: _parle,
      child: Image.network(_imageProf(p),
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          gaplessPlayback: true,
          errorBuilder: (c, e, s) => Center(
              child: Text(p[3].toString(),
                  style: const TextStyle(fontSize: 120)))),
    );
  }

  bool _voirTrad = false; // « TRADUIS » ouvert dans la bulle

  /// Bulle du prof : son texte, 🔊 pour réécouter, « TRADUIS » pour la
  /// traduction.
  Widget _bulle(_LxtCouleurs c, String texte, {String? sous}) {
    final francais = _niveau <= 2 && widget.langue != 'fr';
    final aTraduire = sous != null && sous.isNotEmpty && sous != texte;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 12),
      decoration: BoxDecoration(
        color: c.carte,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.bord),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(texte,
                style: TextStyle(
                    color: c.texte,
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w600)),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _dire(texte,
                francais: francais && !_semblAnglais(texte)),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.volume_up_rounded,
                  color: _LxtCouleurs.violet, size: 24),
            ),
          ),
        ]),
        if (aTraduire) ...[
          if (_voirTrad)
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 8),
              child: Text(sous,
                  style: TextStyle(
                      color: c.gris,
                      fontSize: 14.5,
                      fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _voirTrad = !_voirTrad),
            child: Text(_voirTrad ? 'MASQUER' : 'TRADUIS',
                style: const TextStyle(
                    color: _LxtCouleurs.violet,
                    fontSize: 12.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900)),
          ),
        ],
      ]),
    );
  }

  // Une phrase sans accents et avec des mots anglais courants = anglais.
  bool _semblAnglais(String t) {
    if (RegExp(r'[éèêàùçôîâ]').hasMatch(t)) return false;
    return RegExp(r"\b(the|you|i'm|hello|is|are|let's|my|your|today)\b",
            caseSensitive: false)
        .hasMatch(t);
  }

  // ---------------- 1. Quel est ton niveau ? ----------------

  Widget _ecranChoix(_LxtCouleurs c) {
    final langue = _lxtNomsLangues[widget.langue] ?? 'anglais';
    const emojis = ['🌱', '🌿', '🌳', '🏔️', '👑'];
    const cecrl = ['A1', 'A2', 'B1', 'B2', 'C1'];
    const couleurs = [
      Color(0xFF22C55E),
      Color(0xFF0EA5E9),
      Color(0xFFF97316),
      Color(0xFF8B5CF6),
      Color(0xFFE11D48),
    ];
    Widget carre(int i) {
      final n = i + 1;
      final ouvert = n <= _max || n == 1;
      final enCours = _max > 0 && n == _niveau;
      final etiquette = enCours
          ? 'En cours'
          : ouvert
              ? (_max == 0 ? 'On commence' : 'Ouvert')
              : 'Petit test 📝';
      return GestureDetector(
        onTap: () async {
          if (ouvert) {
            _niveau = n;
            if (_max < 1) _max = 1;
            await _sauver();
            setState(() =>
                _ecran = _prof[n.toString()] == null ? 'profs' : 'accueil');
            if (_ecran == 'accueil') _saluer();
          } else {
            _choisirNiveau(n);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [couleurs[i], couleurs[i].withOpacity(0.72)],
            ),
            border: enCours ? Border.all(color: Colors.white, width: 3) : null,
            boxShadow: [
              BoxShadow(
                  color: couleurs[i].withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emojis[i], style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(_lxtNiveaux[i],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ),
                Text(cecrl[i],
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(etiquette,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      children: [
        Text('Ton tuteur d\'' + langue + ' 🎓',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: c.texte, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Quel est ton niveau en ' + langue + ' ?',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: c.gris, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1,
          children: [for (var i = 0; i < 4; i++) carre(i)],
        ),
        const SizedBox(height: 14),
        Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 50) / 2,
            child: AspectRatio(aspectRatio: 1, child: carre(4)),
          ),
        ),
        const SizedBox(height: 14),
        Text(
            'Pour commencer plus haut que Débutant, je te fais passer un petit test.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.gris, fontSize: 13.5)),
        if (_max > 0) ...[
          const SizedBox(height: 16),
          _bouton('Continuer ma leçon ▶', _LxtCouleurs.orange, () {
            setState(() => _ecran =
                _prof[_niveau.toString()] == null ? 'profs' : 'accueil');
            if (_ecran == 'accueil') _saluer();
          }),
        ],
      ],
    );
  }

  // ---------------- 2. Choisis ton prof ----------------

  Widget _ecranProfs(_LxtCouleurs c) {
    final profs = _lxtProfs.where((p) => p[5] == _niveau).toList();
    final dejaUn = _prof[_niveau.toString()] != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 6, 18, 30),
      children: [
        Row(children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: c.texte),
            onPressed: () =>
                setState(() => _ecran = dejaUn ? 'accueil' : 'choix'),
          ),
          Expanded(
            child: Text('Choisis ton prof 👋',
                style: TextStyle(
                    color: c.texte, fontSize: 22, fontWeight: FontWeight.w900)),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 14),
          child: Text(
              'Niveau ' +
                  _lxtNiveaux[_niveau - 1] +
                  ' · tu pourras changer quand tu veux.',
              style: TextStyle(color: c.gris, fontSize: 14.5)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.8,
            children: [
              for (final p in profs)
                GestureDetector(
                  onTap: () async {
                    _prof[_niveau.toString()] = p[0].toString();
                    _salue = false;
                    await _sauver();
                    setState(() => _ecran = 'accueil');
                    _saluer();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: _prof[_niveau.toString()] == p[0]
                              ? _LxtCouleurs.orange
                              : c.bord,
                          width: _prof[_niveau.toString()] == p[0] ? 3 : 1.5),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.network(
                          _lxtBase + 'profs/' + p[0].toString() + '_ferme.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (c, e, s) => Center(
                              child: Text(p[3].toString(),
                                  style: const TextStyle(fontSize: 64)))),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 22, 12, 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.75)
                              ],
                            ),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p[1].toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900)),
                                Text(
                                    (p[2] as int) > 0
                                        ? p[2].toString() + ' ans'
                                        : 'Mascotte Léxi',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13)),
                              ]),
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- 3. Le prof + la leçon du jour ----------------

  int? get _prochaineLecon {
    for (var l = 1; l <= 10; l++) {
      if (!_faite(_niveau, l)) return l;
    }
    return null; // les 10 leçons sont faites → examen
  }

  void _revoir(_LxtCouleurs c, List lecons) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.carte,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          children: [
            Text('Revoir une leçon',
                style: TextStyle(
                    color: c.texte, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            for (var i = 0; i < lecons.length; i++)
              if (_faite(_niveau, i + 1))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                      backgroundColor: _LxtCouleurs.vert,
                      child: Text('✓', style: TextStyle(color: Colors.white))),
                  title: Text(((lecons[i] as Map)['titre'] ?? '').toString(),
                      style: TextStyle(
                          color: c.texte, fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _ouvrirLecon(i + 1);
                  },
                ),
            if (!List.generate(lecons.length, (i) => i + 1)
                .any((l) => _faite(_niveau, l)))
              Text('Tu n\'as pas encore terminé de leçon.',
                  style: TextStyle(color: c.gris)),
          ],
        ),
      ),
    );
  }

  Widget _puce(String t, bool principal, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: ElevatedButton(
          onPressed: f,
          style: ElevatedButton.styleFrom(
            backgroundColor: principal ? _LxtCouleurs.violet : Colors.white,
            foregroundColor: principal ? Colors.white : _LxtCouleurs.violet,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: _LxtCouleurs.violet, width: 1.5)),
          ),
          child: Text(t,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ),
      );

  /// Écran du prof : il est en grand, il parle, son texte s'écrit en bas,
  /// et l'élève répond Oui / Non.
  Widget _ecranAccueil(_LxtCouleurs c) {
    final niveaux = (_programme?['niveaux'] as List?) ?? [];
    final infos = niveaux.length >= _niveau
        ? niveaux[_niveau - 1] as Map
        : <String, dynamic>{};
    final lecons = (infos['lecons'] as List?) ?? [];
    final p = _profActuel;
    final t = _texteScene();
    final fr = _niveau <= 2;
    final sombre = _LxtCouleurs().s;
    List<Widget> reponses;
    if (_dialogue == 0) {
      reponses = [
        _puce(fr ? 'Non' : 'No', false, () => _repondre(false)),
        _puce(fr ? 'Oui, on y va !' : 'Yes, let\'s go!', true,
            () => _repondre(true)),
      ];
    } else if (_dialogue == 1) {
      reponses = [
        _puce(fr ? 'Oui, plus tard' : 'Yes, later', false,
            () => _repondre(true)),
        _puce(fr ? 'Non, on continue !' : 'No, let\'s continue!', true,
            () => _repondre(false)),
      ];
    } else {
      reponses = [
        _puce(fr ? 'Je suis prêt(e) !' : 'I\'m ready!', true,
            () => _repondre(true)),
      ];
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sombre
              ? [const Color(0xFF3B1E7A), c.fond]
              : [const Color(0xFFC4B5FD), c.fond],
        ),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
          child: Row(children: [
            IconButton(
              tooltip: 'Niveaux',
              icon: Icon(Icons.arrow_back_rounded, color: c.texte),
              onPressed: () {
                _tts.stop();
                setState(() => _ecran = 'choix');
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _tts.stop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _LxtFiches(langue: widget.langue)));
              },
              child: Text('📚 Fiches',
                  style: TextStyle(color: c.texte, fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () => _revoir(c, lecons),
              child: Text('Revoir',
                  style: TextStyle(color: c.texte, fontWeight: FontWeight.w700)),
            ),
            TextButton.icon(
              onPressed: () {
                _tts.stop();
                setState(() => _ecran = 'profs');
              },
              icon: Icon(Icons.swap_horiz_rounded, color: c.texte, size: 20),
              label: Text('Prof',
                  style: TextStyle(color: c.texte, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(onTap: _saluer, child: _grandProf(p)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(children: [
            _bulle(c, t[0] as String, sous: t[1] as String),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                  alignment: WrapAlignment.end,
                  runSpacing: 8,
                  children: reponses),
            ),
          ]),
        ),
      ]),
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
    final sombre = _LxtCouleurs().s;
    // Le prof en GRAND en haut (il flotte et parle), la leçon en dessous
    // dans un panneau qui défile.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: sombre
              ? [const Color(0xFF3B1E7A), c.fond]
              : [const Color(0xFFC4B5FD), c.fond],
        ),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 18, 0),
          child: Row(children: [
            IconButton(
              icon: Icon(Icons.close_rounded, color: c.texte),
              onPressed: () {
                _tts.stop();
                setState(() => _ecran =
                    _ecran == 'test' || _max == 0 ? 'choix' : 'accueil');
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
        Expanded(
          flex: 9,
          child: Stack(children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                child: _grandProf(_profActuel),
              ),
            ),
            Positioned(
              left: 16,
              top: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.carte.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(titre,
                    style: TextStyle(
                        color: c.gris,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
        Expanded(
          flex: 11,
          child: Container(
            decoration: BoxDecoration(
              color: c.fond,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(26)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4)),
              ],
            ),
            child: _LxtEtape(
              key: ValueKey('etape' + _ecran + _etape.toString()),
              etape: e,
              niveau: _ecran == 'test' ? _niveauVise - 1 : _niveau,
              couleurs: c,
              bulle: (t, {String? sous}) => _bulle(c, t, sous: sous),
              dire: _dire,
              noter: _noter,
              suivant: _suivant,
              locale: _lxtVoix[widget.langue] ?? 'en-US',
            ),
          ),
        ),
      ]),
    );
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
          _bulle(c,
              'Bravo ! Voici ce qu\'il faut retenir : ' +
                  (doc['resume'] ?? '').toString()),
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
          // « Passons à la leçon 2, tu es prêt(e) ? » → Oui : on enchaîne.
          Builder(builder: (_) {
            final l = _prochaineLecon;
            final fr = _niveau <= 2;
            final question = l != null
                ? (fr
                    ? 'Passons à la leçon numéro ' + l.toString() + '. Tu es prêt(e) ?'
                    : 'Let\'s move on to lesson ' + l.toString() + '. Are you ready?')
                : (fr
                    ? 'Tu as fini les 10 leçons ! On passe l\'examen ?'
                    : 'You finished all 10 lessons! Shall we take the exam?');
            return Column(children: [
              _bulle(c, question),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(alignment: WrapAlignment.end, runSpacing: 8, children: [
                  _puce(fr ? 'Plus tard' : 'Later', false, () {
                    _tts.stop();
                    setState(() {
                      _ecran = 'accueil';
                      _dialogue = 2;
                    });
                    _saluer();
                  }),
                  _puce(fr ? 'Oui, on continue !' : 'Yes, let\'s go!', true, () {
                    _tts.stop();
                    _dialogue = 0;
                    if (l != null) {
                      _ouvrirLecon(l);
                    } else {
                      _ouvrirExamen();
                    }
                  }),
                ]),
              ),
            ]);
          }),
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
                _dialogue = 0;
                _ecran = _prof[_niveau.toString()] == null ? 'profs' : 'accueil';
              });
              _sauver();
              if (_ecran == 'accueil') _saluer();
            }),
          if (!(ok && _niveau < 5)) ...[
            const SizedBox(height: 10),
            _bouton('Retour', _LxtCouleurs.violet,
                () => setState(() => _ecran = 'accueil')),
          ],
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
            offset: Offset(0, fort ? -10 * t : -7 * t),
            child: Transform.scale(
                scale: 1 + (fort ? 0.03 : 0.015) * t,
                child: Transform.rotate(
                    angle: fort ? 0.025 * (t - 0.5) : 0.01 * (t - 0.5),
                    child: e)),
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
    this.locale = 'en-US',
  });
  final Map<String, dynamic> etape;
  final int niveau;
  final _LxtCouleurs couleurs;
  final Widget Function(String, {String? sous}) bulle;
  final Future<void> Function(String, {bool francais}) dire;
  final void Function(bool) noter;
  final VoidCallback suivant;
  final String locale;

  @override
  State<_LxtEtape> createState() => _LxtEtapeState();
}

class _LxtEtapeState extends State<_LxtEtape> {
  int? _choix;
  bool? _juste; // null = pas encore vérifié
  final _champ = TextEditingController();
  List<String> _melange = [];
  final List<int> _pris = [];
  // Micro : le prof écoute ce que l'élève dit.
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _sttPret = false;
  bool _ecoute = false;
  String? _motEcoute; // mot du vocabulaire en cours d'écoute
  int _essais = 0;
  String _entendu = '';
  int? _score;
  final Map<String, bool> _motsDits = {};

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
    try {
      _stt.cancel();
    } catch (_) {}
    super.dispose();
  }

  Future<List<String>?> _micro() async {
    try {
      if (!_sttPret) _sttPret = await _stt.initialize();
      if (!_sttPret) return null;
      final fin = Completer<List<String>?>();
      List<String> dernier = [];
      void finir() {
        if (!fin.isCompleted) fin.complete(dernier.isEmpty ? null : dernier);
      }
      _stt.statusListener = (s) {
        if (s == 'done' || s == 'notListening') {
          Future.delayed(const Duration(milliseconds: 400), finir);
        }
      };
      _stt.errorListener = (_) => finir();
      await _stt.listen(
        onResult: (r) {
          final l = <String>[r.recognizedWords];
          for (final a in r.alternates) {
            if (!l.contains(a.recognizedWords)) l.add(a.recognizedWords);
          }
          dernier = l.where((t) => t.trim().isNotEmpty).toList();
          if (r.finalResult) finir();
        },
        localeId: widget.locale.replaceAll('-', '_'),
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
      );
      return await fin.future.timeout(const Duration(seconds: 16),
          onTimeout: () => dernier.isEmpty ? null : dernier);
    } catch (_) {
      return null;
    }
  }

  // % de mots de la phrase attendue retrouvés dans ce que l'élève a dit.
  int _noteDiction(String attendu, List<String> props) {
    final a = _norm(attendu).split(' ').where((m) => m.isNotEmpty).toList();
    if (a.isEmpty) return 0;
    var mieux = 0;
    for (final p in props) {
      final reste = _norm(p).split(' ').toList();
      var n = 0;
      for (final m in a) {
        final k = reste.indexOf(m);
        if (k >= 0) {
          n++;
          reste.removeAt(k);
        }
      }
      if (n > mieux) mieux = n;
    }
    return (100 * mieux / a.length).round();
  }

  void _sonCourt(bool bon) {
    try {
      const FlutterScreentime().lexiSon(bon ? 'bon' : 'faux');
    } catch (_) {}
  }

  // Étape « Répète » : le prof écoute et dit si c'est bien prononcé.
  Future<void> _ecouterPhrase() async {
    if (_ecoute) return;
    setState(() => _ecoute = true);
    final props = await _micro();
    if (!mounted) return;
    if (props == null) {
      setState(() {
        _ecoute = false;
        _essais++;
        _entendu = '';
        _score = 0;
      });
      return;
    }
    final score = _noteDiction((e['en'] ?? '').toString(), props);
    final ok = score >= 70;
    _sonCourt(ok);
    setState(() {
      _ecoute = false;
      _essais++;
      _entendu = props.first;
      _score = score;
      if (ok) _juste = true;
    });
    widget.dire(ok
        ? (score >= 95 ? 'Perfect!' : 'Great job!')
        : 'Almost! Listen and try again.');
  }

  // Vocabulaire : on peut dire chaque mot au micro.
  Future<void> _ecouterMot(String mot) async {
    if (_ecoute) return;
    setState(() {
      _ecoute = true;
      _motEcoute = mot;
    });
    final props = await _micro();
    if (!mounted) return;
    final ok = props != null && _noteDiction(mot, props) >= 70;
    if (props != null) _sonCourt(ok);
    setState(() {
      _ecoute = false;
      _motEcoute = null;
      if (props != null) _motsDits[mot] = ok;
    });
    if (props != null) widget.dire(ok ? 'Good!' : 'Try again: ' + mot);
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

  Widget _ligneSon(String en, String fr, {bool micro = false}) => GestureDetector(
        onTap: () => widget.dire(en),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.carte,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _motsDits[en] == null
                    ? c.bord
                    : (_motsDits[en]! ? _LxtCouleurs.vert : _LxtCouleurs.rouge),
                width: _motsDits[en] == null ? 1 : 2),
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
            if (micro)
              IconButton(
                tooltip: 'Dis-le',
                icon: Icon(
                    _ecoute && _motEcoute == en
                        ? Icons.graphic_eq_rounded
                        : (_motsDits[en] == true
                            ? Icons.check_circle_rounded
                            : Icons.mic_rounded),
                    color: _motsDits[en] == true
                        ? _LxtCouleurs.vert
                        : _LxtCouleurs.violet),
                onPressed: () => _ecouterMot(en),
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
          Text('Touche un mot pour l\'écouter, puis 🎤 pour le dire.',
              style: TextStyle(color: c.gris, fontSize: 13.5)),
          const SizedBox(height: 10),
          for (final m in (e['mots'] as List? ?? []))
            _ligneSon(
                (m as Map)['en'].toString(),
                (m['fr'] ?? '').toString() +
                    ((m['pron'] ?? '').toString().isEmpty
                        ? ''
                        : '  ·  « ' + m['pron'].toString() + ' »'),
                micro: true),
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
            textCapitalization: TextCapitalization.sentences,
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
          if (_juste != null &&
              RegExp(r"(^|[^A-Za-z'])i('m|'ve|'d|'ll)?\b").hasMatch(_champ.text)) ...[
            const SizedBox(height: 10),
            Text('💡 En anglais, « I » (je) s\'écrit toujours avec une majuscule.',
                style: const TextStyle(
                    color: _LxtCouleurs.orange, fontWeight: FontWeight.w700)),
          ],
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
          Text(
              _ecoute
                  ? '🎤 Je t\'écoute… parle maintenant !'
                  : 'Écoute, puis appuie sur 🎤 et dis la phrase.',
              style: TextStyle(
                  color: _ecoute ? _LxtCouleurs.violet : c.gris,
                  fontSize: 14,
                  fontWeight: _ecoute ? FontWeight.w800 : FontWeight.w400)),
          if (_score != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_juste == true ? _LxtCouleurs.vert : _LxtCouleurs.orange)
                    .withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _juste == true
                            ? '✅ Bravo, c\'est bien prononcé ! ($_score %)'
                            : (_entendu.isEmpty
                                ? '🤔 Je n\'ai rien entendu. Parle plus près du micro.'
                                : '💪 Presque ($_score %). Réécoute et réessaie !'),
                        style: TextStyle(
                            color: c.texte,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    if (_entendu.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('J\'ai entendu : « ' + _entendu + ' »',
                            style: TextStyle(color: c.gris, fontSize: 13.5)),
                      ),
                  ]),
            ),
          ],
        ]);
      default:
        return const SizedBox();
    }
  }

  // Étape « Répète » : il faut parler (2 essais ratés → on peut continuer).
  bool get _micAFaire => _type == 'repeter' && _juste != true && _essais < 2;

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
            onPressed: _micAFaire
                ? (_ecoute ? null : _ecouterPhrase)
                : (_aVerifier && _juste == null ? _verifier : widget.suivant),
            style: ElevatedButton.styleFrom(
              backgroundColor: _micAFaire || (_aVerifier && _juste == null)
                  ? _LxtCouleurs.violet
                  : _LxtCouleurs.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
                _micAFaire
                    ? (_ecoute
                        ? '🎤 J\'ÉCOUTE…'
                        : (_essais == 0 ? '🎤 À TOI DE DIRE' : '🎤 RÉESSAYER'))
                    : (_aVerifier && _juste == null ? 'VÉRIFIER' : 'CONTINUER'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    ]);
  }
}

/// Fiches de grammaire et d'orthographe (lexi_bibliotheque/<langue>/tuteur/
/// ressources/fiches.json), ouvertes depuis l'écran du prof.
class _LxtFiches extends StatefulWidget {
  const _LxtFiches({required this.langue});
  final String langue;

  @override
  State<_LxtFiches> createState() => _LxtFichesState();
}

class _LxtFichesState extends State<_LxtFiches> {
  final FlutterTts _tts = FlutterTts();
  List<dynamic>? _fiches;
  bool _erreur = false;
  String _cat = 'grammaire';
  Map<String, dynamic>? _ouverte;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final r = await http.get(Uri.parse(
          _lxtBase + widget.langue + '/tuteur/ressources/fiches.json'));
      if (r.statusCode == 200) {
        _fiches = (jsonDecode(utf8.decode(r.bodyBytes)) as Map)['fiches']
            as List<dynamic>;
      } else {
        _erreur = true;
      }
    } catch (_) {
      _erreur = true;
    }
    if (mounted) setState(() {});
  }

  Future<void> _dire(String t) async {
    try {
      await _tts.stop();
      await _tts.setLanguage(_lxtVoix[widget.langue] ?? 'en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.speak(t);
    } catch (_) {}
  }

  Widget _liste(_LxtCouleurs c) {
    final l = (_fiches ?? []).where((x) => (x as Map)['categorie'] == _cat).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Row(children: [
          for (final k in const [
            ['grammaire', '📘 Grammaire'],
            ['orthographe', '✏️ Orthographe']
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(k[1]),
                selected: _cat == k[0],
                selectedColor: _LxtCouleurs.violet.withOpacity(0.25),
                backgroundColor: c.carte,
                labelStyle:
                    TextStyle(color: c.texte, fontWeight: FontWeight.w800),
                onSelected: (_) => setState(() => _cat = k[0]),
              ),
            ),
        ]),
      ),
      Expanded(
        child: GridView.count(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            for (final x in l)
              GestureDetector(
                onTap: () =>
                    setState(() => _ouverte = Map<String, dynamic>.from(x as Map)),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.carte,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.bord),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((x as Map)['emoji'].toString(),
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(x['titre'].toString(),
                              style: TextStyle(
                                  color: c.texte,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25)),
                        ),
                        Text(
                            _lxtNiveaux[((x['niveau'] as num).toInt() - 1)
                                .clamp(0, 4)],
                            style: TextStyle(
                                color: _LxtCouleurs.violet,
                                fontSize: 12,
                                fontWeight: FontWeight.w800)),
                      ]),
                ),
              ),
          ],
        ),
      ),
    ]);
  }

  Widget _detail(_LxtCouleurs c) {
    final x = _ouverte!;
    Widget titre(String t) => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(t,
              style: TextStyle(
                  color: c.texte, fontSize: 17, fontWeight: FontWeight.w900)),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
      children: [
        Text(x['emoji'].toString() + '  ' + x['titre'].toString(),
            style: TextStyle(
                color: c.texte, fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(x['resume'].toString(),
            style: TextStyle(color: c.gris, fontSize: 15, height: 1.4)),
        titre('📌 La règle'),
        for (final r in (x['regles'] as List? ?? []))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('•  ',
                  style: TextStyle(
                      color: _LxtCouleurs.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
              Expanded(
                child: Text(r.toString(),
                    style:
                        TextStyle(color: c.texte, fontSize: 15, height: 1.35)),
              ),
            ]),
          ),
        titre('🔊 Exemples'),
        for (final e in (x['exemples'] as List? ?? []))
          GestureDetector(
            onTap: () => _dire((e as Map)['en'].toString()),
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
                        Text((e as Map)['en'].toString(),
                            style: TextStyle(
                                color: c.texte,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700)),
                        Text(e['fr'].toString(),
                            style: TextStyle(color: c.gris, fontSize: 14)),
                      ]),
                ),
              ]),
            ),
          ),
        if ((x['pieges'] as List? ?? []).isNotEmpty) ...[
          titre('⚠️ Attention aux pièges'),
          for (final p in (x['pieges'] as List))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _LxtCouleurs.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(p.toString(),
                  style: TextStyle(color: c.texte, fontSize: 14.5, height: 1.35)),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _LxtCouleurs();
    return Scaffold(
      backgroundColor: c.fond,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: c.texte),
                onPressed: () {
                  _tts.stop();
                  if (_ouverte != null) {
                    setState(() => _ouverte = null);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              Text('📚 Fiches',
                  style: TextStyle(
                      color: c.texte,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
            ]),
          ),
          Expanded(
            child: _fiches == null
                ? Center(
                    child: _erreur
                        ? Text('Pas de connexion internet. Réessaie plus tard.',
                            style: TextStyle(color: c.gris))
                        : const CircularProgressIndicator(
                            color: _LxtCouleurs.orange))
                : (_ouverte == null ? _liste(c) : _detail(c)),
          ),
        ]),
      ),
    );
  }
}
