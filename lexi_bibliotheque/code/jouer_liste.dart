  Widget _liste(_LxP p) {
    const base =
        'https://raw.githubusercontent.com/aude7582-sudo/flutter_screentime/main/lexi_bibliotheque/jeux/';
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        Text('Jouer',
            style: TextStyle(
                color: p.texte, fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('10 jeux · 10 niveaux chacun. Gagne un niveau pour débloquer le suivant !',
            style: TextStyle(color: p.gris, fontSize: 14)),
        const SizedBox(height: 16),
        if (!_charge)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator(color: _lxOrange)),
          ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.74,
          children: [
            for (final j in _jeux)
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _ouvrirJeu(j[0] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: p.carte,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: p.bord),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            base + (j[0] as String) + '.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Color(j[4] as int),
                              alignment: Alignment.center,
                              child: Text(j[3] as String,
                                  style: const TextStyle(fontSize: 56)),
                            ),
                            loadingBuilder: (c, w, prog) => prog == null
                                ? w
                                : Container(
                                    color: Color(j[4] as int),
                                    alignment: Alignment.center,
                                    child: Text(j[3] as String,
                                        style: const TextStyle(fontSize: 56)),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 9, 10, 0),
                          child: Text(j[1] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: p.texte,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 3, 10, 0),
                          child: Text(
                              'Niv. ' +
                                  _niveauActuel(j[0] as String).toString() +
                                  '/10  ·  ★ ' +
                                  _total(j[0] as String).toString() +
                                  '/30',
                              maxLines: 1,
                              style: TextStyle(
                                  color: Color(j[4] as int),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ]),
                ),
              ),
          ],
        ),
      ],
    );
  }

