  // Chaque badge a 3 niveaux : 🥉 Bronze, 🥈 Argent, 🥇 Or.
  // [emoji, nom, description, valeur, [bronze, argent, or]]
  List<List<Object>> get _familles {
    return [
      ['📚', 'Mots appris', 'Apprends de nouveaux mots dans tes leçons.', _motsTotal, [10, 100, 500]],
      ['🔥', 'Série', 'Apprends plusieurs jours d\'affilée.', _entier(_d['currentStreak']), [3, 7, 30]],
      ['🎯', 'Défis réussis', 'Réussis tes défis pour débloquer tes applis.', _entier(_d['defisTotal']), [5, 25, 100]],
      ['🎮', 'Joueur', 'Joue des parties dans Jouer.', _entier(_d['jeuxTotal']), [20, 100, 500]],
      ['🧠', 'Coach', 'Termine des séances avec le coach.', _entier(_d['coachTotal']), [1, 10, 50]],
      ['📖', 'Lecteur', 'Lis des chapitres dans Lecture.', _entier(_d['livresChapitres']), [10, 50, 150]],
      ['📕', 'Livres finis', 'Termine des livres en entier.', _entier(_d['livresFinis']), [1, 5, 15]],
      ['🏆', 'Ligue', 'Monte de ligue : Margouillat, Renard puis Lion.', _entier(_d['ligue']), [1, 2, 4]],
      ['⭐', 'Points', 'Gagne des points partout dans Léxi.', _entier(_d['totalXp']), [500, 5000, 20000]],
      ['🎤', 'Concours', 'Gagne des points dans les concours.', _entier(_d['concoursPts']), [100, 1000, 5000]],
      ['🤝', 'Amis', 'Ajoute des amis avec leur code.', _nbAmis, [1, 5, 20]],
      ['🌙', 'Nuits sans écran', 'Termine des créneaux Sommeil.', _entier(_d['nuitsTotal']), [1, 7, 30]],
    ];
  }

  static const _medailles = ['', '🥉', '🥈', '🥇'];
  static const _nomsNiveaux = ['', 'Bronze', 'Argent', 'Or'];

  // Badge prêt à afficher : [emoji, nom, description, valeur, cible, niveau, paliers]
  List<List<Object>> get _badges {
    return [
      for (final f in _familles)
        () {
          final v = f[3] as int;
          final p = (f[4] as List).cast<int>();
          final niv = p.where((x) => v >= x).length;
          final cible = niv < 3 ? p[niv] : p[2];
          return <Object>[f[0], f[1], f[2], v, cible, niv, p];
        }()
    ];
  }

  void _ficheBadge(List<Object> b) {
    final niv = b[5] as int;
    final p = (b[6] as List).cast<int>();
    final cible = b[4] as int;
    final v = (b[3] as int).clamp(0, cible).toInt();
    final fini = niv >= 3;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _carte,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Opacity(
              opacity: niv > 0 ? 1 : 0.4,
              child:
                  Text(b[0] as String, style: const TextStyle(fontSize: 56))),
          const SizedBox(height: 8),
          Text(b[1] as String,
              style: TextStyle(
                  color: _texte, fontSize: 19, fontWeight: FontWeight.w900)),
          if (niv > 0)
            Text(_medailles[niv] + ' Niveau ' + _nomsNiveaux[niv],
                style: const TextStyle(
                    color: _orange, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(b[2] as String,
              textAlign: TextAlign.center,
              style: TextStyle(color: _gris, fontSize: 14)),
          const SizedBox(height: 14),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Opacity(
                    opacity: niv > i ? 1 : 0.35,
                    child: Text(_medailles[i + 1],
                        style: const TextStyle(fontSize: 22))),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_nomsNiveaux[i + 1] + ' : ' + p[i].toString(),
                      style: TextStyle(
                          color: niv > i ? _vert : _texte,
                          fontWeight: FontWeight.w700)),
                ),
                if (niv > i)
                  const Icon(Icons.check_circle_rounded, color: _vert, size: 20),
              ]),
            ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: v / cible,
              minHeight: 10,
              color: fini ? _vert : _orange,
              backgroundColor: _bord,
            ),
          ),
          const SizedBox(height: 6),
          Text(
              fini
                  ? 'Niveau Or atteint ! 🎉'
                  : '$v de $cible pour le niveau ${_nomsNiveaux[niv + 1]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: fini ? _vert : _texte, fontWeight: FontWeight.w800)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('OK', style: TextStyle(color: _orange)),
          ),
        ],
      ),
    );
  }

  Widget _celluleBadge(List<Object> b) {
    final niv = b[5] as int;
    final obj = b[4] as int;
    final v = (b[3] as int).clamp(0, obj).toInt();
    final fini = niv >= 3;
    return GestureDetector(
      onTap: () => _ficheBadge(b),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(clipBehavior: Clip.none, children: [
          Opacity(
              opacity: niv > 0 ? 1 : 0.35,
              child:
                  Text(b[0] as String, style: const TextStyle(fontSize: 30))),
          if (niv > 0)
            Positioned(
              right: -10,
              bottom: -4,
              child: Text(_medailles[niv],
                  style: const TextStyle(fontSize: 16)),
            ),
        ]),
        const SizedBox(height: 3),
        Text(b[1] as String,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: _texte, fontSize: 11.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: v / obj,
              minHeight: 5,
              color: fini ? _vert : _orange,
              backgroundColor: _bord,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(fini ? '🥇 Or' : '$v de $obj',
            style: TextStyle(
                color: fini ? _vert : _gris,
                fontSize: 10.5,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

