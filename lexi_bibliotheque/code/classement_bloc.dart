
// ===========================================================================
// CLASSEMENT (Amis · Ville · National · International) + PROFIL D'UN JOUEUR

const _lxcDrapeaux = {
  'CI': '🇨🇮', 'SN': '🇸🇳', 'CM': '🇨🇲', 'ML': '🇲🇱', 'BF': '🇧🇫',
  'BJ': '🇧🇯', 'TG': '🇹🇬', 'GN': '🇬🇳', 'NE': '🇳🇪', 'GA': '🇬🇦',
  'CG': '🇨🇬', 'CD': '🇨🇩', 'MG': '🇲🇬', 'MA': '🇲🇦', 'DZ': '🇩🇿',
  'TN': '🇹🇳', 'FR': '🇫🇷', 'BE': '🇧🇪', 'CH': '🇨🇭', 'CA': '🇨🇦',
  'HT': '🇭🇹', 'XX': '🌍',
};

const _lxcVilles = {
  'CI': ['Abidjan', 'Bouaké', 'Yamoussoukro', 'San-Pédro', 'Daloa', 'Korhogo', 'Man', 'Gagnoa', 'Divo', 'Abengourou'],
  'SN': ['Dakar', 'Thiès', 'Saint-Louis', 'Touba', 'Kaolack', 'Ziguinchor'],
  'CM': ['Douala', 'Yaoundé', 'Bafoussam', 'Garoua', 'Bamenda'],
  'ML': ['Bamako', 'Sikasso', 'Ségou', 'Mopti'],
  'BF': ['Ouagadougou', 'Bobo-Dioulasso', 'Koudougou'],
  'BJ': ['Cotonou', 'Porto-Novo', 'Parakou', 'Abomey-Calavi'],
  'TG': ['Lomé', 'Sokodé', 'Kara'],
  'GN': ['Conakry', 'Kankan', 'Labé', 'Nzérékoré'],
  'FR': ['Paris', 'Lyon', 'Marseille', 'Lille', 'Toulouse'],
};

const _lxcLigues = [
  ['🐜', 'Fourmi'],
  ['🦎', 'Margouillat'],
  ['🦊', 'Renard'],
  ['🐆', 'Panthère'],
  ['🦁', 'Lion'],
];

int _lxcEntier(dynamic v) => v is num ? v.toInt() : 0;

String _lxcSemaine() {
  final n = DateTime.now();
  final j = DateTime(n.year, n.month, n.day).subtract(Duration(days: n.weekday - 1));
  return '${j.year}-${j.month.toString().padLeft(2, '0')}-${j.day.toString().padLeft(2, '0')}';
}

String _lxcCleVille(String v) => v
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[àâä]'), 'a')
    .replaceAll(RegExp('[ôö]'), 'o')
    .replaceAll(RegExp('[ïî]'), 'i')
    .replaceAll(RegExp('[ûüù]'), 'u')
    .replaceAll(RegExp('[^a-z0-9]'), '');

bool _lxcEnLigne(Map<String, dynamic> j) =>
    DateTime.now().millisecondsSinceEpoch - _lxcEntier(j['vu']) < 150000;

class _LxcCouleurs {
  _LxcCouleurs() : s = FFAppState().isDarkMode;
  final bool s;
  Color get fond => s ? const Color(0xFF14112B) : const Color(0xFFF7F4FF);
  Color get carte => s ? const Color(0xFF221D3D) : Colors.white;
  Color get texte => s ? Colors.white : const Color(0xFF1E1640);
  Color get gris => s ? const Color(0xFFB8B2D6) : const Color(0xFF6B6490);
  Color get bord => s ? const Color(0xFF3A3360) : const Color(0xFFE6E0F5);
  static const orange = Color(0xFFF97316);
  static const violet = Color(0xFF7C3AED);
}

class _LxClassement extends StatefulWidget {
  const _LxClassement({this.onDefier});
  final Future<void> Function(Map<String, dynamic>)? onDefier;
  @override
  State<_LxClassement> createState() => _LxClassementState();
}

