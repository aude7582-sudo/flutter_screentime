// Mémoire : on montre toutes les cartes 3 secondes (3, 2, 1) puis on les ferme.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`  int _coups = 0;
  bool _bloque = false;
  late int _paires;
`,`  int _coups = 0;
  bool _bloque = false;
  late int _paires;
  bool _apercu = true; // on montre les cartes au début
  int _compte = 3;
`);
  rep(`    _cartes.shuffle(_lxR);
  }

  void _retourner(int i) {
    if (_bloque ||`,`    _cartes.shuffle(_lxR);
    _lancerApercu();
  }

  // 3… 2… 1… puis toutes les cartes se ferment
  Future<void> _lancerApercu() async {
    for (var n = 3; n >= 1; n--) {
      if (!mounted) return;
      setState(() => _compte = n);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => _apercu = false);
  }

  void _retourner(int i) {
    if (_apercu || _bloque ||`);
  rep(`    final col = _cartes.length > 12 ? 4 : 3;
    return Column(children: [
`,`    final col = _cartes.length > 12 ? 4 : 3;
    return Column(children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _apercu
            ? Container(
                key: ValueKey(_compte),
                margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.a.couleur.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Mémorise les cartes !  ',
                      style: TextStyle(
                          color: p.texte,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  Text(_compte.toString(),
                      style: TextStyle(
                          color: widget.a.couleur,
                          fontSize: 28,
                          fontWeight: FontWeight.w900)),
                ]),
              )
            : const SizedBox(key: ValueKey('jeu'), height: 0),
      ),
`);
  rep(`            final visible = _ouvertes.contains(i) || _trouvees.contains(i);`,
      `            final visible = _apercu ||
                _ouvertes.contains(i) ||
                _trouvees.contains(i);`);
  window._memR=R; return c;
})
