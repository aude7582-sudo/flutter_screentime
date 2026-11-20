// Barre du bas : présence « en ligne » + fenêtre « X te défie » sur toutes les pages.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`import '/flutter_flow/nav/nav.dart';
`,`import '/flutter_flow/nav/nav.dart';
import 'dart:async';
import '/auth/firebase_auth/auth_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
`);
  rep(`class _LexiNavState extends State<LexiNav> {
`,`class _LexiNavState extends State<LexiNav> {
  // ---- En ligne + défis en direct (communs à toutes les pages) ----
  static Timer? _tPresence;
  static StreamSubscription? _abo;
  static BuildContext? _ctx;
  static final Set<String> _vus = {};

  @override
  void initState() {
    super.initState();
    _ctx = context;
    _demarrer();
  }

  @override
  void dispose() {
    if (identical(_ctx, context)) _ctx = null;
    super.dispose();
  }

  static void _presence() {
    final uid = currentUserUid;
    if (uid.isEmpty) return;
    FirebaseFirestore.instance.collection('joueurs').doc(uid).set(
        {'vu': DateTime.now().millisecondsSinceEpoch},
        SetOptions(merge: true)).catchError((_) {});
  }

  static void _demarrer() {
    final uid = currentUserUid;
    if (uid.isEmpty) return;
    if (_tPresence == null) {
      _presence();
      _tPresence =
          Timer.periodic(const Duration(seconds: 60), (_) => _presence());
    }
    _abo ??= FirebaseFirestore.instance
        .collection('duels')
        .where('pour', isEqualTo: uid)
        .where('statut', isEqualTo: 'invite')
        .snapshots()
        .listen((s) {
      for (final d in s.docs) {
        final x = d.data();
        if (x['direct'] != true) continue;
        final cree = x['cree'] is num ? (x['cree'] as num).toInt() : 0;
        if (DateTime.now().millisecondsSinceEpoch - cree > 45000) continue;
        if (!_vus.add(d.id)) continue;
        _invitation(d.id, x);
      }
    }, onError: (_) {
      _abo = null;
    });
  }

  static Future<void> _invitation(String id, Map<String, dynamic> x) async {
    final ctx = _ctx;
    if (ctx == null || !ctx.mounted) return;
    final ref = FirebaseFirestore.instance.collection('duels').doc(id);
    final ok = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (c) => _LxDialogueDefi(x: x, ref: ref),
    );
    try {
      if (ok == true) {
        await ref.update({
          'statut': 'accepte',
          'accepte': DateTime.now().millisecondsSinceEpoch,
        });
        final pr = await SharedPreferences.getInstance();
        await pr.setString('lexi_direct', id);
        final c2 = _ctx;
        if (c2 != null && c2.mounted) c2.goNamed('Jouer');
      } else if (ok == false) {
        await ref.update({'statut': 'refuse'});
      }
    } catch (_) {}
  }

`);
  c = c.replace(/\s*$/, '\n') + `
// Fenêtre « Ton ami te défie ! » (30 secondes pour répondre).
class _LxDialogueDefi extends StatefulWidget {
  const _LxDialogueDefi({required this.x, required this.ref});
  final Map<String, dynamic> x;
  final DocumentReference<Map<String, dynamic>> ref;
  @override
  State<_LxDialogueDefi> createState() => _LxDialogueDefiState();
}

class _LxDialogueDefiState extends State<_LxDialogueDefi> {
  static const _jeux = {
    'paires': '🧩 Paires',
    'meles': '🔤 Mots mêlés',
    'memoire': '🃏 Mémoire',
    'duel': '⚡ Duel éclair',
    'lettres': '🔠 Lettres mélangées',
    'vraifaux': '✅ Vrai ou Faux',
    'ecoute': '👂 Écoute et écris',
    'pluie': '🌧️ Pluie de mots',
    'motjour': '🟩 Le mot mystère',
    'image': '🖼️ Devine l’image',
  };
  int _reste = 30;
  Timer? _t;
  StreamSubscription? _abo;

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
      if (st != null && st != 'invite') _fermer(null);
    });
  }

  void _fermer(bool? r) {
    _t?.cancel();
    _abo?.cancel();
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop(r);
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
    final nom = (widget.x['deNom'] ?? 'Ton ami').toString();
    final jeu = _jeux[widget.x['jeu']] ?? '🎮 un jeu';
    return AlertDialog(
      backgroundColor: s ? const Color(0xFF221D3D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('⚔️', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 6),
        Text('Défi en direct !',
            style: TextStyle(
                color: texte, fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(nom + ' te défie maintenant au jeu',
            textAlign: TextAlign.center,
            style: TextStyle(color: texte, fontSize: 15.5)),
        const SizedBox(height: 4),
        Text(jeu,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFFF97316),
                fontSize: 19,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text('Réponds dans ' + _reste.toString() + ' s',
            style: const TextStyle(color: Color(0xFF9A93B8), fontSize: 13.5)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _fermer(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Refuser',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _fermer(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Accepter',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ]),
      ]),
    );
  }
}
`;
  window._navR=R; return c;
})
