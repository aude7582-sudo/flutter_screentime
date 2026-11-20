// Accueil : envoie la série de jours au widget de l'écran d'accueil.
(function(c){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,b);}
  if(!c.includes("package:shared_preferences/shared_preferences.dart")) {
    rep("import 'package:provider/provider.dart';\n","import 'package:provider/provider.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n");
  }
  rep("                final serie = _entier(d, 'currentStreak');\n","                final serie = _entier(d, 'currentStreak');\n                _serieWidget(serie);\n");
  rep("  Widget _puce(String emoji, String texte, VoidCallback? onTap) {",`  // Série de jours lue par le widget Léxi de l'écran d'accueil.
  static int _derniereSerie = -1;
  void _serieWidget(int s) {
    if (s == _derniereSerie) return;
    _derniereSerie = s;
    SharedPreferences.getInstance().then((p) => p.setInt('lexi_w_serie', s));
  }

  Widget _puce(String emoji, String texte, VoidCallback? onTap) {`);
  window._serR=R; return c;
})
