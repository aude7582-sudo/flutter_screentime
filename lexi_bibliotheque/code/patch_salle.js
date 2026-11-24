// Jouer : « Partie à plusieurs » — chacun sur son téléphone, avec un code à 5 chiffres (2 à 8 joueurs).
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  // 1. Carte d'entrée dans la liste des jeux.
  rep(`        if (_defis.isNotEmpty) _blocDefis(p),
`,`        if (_defis.isNotEmpty) _blocDefis(p),
        _carteSalle(p),
        const SizedBox(height: 16),
`);
  // 2. Ouverture de la salle + fin de partie en salle.
  rep(`  Future<void> _finDefi(int etoiles, int score) async {
    final d = _defi;
    if (d == null) return;
`,`  Widget _carteSalle(_LxP p) => InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _ouvrirSalle,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(children: [
            const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 38)),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Partie à plusieurs',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    SizedBox(height: 3),
                    Text(
                        'Jouez ensemble, chacun sur son téléphone, avec un code. De 2 à 8 joueurs !',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.3)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 30),
          ]),
        ),
      );

  Future<void> _ouvrirSalle() async {
    final r = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _LxSalle(
          moi: _moi,
          pseudo: _pseudo,
          langue: _langue,
          jeux: [
            for (final j in _jeux) <Object>[j[0], j[1], j[3], j[4]]
          ],
        ),
      ),
    );
    if (r == null || !mounted) return;
    await _jouerDefi({...r, 'de': '', 'deNom': 'tes amis'});
  }

  Future<void> _finSalle(Map<String, dynamic> d, int etoiles, int score) async {
    try {
      await FirebaseFirestore.instance
          .collection('salles')
          .doc(d['salle'].toString())
          .update({
        'joueurs.' + _moi + '.score': score,
        'joueurs.' + _moi + '.etoiles': etoiles,
      });
      if (score > 0) {
        await _ref?.update({
          'totalXp': FieldValue.increment(score),
          'jeuxTotal': FieldValue.increment(1),
        });
      }
    } catch (_) {}
  }

  Future<void> _finDefi(int etoiles, int score) async {
    final d = _defi;
    if (d == null) return;
    if (d['salle'] != null) {
      await _finSalle(d, etoiles, score);
      return;
    }
`);
  // 3. La partie reçoit le code de la salle.
  rep(`        duelId: _defi != null && _defi!['direct'] == true
            ? _defi!['id'].toString()
            : null,
      );`,`        duelId: _defi != null && _defi!['direct'] == true
            ? _defi!['id'].toString()
            : null,
        salle: _defi?['salle']?.toString(),
      );`);
  rep(`    this.adversaireUid,
    this.duelId,
  });`,`    this.adversaireUid,
    this.duelId,
    this.salle,
  });
  final String? salle; // partie à plusieurs : classement en direct`);
  rep(`    if (widget.adversaire != null) return _resultatDefi(p);`,`    if (widget.salle != null) {
      return _LxSalleClassement(
          code: widget.salle!, monScore: _score, onQuitter: widget.onQuitter);
    }
    if (widget.adversaire != null) return _resultatDefi(p);`);

  c = c.replace(/\s*$/, '\n') + `
// ---------------------------------------------------------------------------
// Partie à plusieurs : chacun sur son téléphone, avec un code à 5 chiffres.

int _lxsN(dynamic v) => v is num ? v.toInt() : 0;

String _lxsInitiale(String n) =>
    n.trim().isEmpty ? '?' : n.trim().substring(0, 1).toUpperCase();

class _LxSalle extends StatefulWidget {
  const _LxSalle({
    required this.moi,
    required this.pseudo,
    required this.langue,
    required this.jeux,
  });
  final String moi;
  final String pseudo;
  final String langue;
  final List<List<Object>> jeux; // id, nom, emoji, couleur

  @override
  State<_LxSalle> createState() => _LxSalleState();
}

class _LxSalleState extends State<_LxSalle> {
  final _db = FirebaseFirestore.instance;
  final _champ = TextEditingController();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _abo;
  Map<String, dynamic>? _salle;
  String? _code;
  bool _hote = false;
  bool _occupe = false;
  bool _parti = false;
  String _jeu = 'paires';
  int _niveau = 3;

  @override
  void dispose() {
    _abo?.cancel();
    _champ.dispose();
    if (!_parti) _quitter();
    super.dispose();
  }

  void _message(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Map<String, dynamic> _moiJoueur() => {
        'nom': widget.pseudo,
        'arrive': DateTime.now().millisecondsSinceEpoch,
      };

  Future<void> _quitter() async {
    final code = _code;
    if (code == null) return;
    try {
      final ref = _db.collection('salles').doc(code);
      if (_hote) {
        await ref.delete();
      } else {
        await ref.update({'joueurs.' + widget.moi: FieldValue.delete()});
      }
    } catch (_) {}
  }

  void _ecouter(String code) {
    _abo?.cancel();
    _abo = _db.collection('salles').doc(code).snapshots().listen((s) {
      if (!mounted) return;
      final x = s.data();
      if (x == null) {
        if (_code != null && !_hote) {
          _code = null;
          _message('L\\'hôte a fermé la partie.');
        }
        setState(() => _salle = null);
        return;
      }
      setState(() => _salle = x);
      final joueurs = (x['joueurs'] as Map?) ?? {};
      if (!_parti && x['statut'] == 'partie' && joueurs.containsKey(widget.moi)) {
        _parti = true;
        Navigator.of(context).pop(<String, dynamic>{
          'jeu': x['jeu'],
          'niveau': x['niveau'],
          'langue': x['langue'],
          'graine': x['graine'],
          'salle': code,
        });
      }
    }, onError: (_) {});
  }

  Future<void> _creer() async {
    if (_occupe) return;
    setState(() => _occupe = true);
    final r = math.Random();
    for (var essai = 0; essai < 6 && _code == null; essai++) {
      final code = (10000 + r.nextInt(90000)).toString();
      final ref = _db.collection('salles').doc(code);
      try {
        final ex = await ref.get();
        if (ex.exists) continue;
        await ref.set({
          'hote': widget.moi,
          'hoteNom': widget.pseudo,
          'jeu': _jeu,
          'niveau': _niveau,
          'langue': widget.langue,
          'statut': 'attente',
          'cree': DateTime.now().millisecondsSinceEpoch,
          'joueurs': {widget.moi: _moiJoueur()},
        });
        _hote = true;
        _code = code;
        _ecouter(code);
      } catch (_) {
        break;
      }
    }
    if (_code == null) _message('Oups, vérifie ta connexion et réessaie.');
    if (mounted) setState(() => _occupe = false);
  }

  Future<void> _rejoindre() async {
    final code = _champ.text.trim();
    if (code.length != 5) {
      _message('Le code a 5 chiffres.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _occupe = true);
    try {
      final ref = _db.collection('salles').doc(code);
      final s = await ref.get();
      final x = s.data();
      if (x == null) {
        _message('Aucune partie avec ce code. Vérifie les chiffres.');
      } else if (x['statut'] != 'attente') {
        _message('Cette partie a déjà commencé.');
      } else if (((x['joueurs'] as Map?) ?? {}).length >= 8 &&
          !((x['joueurs'] as Map?) ?? {}).containsKey(widget.moi)) {
        _message('La partie est pleine (8 joueurs).');
      } else {
        await ref.update({'joueurs.' + widget.moi: _moiJoueur()});
        _hote = x['hote'] == widget.moi;
        _code = code;
        _ecouter(code);
      }
    } catch (_) {
      _message('Oups, vérifie ta connexion et réessaie.');
    }
    if (mounted) setState(() => _occupe = false);
  }

  Future<void> _lancer() async {
    final code = _code;
    if (code == null) return;
    try {
      await _db.collection('salles').doc(code).update({
        'statut': 'partie',
        'graine': math.Random().nextInt(1 << 30),
        'debut': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {
      _message('Oups, vérifie ta connexion et réessaie.');
    }
  }

  String _nomJeu(dynamic id) {
    for (final j in widget.jeux) {
      if (j[0] == id) return j[2].toString() + ' ' + j[1].toString();
    }
    return id.toString();
  }

  Widget _carte(_LxP p, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.carte,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.bord),
        ),
        child: child,
      );

  Widget _titre(_LxP p, String t) => Text(t,
      style: TextStyle(color: p.texte, fontSize: 19, fontWeight: FontWeight.w900));

  Widget _sous(_LxP p, String t) =>
      Text(t, style: TextStyle(color: p.gris, fontSize: 14, height: 1.35));

  @override
  Widget build(BuildContext context) {
    final p = _lxP(context);
    return Scaffold(
      backgroundColor: p.fond,
      appBar: AppBar(
        backgroundColor: p.fond,
        foregroundColor: p.texte,
        elevation: 0,
        title: Text('Partie à plusieurs',
            style: TextStyle(color: p.texte, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(child: _code == null ? _accueil(p) : _attente(p)),
    );
  }

  Widget _accueil(_LxP p) {
    const niveaux = [
      [2, 'Facile'],
      [5, 'Moyen'],
      [8, 'Difficile'],
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
      children: [
        const Center(child: Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 56))),
        const SizedBox(height: 6),
        Text(
            'Jouez ensemble, chacun sur son téléphone !\\nLe même jeu, les mêmes mots, et un classement à la fin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.gris, fontSize: 15, height: 1.4)),
        const SizedBox(height: 20),
        _carte(
          p,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _titre(p, '🎲 Créer une partie'),
            const SizedBox(height: 4),
            _sous(p, 'Choisis le jeu et la difficulté, puis donne le code à tes amis.'),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final j in widget.jeux)
                ChoiceChip(
                  label: Text(j[2].toString() + ' ' + j[1].toString()),
                  selected: _jeu == j[0],
                  onSelected: (_) => setState(() => _jeu = j[0].toString()),
                  selectedColor: Color(j[3] as int).withOpacity(0.3),
                  backgroundColor: p.doux,
                  labelStyle:
                      TextStyle(color: p.texte, fontWeight: FontWeight.w700),
                ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              for (final n in niveaux)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: SizedBox(
                          width: double.infinity,
                          child: Text(n[1] as String,
                              textAlign: TextAlign.center)),
                      selected: _niveau == n[0],
                      onSelected: (_) =>
                          setState(() => _niveau = n[0] as int),
                      selectedColor: _lxOrange.withOpacity(0.3),
                      backgroundColor: p.doux,
                      labelStyle: TextStyle(
                          color: p.texte, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 16),
            _lxBouton(_occupe ? 'Un instant…' : 'Créer la partie', _lxOrange,
                _occupe ? null : _creer),
          ]),
        ),
        const SizedBox(height: 16),
        _carte(
          p,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _titre(p, '🔑 Rejoindre une partie'),
            const SizedBox(height: 4),
            _sous(p, 'Tape le code à 5 chiffres affiché sur le téléphone de ton ami.'),
            const SizedBox(height: 14),
            TextField(
              controller: _champ,
              keyboardType: TextInputType.number,
              maxLength: 5,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: p.texte,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10),
              decoration: InputDecoration(
                counterText: '',
                hintText: '00000',
                hintStyle: TextStyle(color: p.gris.withOpacity(0.4)),
                filled: true,
                fillColor: p.doux,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _lxBouton('Rejoindre ➜', const Color(0xFF7C3AED),
                _occupe ? null : _rejoindre),
          ]),
        ),
      ],
    );
  }

  Widget _attente(_LxP p) {
    final x = _salle;
    if (x == null) {
      return const Center(child: CircularProgressIndicator(color: _lxOrange));
    }
    final joueurs = ((x['joueurs'] as Map?) ?? {}).entries.toList()
      ..sort((a, b) => _lxsN((a.value as Map?)?['arrive'])
          .compareTo(_lxsN((b.value as Map?)?['arrive'])));
    final assez = joueurs.length >= 2;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
      children: [
        Text(_hote ? 'Donne ce code à tes amis 👇' : 'Tu es dans la partie ! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.gris, fontSize: 15)),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: p.carte,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _lxOrange, width: 2),
            ),
            child: SelectableText(_code ?? '',
                style: TextStyle(
                    color: p.texte,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10)),
          ),
        ),
        const SizedBox(height: 16),
        _carte(
          p,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _titre(p, _nomJeu(x['jeu'])),
            const SizedBox(height: 4),
            _sous(
                p,
                'Niveau ' +
                    _lxsN(x['niveau']).toString() +
                    ' · Langue : ' +
                    (x['langue'] ?? 'en').toString().toUpperCase() +
                    ' · Hôte : ' +
                    (x['hoteNom'] ?? '').toString()),
          ]),
        ),
        const SizedBox(height: 16),
        Text('Joueurs (' + joueurs.length.toString() + '/8)',
            style: TextStyle(
                color: p.texte, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final e in joueurs)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: p.carte,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: e.key == widget.moi ? _lxOrange : p.bord),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: _lxOrange.withOpacity(0.2),
                child: Text(
                    _lxsInitiale(((e.value as Map?)?['nom'] ?? '').toString()),
                    style: const TextStyle(
                        color: _lxOrange, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    ((e.value as Map?)?['nom'] ?? 'Joueur').toString() +
                        (e.key == widget.moi ? ' (toi)' : ''),
                    style: TextStyle(
                        color: p.texte,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              if (e.key == x['hote'])
                const Text('👑', style: TextStyle(fontSize: 18)),
            ]),
          ),
        const SizedBox(height: 18),
        if (_hote)
          _lxBouton(
              assez
                  ? 'Lancer la partie 🚀'
                  : 'En attente d\\'au moins un ami…',
              assez ? const Color(0xFF16A34A) : p.doux,
              assez ? _lancer : null,
              texte: assez ? null : p.gris)
        else
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: _lxOrange)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                  'En attente que ' +
                      (x['hoteNom'] ?? 'l\\'hôte').toString() +
                      ' lance la partie…',
                  style: TextStyle(color: p.gris, fontSize: 14)),
            ),
          ]),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_hote ? 'Annuler la partie' : 'Quitter la partie',
                style: TextStyle(color: p.gris)),
          ),
        ),
      ],
    );
  }
}

/// Classement en direct à la fin d'une partie à plusieurs.
class _LxSalleClassement extends StatelessWidget {
  const _LxSalleClassement({
    required this.code,
    required this.monScore,
    required this.onQuitter,
  });
  final String code;
  final int monScore;
  final VoidCallback onQuitter;

  @override
  Widget build(BuildContext context) {
    final p = _lxP(context);
    final moi = currentUserUid;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('salles')
          .doc(code)
          .snapshots(),
      builder: (c, s) {
        final x = s.data?.data() ?? {};
        final tous = ((x['joueurs'] as Map?) ?? {}).entries.toList();
        final finis = tous
            .where((e) => (e.value as Map?)?['score'] is num)
            .toList()
          ..sort((a, b) => _lxsN((b.value as Map)['score'])
              .compareTo(_lxsN((a.value as Map)['score'])));
        final enCours =
            tous.where((e) => (e.value as Map?)?['score'] is! num).toList();
        String nom(MapEntry e) =>
            ((e.value as Map?)?['nom'] ?? 'Joueur').toString() +
            (e.key == moi ? ' (toi)' : '');
        const medailles = ['🥇', '🥈', '🥉'];
        Widget ligne(String gauche, String n, String droite, bool estMoi) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: p.carte,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: estMoi ? _lxOrange : p.bord,
                    width: estMoi ? 2 : 1),
              ),
              child: Row(children: [
                SizedBox(
                    width: 36,
                    child: Text(gauche,
                        style: TextStyle(
                            color: p.texte,
                            fontSize: 20,
                            fontWeight: FontWeight.w900))),
                Expanded(
                    child: Text(n,
                        style: TextStyle(
                            color: p.texte,
                            fontSize: 15,
                            fontWeight: FontWeight.w700))),
                Text(droite,
                    style: TextStyle(
                        color: p.gris,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ]),
            );
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
          children: [
            const Center(child: Text('🏆', style: TextStyle(fontSize: 64))),
            const SizedBox(height: 6),
            Text(
                enCours.isEmpty && finis.isNotEmpty
                    ? '🎉 ' + nom(finis.first) + ' gagne !'
                    : 'Ton score : ' + monScore.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: p.texte,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(
                enCours.isEmpty
                    ? 'Classement final · partie ' + code
                    : 'Classement en direct · partie ' + code,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.gris, fontSize: 14)),
            const SizedBox(height: 18),
            for (var i = 0; i < finis.length; i++)
              ligne(
                  i < 3 ? medailles[i] : (i + 1).toString() + '.',
                  nom(finis[i]),
                  _lxsN((finis[i].value as Map)['score']).toString() + ' pts',
                  finis[i].key == moi),
            for (final e in enCours)
              ligne('⏳', nom(e), 'joue encore…', e.key == moi),
            const SizedBox(height: 18),
            _lxBouton('Retour aux jeux', p.doux, onQuitter, texte: p.texte),
          ],
        );
      },
    );
  }
}
`;
  window._saR=R; return c;
})
