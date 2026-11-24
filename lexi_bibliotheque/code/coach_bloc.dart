
// ---------------------------------------------------------------------------
// Coach Léxi : répliques en français ou en nouchi, petits sons, renard animé.
// Réglages (Paramètres) : lexi_coach_ton = 'fr' | 'nouchi', lexi_sons = true/false.

const Map<String, List<List<String>>> _lxcRepliques = {
  'debut': [
    ['C\'est parti ! Concentre-toi, tu vas assurer 🦊', 'On est ensemble ! Concentre-toi, tu vas gâter ça 🦊'],
    ['Prends ton temps, lis bien chaque mot.', 'Doucement-doucement, regarde bien chaque mot.'],
    ['Je suis avec toi. Montre-moi ce que tu sais !', 'Je suis derrière toi, mon môgô. Montre-moi ton niveau !'],
    ['Un mot à la fois, et tu vas y arriver.', 'Mot par mot, on va arriver. Y a pas drap !'],
  ],
  'bon': [
    ['Bien joué !', 'C\'est propre !'],
    ['Exactement !', 'C\'est ça même !'],
    ['Tu gères !', 'Tu es fort dêh !'],
    ['Super réponse !', 'C\'est doux, ça !'],
    ['Oui ! Continue comme ça.', 'Ehé ! Continue comme ça, on est ensemble.'],
  ],
  'serie': [
    ['Trois d\'affilée, tu es en feu ! 🔥', 'Trois de suite ! Tu es chaud comme braise 🔥'],
    ['Rien ne t\'arrête aujourd\'hui !', 'Aujourd\'hui, personne ne peut te freiner !'],
  ],
  'faux': [
    ['Pas grave, on apprend en se trompant.', 'Y a pas drap, c\'est en tombant qu\'on apprend.'],
    ['Presque ! Regarde bien la prochaine.', 'C\'était pas loin ! Ouvre l\'œil pour la suite.'],
    ['Courage, tu vas l\'avoir !', 'Faut pas fatiguer, tu vas l\'avoir !'],
    ['On respire et on continue.', 'On souffle un peu et on avance.'],
  ],
  'victoire': [
    ['Bravo, niveau réussi ! 🎉', 'Tu as gâté le niveau ! 🎉'],
    ['Tu as été excellent !', 'Tu es en haut, môgô !'],
    ['Je suis fier de toi !', 'Tu m\'as fait plaisir dêh !'],
  ],
  'parfait': [
    ['3 étoiles ! Parfait du début à la fin ⭐⭐⭐', '3 étoiles ! Zéro faute, c\'est trop doux ⭐⭐⭐'],
    ['Un sans-faute, chapeau !', 'Sans faute ! Je te tire mon chapeau !'],
  ],
  'defaite': [
    ['Ce n\'est pas grave, réessaie : tu progresses déjà !', 'C\'est pas grave, on recommence. Tu avances déjà !'],
    ['Chaque essai te rend plus fort.', 'Chaque essai-là te rend plus fort.'],
    ['On se relève et on y retourne ! 💪', 'On se lève et on repart dedans ! 💪'],
  ],
  'manche': [
    ['Bien joué ! On passe à la suite.', 'C\'est propre ! On enchaîne.'],
    ['Une manche de plus ! Tu chauffes.', 'Encore une manche ! Tu es chaud.'],
  ],
};

class _LxCoach {
  static String ton = 'fr';
  static bool sons = true;
  static bool _charge = false;
  static final _hasard = math.Random();

  static Future<void> charger() async {
    if (_charge) return;
    try {
      final pr = await SharedPreferences.getInstance();
      ton = pr.getString('lexi_coach_ton') ?? 'fr';
      sons = pr.getBool('lexi_sons') ?? true;
      _charge = true;
    } catch (_) {}
  }

  static String phrase(String situation) {
    final l = _lxcRepliques[situation] ?? _lxcRepliques['bon']!;
    final r = l[_hasard.nextInt(l.length)];
    return ton == 'nouchi' ? r[1] : r[0];
  }

  static Future<void> son(String type) async {
    await charger();
    if (!sons) return;
    try {
      await const FlutterScreentime().lexiSon(type);
    } catch (_) {}
  }
}

/// Bulle du coach : renard qui bouge + réplique. Joue un son à l'apparition.
class _LxCoachBulle extends StatefulWidget {
  const _LxCoachBulle({required this.situation, this.son});
  final String situation;
  final String? son;

  @override
  State<_LxCoachBulle> createState() => _LxCoachBulleState();
}

class _LxCoachBulleState extends State<_LxCoachBulle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat(reverse: true);
  String _texte = '';

  @override
  void initState() {
    super.initState();
    _LxCoach.charger().then((_) {
      if (!mounted) return;
      setState(() => _texte = _LxCoach.phrase(widget.situation));
      final s = widget.son;
      if (s != null) _LxCoach.son(s);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  String get _image {
    switch (widget.situation) {
      case 'victoire':
      case 'parfait':
      case 'serie':
      case 'manche':
        return 'assets/images/renard_content.png';
      case 'faux':
      case 'defaite':
        return 'assets/images/renard_solution.png';
      default:
        return 'assets/images/renard_focus.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sombre = FFAppState().isDarkMode;
    final fond = sombre ? const Color(0xFF2A2350) : Colors.white;
    final texte = sombre ? Colors.white : const Color(0xFF1E1640);
    final joyeux = widget.situation == 'victoire' ||
        widget.situation == 'parfait' ||
        widget.situation == 'serie';
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (c, v, enfant) => Transform.scale(
          scale: 0.6 + 0.4 * v,
          child: Opacity(opacity: v.clamp(0.0, 1.0).toDouble(), child: enfant)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (c, enfant) {
            final t = Curves.easeInOut.transform(_anim.value);
            return Transform.translate(
              offset: Offset(0, joyeux ? -10 * t : -4 * t),
              child: Transform.rotate(
                  angle: (joyeux ? 0.08 : 0.04) * (t - 0.5), child: enfant),
            );
          },
          child: Image.asset(_image,
              width: 74,
              height: 74,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) =>
                  const Text('🦊', style: TextStyle(fontSize: 52))),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: fond,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                  color: const Color(0xFFF97316).withOpacity(0.55),
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Text(_texte,
                style: TextStyle(
                    color: texte,
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}
