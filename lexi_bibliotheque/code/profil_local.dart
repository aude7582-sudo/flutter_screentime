
import '/app_state.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/nav/nav.dart';

/// Profil Léxi : avatar, code ami, Léxi Pro, amis, série, ligue, progrès,
/// badges et statistiques. La roue ⚙️ ouvre les Options (Réglages).
class LexiProfil extends StatefulWidget {
  const LexiProfil({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<LexiProfil> createState() => _LexiProfilState();
}

class _LexiProfilState extends State<LexiProfil> {
  static const _orange = Color(0xFFF97316);
  static const _violet = Color(0xFF7C3AED);
  static const _vert = Color(0xFF16A34A);
  static const _avatars = [
    '🦊', '🐱', '🐼', '🦁', '🐯', '🐸', '🐵', '🐨',
    '🐰', '🐻', '🦉', '🐧', '🦒', '🐘', '🦓', '🐢',
  ];
  static const _ligues = [
    ['🐜', 'Fourmi'],
    ['🦎', 'Margouillat'],
    ['🦊', 'Renard'],
    ['🐆', 'Panthère'],
    ['🦁', 'Lion'],
  ];
  static const _drapeaux = {
    'CI': '🇨🇮', 'SN': '🇸🇳', 'CM': '🇨🇲', 'ML': '🇲🇱', 'BF': '🇧🇫', 'BJ': '🇧🇯',
    'TG': '🇹🇬', 'GN': '🇬🇳', 'NE': '🇳🇪', 'GA': '🇬🇦', 'CG': '🇨🇬', 'CD': '🇨🇩',
    'MG': '🇲🇬', 'MA': '🇲🇦', 'DZ': '🇩🇿', 'TN': '🇹🇳', 'FR': '🇫🇷', 'BE': '🇧🇪',
    'CH': '🇨🇭', 'CA': '🇨🇦', 'HT': '🇭🇹',
  };

  bool _charge = false;
  bool _vueAmis = false;
  Map<String, dynamic> _d = {};
  DocumentReference? _ref;
  int _nbAmis = 0;
  int _acces = 7;

  bool get _s => FFAppState().isDarkMode;
  Color get _fond => _s ? const Color(0xFF14112B) : const Color(0xFFF6F3FF);
  Color get _carte => _s ? const Color(0xFF221D3D) : Colors.white;
  Color get _texte => _s ? Colors.white : const Color(0xFF1E1640);
  Color get _gris => _s ? const Color(0xFFB8B2D6) : const Color(0xFF6B6490);
  Color get _bord => _s ? const Color(0xFF3A3460) : const Color(0xFFE2DBF5);

  String get _code {
    final u = currentUserUid;
    return (u.length >= 6 ? u.substring(0, 6) : u).toUpperCase();
  }

  int _entier(dynamic v) => v is num ? v.toInt() : 0;

  @override
  void initState() {
    super.initState();
    _charger();
    lexiAcces().then((v) {
      if (mounted) setState(() => _acces = v);
    });
  }

  Future<void> _charger() async {
    try {
      final db = FirebaseFirestore.instance;
      final q = await db
          .collection('user_stats')
          .where('uid', isEqualTo: currentUserUid)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        _ref = q.docs.first.reference;
        _d = q.docs.first.data();
      }
      final a = await db
          .collection('amities')
          .where('uids', arrayContains: currentUserUid)
          .limit(100)
          .get();
      _nbAmis = a.docs.length;
    } catch (_) {}
    if (mounted) setState(() => _charge = true);
  }

  int get _motsTotal {
    var m = 0;
    for (final k in ['currentIndex', 'currentIndex_es', 'currentIndex_zh', 'currentIndex_pt']) {
      m += _entier(_d[k]);
    }
    return m;
  }

  int get _indexLangue {
    final l = (_d['langue'] ?? 'en').toString();
    return _entier(_d[l == 'en' ? 'currentIndex' : 'currentIndex_$l']);
  }

  String get _pseudo {
    final p = (_d['pseudo'] ?? '').toString();
    if (p.isNotEmpty) return p;
    final e = currentUserEmail;
    return e.contains('@') ? e.split('@').first : 'Moi';
  }

  Future<void> _choisirAvatar() async {
    final choix = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _carte,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Choisis ton avatar',
              style: TextStyle(color: _texte, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: [
            for (final a in _avatars)
              GestureDetector(
                onTap: () => Navigator.of(c).pop(a),
                child: Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _fond,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: a == (_d['avatar'] ?? '🦊') ? _orange : _bord, width: 2.5),
                  ),
                  child: Text(a, style: const TextStyle(fontSize: 30)),
                ),
              ),
          ]),
        ]),
      ),
    );
    if (choix == null) return;
    setState(() => _d['avatar'] = choix);
    try {
      await _ref?.update({'avatar': choix});
    } catch (_) {}
  }

  Widget _section(String t, {String? lien, VoidCallback? onLien}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(
            child: Text(t,
                style: TextStyle(
                    color: _gris, fontSize: 11.5, letterSpacing: 1.3, fontWeight: FontWeight.w800)),
          ),
          if (lien != null)
            GestureDetector(
              onTap: onLien,
              child: Text(lien,
                  style: const TextStyle(
                      color: _orange, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
        ]),
      );

  BoxDecoration get _boite => BoxDecoration(
        color: _carte,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bord, width: 1.5),
      );

  Widget _tuile(String titre, String emoji, String valeur) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: _boite,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titre,
                style: TextStyle(
                    color: _gris, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(valeur,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _texte, fontSize: 20, fontWeight: FontWeight.w900)),
              ),
            ]),
          ]),
        ),
      );

  Widget _stat(String valeur, String nom, String emoji) => Expanded(
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(valeur,
              style: TextStyle(color: _texte, fontSize: 19, fontWeight: FontWeight.w900)),
          Text(nom,
              textAlign: TextAlign.center,
              style: TextStyle(color: _gris, fontSize: 11.5)),
        ]),
      );

  Widget _contenu() {
    final avatar = (_d['avatar'] ?? '🦊').toString();
    final pays = _drapeaux[(_d['pays'] ?? '').toString()] ?? '';
    final serie = _entier(_d['currentStreak']);
    final ligue = _entier(_d['ligue']).clamp(0, 4).toInt();
    final mots = _motsTotal;
    final idx = _indexLangue;
    final niveau = idx ~/ 10 + 1;
    final dansNiveau = idx % 10;
    final coach = _entier(_d['coachTotal']);
    final defis = _entier(_d['defisTotal']);
    final badges = [
      ['🌱', 'Premiers mots', mots >= 10],
      ['📚', '100 mots', mots >= 100],
      ['🔥', '7 jours de suite', serie >= 7],
      ['🧠', 'Coach validé', coach >= 1],
      ['🎯', '5 défis', defis >= 5],
      ['🏆', 'Ligue Renard', ligue >= 2],
    ];
    final gagnes = badges.where((b) => b[2] == true).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      children: [
        Row(children: [
          GestureDetector(
            onTap: _choisirAvatar,
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _carte,
                  shape: BoxShape.circle,
                  border: Border.all(color: _orange, width: 3),
                ),
                child: Text(avatar, style: const TextStyle(fontSize: 40)),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$_pseudo $pays',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _texte, fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text('Code ami : $_code',
                  style: TextStyle(color: _gris, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$_nbAmis ami${_nbAmis > 1 ? 's' : ''}',
                  style: TextStyle(color: _gris, fontSize: 13)),
            ]),
          ),
          IconButton(
            onPressed: () => context.pushNamed('Settings'),
            icon: Icon(Icons.settings_rounded, color: _texte, size: 28),
          ),
        ]),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.pushNamed('Pro'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFB923C)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              const Text('⭐', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    _acces >= 999
                        ? 'Léxi Pro actif · merci !'
                        : _acces < 0
                            ? 'Essai terminé · passe à Léxi Pro'
                            : 'Essai gratuit : encore $_acces jour${_acces > 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _vueAmis = true),
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Trouver des amis',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _violet,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          _tuile('SÉRIE', '🔥', '$serie'),
          const SizedBox(width: 10),
          _tuile('LIGUE', _ligues[ligue][0], _ligues[ligue][1]),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boite,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('PROGRÈS · NIVEAU $niveau',
                lien: 'Tout voir ›', onLien: () => context.pushNamed('ProgressDashboard')),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: dansNiveau / 10,
                minHeight: 10,
                color: _orange,
                backgroundColor: _bord,
              ),
            ),
            const SizedBox(height: 6),
            Text('$dansNiveau / 10 mots du niveau $niveau',
                style: TextStyle(color: _gris, fontSize: 12.5)),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boite,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('BADGES · $gagnes / ${badges.length}'),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 8,
              childAspectRatio: 1.15,
              children: [
                for (final b in badges)
                  Opacity(
                    opacity: b[2] == true ? 1 : 0.35,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(b[0] as String, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 4),
                      Text(b[1] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _texte, fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ]),
                  ),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boite,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('STATISTIQUES'),
            Row(children: [
              _stat('$mots', 'mots\nappris', '📖'),
              _stat('${mots ~/ 10}', 'leçons\nterminées', '✅'),
              _stat('$defis', 'défis\nréussis', '🎯'),
              _stat('$coach', 'séances\ncoach', '🧠'),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.pushNamed('Settings'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: _boite,
            child: Row(children: [
              const Text('⚙️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Options et réglages',
                    style: TextStyle(color: _texte, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Icon(Icons.chevron_right_rounded, color: _gris),
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    if (_vueAmis) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: _fond,
        child: Column(children: [
          Expanded(
            child: LexiAmis(
              mode: 'amis',
              onRetour: () async {
                setState(() => _vueAmis = false);
                await _charger();
              },
            ),
          ),
          const LexiNav(actif: 9),
        ]),
      );
    }
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: _fond,
      child: Column(children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: !_charge
                ? const Center(child: CircularProgressIndicator(color: _orange))
                : RefreshIndicator(color: _orange, onRefresh: _charger, child: _contenu()),
          ),
        ),
        const LexiNav(actif: 9),
      ]),
    );
  }
}
