// Jouer : coach (français / nouchi), sons et renard animé sur les écrans de fin et entre les manches.
(function(c, bloc){
  const R=[];
  function rep(a,b){const n=c.split(a).length-1; R.push(n); if(n===1) c=c.replace(a,()=>b);}
  rep(`import 'package:shared_preferences/shared_preferences.dart';
`,`import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screentime/flutter_screentime.dart';
`);
  rep(`                : 'Réessaie pour débloquer le niveau suivant',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.gris, fontSize: 15.5)),
`,`                : 'Réessaie pour débloquer le niveau suivant',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.gris, fontSize: 15.5)),
        const SizedBox(height: 16),
        _LxCoachBulle(
            situation: gagne ? (e >= 3 ? 'parfait' : 'victoire') : 'defaite',
            son: gagne ? (e >= 3 ? 'niveau' : 'victoire') : 'defaite'),
`);
  rep(`                  ' réussie',
              style: TextStyle(color: p.gris, fontSize: 16)),
          const SizedBox(height: 26),
`,`                  ' réussie',
              style: TextStyle(color: p.gris, fontSize: 16)),
          const SizedBox(height: 18),
          const _LxCoachBulle(situation: 'manche', son: 'bon'),
          const SizedBox(height: 22),
`);
  c = c.replace(/\s*$/, '\n') + bloc;
  window._cjR=R; return c;
})
