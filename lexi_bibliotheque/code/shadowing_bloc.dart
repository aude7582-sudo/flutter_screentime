
// ===========================================================================
// SHADOWING LÉXI : écoute une phrase, répète-la en même temps que la voix,
// puis dis-la au micro (speech_to_text) : Léxi vérifie mot par mot. 4 niveaux de 30 phrases
// (lus sur GitHub : lexi_bibliotheque/<langue>/shadowing/shadowing.json).
// Progression gardée sur le téléphone, séparée par langue.

class _LxShadowing extends StatefulWidget {
  const _LxShadowing({super.key, required this.langue});
  final String langue;

  @override
  State<_LxShadowing> createState() => _LxShadowingState();
}

class _LxShadowingState extends State<_LxShadowing> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _sttPret = false;
  bool _charge = false;
  bool _absent = false;
  List<dynamic> _niveaux = [];
  Map<String, List<int>> _reussies = {};
  int? _niv; // niveau ouvert
  int _i = 0; // phrase affichée
  bool _traduction = true;
  bool _ecoute = false;
  int? _score; // % de mots bien dits
  List<bool> _motsOk = [];
  String _entendu = '';
  bool _sons = true;

  String get _cle => 'lexi_shadow_' + widget.langue;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _tts.stop();
    try {
      _stt.cancel();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final pr = await SharedPreferences.getInstance();
      _sons = pr.getBool('lexi_sons') ?? true;
      final brut = pr.getString(_cle);
      if (brut != null) {
        final m = jsonDecode(brut) as Map<String, dynamic>;
        _reussies = m.map((k, v) =>
            MapEntry(k, (v as List).map((e) => (e as num).toInt()).toList()));
      }
    } catch (_) {}
    try {
      final r = await http.get(Uri.parse(
          _lxtBase + widget.langue + '/shadowing/shadowing.json'));
      if (r.statusCode == 200) {
        final doc = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
        _niveaux = doc['niveaux'] as List<dynamic>;
      } else {
        _absent = true;
      }
    } catch (_) {
      _absent = true;
    }
    if (mounted) setState(() => _charge = true);
  }

  Future<void> _sauver() async {
    try {
      final pr = await SharedPreferences.getInstance();
      await pr.setString(_cle, jsonEncode(_reussies));
    } catch (_) {}
  }

  void _son(String type) {
    if (!_sons) return;
    try {
      const FlutterScreentime().lexiSon(type);
    } catch (_) {}
  }

  Map<String, dynamic> get _phrase =>
      ((_niveaux[_niv!] as Map)['phrases'] as List)[_i] as Map<String, dynamic>;

  String get _idNiv => (_niveaux[_niv!] as Map)['id'].toString();

  Future<void> _dire({bool lent = false}) async {
    try {
      await _tts.stop();
      await _tts.setLanguage(_lxtVoix[widget.langue] ?? 'en-US');
      await _tts.setSpeechRate(lent ? 0.28 : 0.45);
      await _tts.speak((_phrase[widget.langue] ?? '').toString());
    } catch (_) {}
  }

  static List<String> _mots(String t) => t
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll(RegExp(r"[^a-z0-9à-ÿ' ]"), ' ')
      .split(RegExp(r'\s+'))
      .where((m) => m.isNotEmpty)
      .toList();

  // Note une proposition : chaque mot de la phrase est-il entendu ?
  List<bool> _comparer(List<String> attendu, List<String> dit) {
    final reste = List<String>.from(dit);
    return [
      for (final m in attendu)
        () {
          final k = reste.indexWhere((d) =>
              d == m || d.replaceAll("'", '') == m.replaceAll("'", ''));
          if (k < 0) return false;
          reste.removeAt(k);
          return true;
        }()
    ];
  }

  // Écoute le micro (même moteur que le reste de Léxi) et renvoie les
  // propositions entendues, ou null.
  Future<List<String>?> _ecouter() async {
    try {
      if (!_sttPret) {
        _sttPret = await _stt.initialize();
      }
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
        localeId: (_lxtVoix[widget.langue] ?? 'en-US').replaceAll('-', '_'),
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      );
      return await fin.future.timeout(const Duration(seconds: 20),
          onTimeout: () => dernier.isEmpty ? null : dernier);
    } catch (_) {
      return null;
    }
  }

  Future<void> _parler() async {
    if (_ecoute) return;
    await _tts.stop();
    setState(() => _ecoute = true);
    final props = await _ecouter();
    if (!mounted) return;
    if (props == null || props.isEmpty) {
      setState(() => _ecoute = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Je n\'ai rien entendu. Réessaie en parlant bien près du micro 🎤')));
      return;
    }
    final attendu = _mots((_phrase[widget.langue] ?? '').toString());
    var meilleur = <bool>[];
    var texte = props.first;
    var mieux = -1;
    for (final p in props) {
      final ok = _comparer(attendu, _mots(p));
      final n = ok.where((b) => b).length;
      if (n > mieux) {
        mieux = n;
        meilleur = ok;
        texte = p;
      }
    }
    final score =
        attendu.isEmpty ? 0 : (100 * mieux / attendu.length).round();
    final reussi = score >= 80;
    if (reussi) {
      final l = _reussies[_idNiv] ?? <int>[];
      if (!l.contains(_i)) l.add(_i);
      _reussies[_idNiv] = l;
      await _sauver();
    }
    _son(reussi ? 'bon' : 'faux');
    setState(() {
      _ecoute = false;
      _score = score;
      _motsOk = meilleur;
      _entendu = texte;
    });
  }

  void _aller(int i) {
    _tts.stop();
    setState(() {
      _i = i;
      _score = null;
      _motsOk = [];
      _entendu = '';
    });
  }

  // ---------------------------------------------------------------- écrans

  Widget _accueil(_LxtCouleurs c) {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 24), children: [
      Text('🗣️ Shadowing',
          style: TextStyle(
              color: c.texte, fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text(
          'Écoute la phrase, puis répète-la en même temps que la voix, comme son ombre. '
          'Quand tu es prêt, appuie sur 🎤 et dis-la : Léxi vérifie chaque mot.',
          style: TextStyle(color: c.gris, fontSize: 14, height: 1.4)),
      const SizedBox(height: 16),
      for (var n = 0; n < _niveaux.length; n++) _carteNiveau(c, n),
    ]);
  }

  Widget _carteNiveau(_LxtCouleurs c, int n) {
    final niv = _niveaux[n] as Map;
    final total = (niv['phrases'] as List).length;
    final faites = (_reussies[niv['id'].toString()] ?? const <int>[]).length;
    const emojis = ['🌱', '🌿', '🌳', '🏆'];
    return GestureDetector(
      onTap: () => setState(() {
        _niv = n;
        final l = _reussies[niv['id'].toString()] ?? const <int>[];
        _i = 0;
        while (_i < total - 1 && l.contains(_i)) {
          _i++;
        }
        _score = null;
        _motsOk = [];
        _entendu = '';
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.carte,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.bord),
        ),
        child: Row(children: [
          Text(emojis[n % emojis.length], style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(niv['nom'].toString(),
                  style: TextStyle(
                      color: c.texte, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : faites / total,
                  minHeight: 8,
                  backgroundColor: c.doux,
                  color: _LxtCouleurs.orange,
                ),
              ),
              const SizedBox(height: 4),
              Text('$faites / $total phrases réussies',
                  style: TextStyle(color: c.gris, fontSize: 13)),
            ]),
          ),
          Icon(Icons.chevron_right, color: c.gris),
        ]),
      ),
    );
  }

  Widget _bouton(_LxtCouleurs c, String texte, VoidCallback? f,
      {Color? fond, Color? encre}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: f,
        style: ElevatedButton.styleFrom(
          backgroundColor: fond ?? c.doux,
          foregroundColor: encre ?? c.texte,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(texte,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _exercice(_LxtCouleurs c) {
    final niv = _niveaux[_niv!] as Map;
    final phrases = niv['phrases'] as List;
    final texte = (_phrase[widget.langue] ?? '').toString();
    final fr = (_phrase['fr'] ?? '').toString();
    final faites = _reussies[_idNiv] ?? const <int>[];
    final mots = texte.split(' ');
    // Couleur de chaque mot après l'essai (vert = bien dit, rouge = à revoir).
    final couleurs = <Color>[];
    var j = 0;
    for (final m in mots) {
      final propre = _mots(m);
      if (_motsOk.isEmpty || propre.isEmpty) {
        couleurs.add(c.texte);
        continue;
      }
      var ok = true;
      for (var q = 0; q < propre.length; q++) {
        if (j + q >= _motsOk.length || !_motsOk[j + q]) ok = false;
      }
      j += propre.length;
      couleurs.add(ok ? _LxtCouleurs.vert : _LxtCouleurs.rouge);
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 18, 0),
        child: Row(children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: c.texte),
            onPressed: () {
              _tts.stop();
              setState(() => _niv = null);
            },
          ),
          Expanded(
            child: Text(niv['nom'].toString(),
                style: TextStyle(
                    color: c.texte, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          Text('${_i + 1} / ${phrases.length}',
              style: TextStyle(color: c.gris, fontWeight: FontWeight.w700)),
        ]),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 20), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.carte,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: faites.contains(_i) ? _LxtCouleurs.vert : c.bord,
                  width: faites.contains(_i) ? 2 : 1),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (faites.contains(_i))
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('✅ Déjà réussie',
                      style: TextStyle(
                          color: _LxtCouleurs.vert, fontWeight: FontWeight.w800)),
                ),
              // La phrase : en vert / rouge mot par mot après l'essai.
              Wrap(spacing: 6, runSpacing: 4, children: [
                for (var k = 0; k < mots.length; k++)
                  Text(mots[k],
                      style: TextStyle(
                          color: couleurs[k],
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.3)),
              ]),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(() => _traduction = !_traduction),
                child: Text(
                    _traduction ? fr : 'Toucher pour voir la traduction',
                    style: TextStyle(
                        color: c.gris,
                        fontSize: 15,
                        fontStyle: FontStyle.italic)),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            _bouton(c, '🔊 Écouter', () => _dire()),
            const SizedBox(width: 10),
            _bouton(c, '🐢 Lentement', () => _dire(lent: true)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _bouton(c, _ecoute ? '🎤 J\'écoute…' : '🎤 À toi de dire !',
                _ecoute ? null : _parler,
                fond: _LxtCouleurs.violet, encre: Colors.white),
          ]),
          const SizedBox(height: 10),
          Text(
              'Astuce : écoute 2 ou 3 fois en parlant EN MÊME TEMPS que la voix, '
              'puis dis la phrase seul au micro.',
              style: TextStyle(color: c.gris, fontSize: 13, height: 1.35)),
          if (_score != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_score! >= 80 ? _LxtCouleurs.vert : _LxtCouleurs.orange)
                    .withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    _score! >= 95
                        ? '🌟 Parfait ! $_score %'
                        : _score! >= 80
                            ? '✅ Bravo ! $_score %'
                            : '💪 Presque : $_score %. Réécoute les mots en rouge et réessaie.',
                    style: TextStyle(
                        color: c.texte,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Léxi a entendu : « $_entendu »',
                    style: TextStyle(color: c.gris, fontSize: 14)),
              ]),
            ),
          ],
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Row(children: [
          _bouton(c, '◀ Avant', _i > 0 ? () => _aller(_i - 1) : null),
          const SizedBox(width: 10),
          _bouton(c, 'Suivante ▶',
              _i < phrases.length - 1 ? () => _aller(_i + 1) : null,
              fond: _LxtCouleurs.orange, encre: Colors.white),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final c = _LxtCouleurs();
    if (!_charge) {
      return const Center(
          child: CircularProgressIndicator(color: _LxtCouleurs.orange));
    }
    if (_absent || _niveaux.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Le Shadowing arrive bientôt dans cette langue 🦊',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.gris, fontSize: 16)),
        ),
      );
    }
    return Container(
        color: c.fond, child: _niv == null ? _accueil(c) : _exercice(c));
  }
}
