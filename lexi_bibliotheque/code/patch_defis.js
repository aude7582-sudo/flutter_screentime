// Jouer : « Défier un ami » (même jeu, même niveau, mêmes cartes) + défis reçus.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`final math.Random _lxR = math.Random();`,
`// Hasard des jeux. Une « graine » partagée permet à deux amis d'avoir
// exactement les mêmes cartes et questions lors d'un défi.
math.Random _lxR = math.Random();`);
  rep(`  int? _niveau;
  int _cle = 0;
`,`  int? _niveau;
  int _cle = 0;

  // Défis entre amis.
  int _graine = 0;
  Map<String, dynamic>? _defi; // défi reçu en cours
  List<Map<String, String>>? _motsDefi;
  List<Map<String, dynamic>> _defis = [];
  List<Map<String, String>> _amis = [];
  bool _amisCharges = false;
  String _pseudo = 'Moi';
`);
  rep(`    _charger();
    lexiAcces().then(`,`    _charger();
    _chargerDefis();
    lexiAcces().then(`);
  rep(`      await _tts.setLanguage(_lxVoix[_langue] ?? 'en-US');`,
`      await _tts.setLanguage(_lxVoix[_defi == null
              ? _langue
              : (_defi!['langue'] ?? _langue).toString()] ??
          'en-US');`);
  rep(`  void _jouerNiveau(int n) {
    setState(() {
      _niveau = n;
      _cle++;
    });
  }
`,`  void _jouerNiveau(int n) {
    _graine = math.Random().nextInt(1 << 30);
    _lxR = math.Random(_graine);
    setState(() {
      _defi = null;
      _motsDefi = null;
      _niveau = n;
      _cle++;
    });
  }

  // ---- Défis entre amis
  String get _moi => currentUserUid;

  String _nomJeu(dynamic id) {
    for (final j in _jeux) {
      if (j[0] == id) return j[1] as String;
    }
    return 'Jeu';
  }

  String _emojiJeu(dynamic id) {
    for (final j in _jeux) {
      if (j[0] == id) return j[3] as String;
    }
    return '🎮';
  }

  Future<void> _chargerDefis() async {
    try {
      final db = FirebaseFirestore.instance;
      try {
        final j = await db.collection('joueurs').doc(_moi).get();
        final ps = (j.data()?['pseudo'] ?? '').toString();
        if (ps.isNotEmpty) _pseudo = ps;
      } catch (_) {}
      final a = await db
          .collection('duels')
          .where('membres', arrayContains: _moi)
          .limit(80)
          .get();
      final l = <Map<String, dynamic>>[];
      for (final d in a.docs) {
        final x = d.data();
        if (x['type'] != 'jeu') continue;
        l.add({...x, 'id': d.id});
      }
      l.sort((x, y) => _entier(y['cree']).compareTo(_entier(x['cree'])));
      _defis = l.take(12).toList();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _chargerAmis() async {
    if (_amisCharges) return;
    final db = FirebaseFirestore.instance;
    try {
      final a = await db
          .collection('amities')
          .where('uids', arrayContains: _moi)
          .limit(100)
          .get();
      final ids = <String>{};
      for (final d in a.docs) {
        for (final u in (d.data()['uids'] as List? ?? [])) {
          if (u != _moi) ids.add(u.toString());
        }
      }
      final l = <Map<String, String>>[];
      for (final id in ids.take(40)) {
        var nom = 'Ami';
        var av = '🦊';
        try {
          final j = await db.collection('joueurs').doc(id).get();
          if (j.exists) {
            nom = (j.data()?['pseudo'] ?? nom).toString();
            av = (j.data()?['avatar'] ?? av).toString();
          } else {
            final q = await db
                .collection('joueurs')
                .where('uid', isEqualTo: id)
                .limit(1)
                .get();
            if (q.docs.isNotEmpty) {
              nom = (q.docs.first.data()['pseudo'] ?? nom).toString();
              av = (q.docs.first.data()['avatar'] ?? av).toString();
            }
          }
        } catch (_) {}
        l.add({'uid': id, 'nom': nom, 'avatar': av});
      }
      _amis = l;
      _amisCharges = true;
    } catch (_) {}
  }

  /// Après une partie : envoyer le même niveau (mêmes cartes) à un ami.
  Future<void> _defier(int etoiles, int score) async {
    final jeu = _jeu;
    final niveau = _niveau;
    final graine = _graine;
    if (jeu == null || niveau == null) return;
    final p = _lxP(context);
    await _chargerAmis();
    if (!mounted) return;
    if (_amis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Ajoute d\\'abord un ami avec son code (Profil → Trouver des amis) 🦊')));
      return;
    }
    final ami = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.carte,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('⚔️ Qui veux-tu défier ?',
              style: TextStyle(
                  color: p.texte, fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
              'Ton ami jouera ' +
                  _nomJeu(jeu) +
                  ', niveau ' +
                  niveau.toString() +
                  ', avec exactement les mêmes cartes. Ton score : ' +
                  score.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 14)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView(shrinkWrap: true, children: [
              for (final a in _amis)
                ListTile(
                  onTap: () => Navigator.of(c).pop(a),
                  leading:
                      Text(a['avatar']!, style: const TextStyle(fontSize: 28)),
                  title: Text(a['nom']!,
                      style: TextStyle(
                          color: p.texte, fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.send_rounded, color: _lxOrange),
                ),
            ]),
          ),
        ]),
      ),
    );
    if (ami == null) return;
    try {
      await FirebaseFirestore.instance.collection('duels').add({
        'type': 'jeu',
        'jeu': jeu,
        'niveau': niveau,
        'langue': _langue,
        'graine': graine,
        'de': _moi,
        'deNom': _pseudo,
        'pour': ami['uid'],
        'pourNom': ami['nom'],
        'membres': [_moi, ami['uid']],
        'score_' + _moi: score,
        'etoiles_' + _moi: etoiles,
        'statut': 'attente',
        'cree': DateTime.now().millisecondsSinceEpoch,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Défi envoyé à ' +
              ami['nom']! +
              ' ⚔️ Il le trouvera dans l\\'onglet Jouer.')));
      _chargerDefis();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Le défi n\\'a pas pu être envoyé. Réessaie.')));
    }
  }

  /// Mots d'une autre langue (défi lancé dans la langue de l'ami).
  Future<List<Map<String, String>>> _motsLangue(
      String langue, int niveau) async {
    final l = <Map<String, String>>[];
    final ordre = <int>[];
    try {
      try {
        await lexiParcours(langue);
      } catch (_) {}
      final s = await FirebaseFirestore.instance
          .collection('parcours')
          .where('langue', isEqualTo: langue)
          .limit(450)
          .get();
      final docs = [...s.docs]
        ..sort((a, b) => _entier(a.data()['orderIndex'])
            .compareTo(_entier(b.data()['orderIndex'])));
      for (final doc in docs) {
        final m = doc.data();
        final t = (m['term'] ?? '').toString().trim();
        final d = (m['definition'] ?? '').toString().trim();
        if (t.isNotEmpty && d.isNotEmpty) {
          l.add({'t': t, 'd': d});
          ordre.add(_entier(m['orderIndex']));
        }
      }
    } catch (_) {}
    final lim = 20 + 10 * niveau;
    final r = <Map<String, String>>[];
    for (var i = 0; i < l.length; i++) {
      if (ordre[i] < lim) r.add(l[i]);
    }
    return r.length >= 14 ? r : l;
  }

  Future<void> _jouerDefi(Map<String, dynamic> d) async {
    final langue = (d['langue'] ?? _langue).toString();
    final niveau = _entier(d['niveau']).clamp(1, 10).toInt();
    List<Map<String, String>>? mots;
    if (langue != _langue) {
      mots = await _motsLangue(langue, niveau);
    }
    if ((mots ?? _tous).length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Les mots se chargent… réessaie dans un instant.')));
      }
      return;
    }
    if (!mounted) return;
    _graine = _entier(d['graine']);
    _lxR = math.Random(_graine);
    setState(() {
      _defi = d;
      _motsDefi = mots;
      _jeu = d['jeu'].toString();
      _niveau = niveau;
      _cle++;
    });
  }

  Future<void> _finDefi(int etoiles, int score) async {
    final d = _defi;
    if (d == null) return;
    d['score_' + _moi] = score;
    try {
      await FirebaseFirestore.instance.collection('duels').doc(d['id']).update({
        'score_' + _moi: score,
        'etoiles_' + _moi: etoiles,
        'statut': 'fini',
        'fini': DateTime.now().millisecondsSinceEpoch,
      });
      if (score > 0) {
        await _ref?.update({
          'totalXp': FieldValue.increment(score),
          'jeuxTotal': FieldValue.increment(1),
        });
      }
    } catch (_) {}
    _chargerDefis();
  }

  void _quitterDefi() {
    setState(() {
      _defi = null;
      _motsDefi = null;
      _jeu = null;
      _niveau = null;
    });
  }

  Widget _blocDefis(_LxP p) {
    final lignes = <Widget>[];
    for (final d in _defis.take(6)) {
      final recu = d['pour'] == _moi;
      final autre = (recu ? d['deNom'] : d['pourNom'] ?? 'Ton ami').toString();
      final autreUid = (recu ? d['de'] : d['pour']).toString();
      final monScore = d['score_' + _moi];
      final sonScore = d['score_' + autreUid];
      final titre = _emojiJeu(d['jeu']) +
          ' ' +
          _nomJeu(d['jeu']) +
          ' · niveau ' +
          _entier(d['niveau']).toString();
      String texte;
      Widget? action;
      if (recu && monScore == null) {
        texte = autre + ' te défie ! Score à battre : ' + _entier(sonScore).toString();
        action = ElevatedButton(
          onPressed: () => _jouerDefi(d),
          style: ElevatedButton.styleFrom(
              backgroundColor: _lxOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: const Text('Jouer',
              style: TextStyle(fontWeight: FontWeight.w900)),
        );
      } else if (sonScore == null) {
        texte = 'En attente de ' + autre + '… (ton score : ' + _entier(monScore).toString() + ')';
      } else {
        final a = _entier(monScore);
        final b = _entier(sonScore);
        texte = 'Toi ' +
            a.toString() +
            ' – ' +
            autre +
            ' ' +
            b.toString() +
            (a > b ? '  🏆 Gagné !' : (a == b ? '  🤝 Égalité' : '  😅 Perdu'));
      }
      lignes.add(Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre,
                      style: TextStyle(
                          color: p.texte,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(texte, style: TextStyle(color: p.gris, fontSize: 13.5)),
                ]),
          ),
          if (action != null) ...[const SizedBox(width: 8), action],
        ]),
      ));
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: p.carte,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('⚔️ Défis entre amis',
            style: TextStyle(
                color: p.texte, fontSize: 17, fontWeight: FontWeight.w900)),
        ...lignes,
      ]),
    );
  }
`);
  rep(`        Text('10 jeux · 10 niveaux chacun. Gagne un niveau pour débloquer le suivant !',
            style: TextStyle(color: p.gris, fontSize: 14)),
        const SizedBox(height: 16),
`,`        Text('10 jeux · 10 niveaux chacun. Gagne un niveau pour débloquer le suivant !',
            style: TextStyle(color: p.gris, fontSize: 14)),
        const SizedBox(height: 16),
        if (_defis.isNotEmpty) _blocDefis(p),
`);
  rep(`        langue: _langue,
        mots: _pool(n),
        dire: _dire,
        onGagne: (e, s) => _gagne(_jeu!, n, e, s),
        onQuitter: () => setState(() => _niveau = null),
        onSuivant: n < 10 ? () => _jouerNiveau(n + 1) : null,
        onRejouer: () => _jouerNiveau(n),
      );`,`        langue: _defi == null
            ? _langue
            : (_defi!['langue'] ?? _langue).toString(),
        mots: _motsDefi ?? _pool(n),
        dire: _dire,
        onGagne: (e, s) =>
            _defi == null ? _gagne(_jeu!, n, e, s) : _finDefi(e, s),
        onQuitter: () {
          if (_defi == null) {
            setState(() => _niveau = null);
          } else {
            _quitterDefi();
          }
        },
        onSuivant: _defi == null && n < 10 ? () => _jouerNiveau(n + 1) : null,
        onRejouer: () {
          if (_defi == null) {
            _jouerNiveau(n);
          } else {
            _quitterDefi();
          }
        },
        onDefier: _defi == null ? (e, s) => _defier(e, s) : null,
        adversaire: _defi == null
            ? null
            : (_defi!['deNom'] ?? 'Ton ami').toString(),
        scoreAdverse: _defi == null
            ? null
            : _entier(_defi!['score_' + _defi!['de'].toString()]),
      );`);
  rep(`    required this.onRejouer,
  });
  final String jeu;`,`    required this.onRejouer,
    this.onDefier,
    this.adversaire,
    this.scoreAdverse,
  });
  final _LxFin? onDefier;
  final String? adversaire;
  final int? scoreAdverse;
  final String jeu;`);
  rep(`  Widget _resultat(_LxP p) {
    final e = _etoiles!;`,`  Widget _resultatDefi(_LxP p) {
    final moi = _score;
    final lui = widget.scoreAdverse ?? 0;
    final nom = widget.adversaire ?? 'Ton ami';
    final verdict = moi > lui
        ? '🏆 Tu as gagné le défi !'
        : (moi == lui ? '🤝 Égalité !' : '😅 ' + nom + ' gagne cette fois');
    Widget carte(String qui, int s, bool gagnant) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: gagnant ? _lxOrange.withOpacity(0.15) : p.carte,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: gagnant ? _lxOrange : p.bord, width: 2),
            ),
            child: Column(children: [
              Text(qui,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: p.gris,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(s.toString(),
                  style: TextStyle(
                      color: p.texte,
                      fontSize: 30,
                      fontWeight: FontWeight.w900)),
            ]),
          ),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 30),
      children: [
        Center(
          child: Text(moi >= lui ? '🦊🏆' : '🦊💪',
              style: const TextStyle(fontSize: 70)),
        ),
        const SizedBox(height: 10),
        Text(verdict,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: p.texte, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 20),
        Row(children: [
          carte('Toi', moi, moi > lui),
          const SizedBox(width: 12),
          carte(nom, lui, lui > moi),
        ]),
        const SizedBox(height: 28),
        _lxBouton('Retour aux jeux', _lxOrange, widget.onQuitter),
      ],
    );
  }

  Widget _resultat(_LxP p) {
    if (widget.adversaire != null) return _resultatDefi(p);
    final e = _etoiles!;`);
  rep(`        _lxBouton('Rejouer', gagne ? p.doux : _lxOrange, widget.onRejouer,`,
`        if (widget.onDefier != null) ...[
          _lxBouton('⚔️ Défier un ami', const Color(0xFF7C3AED),
              () => widget.onDefier!(e, _score)),
          const SizedBox(height: 10),
        ],
        _lxBouton('Rejouer', gagne ? p.doux : _lxOrange, widget.onRejouer,`);
  window._defR=R; return c;
})
