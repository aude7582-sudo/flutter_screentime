// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:firebase_auth/firebase_auth.dart' as fb;
import '/app_state.dart';
import 'package:provider/provider.dart';

/// Planning Léxi : plusieurs créneaux par jour (travail, révisions, sommeil…),
/// clair ou sombre.
class LexiPlanning extends StatefulWidget {
  const LexiPlanning({
    super.key,
    this.width,
    this.height,
    required this.onEnregistre,
  });

  final double? width;
  final double? height;
  final Future Function() onEnregistre;

  @override
  State<LexiPlanning> createState() => _LexiPlanningState();
}

class _LexiPlanningState extends State<LexiPlanning> {
  static const _orange = Color(0xFFF97316);
  static const _violet = Color(0xFF8B5CF6);
  static const _nuit = Color(0xFF312E81);
  static const _jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _durees = ['15 min', '25 min', '45 min', '1 h', '2 h'];
  static const _max = 5;
  static final _h = RegExp(r'^\d{2}:\d{2}$');

  // Modèles prêts à l'emploi.
  static const _modeles = [
    {
      'nom': 'Travail',
      'emoji': '💼',
      'debut': '08:00',
      'fin': '12:00',
      'mode': 'temp',
      'jours': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
    },
    {
      'nom': 'Révisions',
      'emoji': '📚',
      'debut': '18:00',
      'fin': '19:00',
      'mode': 'deux',
      'jours': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
    },
    {
      'nom': 'Sommeil',
      'emoji': '🌙',
      'debut': '22:00',
      'fin': '06:00',
      'mode': 'sommeil',
      'jours': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    },
    {
      'nom': 'Repas en famille',
      'emoji': '🍽️',
      'debut': '19:30',
      'fin': '20:30',
      'mode': 'temp',
      'jours': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    },
    {
      'nom': 'Prière',
      'emoji': '🙏',
      'debut': '05:30',
      'fin': '06:00',
      'mode': 'temp',
      'jours': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    },
    {
      'nom': 'Sport',
      'emoji': '🏃',
      'debut': '17:00',
      'fin': '18:00',
      'mode': 'temp',
      'jours': ['Lun', 'Mer', 'Ven'],
    },
  ];

  static const _nomsModes = {
    'lexi': 'Leçon Léxi 🦊',
    'temp': 'Focus 🎯',
    'deux': 'Léxi + Focus ✨',
    'sommeil': 'Sommeil 🌙',
  };
  static const _emojisModes = {
    'lexi': '🦊',
    'temp': '🎯',
    'deux': '✨',
    'sommeil': '🌙',
  };

  final List<Map<String, dynamic>> _crens = [];
  int _limite = _max;
  String _duree = '15 min';
  bool _charge = false;
  bool _envoi = false;
  DocumentReference? _ref;
  bool _premier = false;

  // Créneau en cours de modification (null = liste).
  Map<String, dynamic>? _c;
  int _index = -1;
  final _nomCtrl = TextEditingController();
  List<Map<String, String>>? _applis;
  bool _chargeApplis = false;

  String get _uid => fb.FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  List<String> _ordonner(Iterable<String> j) =>
      _jours.where((x) => j.contains(x)).toList();

