  // Progression de chaque langue (leçons, mots, étoiles des jeux).
  Widget _mesLangues() {
    const langues = [
      ['en', '🇬🇧', 'Anglais'],
      ['es', '🇪🇸', 'Espagnol'],
      ['pt', '🇵🇹', 'Portugais'],
      ['zh', '🇨🇳', 'Mandarin'],
    ];
    final actuelle = (_d['langue'] ?? 'en').toString();
    int etoiles(String l) {
      final m = _d[l == 'en' ? 'jeuxNiv' : 'jeuxNiv_' + l];
      var t = 0;
      if (m is Map) {
        for (final j in m.values) {
          if (j is Map) {
            for (final v in j.values) {
              t += _entier(v);
            }
          }
        }
      }
      return t;
    }

    final lignes = <Widget>[];
    for (final l in langues) {
      final mots =
          _entier(_d[l[0] == 'en' ? 'currentIndex' : 'currentIndex_' + l[0]]);
      final e = etoiles(l[0]);
      final enCours = l[0] == actuelle;
      if (mots == 0 && e == 0 && !enCours) continue;
      lignes.add(Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: _carte,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: enCours ? _orange : _bord, width: enCours ? 2 : 1.5),
        ),
        child: Row(children: [
          Text(l[1], style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l[2] + (enCours ? '  · en cours' : ''),
                  style: TextStyle(
                      color: _texte,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                  'Niveau ${mots ~/ 10 + 1} · $mots mots appris · ⭐ $e dans les jeux',
                  style: TextStyle(color: _gris, fontSize: 12.5)),
            ]),
          ),
        ]),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _section('MES LANGUES'),
      ...lignes,
      const SizedBox(height: 10),
    ]);
  }

