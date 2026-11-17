// Paiement Google Play pour Léxi Pro (in_app_purchase)
(function(c){
  const R={};
  // 1) imports
  const imp="// DO NOT REMOVE OR MODIFY THE CODE ABOVE!\n";
  let add="";
  if(!c.includes("package:in_app_purchase/in_app_purchase.dart")) add+="import 'package:in_app_purchase/in_app_purchase.dart';\n";
  if(!c.includes("import 'dart:async'")) add+="import 'dart:async';\n";
  if(!c.includes("auth_util.dart")) add+="import '/auth/firebase_auth/auth_util.dart';\n";
  R.imp=c.split(imp).length-1;
  c=c.replace(imp, imp+"\n"+add);
  // 2) fonction existante qui affichait « Le paiement arrive très bientôt »
  const s=c.indexOf("Le paiement arrive très bientôt");
  const debut=c.lastIndexOf("void ", s);
  const ouv=c.indexOf("{", debut);
  const fin=window._match(c, ouv);
  R.nom=c.slice(debut, ouv).trim();
  R.ok2 = s>0 && debut>0 && fin>s;
  if(R.ok2) c=c.slice(0,ouv)+"{\n    _acheter();\n  }"+c.slice(fin+1);
  // 3) champs + initState + dispose + méthodes
  const a1="  int? _acces;\n  bool _annuel = true;\n";
  R.a1=c.split(a1).length-1;
  c=c.replace(a1, a1+`  bool _paiement = false;
  StreamSubscription<List<PurchaseDetails>>? _achatsSub;
  static const _idMensuel = 'lexi_pro_mensuel';
  static const _idAnnuel = 'lexi_pro_annuel';

  void _message(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  // Écoute les achats Google Play (achat, restauration, erreur).
  void _ecouterAchats() {
    _achatsSub = InAppPurchase.instance.purchaseStream.listen((achats) async {
      for (final a in achats) {
        if (a.status == PurchaseStatus.purchased ||
            a.status == PurchaseStatus.restored) {
          await _activerPro(a);
        } else if (a.status == PurchaseStatus.error) {
          _message('Le paiement n\\'a pas abouti. Réessaie 🙏');
        } else if (a.status == PurchaseStatus.canceled) {
          _message('Paiement annulé.');
        }
        if (a.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(a);
        }
        if (a.status != PurchaseStatus.pending && mounted) {
          setState(() => _paiement = false);
        }
      }
    }, onError: (_) {
      if (mounted) setState(() => _paiement = false);
    });
    // Récupère un abonnement déjà payé (nouveau téléphone, réinstallation).
    InAppPurchase.instance.isAvailable().then((ok) {
      if (ok) InAppPurchase.instance.restorePurchases();
    });
  }

  // Enregistre Léxi Pro dans le profil (lu par lexiAcces).
  Future<void> _activerPro(PurchaseDetails a) async {
    try {
      final uid = currentUserUid;
      if (uid.isEmpty) return;
      final jours = a.productID == _idAnnuel ? 370 : 35;
      final data = {
        'proJusqua': DateTime.now()
            .add(Duration(days: jours))
            .millisecondsSinceEpoch,
        'proProduit': a.productID,
        'proAchat': a.purchaseID ?? '',
        'proMaj': DateTime.now().millisecondsSinceEpoch,
      };
      final col = FirebaseFirestore.instance.collection('user_stats');
      final q = await col.where('uid', isEqualTo: uid).limit(1).get();
      if (q.docs.isEmpty) {
        await col.add({'uid': uid, ...data});
      } else {
        await q.docs.first.reference.update(data);
      }
      if (mounted) setState(() => _acces = 999);
      if (a.status == PurchaseStatus.purchased) {
        _message('Bienvenue dans Léxi Pro 🧡 Merci pour ton soutien !');
      }
    } catch (_) {}
  }

  // Lance le paiement Google Play de l'offre choisie.
  Future<void> _acheter() async {
    if (_paiement) return;
    setState(() => _paiement = true);
    try {
      final iap = InAppPurchase.instance;
      if (!await iap.isAvailable()) {
        _message('Google Play n\\'est pas disponible sur ce téléphone.');
        if (mounted) setState(() => _paiement = false);
        return;
      }
      final id = _annuel ? _idAnnuel : _idMensuel;
      final rep = await iap.queryProductDetails({id});
      if (rep.productDetails.isEmpty) {
        _message('L\\'abonnement arrive très bientôt sur Google Play 🦊');
        if (mounted) setState(() => _paiement = false);
        return;
      }
      final lance = await iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: rep.productDetails.first));
      if (!lance && mounted) setState(() => _paiement = false);
    } catch (_) {
      _message('Le paiement n\\'a pas abouti. Réessaie 🙏');
      if (mounted) setState(() => _paiement = false);
    }
  }

  @override
  void dispose() {
    _achatsSub?.cancel();
    super.dispose();
  }
`);
  const a2="  void initState() {\n    super.initState();\n";
  R.a2=c.split(a2).length-1;
  c=c.replace(a2, a2+"    _ecouterAchats();\n");
  window._payR=R; return c;
})
