// Jouer : lancer un défi en direct (accepté depuis la barre du bas) + score de l'ami en direct.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`  String _pseudo = 'Moi';
`,`  String _pseudo = 'Moi';
  Timer? _tDirect;
  bool _directEnCours = false;
`);
  rep(`    _chargerDefis();
    lexiAcces().then(`,`    _chargerDefis();
    _tDirect = Timer.periodic(
        const Duration(seconds: 2), (_) => _verifierDirect());
    lexiAcces().then(`);
  rep(`    _tts.stop();
    super.dispose();`,`    _tDirect?.cancel();
    _tts.stop();
    super.dispose();`);
  rep(`  void _quitterDefi() {`,`  /// Défi en direct accepté (par moi ou par mon ami) : on lance la partie.
  Future<void> _verifierDirect() async {
    if (_directEnCours || _tous.length < 6) return;
    _directEnCours = true;
    try {
      final pr = await SharedPreferences.getInstance();
      await pr.reload();
      final id = pr.getString('lexi_direct');
      if (id != null && id.isNotEmpty) {
        await pr.remove('lexi_direct');
        final doc = await FirebaseFirestore.instance
            .collection('duels')
            .doc(id)
            .get();
        final x = doc.data();
        if (x != null && mounted) {
          await _jouerDefi({...x, 'id': doc.id});
        }
      }
    } catch (_) {}
    _directEnCours = false;
  }

  void _quitterDefi() {`);
  rep(`        adversaire: _defi == null
            ? null
            : (_defi!['deNom'] ?? 'Ton ami').toString(),
        scoreAdverse: _defi == null
            ? null
            : _entier(_defi!['score_' + _defi!['de'].toString()]),`,`        adversaire: _defi == null
            ? null
            : ((_defi!['de'] == _moi ? _defi!['pourNom'] : _defi!['deNom']) ??
                    'Ton ami')
                .toString(),
        adversaireUid: _defi == null
            ? null
            : (_defi!['de'] == _moi ? _defi!['pour'] : _defi!['de'])
                .toString(),
        scoreAdverse: _defi == null
            ? null
            : _entier(_defi!['score_' +
                (_defi!['de'] == _moi ? _defi!['pour'] : _defi!['de'])
                    .toString()]),
        duelId: _defi != null && _defi!['direct'] == true
            ? _defi!['id'].toString()
            : null,`);
  rep(`    this.scoreAdverse,
  });
  final _LxFin? onDefier;
  final String? adversaire;
  final int? scoreAdverse;`,`    this.scoreAdverse,
    this.adversaireUid,
    this.duelId,
  });
  final _LxFin? onDefier;
  final String? adversaire;
  final int? scoreAdverse;
  final String? adversaireUid;
  final String? duelId; // défi en direct : score de l'ami lu en direct`);
  rep(`  Widget _resultatDefi(_LxP p) {
    final moi = _score;
    final lui = widget.scoreAdverse ?? 0;`,`  Widget _resultatDefi(_LxP p) {
    final id = widget.duelId;
    final adv = widget.adversaireUid;
    if (id == null || adv == null) {
      return _resultatDefiCorps(p, widget.scoreAdverse ?? 0);
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('duels').doc(id).snapshots(),
      builder: (c, s) {
        final v = s.data?.data()?['score_' + adv];
        if (v is! num) return _attenteAdversaire(p);
        return _resultatDefiCorps(p, v.toInt());
      },
    );
  }

  Widget _attenteAdversaire(_LxP p) => ListView(
        padding: const EdgeInsets.fromLTRB(26, 40, 26, 30),
        children: [
          const Center(child: Text('⏳', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 10),
          Text('Ton score : ' + _score.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: p.texte, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text((widget.adversaire ?? 'Ton ami') + ' joue encore…',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 16)),
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator(color: _lxOrange)),
          const SizedBox(height: 30),
          _lxBouton('Retour aux jeux', p.doux, widget.onQuitter),
        ],
      );

  Widget _resultatDefiCorps(_LxP p, int lui) {
    final moi = _score;`);
  rep(`    for (final d in _defis.take(6)) {
`,`    for (final d in _defis.take(6)) {
      if (d['direct'] == true &&
          d['statut'] != 'accepte' &&
          d['statut'] != 'fini') continue;
`);
  window._dirR=R; return c;
})
