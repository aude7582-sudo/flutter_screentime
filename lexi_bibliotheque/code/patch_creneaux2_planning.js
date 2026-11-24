// Créneaux phase 2 (LexiPlanning) : récompenses, stats par créneau, pause de 5 min, code parent.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,()=>b);}
  // Imports.
  let imp='';
  if(!c.includes("package:shared_preferences/shared_preferences.dart")) imp+="import 'package:shared_preferences/shared_preferences.dart';\n";
  if(!c.includes("import 'dart:convert'")) imp+="import 'dart:convert';\n";
  rep(`import 'package:installed_apps/installed_apps.dart';
`,`import 'package:installed_apps/installed_apps.dart';
`+imp);
  // Champs.
  rep(`  bool _premier = false;
`,`  bool _premier = false;
  // Phase 2 : stats par créneau, XP gagnés, pause, code parent.
  Map<String, dynamic> _stats = {};
  int _xpGagne = 0;
  bool _strict = false;
  String? _codeParent;
  String _pause = '';
`);
  rep(`        _premier = d['onboardingDone'] == false;
`,`        _premier = d['onboardingDone'] == false;
        _strict = d['strictMode'] == true;
`);
  rep(`    if (mounted) setState(() => _charge = true);
  }
`,`    await _chargerPhase2();
    if (mounted) setState(() => _charge = true);
  }

  Future<void> _chargerPhase2() async {
    try {
      final pr = await SharedPreferences.getInstance();
      await pr.reload();
      _stats = Map<String, dynamic>.from(
          jsonDecode(pr.getString('lexi_stats_cren') ?? '{}') as Map);
      _pause = pr.getString('lexi_pause') ?? '';
      _codeParent = pr.getString('lexi_code_parent');
      final xp = pr.getInt('lexi_xp_attente') ?? 0;
      if (xp > 0 && _ref != null) {
        await _ref!.update({'totalXp': FieldValue.increment(xp)});
        await pr.setInt('lexi_xp_attente', 0);
        _xpGagne = xp;
      }
    } catch (_) {}
  }

  // ---------- Code parent ----------
  String _hash(String s) {
    var h = 5381;
    for (final u in ('lexi-parent-' + s).codeUnits) {
      h = ((h * 33) ^ u) & 0x7fffffff;
    }
    return 'lx' + h.toString();
  }

  Future<String?> _demanderCode(String titre, String texte) async {
    final ctrl = TextEditingController();
    final p = _P(context);
    final r = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: p.carte,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(titre,
            style: TextStyle(color: p.texte, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(texte, style: TextStyle(color: p.gris, fontSize: 14)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: p.texte,
                fontSize: 28,
                letterSpacing: 14,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              hintStyle: TextStyle(color: p.gris.withOpacity(0.4)),
              filled: true,
              fillColor: p.puce,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: Text('Annuler', style: TextStyle(color: p.gris))),
          TextButton(
              onPressed: () => Navigator.of(c).pop(ctrl.text.trim()),
              child: const Text('Valider',
                  style: TextStyle(
                      color: _orange, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    ctrl.dispose();
    return r;
  }

  /// true si pas de code parent, ou si le bon code est tapé.
  Future<bool> _verifierCode() async {
    final code = _codeParent;
    if (code == null || code.isEmpty) return true;
    final r = await _demanderCode('🔒 Code parent',
        'Le planning est protégé. Tape le code parent pour continuer.');
    if (r == null) return false;
    if (_hash(r) == code) return true;
    _message('Code incorrect 🔒');
    return false;
  }

  Future<void> _reglerCode() async {
    final pr = await SharedPreferences.getInstance();
    if (_codeParent != null && _codeParent!.isNotEmpty) {
      if (!await _verifierCode()) return;
      if (!mounted) return;
      final p = _P(context);
      final choix = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: p.carte,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (c) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            ListTile(
                leading: const Text('🔁', style: TextStyle(fontSize: 22)),
                title: Text('Changer le code',
                    style: TextStyle(color: p.texte)),
                onTap: () => Navigator.of(c).pop('changer')),
            ListTile(
                leading: const Text('🔓', style: TextStyle(fontSize: 22)),
                title: Text('Retirer le code',
                    style: TextStyle(color: p.texte)),
                onTap: () => Navigator.of(c).pop('retirer')),
            const SizedBox(height: 10),
          ]),
        ),
      );
      if (choix == 'retirer') {
        await pr.remove('lexi_code_parent');
        setState(() => _codeParent = null);
        _message('Code parent retiré 🔓');
        return;
      }
      if (choix != 'changer') return;
    }
    final a = await _demanderCode('👨‍👩‍👧 Nouveau code parent',
        'Choisis un code à 4 chiffres. Il sera demandé pour modifier le planning ou faire une pause.');
    if (a == null) return;
    if (!RegExp(r'^[0-9]{4}\$').hasMatch(a)) {
      _message('Le code doit avoir 4 chiffres.');
      return;
    }
    final b = await _demanderCode('👨‍👩‍👧 Confirme le code', 'Tape le même code encore une fois.');
    if (b == null) return;
    if (a != b) {
      _message('Les deux codes sont différents. Réessaie.');
      return;
    }
    await pr.setString('lexi_code_parent', _hash(a));
    setState(() => _codeParent = _hash(a));
    _message('Code parent activé 🔒 Garde-le bien !');
  }

  // ---------- Pause de 5 min ----------
  int get _pauseJusqua => _pause.contains('|')
      ? int.tryParse(_pause.split('|').last) ?? 0
      : 0;

  bool _enPause(Map<String, dynamic> c) =>
      _pause.split('|').first == c['nom'] &&
      DateTime.now().millisecondsSinceEpoch < _pauseJusqua;

  Future<void> _pauser(Map<String, dynamic> c) async {
    if (_strict) {
      _message('Mode strict activé : pas de pause possible 🔒');
      return;
    }
    if (!await _verifierCode()) return;
    final pr = await SharedPreferences.getInstance();
    final n = DateTime.now();
    final cle = '\${c['nom']}@\${n.year}-\${n.month}-\${n.day}';
    final faites = pr.getStringList('lexi_pauses_faites') ?? <String>[];
    if (faites.contains(cle)) {
      _message('Tu as déjà pris ta pause pour ce créneau aujourd\\'hui ⏸');
      return;
    }
    faites.add(cle);
    await pr.setStringList('lexi_pauses_faites',
        faites.length > 30 ? faites.sublist(faites.length - 30) : faites);
    final fin = n.add(const Duration(minutes: 5));
    final v = '\${c['nom']}|\${fin.millisecondsSinceEpoch}';
    await pr.setString('lexi_pause', v);
    setState(() => _pause = v);
    await lexiBlocage('planifier');
    _message('⏸ Pause de 5 min : tes applis sont libres jusqu\\'à ' +
        fin.hour.toString().padLeft(2, '0') +
        ':' +
        fin.minute.toString().padLeft(2, '0'));
  }

  // ---------- Stats et médailles ----------
  String _heures(int min) => min < 60
      ? '\$min min'
      : '\${min ~/ 60} h' +
          (min % 60 > 0 ? (min % 60).toString().padLeft(2, '0') : '');

  String? _statsDe(Map<String, dynamic> c) {
    final s = _stats[c['nom']];
    if (s is! Map) return null;
    final n = (s['n'] as num?)?.toInt() ?? 0;
    final min = (s['min'] as num?)?.toInt() ?? 0;
    if (n <= 0) return null;
    final medaille = n >= 50
        ? ' · 🥇'
        : n >= 20
            ? ' · 🥈'
            : n >= 5
                ? ' · 🥉'
                : '';
    return '✅ \$n réussi' +
        (n > 1 ? 's' : '') +
        ' · ' +
        _heures(min) +
        ' protégées' +
        medaille;
  }
`);
  // Le code parent protège l'ouverture d'un créneau (modifier, ajouter, supprimer).
  rep(`  void _ouvrir(int index) {
`,`  Future<void> _ouvrir(int index) async {
    if (!await _verifierCode()) return;
    _ouvrirSansCode(index);
  }

  void _ouvrirSansCode(int index) {
`);
  // Bandeau : bouton pause pendant un créneau.
  rep(`            Text(sous,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.92), fontSize: 14)),
`,`            Text(sous,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.92), fontSize: 14)),
            if (enCours != null) ...[
              const SizedBox(height: 10),
              _boutonPause(enCours!),
            ],
`);
  rep(`  Color _couleurMode(String m) => m == 'lexi'`,`  Widget _boutonPause(Map<String, dynamic> c) {
    final enPause = _enPause(c);
    final fin = DateTime.fromMillisecondsSinceEpoch(_pauseJusqua);
    return GestureDetector(
      onTap: enPause ? null : () => _pauser(c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(enPause ? 0.35 : 0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
        ),
        child: Text(
            enPause
                ? '⏸ En pause jusqu\\'à ' +
                    fin.hour.toString().padLeft(2, '0') +
                    ':' +
                    fin.minute.toString().padLeft(2, '0')
                : (_strict ? '🔒 Mode strict : pas de pause' : '⏸ Pause 5 min'),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Color _couleurMode(String m) => m == 'lexi'`);
  // Carte d'un créneau : stats et médaille.
  rep(`                        maxLines: 2,
                        style: TextStyle(color: p.gris, fontSize: 13)),
                  ]),`,`                        maxLines: 2,
                        style: TextStyle(color: p.gris, fontSize: 13)),
                    if (!verrou && _statsDe(c) != null) ...[
                      const SizedBox(height: 4),
                      Text(_statsDe(c)!,
                          style: TextStyle(
                              color: coul,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700)),
                    ],
                  ]),`);
  // Liste : XP gagnés + explication des récompenses + code parent.
  rep(`        _bandeau(p),
`,`        _bandeau(p),
        if (_xpGagne > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: const Color(0xFF16A34A).withOpacity(0.5)),
            ),
            child: Text(
                '🎁 +\$_xpGagne XP gagnés grâce à tes créneaux réussis !',
                style: TextStyle(
                    color: p.texte,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
`);
  rep(`        const SizedBox(height: 4),
        _bouton(
            'Enregistrer mon planning ✓',`,`        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.carte,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.bord, width: 1.5),
          ),
          child: Text(
              '🏅 Récompenses : chaque créneau tenu jusqu\\'au bout te rapporte des XP (plus il est long, plus tu gagnes). Médailles : 🥉 5 réussites · 🥈 20 · 🥇 50.',
              style: TextStyle(color: p.gris, fontSize: 13, height: 1.35)),
        ),
        GestureDetector(
          onTap: _reglerCode,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            decoration: BoxDecoration(
              color: p.carte,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _codeParent != null ? _orange : p.bord, width: 1.5),
            ),
            child: Row(children: [
              const Text('👨‍👩‍👧', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _codeParent != null
                              ? 'Code parent activé 🔒'
                              : 'Code parent',
                          style: TextStyle(
                              color: p.texte,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                          _codeParent != null
                              ? 'Il faut le code pour modifier le planning ou faire une pause.'
                              : 'Protège le planning d\\'un enfant avec un code à 4 chiffres.',
                          style: TextStyle(color: p.gris, fontSize: 13)),
                    ]),
              ),
              Icon(Icons.chevron_right, color: p.gris),
            ]),
          ),
        ),
        const SizedBox(height: 4),
        _bouton(
            'Enregistrer mon planning ✓',`);
  window._c2pR=R; return c;
})