class _LxClassementState extends State<_LxClassement> {
  final _db = FirebaseFirestore.instance;
  String get _uid => currentUserUid;
  String _onglet = 'amis'; // amis | ville | pays | monde
  bool _semaine = true;
  bool _charge = false;
  Map<String, dynamic> _moi = {};
  List<Map<String, dynamic>> _liste = [];
  final _villeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _villeCtrl.dispose();
    super.dispose();
  }

  int _valeur(Map<String, dynamic> j) => _semaine
      ? (j['semaine'] == _lxcSemaine() ? _lxcEntier(j['points']) : 0)
      : _lxcEntier(j['xp']);

  Future<List<Map<String, dynamic>>> _parIds(List<String> ids) async {
    final r = <Map<String, dynamic>>[];
    for (var i = 0; i < ids.length; i += 10) {
      final lot = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final q = await _db
          .collection('joueurs')
          .where(FieldPath.documentId, whereIn: lot)
          .get();
      r.addAll(q.docs.map((d) => {...d.data(), 'uid': d.id}));
    }
    return r;
  }

  Future<void> _charger() async {
    setState(() => _charge = false);
    try {
      final m = await _db.collection('joueurs').doc(_uid).get();
      _moi = {...?m.data(), 'uid': _uid};
      List<Map<String, dynamic>> l = [];
      if (_onglet == 'amis') {
        final a = await _db
            .collection('amities')
            .where('uids', arrayContains: _uid)
            .limit(100)
            .get();
        final ids = <String>{_uid};
        for (final d in a.docs) {
          if (d.data()['statut'] == 'attente') continue;
          for (final u in (d.data()['uids'] as List? ?? [])) {
            ids.add(u.toString());
          }
        }
        l = await _parIds(ids.toList());
      } else if (_onglet == 'ville') {
        final cle = (_moi['villeCle'] ?? '').toString();
        if (cle.isNotEmpty) {
          final q = await _db
              .collection('joueurs')
              .where('villeCle', isEqualTo: cle)
              .limit(500)
              .get();
          l = q.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
        }
      } else if (_onglet == 'pays') {
        final p = (_moi['pays'] ?? 'XX').toString();
        if (p != 'XX') {
          final q = await _db
              .collection('joueurs')
              .where('pays', isEqualTo: p)
              .limit(500)
              .get();
          l = q.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
        }
      } else {
        final q = await _db
            .collection('joueurs')
            .orderBy(_semaine ? 'points' : 'xp', descending: true)
            .limit(_semaine ? 300 : 100)
            .get();
        l = q.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
      }
      l.removeWhere((j) => (j['pseudo'] ?? '').toString().isEmpty);
      _liste = l;
    } catch (_) {
      _liste = [];
    }
    if (mounted) setState(() => _charge = true);
  }

  Future<void> _enregistrerVille(String v) async {
    final ville = v.trim();
    if (ville.length < 2) return;
    try {
      await _db.collection('joueurs').doc(_uid).set(
          {'ville': ville, 'villeCle': _lxcCleVille(ville)},
          SetOptions(merge: true));
    } catch (_) {}
    _charger();
  }

  Widget _onglets(_LxcCouleurs c) {
    final pays = (_moi['pays'] ?? 'XX').toString();
    final items = [
      ['amis', '👥 Amis'],
      ['ville', '🏙️ Ville'],
      ['pays', (_lxcDrapeaux[pays] ?? '🏳️') + ' National'],
      ['monde', '🌍 Monde'],
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                _onglet = it[0];
                _charger();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _onglet == it[0] ? _LxcCouleurs.violet : c.carte,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color:
                          _onglet == it[0] ? _LxcCouleurs.violet : c.bord),
                ),
                child: Text(it[1],
                    style: TextStyle(
                        color: _onglet == it[0] ? Colors.white : c.texte,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _periode(_LxcCouleurs c) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: c.carte, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          for (final p in [
            [true, 'Cette semaine'],
            [false, 'Depuis le début'],
          ])
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _semaine = p[0] as bool;
                  _charger();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _semaine == p[0]
                        ? _LxcCouleurs.orange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(p[1] as String,
                      style: TextStyle(
                          color: _semaine == p[0] ? Colors.white : c.gris,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5)),
                ),
              ),
            ),
        ]),
      );

  Widget _demandeVille(_LxcCouleurs c) {
    final pays = (_moi['pays'] ?? 'XX').toString();
    final sugg = _lxcVilles[pays] ?? const <String>[];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: c.carte, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🏙️ Dans quelle ville habites-tu ?',
            style: TextStyle(
                color: c.texte, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('Pour te classer avec les joueurs de ta ville.',
            style: TextStyle(color: c.gris, fontSize: 13.5)),
        const SizedBox(height: 12),
        if (sugg.isNotEmpty)
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final v in sugg)
              GestureDetector(
                onTap: () => _enregistrerVille(v),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _LxcCouleurs.violet.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(v,
                      style: TextStyle(
                          color: c.texte, fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _villeCtrl,
              style: TextStyle(color: c.texte),
              decoration: InputDecoration(
                hintText: 'Autre ville…',
                hintStyle: TextStyle(color: c.gris),
                filled: true,
                fillColor: c.fond,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _enregistrerVille(_villeCtrl.text),
            style: ElevatedButton.styleFrom(
                backgroundColor: _LxcCouleurs.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            child: const Text('OK',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ]),
      ]),
    );
  }

  void _ouvrirProfil(Map<String, dynamic> j) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _LxProfilJoueur(j: j, onDefier: widget.onDefier)));
  }

  Widget _ligne(_LxcCouleurs c, int rang, Map<String, dynamic> j) {
    final moi = j['uid'] == _uid;
    final medaille = rang == 0
        ? '🥇'
        : rang == 1
            ? '🥈'
            : rang == 2
                ? '🥉'
                : '${rang + 1}';
    return GestureDetector(
      onTap: () => _ouvrirProfil(j),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
        decoration: BoxDecoration(
          color: moi ? _LxcCouleurs.orange.withOpacity(0.14) : c.carte,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: moi ? _LxcCouleurs.orange : c.bord,
              width: moi ? 2 : 1),
        ),
        child: Row(children: [
          SizedBox(
            width: 34,
            child: Text(medaille,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: c.gris,
                    fontSize: rang < 3 ? 22 : 15,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 6),
          Stack(clipBehavior: Clip.none, children: [
            Text(_lxcDrapeaux[(j['pays'] ?? 'XX').toString()] ?? '🌍',
                style: const TextStyle(fontSize: 24)),
            if (_lxcEnLigne(j))
              Positioned(
                right: -3,
                bottom: -1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: c.carte, width: 2)),
                ),
              ),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      (j['pseudo'] ?? '').toString() + (moi ? ' (toi)' : ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.texte,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800)),
                  if ((j['ville'] ?? '').toString().isNotEmpty)
                    Text(j['ville'].toString(),
                        style: TextStyle(color: c.gris, fontSize: 12.5)),
                ]),
          ),
          Text('${_valeur(j)} pts',
              style: TextStyle(
                  color: rang < 3 ? _LxcCouleurs.orange : c.texte,
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _LxcCouleurs();
    final tri = [..._liste]
      ..sort((a, b) => _valeur(b).compareTo(_valeur(a)));
    final affiche = _onglet == 'monde' ? tri.take(100).toList() : tri;
    final monRang = tri.indexWhere((j) => j['uid'] == _uid);
    final ville = (_moi['ville'] ?? '').toString();
    final pays = (_moi['pays'] ?? 'XX').toString();
    Widget corps;
    if (!_charge) {
      corps = const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
              child: CircularProgressIndicator(color: _LxcCouleurs.orange)));
    } else if (_onglet == 'ville' && ville.isEmpty) {
      corps = _demandeVille(c);
    } else if (_onglet == 'pays' && pays == 'XX') {
      corps = Text(
          'Choisis d\'abord ton pays dans Concours pour voir le classement national 🦊',
          style: TextStyle(color: c.gris, fontSize: 15));
    } else if (affiche.isEmpty) {
      corps = Text(
          _onglet == 'amis'
              ? 'Ajoute des amis pour te mesurer à eux ! 🦊'
              : 'Personne ici pour l\'instant. Invite tes amis ! 🦊',
          style: TextStyle(color: c.gris, fontSize: 15));
    } else {
      corps = Column(children: [
        for (var i = 0; i < affiche.length; i++) _ligne(c, i, affiche[i]),
      ]);
    }
    final titreZone = _onglet == 'ville'
        ? (ville.isEmpty ? 'Ta ville' : ville)
        : _onglet == 'pays'
            ? 'Ton pays ' + (_lxcDrapeaux[pays] ?? '')
            : _onglet == 'monde'
                ? 'Le monde entier 🌍'
                : 'Toi et tes amis';
    return Scaffold(
      backgroundColor: c.fond,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_rounded, color: c.texte),
              ),
              Expanded(
                child: Text('🏆 Classement',
                    style: TextStyle(
                        color: c.texte,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
              ),
              if (_onglet == 'ville' && ville.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    try {
                      await _db.collection('joueurs').doc(_uid).set(
                          {'ville': '', 'villeCle': ''},
                          SetOptions(merge: true));
                    } catch (_) {}
                    _charger();
                  },
                  child: const Text('Changer de ville',
                      style: TextStyle(color: _LxcCouleurs.violet)),
                ),
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _charger,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _onglets(c),
                  const SizedBox(height: 12),
                  _periode(c),
                  const SizedBox(height: 14),
                  Text(titreZone,
                      style: TextStyle(
                          color: c.gris,
                          fontSize: 13,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  corps,
                ],
              ),
            ),
          ),
          if (_charge && monRang >= 0 && affiche.length > 6)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              color: _LxcCouleurs.violet,
              child: Text(
                  'Tu es ${monRang + 1}e sur ${tri.length} · ${_valeur(tri[monRang])} pts',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ),
        ]),
      ),
    );
  }
}

