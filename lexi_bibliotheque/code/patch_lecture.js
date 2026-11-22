// Lecture : une bibliothèque par langue (es/pt/zh dans leur dossier), voix et mots touchables (chinois inclus).
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`  static Map<String, dynamic>? catalogue;
`,`  static Map<String, dynamic>? catalogue;
  static String langue = 'en';
  static String? _langueCat;
  static String get pre => langue == 'en' ? '' : langue + '/';
`);
  rep(`    catalogue ??= await _json('catalogue.json');`,`    if (_langueCat != langue) {
      catalogue = null;
      dico = null;
      _langueCat = langue;
    }
    catalogue ??= await _json(pre + 'catalogue.json');`);
  rep(`    dico ??= await _json('dico.json');`,`    dico ??= await _json(pre + 'dico.json');`);
  rep(`    if (livres[id] != null) return livres[id];
    final l = await _json('livres/' + id + '.json');`,`    if (livres[id] != null) return livres[id];
    final l = await _json(pre + 'livres/' + id + '.json');`);
  rep(`    try {
      _acces = await lexiAcces();
    } catch (_) {}
    final c = await _LexiStock.chargerCatalogue();`,`    try {
      _acces = await lexiAcces();
    } catch (_) {}
    try {
      final q = await FirebaseFirestore.instance
          .collection('user_stats')
          .where('uid', isEqualTo: currentUserUid)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        _LexiStock.langue = (q.docs.first.data()['langue'] ?? 'en').toString();
      }
    } catch (_) {}
    final c = await _LexiStock.chargerCatalogue();`);
  { const a=`kLexiBiblio + 'couv/' + l['id'] + '.jpg'`; R.push(c.split(a).length>1?1:0); c=c.split(a).join(`kLexiBiblio + _LexiStock.pre + 'couv/' + l['id'] + '.jpg'`); }
  rep(`      await _tts.setLanguage('en-US');`,`      await _tts.setLanguage(const {
            'es': 'es-ES',
            'pt': 'pt-PT',
            'zh': 'zh-CN',
          }[_LexiStock.langue] ??
          'en-US');`);
  rep(`  static final RegExp _motRe = RegExp(r"[A-Za-zÀ-ÿ]+(?:['’][A-Za-z]+)?");
`,`  static final RegExp _motRe = RegExp(r"[A-Za-zÀ-ÿ]+(?:['’][A-Za-z]+)?");
  RegExp? _zhRe;

  // Chinois : découpe en mots grâce au dictionnaire (le plus long d'abord).
  Iterable<Match> _mots(String t) {
    if (_LexiStock.langue != 'zh') return _motRe.allMatches(t);
    if (_zhRe == null) {
      final cles = <String>{..._dico.keys};
      for (final ch in _chaps) {
        for (final w in ((ch as Map)['w'] as List? ?? [])) {
          cles.add(w[0].toString());
        }
      }
      final l = cles.where((k) => k.isNotEmpty).toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      _zhRe = RegExp(
          (l.isEmpty ? '' : l.map(RegExp.escape).join('|') + '|') +
              '[\\u4e00-\\u9fff]');
    }
    return _zhRe!.allMatches(t);
  }
`);
  rep(`      for (final m in _motRe.allMatches(txt)) {`,`      for (final m in _mots(txt)) {`);
  rep(`    if (mounted) setState(() => _dico = d ?? {});`,`    if (mounted) {
      setState(() {
        _dico = d ?? {};
        _zhRe = null;
      });
    }`);
  rep(`                  ' » en anglais. +30 ⭐',`,`                  ' » en ' +
                  (const {
                        'es': 'espagnol',
                        'pt': 'portugais',
                        'zh': 'chinois',
                      }[_LexiStock.langue] ??
                      'anglais') +
                  '. +30 ⭐',`);
  window._lecR=R; return c;
})
