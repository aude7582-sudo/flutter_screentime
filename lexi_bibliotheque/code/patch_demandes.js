// Amis : demandes d'amis (envoyer / accepter / refuser) + profil joueur créé automatiquement.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`  List<Map<String, dynamic>> _amis = [];
`,`  List<Map<String, dynamic>> _amis = [];
  List<Map<String, dynamic>> _recues = []; // demandes reçues
  List<Map<String, dynamic>> _envoyees = []; // demandes envoyées
`);
  rep(`      _moi = m.data() ?? {};
`,`      _moi = m.data() ?? {};
      // Profil joueur créé tout seul (plus besoin de passer par Concours).
      if ((_moi['pseudo'] ?? '').toString().isEmpty || _moi['code'] == null) {
        await _creerProfil();
        final m2 = await _db.collection('joueurs').doc(_uid).get();
        _moi = m2.data() ?? {};
      }
`);
  rep(`      final ids = <String>{};
      for (final d in a.docs) {
        for (final u in (d.data()['uids'] as List? ?? [])) {
          if (u != _uid) ids.add(u.toString());
        }
      }
      _amis = await _joueurs(ids.toList());
`,`      final ids = <String>{};
      final recues = <String, String>{}; // uid -> id de la demande
      final envoyees = <String, String>{};
      for (final d in a.docs) {
        final x = d.data();
        final autres = (x['uids'] as List? ?? [])
            .map((u) => u.toString())
            .where((u) => u != _uid)
            .toList();
        if (autres.isEmpty) continue;
        final autre = autres.first;
        if (x['statut'] == 'attente') {
          if (x['de'] == _uid) {
            envoyees[autre] = d.id;
          } else {
            recues[autre] = d.id;
          }
        } else {
          ids.add(autre);
        }
      }
      _amis = await _joueurs(ids.toList());
      final jr = await _joueurs(recues.keys.toList());
      _recues = [
        for (final j in jr) {...j, 'doc': recues[j['uid']]}
      ];
      final je = await _joueurs(envoyees.keys.toList());
      _envoyees = [
        for (final j in je) {...j, 'doc': envoyees[j['uid']]}
      ];
`);
  rep(`        _message(
            'Aucun joueur avec ce code. Il doit d\\'abord ouvrir « Concours » dans Léxi.');`,
`        _message(
            'Aucun joueur avec ce code. Ton ami doit ouvrir Léxi → Profil → Amis une fois, puis réessaie.');`);
  rep(`        final ami = q.docs.first.id;
        final ids = [_uid, ami]..sort();
        await _db.collection('amities').doc('\${ids[0]}_\${ids[1]}').set({
          'uids': ids,
          'cree': DateTime.now().millisecondsSinceEpoch,
        });
        _champCode.clear();
        _message(
            '\${q.docs.first.data()['pseudo'] ?? 'Ton ami'} est maintenant ton ami 🎉');`,
`        final ami = q.docs.first.id;
        final nom = (q.docs.first.data()['pseudo'] ?? 'Ton ami').toString();
        final ids = [_uid, ami]..sort();
        final ref = _db.collection('amities').doc('\${ids[0]}_\${ids[1]}');
        final ex = await ref.get();
        final x = ex.data();
        final maintenant = DateTime.now().millisecondsSinceEpoch;
        if (ex.exists && x != null && x['statut'] != 'attente') {
          _message('\$nom est déjà ton ami 🦊');
        } else if (ex.exists && x != null && x['de'] == ami) {
          // Il t'avait déjà envoyé une demande : vous devenez amis.
          await ref.update({'statut': 'ok', 'accepte': maintenant});
          _message('\$nom et toi êtes maintenant amis 🎉');
        } else if (ex.exists) {
          _message('Demande déjà envoyée à \$nom ⏳');
        } else {
          await ref.set({
            'uids': ids,
            'de': _uid,
            'statut': 'attente',
            'cree': maintenant,
          });
          _message('Demande envoyée à \$nom ⏳ Il doit l\\'accepter.');
        }
        _champCode.clear();`);
  rep(`  Future<void> _partager(String texte) async {`,`  Future<void> _creerProfil() async {
    try {
      var pseudo = currentUserDisplayName.trim();
      if (pseudo.isEmpty) pseudo = currentUserEmail.split('@').first;
      if (pseudo.isEmpty) pseudo = 'Joueur';
      if (pseudo.length > 18) pseudo = pseudo.substring(0, 18);
      var pays = 'XX';
      try {
        final s = await _db
            .collection('user_stats')
            .where('uid', isEqualTo: _uid)
            .limit(1)
            .get();
        if (s.docs.isNotEmpty) {
          final p = (s.docs.first.data()['pays'] ?? '').toString();
          if (p.isNotEmpty) pays = p;
        }
      } catch (_) {}
      await _db.collection('joueurs').doc(_uid).set({
        'uid': _uid,
        'pseudo': (_moi['pseudo'] ?? '').toString().isEmpty
            ? pseudo
            : _moi['pseudo'],
        'pays': _moi['pays'] ?? pays,
        'code': _code,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _accepter(Map<String, dynamic> j) async {
    try {
      await _db.collection('amities').doc(j['doc'].toString()).update({
        'statut': 'ok',
        'accepte': DateTime.now().millisecondsSinceEpoch,
      });
      _message('\${j['pseudo'] ?? 'Ton ami'} et toi êtes maintenant amis 🎉');
      await _charger();
    } catch (_) {
      _message('Oups, vérifie ta connexion et réessaie.');
    }
  }

  Future<void> _supprimerDemande(Map<String, dynamic> j, String texte) async {
    try {
      await _db.collection('amities').doc(j['doc'].toString()).delete();
      _message(texte);
      await _charger();
    } catch (_) {
      _message('Oups, vérifie ta connexion et réessaie.');
    }
  }

  Widget _ligneDemande(Map<String, dynamic> j, bool recue) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: _boite(bord: recue ? _orange : null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Text(recue ? '👋' : '⏳', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((j['pseudo'] ?? 'Un joueur').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _texte,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800)),
                    Text(
                        recue
                            ? 'veut être ton ami(e) sur Léxi'
                            : 'Demande envoyée · en attente',
                        style: TextStyle(color: _gris, fontSize: 12.5)),
                  ]),
            ),
            if (!recue)
              _bouton('Annuler', _gris,
                  () => _supprimerDemande(j, 'Demande annulée.'),
                  plein: false),
          ]),
          if (recue) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _bouton('✓ Accepter', _vert, () => _accepter(j))),
              const SizedBox(width: 10),
              Expanded(
                  child: _bouton('Refuser', _rouge,
                      () => _supprimerDemande(j, 'Demande refusée.'),
                      plein: false)),
            ]),
          ],
        ]),
      );

  Future<void> _partager(String texte) async {`);
  rep(`      _titreSection('MES AMIS (\${_amis.length})'),`,`      if (_recues.isNotEmpty) ...[
        _titreSection('👋 DEMANDES D\\'AMIS (\${_recues.length})'),
        for (final j in _recues) _ligneDemande(j, true),
      ],
      if (_envoyees.isNotEmpty) ...[
        _titreSection('DEMANDES ENVOYÉES (\${_envoyees.length})'),
        for (final j in _envoyees) _ligneDemande(j, false),
      ],
      _titreSection('MES AMIS (\${_amis.length})'),`);
  window._demR=R; return c;
})
