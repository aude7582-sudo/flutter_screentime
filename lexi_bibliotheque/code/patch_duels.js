// Duels du Silence variés : moins d'ouvertures / moins de temps d'écran / zéro réseau social, 30 min à 2 h.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`  Future<void> _defier(Map<String, dynamic> ami) async {
    try {
      await _db.collection('duels').add({
`,`  static const _typesDuel = [
    ['ouvertures', '📵', 'Moins d\\'ouvertures', 'Celui qui ouvre le moins d\\'applis gagne.'],
    ['temps', '⏱️', 'Moins de temps d\\'écran', 'Celui qui passe le moins de temps sur son téléphone gagne.'],
    ['reseaux', '🚫', 'Zéro réseau social', 'Celui qui passe le moins de temps sur TikTok, Facebook, WhatsApp, YouTube… gagne.'],
  ];

  String _titreDuel(Map d) {
    final t = (d['type'] ?? 'ouvertures').toString();
    for (final x in _typesDuel) {
      if (x[0] == t) return x[1] + ' ' + x[2];
    }
    return '📵 Moins d\\'ouvertures';
  }

  String _scoreDuel(Map d, int v) {
    final t = (d['type'] ?? 'ouvertures').toString();
    if (t == 'ouvertures') return '$v ouverture' + (v > 1 ? 's' : '');
    if (v < 60) return '$v s';
    return '\${v ~/ 60} min';
  }

  Future<void> _defier(Map<String, dynamic> ami) async {
    var type = 0;
    var duree = 60;
    final choix = await showModalBottomSheet<List<Object>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _carte,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => StatefulBuilder(
        builder: (c, maj) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('⏳ Duel du Silence contre \${ami['pseudo'] ?? 'ton ami'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _texte, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            for (var i = 0; i < _typesDuel.length; i++)
              GestureDetector(
                onTap: () => maj(() => type = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: type == i ? _orange.withOpacity(0.12) : _carte,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: type == i ? _orange : _gris.withOpacity(0.3),
                        width: type == i ? 2 : 1),
                  ),
                  child: Row(children: [
                    Text(_typesDuel[i][1],
                        style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_typesDuel[i][2],
                                style: TextStyle(
                                    color: _texte,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800)),
                            Text(_typesDuel[i][3],
                                style:
                                    TextStyle(color: _gris, fontSize: 12.5)),
                          ]),
                    ),
                  ]),
                ),
              ),
            GestureDetector(
              onTap: () => maj(() => type = math.Random().nextInt(3)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('🎲 Au hasard !',
                    style: TextStyle(
                        color: _violet,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 6),
            Row(children: [
              for (final m in [30, 60, 120])
                Expanded(
                  child: GestureDetector(
                    onTap: () => maj(() => duree = m),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: duree == m ? _violet : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _violet, width: 1.5),
                      ),
                      child: Text(m < 60 ? '$m min' : '\${m ~/ 60} h',
                          style: TextStyle(
                              color: duree == m ? Colors.white : _violet,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: _bouton('⏳ Lancer le duel', _orange,
                  () => Navigator.of(c).pop(<Object>[_typesDuel[type][0], duree])),
            ),
          ]),
        ),
      ),
    );
    if (choix == null) return;
    try {
      await _db.collection('duels').add({
        'type': choix[0],
`);
  rep(`        'duree': _dureeDuel.inMilliseconds,`,`        'duree': (choix[1] as int) * 60000,`);
  rep(`        final n = await const FlutterScreentime()
            .lexiOuvertures(_entier(d['debut']), fin);`,`        final type = (d['type'] ?? 'ouvertures').toString();
        final n = type == 'ouvertures'
            ? await const FlutterScreentime()
                .lexiOuvertures(_entier(d['debut']), fin)
            : await const FlutterScreentime()
                .lexiMesure(_entier(d['debut']), fin, type);`);
  rep(`            Text('Toi : $m ouverture\${m > 1 ? 's' : ''} · $adversaire : $s',`,`            Text('Toi : ' + _scoreDuel(d, m) + ' · $adversaire : ' + _scoreDuel(d, s),`);
  rep(`        Text('⏳ Toi contre $adversaire',`,`        Text(_titreDuel(d) + ' · contre $adversaire',`);
  rep(`'⏳ Défie un ami pendant 2 heures : celui qui ouvre le moins d\\'applis gagne ! Lance un duel depuis l\\'onglet 👥 Amis. À la fin, ouvre Léxi pour envoyer ton score.',`,`'⏳ Défie un ami de 30 min à 2 h : moins d\\'ouvertures, moins de temps d\\'écran ou zéro réseau social. Lance un duel depuis 👥 Amis (bouton ⏳ Défier). À la fin, ouvre Léxi pour envoyer ton score.',`);
  window._duR=R; return c;
})
