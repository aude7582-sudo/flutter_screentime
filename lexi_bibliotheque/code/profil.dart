
import '/app_state.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/nav/nav.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Profil Léxi (façon EWA) : avatar ou photo, pseudo, code ami, Léxi Pro,
/// amis + invitation, série, ligue, progrès, badges avec progression et
/// statistiques. La roue ⚙️ ouvre les Paramètres.
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
    '🐶', '🐮', '🐷', '🦄', '🐙', '🦋', '🐬', '🦜',
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
  // 'accueil', 'amis', 'profil' ou 'ligue'
  String _vue = 'accueil';
  Map<String, dynamic> _d = {};
  DocumentReference? _ref;
  int _nbAmis = 0;
  int _acces = 7;
  Uint8List? _photo;

  // Brouillon de la page « Mon profil »
  final TextEditingController _nomCtrl = TextEditingController();
  String _edAvatar = '🦊';
  Uint8List? _edPhoto;
  bool _enregistre = false;

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

  Uint8List? _decoder(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    try {
      return base64Decode(v);
    } catch (_) {
      return null;
    }
  }

  void _message(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  void initState() {
    super.initState();
    _charger();
    lexiAcces().then((v) {
      if (mounted) setState(() => _acces = v);
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
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
        _photo = _decoder(_d['photoData']);
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
    for (final k in [
      'currentIndex',
      'currentIndex_es',
      'currentIndex_zh',
      'currentIndex_pt'
    ]) {
      m += _entier(_d[k]);
    }
    return m;
  }

  int get _indexLangue {
    final l = (_d['langue'] ?? 'en').toString();
    return _entier(_d[l == 'en' ? 'currentIndex' : 'currentIndex_' + l]);
  }

  String get _pseudo {
    final p = (_d['pseudo'] ?? '').toString();
    if (p.isNotEmpty) return p;
    final e = currentUserEmail;
    return e.contains('@') ? e.split('@').first : 'Moi';
  }

  // ---------- Avatar (photo ou emoji) ----------

  Widget _rond(double taille,
      {String? emoji, Uint8List? photo, bool bordure = true}) {
    final img = photo;
    return Container(
      width: taille,
      height: taille,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _carte,
        shape: BoxShape.circle,
        border: bordure ? Border.all(color: _orange, width: 3) : null,
      ),
      child: img != null
          ? ClipOval(
              child: Image.memory(img,
                  width: taille - 6,
                  height: taille - 6,
                  fit: BoxFit.cover,
                  gaplessPlayback: true),
            )
          : Text(emoji ?? '🦊', style: TextStyle(fontSize: taille * 0.55)),
    );
  }

  void _ouvrirMonProfil() {
    _nomCtrl.text = (_d['pseudo'] ?? '').toString().isNotEmpty
        ? (_d['pseudo'] ?? '').toString()
        : _pseudo;
    _edAvatar = (_d['avatar'] ?? '🦊').toString();
    _edPhoto = _photo;
    setState(() => _vue = 'profil');
  }

  Future<void> _choisirPhoto() async {
    try {
      final x = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 320,
          maxHeight: 320,
          imageQuality: 70);
      if (x == null) return;
      final octets = await x.readAsBytes();
      if (mounted) setState(() => _edPhoto = octets);
    } catch (_) {
      _message('Impossible d\'ouvrir ta galerie.');
    }
  }

  Future<void> _enregistrerProfil() async {
    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) {
      _message('Écris ton prénom ou ton pseudo 🙂');
      return;
    }
    setState(() => _enregistre = true);
    final donnees = <String, dynamic>{
      'pseudo': nom,
      'avatar': _edAvatar,
      'photoData': _edPhoto != null ? base64Encode(_edPhoto!) : '',
    };
    try {
      await _ref?.update(donnees);
      _d.addAll(donnees);
      _photo = _edPhoto;
      _message('Profil enregistré ✓');
      if (mounted) setState(() => _vue = 'accueil');
    } catch (_) {
      _message('Oups, vérifie ta connexion et réessaie.');
    }
    if (mounted) setState(() => _enregistre = false);
  }

  // ---------- Partage / code ami ----------

  String get _invitation =>
      'Viens apprendre l\'anglais avec moi sur Léxi 🦊 ! '
      'Ajoute-moi avec mon code ami : $_code';

  Future<void> _copierCode() async {
    await Clipboard.setData(ClipboardData(text: _code));
    _message('Code ami copié : $_code');
  }

  Future<void> _partager() async {
    try {
      await launchURL(
          'https://wa.me/?text=' + Uri.encodeComponent(_invitation));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: _invitation));
      _message('Invitation copiée ! Colle-la dans WhatsApp ou un SMS.');
    }
  }

  // ---------- Petits éléments ----------

  Widget _section(String t, {String? lien, VoidCallback? onLien}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(
            child: Text(t,
                style: TextStyle(
                    color: _gris,
                    fontSize: 11.5,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w800)),
          ),
          if (lien != null)
            GestureDetector(
              onTap: onLien,
              child: Text(lien,
                  style: const TextStyle(
                      color: _orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
            ),
        ]),
      );

  BoxDecoration get _boite => BoxDecoration(
        color: _carte,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bord, width: 1.5),
      );

  Widget _tuile(String titre, String emoji, String valeur,
          {VoidCallback? onTap}) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: _boite,
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre,
                          style: TextStyle(
                              color: _gris,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(valeur,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _texte,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ]),
                    ]),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: _gris),
            ]),
          ),
        ),
      );

  Widget _stat(String valeur, String nom, String emoji) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: _fond,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(valeur,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: _texte, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(nom,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(color: _gris, fontSize: 11, height: 1.15)),
        ]),
      );

  Widget _entete(String titre) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 16, 4),
        child: Row(children: [
          IconButton(
            onPressed: () => setState(() => _vue = 'accueil'),
            icon: Icon(Icons.arrow_back_rounded, color: _texte, size: 28),
          ),
          Expanded(
            child: Text(titre,
                style: TextStyle(
                    color: _texte, fontSize: 21, fontWeight: FontWeight.w900)),
          ),
        ]),
      );

  static const _txtAPropos =
      "Léxi t'aide à apprendre une langue et à reprendre le contrôle de ton téléphone : tes applis se débloquent quand tu as appris tes mots. Léxi est une application Veroli. Langues : anglais, espagnol, portugais et mandarin.";
  static const _txtConditions =
      "En utilisant Léxi, tu acceptes de l'utiliser pour ton usage personnel. Le blocage des applis est une aide : tu peux le désactiver à tout moment dans les Réglages. L'abonnement Léxi Pro se gère et s'annule depuis Google Play. Léxi peut évoluer et ajouter de nouvelles fonctions. Pour toute question, écris-nous depuis Réglages, Nous contacter.";
  static const _txtConfidentialite =
      "Léxi enregistre ton adresse e-mail, ta progression (mots, défis, séries) et tes choix (langue, objectifs, applis à bloquer) pour faire fonctionner l'appli. Ton temps d'écran est calculé sur ton téléphone ; seuls tes points de concours et de duels sont partagés avec tes amis. Tes données ne sont pas vendues. Tu peux supprimer ton compte et tes données à tout moment dans les Réglages.";

  Widget _lien(String t, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Text(t,
            style: TextStyle(
                color: _gris,
                fontSize: 12.5,
                decoration: TextDecoration.underline)),
      );

  void _fiche(String titre, String corps) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _carte,
        title: Text(titre,
            style: TextStyle(color: _texte, fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Text(corps,
              style: TextStyle(color: _texte, fontSize: 14, height: 1.4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('OK', style: TextStyle(color: _orange)),
          ),
        ],
      ),
    );
  }

  // ---------- Badges ----------

  // [emoji, nom, description, valeur, objectif]
  List<List<Object>> get _badges {
    final mots = _motsTotal;
    final serie = _entier(_d['currentStreak']);
    final ligue = _entier(_d['ligue']);
    return [
      ['🌱', 'Premiers mots', 'Apprends tes 10 premiers mots.', mots, 10],
      ['📚', '100 mots', 'Apprends 100 mots.', mots, 100],
      ['🔥', '7 jours de suite', 'Apprends 7 jours d\'affilée.', serie, 7],
      ['🧠', 'Coach validé', 'Termine une séance avec le coach.',
        _entier(_d['coachTotal']), 1],
      ['🎯', '5 défis', 'Réussis 5 défis pour débloquer tes applis.',
        _entier(_d['defisTotal']), 5],
      ['🏆', 'Ligue Renard', 'Monte jusqu\'à la ligue Renard.', ligue, 2],
      ['📖', 'Petit lecteur', 'Lis 10 chapitres dans Lecture.',
        _entier(_d['livresChapitres']), 10],
      ['📕', 'Premier livre', 'Termine un livre en entier.',
        _entier(_d['livresFinis']), 1],
      ['🎮', 'Joueur', 'Joue 20 parties dans Jouer.',
        _entier(_d['jeuxTotal']), 20],
    ];
  }

  void _ficheBadge(List<Object> b) {
    final v = (b[3] as int).clamp(0, b[4] as int).toInt();
    final fini = v >= (b[4] as int);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _carte,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Opacity(
              opacity: fini ? 1 : 0.4,
              child: Text(b[0] as String,
                  style: const TextStyle(fontSize: 56))),
          const SizedBox(height: 8),
          Text(b[1] as String,
              style: TextStyle(
                  color: _texte, fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(b[2] as String,
              textAlign: TextAlign.center,
              style: TextStyle(color: _gris, fontSize: 14)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: v / (b[4] as int),
              minHeight: 10,
              color: fini ? _vert : _orange,
              backgroundColor: _bord,
            ),
          ),
          const SizedBox(height: 6),
          Text(fini ? 'Badge gagné ! 🎉' : '$v de ${b[4]}',
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
    final obj = b[4] as int;
    final v = (b[3] as int).clamp(0, obj).toInt();
    final fini = v >= obj;
    return GestureDetector(
      onTap: () => _ficheBadge(b),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Opacity(
            opacity: fini ? 1 : 0.35,
            child:
                Text(b[0] as String, style: const TextStyle(fontSize: 30))),
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
        Text(fini ? '✓' : '$v de $obj',
            style: TextStyle(
                color: fini ? _vert : _gris,
                fontSize: 10.5,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  // ---------- Page d'accueil du profil ----------

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
    final badges = _badges;
    final gagnes =
        badges.where((b) => (b[3] as int) >= (b[4] as int)).length;
    final amisTexte = _nbAmis > 1 ? '$_nbAmis amis' : '$_nbAmis ami';
    final jours = _acces > 1 ? 'jours' : 'jour';
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      children: [
        Row(children: [
          GestureDetector(
            onTap: _ouvrirMonProfil,
            child: Stack(clipBehavior: Clip.none, children: [
              _rond(72, emoji: avatar, photo: _photo),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: _orange, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: _ouvrirMonProfil,
                child: Text('$_pseudo $pays',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: _texte,
                        fontSize: 21,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: _copierCode,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Code ami : $_code',
                      style: TextStyle(
                          color: _gris,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(Icons.copy_rounded, color: _gris, size: 14),
                ]),
              ),
              GestureDetector(
                onTap: () => setState(() => _vue = 'amis'),
                child: Text(amisTexte + ' ›',
                    style: const TextStyle(
                        color: _violet,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
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
              gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFFB923C)]),
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
                            : 'Essai gratuit : encore $_acces $jours',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _vue = 'amis'),
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('Trouver des amis',
                    style:
                        TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _violet,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            height: 48,
            child: OutlinedButton(
              onPressed: _partager,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: _violet, width: 1.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Icon(Icons.share_rounded, color: _violet),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          _tuile('SÉRIE', '🔥', '$serie'),
          const SizedBox(width: 10),
          _tuile('LIGUE', _ligues[ligue][0], _ligues[ligue][1],
              onTap: () => setState(() => _vue = 'ligue')),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boite,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('PROGRÈS · NIVEAU $niveau',
                lien: 'Tout voir ›',
                onLien: () => context.pushNamed('ProgressDashboard')),
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('BADGES · $gagnes DE ${badges.length}'),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 6,
              childAspectRatio: 0.95,
              children: [for (final b in badges) _celluleBadge(b)],
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boite,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section('STATISTIQUES'),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.72,
              children: [
                _stat('$mots', 'mots appris', '📖'),
                _stat('${mots ~/ 10}', 'leçons terminées', '✅'),
                _stat('$defis', 'défis réussis', '🎯'),
                _stat('$coach', 'séances coach', '🧠'),
                _stat('${_entier(_d['minutesLecture'])}', 'minutes de lecture',
                    '⏱️'),
                _stat('${_entier(_d['livresChapitres'])}', 'chapitres lus',
                    '📕'),
                _stat('${_entier(_d['jeuxTotal'])}', 'parties jouées', '🎮'),
                _stat('${_entier(_d['totalXp'])}', 'XP gagnés', '⚡'),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
            _lien('À propos', () => _fiche('À propos', _txtAPropos)),
            Text('·', style: TextStyle(color: _gris)),
            _lien('Conditions d’utilisation',
                () => _fiche('Conditions d’utilisation', _txtConditions)),
            Text('·', style: TextStyle(color: _gris)),
            _lien('Confidentialité',
                () => _fiche('Confidentialité', _txtConfidentialite)),
          ]),
        ),
      ],
    );
  }

  // ---------- Page « Mon profil » ----------

  Widget _pageMonProfil() {
    return Column(children: [
      _entete('Mon profil'),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(child: _rond(110, emoji: _edAvatar, photo: _edPhoto)),
            const SizedBox(height: 18),
            Text('TON PRÉNOM OU PSEUDO',
                style: TextStyle(
                    color: _gris,
                    fontSize: 11.5,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            TextField(
              controller: _nomCtrl,
              maxLength: 20,
              style: TextStyle(
                  color: _texte, fontSize: 17, fontWeight: FontWeight.w700),
              cursorColor: _orange,
              decoration: InputDecoration(
                filled: true,
                fillColor: _carte,
                counterStyle: TextStyle(color: _gris),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _bord, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _orange, width: 2)),
              ),
            ),
            const SizedBox(height: 10),
            Text('CHOISIS TON AVATAR',
                style: TextStyle(
                    color: _gris,
                    fontSize: 11.5,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final a in _avatars)
                  GestureDetector(
                    onTap: () => setState(() {
                      _edAvatar = a;
                      _edPhoto = null;
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _carte,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _edPhoto == null && a == _edAvatar
                                ? _orange
                                : _bord,
                            width: 2.5),
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _choisirPhoto,
                icon: const Icon(Icons.photo_library_rounded, color: _violet),
                label: Text(
                    _edPhoto == null
                        ? 'Prendre une photo de ma galerie'
                        : 'Changer de photo',
                    style: const TextStyle(
                        color: _violet,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _violet, width: 1.8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            if (_edPhoto != null)
              TextButton(
                onPressed: () => setState(() => _edPhoto = null),
                child: Text('Retirer la photo',
                    style: TextStyle(color: _gris, fontSize: 14)),
              ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _enregistre ? null : _enregistrerProfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: _enregistre
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Prêt',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ---------- Page « Ligue » ----------

  Widget _pageLigue() {
    final ligue = _entier(_d['ligue']).clamp(0, 4).toInt();
    final xp = _entier(_d['totalXp']);
    return Column(children: [
      _entete('Ma ligue'),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C3AED), Color(0xFFF97316)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(children: [
                Text(_ligues[ligue][0], style: const TextStyle(fontSize: 64)),
                Text('Ligue ${_ligues[ligue][1]}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('$xp XP au total',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _boite,
              child: Text(
                  'Chaque semaine, joue à « Ligue de la semaine » dans Concours. '
                  'Gagne des XP en apprenant tes mots, en lisant et en jouant : '
                  'les meilleurs de la semaine montent dans la ligue suivante 🚀',
                  style: TextStyle(color: _texte, fontSize: 14, height: 1.4)),
            ),
            const SizedBox(height: 14),
            for (var i = _ligues.length - 1; i >= 0; i--)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _carte,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: i == ligue ? _orange : _bord,
                      width: i == ligue ? 2.5 : 1.5),
                ),
                child: Row(children: [
                  Opacity(
                      opacity: i > ligue ? 0.4 : 1,
                      child: Text(_ligues[i][0],
                          style: const TextStyle(fontSize: 30))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Ligue ${_ligues[i][1]}',
                        style: TextStyle(
                            color: i > ligue ? _gris : _texte,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                  if (i == ligue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Tu es ici',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    )
                  else if (i < ligue)
                    const Icon(Icons.check_circle_rounded, color: _vert)
                  else
                    Icon(Icons.lock_rounded, color: _gris),
                ]),
              ),
            const SizedBox(height: 6),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed('Concours'),
                icon: const Icon(Icons.emoji_events_rounded),
                label: const Text('Jouer la Ligue de la semaine',
                    style:
                        TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    Widget corps;
    if (_vue == 'amis') {
      corps = LexiAmis(
        mode: 'amis',
        onRetour: () async {
          setState(() => _vue = 'accueil');
          await _charger();
        },
      );
    } else if (_vue == 'profil') {
      corps = SafeArea(bottom: false, child: _pageMonProfil());
    } else if (_vue == 'ligue') {
      corps = SafeArea(bottom: false, child: _pageLigue());
    } else {
      corps = SafeArea(
        bottom: false,
        child: !_charge
            ? const Center(child: CircularProgressIndicator(color: _orange))
            : RefreshIndicator(
                color: _orange, onRefresh: _charger, child: _contenu()),
      );
    }
    return PopScope(
      canPop: _vue == 'accueil',
      onPopInvoked: (dejaFait) {
        if (!dejaFait) setState(() => _vue = 'accueil');
      },
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        color: _fond,
        child: Column(children: [
          Expanded(child: corps),
          const LexiNav(actif: 9),
        ]),
      ),
    );
  }
}
