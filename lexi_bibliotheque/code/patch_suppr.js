// Réglages : suppression du compte rapide (écran d'attente + suppressions groupées).
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  rep(`    if (ok != true) return;
    final u = _u;
    if (u == null) return;
    final db = FirebaseFirestore.instance;
    try {
      for (final col in ['apps', 'user_stats']) {
        final q = await db.collection(col).where('uid', isEqualTo: u.uid).get();
        for (final d in q.docs) {
          await d.reference.delete();
        }
      }
      try {
        final q = await db
            .collection('achievements')
            .where('uid', isEqualTo: u.uid)
            .get();
        for (final d in q.docs) {
          await d.reference.delete();
        }
      } catch (_) {}
    } catch (_) {
      _message('La suppression a échoué. Vérifie ta connexion et réessaie.');
      return;
    }
    await lexiBlocage('supprimer');
    try {
      await u.delete();`,`    if (ok != true) return;
    final u = _u;
    if (u == null) return;
    // Écran d'attente tout de suite.
    var attenteOuverte = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.carte,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(children: [
          const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(color: _orange, strokeWidth: 3)),
          const SizedBox(width: 16),
          Expanded(
              child: Text('Suppression de ton compte…',
                  style: TextStyle(
                      color: p.texte, fontWeight: FontWeight.w700))),
        ]),
      ),
    );
    void fermerAttente() {
      if (attenteOuverte && mounted) {
        attenteOuverte = false;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    final db = FirebaseFirestore.instance;
    try {
      // Toutes les recherches en même temps, puis suppressions groupées.
      final refs = <DocumentReference>[];
      await Future.wait(['apps', 'user_stats', 'achievements', 'scores']
          .map((col) async {
        try {
          final q =
              await db.collection(col).where('uid', isEqualTo: u.uid).get();
          refs.addAll(q.docs.map((d) => d.reference));
        } catch (_) {}
      }));
      refs.add(db.collection('joueurs').doc(u.uid));
      for (var i = 0; i < refs.length; i += 400) {
        final lot = refs.skip(i).take(400).toList();
        final b = db.batch();
        for (final r in lot) {
          b.delete(r);
        }
        try {
          await b.commit();
        } catch (_) {
          await Future.wait(lot.map((r) async {
            try {
              await r.delete();
            } catch (_) {}
          }));
        }
      }
    } catch (_) {
      fermerAttente();
      _message('La suppression a échoué. Vérifie ta connexion et réessaie.');
      return;
    }
    try {
      await lexiBlocage('supprimer')
          .timeout(const Duration(seconds: 5), onTimeout: () => true);
    } catch (_) {}
    try {
      await u.delete();
      fermerAttente();`);
  rep(`      if (e.code == 'requires-recent-login') {
        _message(`,`      fermerAttente();
      if (e.code == 'requires-recent-login') {
        _message(`);
  rep(`    } catch (_) {
      _message('La suppression a échoué. Réessaie plus tard.');
    }
  }`,`    } catch (_) {
      fermerAttente();
      _message('La suppression a échoué. Réessaie plus tard.');
    }
  }`);
  window._supR=R; return c;
})