  Future<void> _charger() async {
    try {
      final a = await lexiAcces();
      _limite = a < 0 ? 1 : _max;
    } catch (_) {}
    try {
      final q = await FirebaseFirestore.instance
          .collection('user_stats')
          .where('uid', isEqualTo: _uid)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        final d = q.docs.first.data();
        _ref = q.docs.first.reference;
        _premier = d['onboardingDone'] == false;
        final du = (d['planDuration'] ?? '').toString();
        if (_durees.contains(du)) _duree = du;
        final l = d['planCreneaux'];
        if (l is List && l.isNotEmpty) {
          for (final e in l) {
            if (e is! Map) continue;
            final deb = '${e['debut'] ?? ''}';
            final fin = '${e['fin'] ?? ''}';
            if (!_h.hasMatch(deb) || !_h.hasMatch(fin)) continue;
            final m = '${e['mode'] ?? 'lexi'}';
            final j = e['jours'];
            final ap = e['applis'];
            _crens.add({
              'nom': '${e['nom'] ?? 'Créneau'}',
              'emoji': '${e['emoji'] ?? _emojisModes[m] ?? '⏰'}',
              'debut': deb,
              'fin': fin,
              'mode': _nomsModes.containsKey(m) ? m : 'lexi',
              'jours': j is List
                  ? _ordonner(j.map((x) => '$x'))
                  : ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
              'applis': ap is List ? ap.map((x) => '$x').toList() : null,
            });
          }
        } else {
          final m = (d['planMode'] ?? 'lexi').toString();
          final j = d['planDays'];
          final s = (d['planStart'] ?? '').toString();
          final e = (d['planEnd'] ?? '').toString();
          _crens.add({
            'nom': 'Mon créneau',
            'emoji': _emojisModes[m] ?? '🦊',
            'debut': _h.hasMatch(s) ? s : '09:00',
            'fin': _h.hasMatch(e) ? e : '12:00',
            'mode': _nomsModes.containsKey(m) ? m : 'lexi',
            'jours': (j is List && j.isNotEmpty)
                ? _ordonner(j.map((x) => '$x'))
                : ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
            'applis': null,
          });
        }
      }
    } catch (_) {}
    if (_crens.isEmpty) {
      _crens.add({
        'nom': 'Mon créneau',
        'emoji': '🦊',
        'debut': '09:00',
        'fin': '12:00',
        'mode': 'lexi',
        'jours': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
        'applis': null,
      });
    }
    if (mounted) setState(() => _charge = true);
  }

  Future<void> _chargerApplis() async {
    if (_applis != null || _chargeApplis) return;
    _chargeApplis = true;
    try {
      final q = await FirebaseFirestore.instance
          .collection('apps')
          .where('uid', isEqualTo: _uid)
          .get();
      final l = <Map<String, String>>[];
      final vus = <String>{};
      for (final doc in q.docs) {
        final x = doc.data();
        final p = (x['packageId'] ?? '').toString();
        if (p.isEmpty || !vus.add(p)) continue;
        final n = (x['name'] ?? '').toString();
        l.add({'p': p, 'n': n.isEmpty ? p : n});
      }
      l.sort((a, b) => a['n']!.toLowerCase().compareTo(b['n']!.toLowerCase()));
      _applis = l;
    } catch (_) {
      _applis = [];
    }
    _chargeApplis = false;
    if (mounted) setState(() {});
  }

  void _message(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  int _min(String h) {
    final p = h.split(':');
    return (int.tryParse(p[0]) ?? 0) * 60 +
        (p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0);
  }

  String _plage(Map<String, dynamic> c) {
    final nuit = _min(c['fin']) <= _min(c['debut']);
    return '${c['debut']} → ${c['fin']}${nuit ? ' (lendemain)' : ''}';
  }

  String _resumeJours(List j) {
    if (j.length == 7) return 'Tous les jours';
    if (j.length == 5 && !j.contains('Sam') && !j.contains('Dim')) {
      return 'Du lundi au vendredi';
    }
    if (j.length == 2 && j.contains('Sam') && j.contains('Dim')) {
      return 'Le week-end';
    }
    return j.join(' · ');
  }

  void _ouvrir(int index) {
    if (index < 0) {
      if (_crens.length >= _max) {
        _message('5 créneaux maximum 🦊');
        return;
      }
      if (_crens.length >= _limite) {
        _message(
            'Avec Léxi Pro, tu peux avoir jusqu\'à 5 créneaux par jour 🦊');
        return;
      }
    }
    final src = index >= 0
        ? _crens[index]
        : {
            'nom': '',
            'emoji': '⏰',
            'debut': '14:00',
            'fin': '16:00',
            'mode': 'temp',
            'jours': ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
            'applis': null,
          };
    setState(() {
      _index = index;
      _c = {
        ...src,
        'jours': List<String>.from(src['jours'] as List),
        'applis': src['applis'] == null
            ? null
            : List<String>.from(src['applis'] as List),
      };
      _nomCtrl.text = '${src['nom']}';
    });
  }

  void _appliquerModele(Map<String, Object> m) {
    setState(() {
      _c = {
        ..._c!,
        'nom': m['nom'],
        'emoji': m['emoji'],
        'debut': m['debut'],
        'fin': m['fin'],
        'mode': m['mode'],
        'jours': List<String>.from(m['jours'] as List),
      };
      _nomCtrl.text = '${m['nom']}';
    });
  }

  void _valider() {
    final c = _c!;
    if ((c['jours'] as List).isEmpty) {
      _message('Choisis au moins un jour 📆');
      return;
    }
    if (c['debut'] == c['fin']) {
      _message('Le début et la fin doivent être différents ⏰');
      return;
    }
    if (c['mode'] != 'sommeil' &&
        c['applis'] != null &&
        (c['applis'] as List).isEmpty) {
      _message('Choisis au moins une appli à bloquer 📱');
      return;
    }
    final nom = _nomCtrl.text.trim();
    c['nom'] = nom.isEmpty
        ? 'Créneau ${_index >= 0 ? _index + 1 : _crens.length + 1}'
        : nom;
    if (c['mode'] == 'sommeil') c['applis'] = null;
    if (_modeles.every((m) => m['emoji'] != c['emoji'])) {
      c['emoji'] = _emojisModes[c['mode']] ?? '⏰';
    }
    setState(() {
      if (_index >= 0) {
        _crens[_index] = c;
      } else {
        _crens.add(c);
      }
      _c = null;
    });
  }

  void _supprimer() {
    setState(() {
      if (_index >= 0 && _index < _crens.length) _crens.removeAt(_index);
      _c = null;
    });
  }

  Future<void> _enregistrer() async {
    if (_crens.isEmpty) {
      _message('Ajoute au moins un créneau ⏰');
      return;
    }
    setState(() => _envoi = true);
    try {
      final premier = _crens.first;
      final liste = [
        for (final c in _crens)
          {
            'nom': c['nom'],
            'emoji': c['emoji'],
            'debut': c['debut'],
            'fin': c['fin'],
            'mode': c['mode'],
            'jours': _ordonner((c['jours'] as List).map((x) => '$x')),
            'applis': c['applis'],
          }
      ];
      final v = {
        'planCreneaux': liste,
        'planMode': premier['mode'] == 'sommeil' ? 'temp' : premier['mode'],
        'planDays': _ordonner((premier['jours'] as List).map((x) => '$x')),
        'planStart': premier['debut'],
        'planEnd': premier['fin'],
        'planDuration': _duree,
      };
      if (_ref != null) {
        await _ref!.update(v);
      } else {
        _ref = await FirebaseFirestore.instance
            .collection('user_stats')
            .add({'uid': _uid, ...v});
      }
      _message('Planning enregistré ✓ Léxi veille sur tes applis 🦊');
      await lexiBlocage('planifier');
      await widget.onEnregistre();
    } catch (_) {
      _message('Oups, le planning n\'a pas pu être enregistré. Réessaie.');
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  Widget _carteMode(_P p, String valeur, String emoji, String titre,
      String texte, Color? couleur) {
    final choisi = _c!['mode'] == valeur;
    final fond = couleur ?? (p.s ? const Color(0xFF2E1A3A) : p.carte);
    final txt = couleur != null ? Colors.white : p.texte;
    final sous = couleur != null ? Colors.white.withOpacity(0.92) : p.gris;
    final rond = couleur != null ? Colors.white : p.texte;
    return GestureDetector(
      onTap: () => setState(() => _c!['mode'] = valeur),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: fond,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: choisi
                  ? (couleur != null ? Colors.white : _violet)
                  : (couleur != null ? Colors.transparent : p.bord),
              width: choisi ? 4 : 1.5),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(couleur != null ? 0.22 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titre,
                  style: TextStyle(
                      color: txt, fontSize: 16.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(texte,
                  style: TextStyle(color: sous, fontSize: 13, height: 1.25)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: choisi ? Colors.white : Colors.transparent,
              border: Border.all(color: rond, width: 2),
            ),
            child: choisi
                ? Icon(Icons.check, size: 15, color: couleur ?? _violet)
                : null,
          ),
        ]),
      ),
    );
  }

  Widget _bouton(String t, Color couleur, VoidCallback? onTap,
          {bool occupe = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: couleur,
            borderRadius: BorderRadius.circular(20),
          ),
          child: occupe
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(t,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
        ),
      );

  Widget _bloc(Color fond, String titre, Color couleurTitre, Widget enfant,
          {Color? bord}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
            color: fond,
            borderRadius: BorderRadius.circular(22),
            border: bord == null ? null : Border.all(color: bord, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titre,
              style: TextStyle(
                  color: couleurTitre,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          enfant,
        ]),
      );

  Widget _puce(String t, bool actif, Color fondOff, Color texteOff,
          Color texteOn, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            color: actif ? Colors.white : fondOff,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(t,
              style: TextStyle(
                  color: actif ? texteOn : texteOff,
                  fontSize: 15,
                  fontWeight: actif ? FontWeight.bold : FontWeight.normal)),
        ),
      );

  Widget _heure(String label, String valeur, ValueChanged<String> ok) =>
      Expanded(
        child: GestureDetector(
          onTap: () async {
            final p = valeur.split(':');
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                  hour: int.tryParse(p[0]) ?? 9,
                  minute: p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0),
              helpText: label.toUpperCase(),
              cancelText: 'ANNULER',
              confirmText: 'VALIDER',
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFF97316),
                    onPrimary: Colors.white,
                    surface: Color(0xFF221D3D),
                    onSurface: Colors.white,
                  ),
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor: const Color(0xFF221D3D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    helpTextStyle: const TextStyle(
                        color: Color(0xFFB8B2D6),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4),
                    hourMinuteShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    hourMinuteColor: WidgetStateColor.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? const Color(0xFFF97316)
                            : const Color(0xFF2E2852)),
                    hourMinuteTextColor: Colors.white,
                    dialBackgroundColor: const Color(0xFF14112B),
                    dialHandColor: const Color(0xFFF97316),
                    dialTextColor: WidgetStateColor.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? Colors.white
                            : const Color(0xFFE9E5FF)),
                    entryModeIconColor: const Color(0xFFB8B2D6),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF97316),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                ),
                child: MediaQuery(
                  data:
                      MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                ),
              ),
            );
            if (t != null) {
              setState(() => ok(
                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 14)),
              Text(valeur,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      );

  Color _couleurMode(String m) => m == 'lexi'
      ? _orange
      : m == 'temp'
          ? _violet
          : m == 'sommeil'
              ? _nuit
              : const Color(0xFFDB2777);

  Widget _carteCreneau(_P p, int i) {
    final c = _crens[i];
    final verrou = i >= _limite;
    final coul = _couleurMode(c['mode']);
    return Opacity(
      opacity: verrou ? 0.55 : 1,
      child: GestureDetector(
        onTap: () => _ouvrir(i),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: BoxDecoration(
            color: p.carte,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: p.bord, width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: coul.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('${c['emoji']}', style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c['nom']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: p.texte,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(_plage(c),
                        style: TextStyle(
                            color: p.texte,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                        verrou
                            ? '🔒 Léxi Pro'
                            : '${_resumeJours(c['jours'] as List)} · ${_nomsModes[c['mode']]}',
                        maxLines: 2,
                        style: TextStyle(color: p.gris, fontSize: 13)),
                  ]),
            ),
            Icon(Icons.chevron_right, color: p.gris),
          ]),
        ),
      ),
    );
  }

  Widget _vueListe(_P p) {
    final aLecon = _crens.any((c) => c['mode'] == 'lexi' || c['mode'] == 'deux');
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ton planning 📅',
                  style: TextStyle(
                      color: p.texte,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('Tes moments sans distraction, jour et nuit.',
                  style: TextStyle(color: p.gris, fontSize: 15)),
            ]),
          ),
          Image.asset('assets/images/renard_accueil.png',
              height: 84, fit: BoxFit.contain),
        ]),
        const SizedBox(height: 18),
        for (var i = 0; i < _crens.length; i++) _carteCreneau(p, i),
        if (_crens.length < _max)
          GestureDetector(
            onTap: () => _ouvrir(-1),
            child: Container(
              height: 56,
              margin: const EdgeInsets.only(bottom: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _violet, width: 2),
              ),
              child: Text(
                  _crens.length >= _limite
                      ? '🔒 Ajouter un créneau (Léxi Pro)'
                      : '＋ Ajouter un créneau',
                  style: const TextStyle(
                      color: _violet,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        if (_limite < _max)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
                'Gratuit : 1 créneau. Avec Léxi Pro : jusqu\'à 5 créneaux par jour (travail, révisions, sommeil…).',
                style: TextStyle(color: p.gris, fontSize: 13, height: 1.3)),
          ),
        if (aLecon)
          _bloc(
              p.s ? const Color(0xFF2E1A3A) : p.carte,
              '⏱️ Durée de la leçon',
              p.texte,
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final d in _durees)
                  _puce(
                      d,
                      _duree == d,
                      p.s ? const Color(0xFF1E1530) : p.puce,
                      p.texte,
                      _violet,
                      () => setState(() => _duree = d)),
              ]),
              bord: p.s ? const Color(0xFF5B3A78) : p.bord),
        const SizedBox(height: 4),
        _bouton('Enregistrer mon planning ✓', _orange,
            _envoi ? null : _enregistrer,
            occupe: _envoi),
        const SizedBox(height: 10),
        Center(
          child: Text('Tu reçois un rappel 10 min avant chaque créneau 🔔',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _vueCreneau(_P p) {
    final c = _c!;
    final nuit = _min(c['fin']) <= _min(c['debut']);
    final perso = c['applis'] != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        GestureDetector(
          onTap: () => setState(() => _c = null),
          child: Row(children: [
            Icon(Icons.arrow_back_ios_new, size: 16, color: p.gris),
            const SizedBox(width: 6),
            Text('Mes créneaux',
                style: TextStyle(color: p.gris, fontSize: 15)),
          ]),
        ),
        const SizedBox(height: 12),
        Text(_index >= 0 ? 'Modifier le créneau ✏️' : 'Nouveau créneau ⏰',
            style: TextStyle(
                color: p.texte, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        if (_index < 0) ...[
          Text('Modèles prêts',
              style: TextStyle(
                  color: p.section, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final m in _modeles)
              GestureDetector(
                onTap: () => _appliquerModele(m),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: c['nom'] == m['nom'] ? _violet : p.puce,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('${m['emoji']} ${m['nom']}',
                      style: TextStyle(
                          color: c['nom'] == m['nom'] ? Colors.white : p.texte,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
          const SizedBox(height: 16),
        ],
        Text('Nom du créneau',
            style: TextStyle(
                color: p.section, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _nomCtrl,
          maxLength: 24,
          style: TextStyle(color: p.texte, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Ex. Travail, Révisions, Sommeil…',
            hintStyle: TextStyle(color: p.indice),
            counterText: '',
            filled: true,
            fillColor: p.carte,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: p.bord, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _violet, width: 2)),
          ),
        ),
        const SizedBox(height: 16),
        Text('Que faire pendant ce créneau ?',
            style: TextStyle(
                color: p.section, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _carteMode(p, 'temp', '🎯', 'Focus',
            'Travaille, révise, mange… Tout revient à l\'heure de fin.', _violet),
        _carteMode(p, 'lexi', '🦊', 'Leçon Léxi',
            'Tes applis se débloquent quand ta leçon est finie.', _orange),
        _carteMode(p, 'deux', '✨', 'Léxi + Focus',
            'Focus, puis débloqué à la fin si la leçon est finie.', null),
        _carteMode(
            p,
            'sommeil',
            '🌙',
            'Sommeil',
            'Tout est bloqué sauf téléphone, messages et réveil. Bilan le matin.',
            _nuit),
        const SizedBox(height: 6),
        _bloc(
            _orange,
            '📆 Quels jours ?',
            Colors.white,
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final j in _jours)
                _puce(j, (c['jours'] as List).contains(j),
                    const Color(0xFFC2560F), Colors.white, _orange, () {
                  setState(() {
                    final l = c['jours'] as List<String>;
                    if (!l.remove(j)) l.add(j);
                  });
                }),
            ])),
        _bloc(
            c['mode'] == 'sommeil' ? _nuit : _violet,
            '🕘 Quelles heures ?',
            Colors.white,
            Column(children: [
              Row(children: [
                _heure('Début', c['debut'], (v) => c['debut'] = v),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('→',
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
                _heure('Fin', c['fin'], (v) => c['fin'] = v),
              ]),
              if (nuit) ...[
                const SizedBox(height: 10),
                Text('🌙 Se termine le lendemain à ${c['fin']}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ])),
        if (c['mode'] != 'sommeil')
          _bloc(
              p.carte,
              '📱 Quelles applis bloquer ?',
              p.texte,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 6, runSpacing: 6, children: [
                  _puce('Mes applis habituelles', !perso, p.puce, p.texte,
                      _violet, () => setState(() => c['applis'] = null)),
                  _puce('Choisir pour ce créneau', perso, p.puce, p.texte,
                      _violet, () {
                    setState(() => c['applis'] = <String>[]);
                    _chargerApplis();
                  }),
                ]),
                const SizedBox(height: 8),
                if (!perso)
                  Text(
                      c['mode'] == 'temp'
                          ? 'Réseaux sociaux, jeux et vidéos.'
                          : c['mode'] == 'lexi'
                              ? 'Les applis cochées dans « Mes applis ».'
                              : 'Réseaux sociaux, jeux, vidéos + tes applis cochées.',
                      style: TextStyle(color: p.gris, fontSize: 13)),
                if (perso && _applis == null)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                        child: CircularProgressIndicator(color: _violet)),
                  ),
                if (perso && _applis != null && _applis!.isEmpty)
                  Text('Aucune appli trouvée. Ajoute-les dans « Mes applis ».',
                      style: TextStyle(color: p.gris, fontSize: 13)),
                if (perso && _applis != null)
                  for (final a in _applis!)
                    InkWell(
                      onTap: () => setState(() {
                        final l = c['applis'] as List<String>;
                        if (!l.remove(a['p'])) l.add(a['p']!);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          Icon(
                              (c['applis'] as List).contains(a['p'])
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: _violet),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(a['n']!,
                                style:
                                    TextStyle(color: p.texte, fontSize: 15)),
                          ),
                        ]),
                      ),
                    ),
              ]),
              bord: p.bord),
        const SizedBox(height: 4),
        _bouton('Valider ce créneau ✓', _orange, _valider),
        if (_index >= 0) ...[
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: _supprimer,
              child: const Text('Supprimer ce créneau',
                  style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFEF4444))),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(child: _contenu(context)),
        if (!_premier) const LexiNav(actif: 1),
      ]);

  Widget _contenu(BuildContext context) {
    context.watch<FFAppState>();
    final p = _P(context);
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: p.fond,
      child: SafeArea(
        bottom: false,
        child: !_charge
            ? const Center(child: CircularProgressIndicator(color: _violet))
            : (_c == null ? _vueListe(p) : _vueCreneau(p)),
      ),
    );
  }
}

// Couleurs Léxi selon le mode clair / sombre.
class _P {
  _P(BuildContext c) : s = FFAppState().isDarkMode;
  final bool s;
  Color get fond => s ? const Color(0xFF14112B) : const Color(0xFFF6F3FF);
  Color get carte => s ? const Color(0xFF221D3D) : Colors.white;
  Color get texte => s ? Colors.white : const Color(0xFF1E1640);
  Color get gris => s ? const Color(0xFFB8B2D6) : const Color(0xFF6B6490);
  Color get indice => s ? const Color(0xFF8D86B0) : const Color(0xFF9A93B8);
  Color get bord => s ? const Color(0xFF3A3460) : const Color(0xFFE2DBF5);
  Color get puce => s ? const Color(0xFF2E2752) : const Color(0xFFEFE9FF);
  Color get violetHaut => s ? const Color(0xFF4C1D95) : const Color(0xFFD9C7FF);
  Color get violetMilieu =>
      s ? const Color(0xFF2A1758) : const Color(0xFFEDE4FF);
  Color get section => s ? const Color(0xFFC084FC) : const Color(0xFF7C3AED);
}