/// Page profil d'un joueur (jamais son temps d'écran).
class _LxProfilJoueur extends StatefulWidget {
  const _LxProfilJoueur({required this.j, this.onDefier});
  final Map<String, dynamic> j;
  final Future<void> Function(Map<String, dynamic>)? onDefier;
  @override
  State<_LxProfilJoueur> createState() => _LxProfilJoueurState();
}

class _LxProfilJoueurState extends State<_LxProfilJoueur> {
  final _db = FirebaseFirestore.instance;
  String? _lien; // 'ami' | 'attente' | null
  bool _charge = false;

  String get _uid => currentUserUid;
  String get _autre => widget.j['uid'].toString();
  String get _idAmitie {
    final ids = [_uid, _autre]..sort();
    return ids[0] + '_' + ids[1];
  }

  @override
  void initState() {
    super.initState();
    _chargerLien();
  }

  Future<void> _chargerLien() async {
    try {
      final d = await _db.collection('amities').doc(_idAmitie).get();
      final x = d.data();
      _lien = x == null ? null : (x['statut'] == 'attente' ? 'attente' : 'ami');
    } catch (_) {}
    if (mounted) setState(() => _charge = true);
  }

  Future<void> _ajouter() async {
    try {
      final ids = [_uid, _autre]..sort();
      await _db.collection('amities').doc(_idAmitie).set({
        'uids': ids,
        'de': _uid,
        'statut': 'attente',
        'cree': DateTime.now().millisecondsSinceEpoch,
      });
      if (mounted) {
        setState(() => _lien = 'attente');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Demande d\'ami envoyée ⏳')));
      }
    } catch (_) {}
  }

  Widget _stat(_LxcCouleurs c, String emoji, String valeur, String nom) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
            color: c.carte,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.bord)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(valeur,
              style: TextStyle(
                  color: c.texte, fontSize: 19, fontWeight: FontWeight.w900)),
          Text(nom,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.gris, fontSize: 12)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final c = _LxcCouleurs();
    final j = widget.j;
    final moi = _autre == _uid;
    final ligue = _lxcEntier(j['ligue']).clamp(0, 4).toInt();
    final enLigne = _lxcEnLigne(j);
    final vu = _lxcEntier(j['vu']);
    String statut = '';
    if (enLigne) {
      statut = '🟢 En ligne';
    } else if (vu > 0) {
      final m = (DateTime.now().millisecondsSinceEpoch - vu) ~/ 60000;
      statut = m < 60
          ? 'Vu il y a $m min'
          : m < 1440
              ? 'Vu il y a ${m ~/ 60} h'
              : 'Vu il y a ${m ~/ 1440} j';
    }
    final semaine = j['semaine'] == _lxcSemaine() ? _lxcEntier(j['points']) : 0;
    return Scaffold(
      backgroundColor: c.fond,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_rounded, color: c.texte),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFF97316)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(children: [
                Text((j['avatar'] ?? '🦊').toString(),
                    style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 6),
                Text((j['pseudo'] ?? 'Joueur').toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                    (_lxcDrapeaux[(j['pays'] ?? 'XX').toString()] ?? '🌍') +
                        ((j['ville'] ?? '').toString().isNotEmpty
                            ? '  ' + j['ville'].toString()
                            : ''),
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                if (statut.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(statut,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14)),
                  child: Text(
                      'Ligue ' + _lxcLigues[ligue][0] + ' ' + _lxcLigues[ligue][1],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
              children: [
                _stat(c, '🔥', '${_lxcEntier(j['serie'])}', 'jours de série'),
                _stat(c, '📚', '${_lxcEntier(j['mots'])}', 'mots appris'),
                _stat(c, '⭐', '${_lxcEntier(j['xp'])}', 'points en tout'),
                _stat(c, '📅', '$semaine', 'points cette semaine'),
                _stat(c, '🎯', '${_lxcEntier(j['defis'])}', 'défis réussis'),
                _stat(c, '🎮', '${_lxcEntier(j['jeux'])}', 'parties jouées'),
              ],
            ),
            const SizedBox(height: 18),
            if (!moi && _charge) ...[
              if (_lien == 'ami' && enLigne && widget.onDefier != null)
                _bouton('⚔️ Défier maintenant', _LxcCouleurs.orange, () {
                  Navigator.of(context).pop();
                  widget.onDefier!(j);
                }),
              if (_lien == 'ami' && !enLigne)
                Text(
                    'Tu pourras le défier en direct quand il sera en ligne 🟢',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.gris, fontSize: 14)),
              if (_lien == null)
                _bouton('➕ Ajouter en ami', _LxcCouleurs.violet, _ajouter),
              if (_lien == 'attente')
                Text('⏳ Demande d\'ami en attente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: c.gris,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 10),
            Text('🔒 Le temps d\'écran et les applis ne sont jamais montrés.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.gris, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget _bouton(String t, Color couleur, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: couleur, borderRadius: BorderRadius.circular(18)),
          child: Text(t,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900)),
        ),
      );
}
