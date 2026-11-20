// Amis : point vert « en ligne » + « ⚔️ Jouer » (défi en direct).
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`import 'package:flutter_screentime/flutter_screentime.dart';
`,`import 'package:flutter_screentime/flutter_screentime.dart';
import '/flutter_flow/nav/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
`);
  rep(`  List<Map<String, dynamic>> _recues = []; // demandes reçues
`,`  List<Map<String, dynamic>> _recues = []; // demandes reçues
  Timer? _tAmis;
`);
  rep(`    _mode = widget.mode ?? 'amis';
`,`    _mode = widget.mode ?? 'amis';
    // Rafraîchit qui est en ligne toutes les 30 secondes.
    _tAmis = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted || _amis.isEmpty) return;
      try {
        final l = await _joueurs(
            _amis.map((a) => a['uid'].toString()).toList());
        if (mounted) setState(() => _amis = l);
      } catch (_) {}
    });
`);
  rep(`    _champCode.dispose();
`,`    _tAmis?.cancel();
    _champCode.dispose();
`);
  rep(`  Widget _vueAmis() {
    final tri = [
      ..._amis
    ]..sort((a, b) => _pointsDe(b, 'points').compareTo(_pointsDe(a, 'points')));`,`  bool _enLigne(Map<String, dynamic> a) =>
      DateTime.now().millisecondsSinceEpoch - _entier(a['vu']) < 150000;

  static const _jeuxDirect = [
    ['memoire', '🃏 Mémoire'],
    ['duel', '⚡ Duel éclair'],
    ['vraifaux', '✅ Vrai ou Faux'],
    ['paires', '🧩 Paires'],
    ['pluie', '🌧️ Pluie de mots'],
    ['lettres', '🔠 Lettres mélangées'],
    ['image', '🖼️ Devine l’image'],
    ['ecoute', '👂 Écoute et écris'],
    ['meles', '🔤 Mots mêlés'],
    ['motjour', '🟩 Le mot mystère'],
  ];

  /// Défi en direct : l'ami (en ligne) reçoit une fenêtre Accepter / Refuser.
  Future<void> _defiDirect(Map<String, dynamic> ami) async {
    final nom = (ami['pseudo'] ?? 'Ton ami').toString();
    final jeu = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _carte,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('⚔️ Défier ' + nom + ' en direct',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _texte, fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Choisis le jeu. Vous jouerez en même temps, avec les mêmes cartes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _gris, fontSize: 13.5)),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(c).size.height * 0.55),
            child: ListView(shrinkWrap: true, children: [
              for (final j in _jeuxDirect)
                ListTile(
                  onTap: () => Navigator.of(c).pop(j),
                  title: Text(j[1],
                      style: TextStyle(
                          color: _texte,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right, color: _orange),
                ),
            ]),
          ),
        ]),
      ),
    );
    if (jeu == null || !mounted) return;
    var langue = 'en';
    try {
      final s = await _db
          .collection('user_stats')
          .where('uid', isEqualTo: _uid)
          .limit(1)
          .get();
      if (s.docs.isNotEmpty) {
        langue = (s.docs.first.data()['langue'] ?? 'en').toString();
      }
    } catch (_) {}
    DocumentReference<Map<String, dynamic>> ref;
    try {
      ref = await _db.collection('duels').add({
        'type': 'jeu',
        'direct': true,
        'jeu': jeu[0],
        'niveau': 3,
        'langue': langue,
        'graine': math.Random().nextInt(1 << 30),
        'de': _uid,
        'deNom': (_moi['pseudo'] ?? 'Ton ami').toString(),
        'pour': ami['uid'],
        'pourNom': nom,
        'membres': [_uid, ami['uid']],
        'statut': 'invite',
        'cree': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {
      _message('Oups, vérifie ta connexion et réessaie.');
      return;
    }
    if (!mounted) return;
    final r = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (c) => _LxAttenteDefi(ref: ref, nom: nom, jeu: jeu[1]),
    );
    if (r == 'accepte') {
      final pr = await SharedPreferences.getInstance();
      await pr.setString('lexi_direct', ref.id);
      if (mounted) context.goNamed('Jouer');
    } else {
      try {
        if (r != 'refuse') await ref.update({'statut': 'expire'});
      } catch (_) {}
      _message(r == 'refuse'
          ? nom + ' a refusé le défi. Une autre fois ! 🦊'
          : r == 'annule'
              ? 'Défi annulé.'
              : nom + ' n\\'a pas répondu. Réessaie plus tard 🦊');
    }
  }

  Widget _vueAmis() {
    final tri = [
      ..._amis
    ]..sort((a, b) {
        final l = (_enLigne(b) ? 1 : 0) - (_enLigne(a) ? 1 : 0);
        if (l != 0) return l;
        return _pointsDe(b, 'points').compareTo(_pointsDe(a, 'points'));
      });`);
  rep(`            Text(_drapeau(a['pays']), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),`,`            Stack(clipBehavior: Clip.none, children: [
              Text(_drapeau(a['pays']), style: const TextStyle(fontSize: 24)),
              if (_enLigne(a))
                Positioned(
                  right: -3,
                  bottom: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: _carte, width: 2),
                    ),
                  ),
                ),
            ]),
            const SizedBox(width: 10),`);
  rep(`                    Text('\${_pointsDe(a, 'points')} pts cette semaine',
                        style: TextStyle(color: _gris, fontSize: 12.5)),
                  ]),
            ),
            _bouton('⏳ Défier', _violet, () => _defier(a), plein: false),`,`                    _enLigne(a)
                        ? const Text('🟢 En ligne',
                            style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800))
                        : Text('\${_pointsDe(a, 'points')} pts cette semaine',
                            style: TextStyle(color: _gris, fontSize: 12.5)),
                  ]),
            ),
            _enLigne(a)
                ? _bouton('⚔️ Jouer', _orange, () => _defiDirect(a))
                : _bouton('⏳ Défier', _violet, () => _defier(a),
                    plein: false),`);
  c = c.replace(/\s*$/, '\n') + `
// Attente de la réponse de l'ami (30 secondes).
class _LxAttenteDefi extends StatefulWidget {
  const _LxAttenteDefi(
      {required this.ref, required this.nom, required this.jeu});
  final DocumentReference<Map<String, dynamic>> ref;
  final String nom;
  final String jeu;
  @override
  State<_LxAttenteDefi> createState() => _LxAttenteDefiState();
}

class _LxAttenteDefiState extends State<_LxAttenteDefi> {
  int _reste = 30;
  Timer? _t;
  StreamSubscription? _abo;
  bool _fini = false;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _reste--);
      if (_reste <= 0) _fermer(null);
    });
    _abo = widget.ref.snapshots().listen((s) {
      final st = s.data()?['statut'];
      if (st == 'accepte') _fermer('accepte');
      if (st == 'refuse') _fermer('refuse');
    });
  }

  void _fermer(String? r) {
    if (_fini) return;
    _fini = true;
    _t?.cancel();
    _abo?.cancel();
    if (mounted) Navigator.of(context).pop(r);
  }

  @override
  void dispose() {
    _t?.cancel();
    _abo?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = FFAppState().isDarkMode;
    final texte = s ? Colors.white : const Color(0xFF1E1640);
    return AlertDialog(
      backgroundColor: s ? const Color(0xFF221D3D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('⚔️', style: TextStyle(fontSize: 50)),
        const SizedBox(height: 8),
        Text('Défi envoyé à ' + widget.nom,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: texte, fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(widget.jeu,
            style: const TextStyle(
                color: Color(0xFFF97316),
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        const CircularProgressIndicator(color: Color(0xFFF97316)),
        const SizedBox(height: 14),
        Text('En attente de sa réponse… ' + _reste.toString() + ' s',
            style: const TextStyle(color: Color(0xFF9A93B8), fontSize: 14)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () async {
            try {
              await widget.ref.update({'statut': 'expire'});
            } catch (_) {}
            _fermer('annule');
          },
          child: const Text('Annuler',
              style: TextStyle(color: Color(0xFFDC2626))),
        ),
      ]),
    );
  }
}
`;
  window._amR=R; return c;
})
