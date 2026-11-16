
// ===========================================================================
// JEUX DES CONCOURS : chaque concours a 10 niveaux verrouillés.
// Un niveau s'ouvre quand le précédent est gagné (au moins 1 étoile).
// Progression : user_stats.concoursNiv.<mode>.<niveau> = étoiles.
// ===========================================================================

const _cxOrange = Color(0xFFF97316);
const _cxVert = Color(0xFF16A34A);
const _cxRouge = Color(0xFFDC2626);
const _cxViolet = Color(0xFF7C3AED);
const _cxJaune = Color(0xFFFBBF24);
const _cxVoix = {'en': 'en-US', 'es': 'es-ES', 'pt': 'pt-BR', 'zh': 'zh-CN'};
const _cxStt = {'en': 'en_US', 'es': 'es_ES', 'pt': 'pt_BR', 'zh': 'zh_CN'};
final math.Random _cxR = math.Random();

class _CxP {
  _CxP(this.s);
  final bool s;
  Color get fond => s ? const Color(0xFF14112B) : const Color(0xFFF6F3FF);
  Color get carte => s ? const Color(0xFF221D3D) : Colors.white;
  Color get texte => s ? Colors.white : const Color(0xFF1E1640);
  Color get gris => s ? const Color(0xFFB8B2D6) : const Color(0xFF6B6490);
  Color get bord => s ? const Color(0xFF3A3460) : const Color(0xFFE2DBF5);
  Color get doux => s ? const Color(0xFF2E2852) : const Color(0xFFEDE9FE);
}

_CxP _cxP() => _CxP(FFAppState().isDarkMode);

/// [emoji, titre, sous-titre, couleur, règle]
const _cxModes = <String, List<Object>>{
  'pays': [
    '🌍',
    'Coupe des Pays',
    '3 épreuves : traduction, vrai ou faux, écoute',
    Color(0xFF0EA5E9),
    'Réussis les 3 épreuves du niveau. Chaque bonne réponse rapporte des points à ton pays !'
  ],
  'ligue': [
    '🏆',
    'Match de Ligue',
    'Un match en 5 manches contre un adversaire',
    _cxViolet,
    'Chaque manche = 3 questions. Gagne plus de manches que ton adversaire pour remporter le match.'
  ],
  'accent': [
    '🎤',
    'Concours de l\'Accent',
    'Lis le texte qui défile, Léxi t\'écoute',
    Color(0xFFE11D48),
    'Niveaux 1 à 3 : des mots. 4 à 6 : des phrases. 7 à 10 : des paragraphes. Il faut 80 % pour débloquer le niveau suivant.'
  ],
  'course': [
    '🦊',
    'Course des Renards',
    'Ton renard avance à chaque bonne réponse',
    _cxOrange,
    'Premier arrivé à 30 gagne ! Une erreur fait reculer ton renard d\'une case. Les rivaux vont de plus en plus vite.'
  ],
  'silence': [
    '⏳',
    'Duel du Silence',
    'Pose ton téléphone, puis quiz bonus',
    Color(0xFF64748B),
    'Défie un ami pendant 30 min, 1 h ou 2 h. Quand il appuie sur OK, le duel commence. À la fin, le quiz bonus départage.'
  ],
  'famille': [
    '👨‍👩‍👧',
    'Défi Famille',
    'Passe le téléphone, mime, prononciation',
    _cxVert,
    'À jouer à plusieurs sur un seul téléphone. Chaque niveau = 3 jeux : Passe le téléphone, Mime le mot, Qui prononce le mieux.'
  ],
  'pendu': [
    '🪢',
    'Le Pendu',
    'Trouve le mot lettre par lettre',
    Color(0xFF0891B2),
    'Devine le mot grâce à sa traduction avant que le dessin soit fini.'
  ],
  'phrase': [
    '🧩',
    'Construis la phrase',
    'Remets les mots dans le bon ordre',
    Color(0xFFDB2777),
    'Touche les mots dans le bon ordre pour reconstruire la phrase.'
  ],
};

/// Phrases pour l'accent et « Construis la phrase » : [phrase, traduction]
const _cxPhrases = <String, List<List<String>>>{
  'en': [
    ['I like rice.', 'J\'aime le riz.'],
    ['Where is the bus?', 'Où est le bus ?'],
    ['My sister is very kind.', 'Ma sœur est très gentille.'],
    ['We go to school every day.', 'Nous allons à l\'école chaque jour.'],
    ['I would like a glass of water, please.', 'Je voudrais un verre d\'eau, s\'il te plaît.'],
    ['Today is a beautiful day.', 'Aujourd\'hui est une belle journée.'],
    ['Where is the market?', 'Où est le marché ?'],
    ['Thank you very much for your help.', 'Merci beaucoup pour ton aide.'],
    ['I am happy to see you.', 'Je suis content de te voir.'],
    ['My family is very important to me.', 'Ma famille est très importante pour moi.'],
    ['The taxi is waiting in front of the house.', 'Le taxi attend devant la maison.'],
    ['Can you help me find my phone?', 'Peux-tu m\'aider à trouver mon téléphone ?'],
    ['My mother sells fish at the market.', 'Ma mère vend du poisson au marché.'],
    ['It is very hot in Abidjan today.', 'Il fait très chaud à Abidjan aujourd\'hui.'],
    ['I read a book before I sleep.', 'Je lis un livre avant de dormir.'],
    ['Our teacher speaks English very well.', 'Notre professeur parle très bien anglais.'],
    ['We are going to the beach on Sunday.', 'Nous allons à la plage dimanche.'],
    ['I learn ten new words every morning.', 'J\'apprends dix nouveaux mots chaque matin.'],
    ['My best friend lives near the river.', 'Mon meilleur ami habite près de la rivière.'],
    ['Please turn off your phone during the lesson.', 'Éteins ton téléphone pendant la leçon, s\'il te plaît.'],
  ],
  'es': [
    ['Me gusta el arroz.', 'J\'aime le riz.'],
    ['¿Dónde está el autobús?', 'Où est le bus ?'],
    ['Me llamo Eva y vivo en Abiyán.', 'Je m\'appelle Eva et j\'habite à Abidjan.'],
    ['Quiero un vaso de agua, por favor.', 'Je veux un verre d\'eau, s\'il te plaît.'],
    ['Hoy es un día muy bonito.', 'Aujourd\'hui est une très belle journée.'],
    ['Aprendo español todos los días.', 'J\'apprends l\'espagnol tous les jours.'],
    ['¿Dónde está el mercado?', 'Où est le marché ?'],
    ['Muchas gracias por tu ayuda.', 'Merci beaucoup pour ton aide.'],
    ['Estoy muy feliz de verte.', 'Je suis très content de te voir.'],
    ['Mi familia es muy importante.', 'Ma famille est très importante.'],
    ['Mi madre vende pescado en el mercado.', 'Ma mère vend du poisson au marché.'],
    ['Leo un libro antes de dormir.', 'Je lis un livre avant de dormir.'],
  ],
  'pt': [
    ['Eu gosto de arroz.', 'J\'aime le riz.'],
    ['Onde está o ônibus?', 'Où est le bus ?'],
    ['Meu nome é Eva e moro em Abidjan.', 'Je m\'appelle Eva et j\'habite à Abidjan.'],
    ['Eu quero um copo de água, por favor.', 'Je veux un verre d\'eau, s\'il te plaît.'],
    ['Hoje é um dia muito bonito.', 'Aujourd\'hui est une très belle journée.'],
    ['Eu aprendo português todos os dias.', 'J\'apprends le portugais tous les jours.'],
    ['Onde fica o mercado?', 'Où est le marché ?'],
    ['Muito obrigado pela sua ajuda.', 'Merci beaucoup pour ton aide.'],
    ['Estou muito feliz em te ver.', 'Je suis très content de te voir.'],
    ['Minha família é muito importante.', 'Ma famille est très importante.'],
    ['Minha mãe vende peixe no mercado.', 'Ma mère vend du poisson au marché.'],
    ['Eu leio um livro antes de dormir.', 'Je lis un livre avant de dormir.'],
  ],
  'zh': [
    ['我喜欢米饭。', 'J\'aime le riz.'],
    ['公共汽车在哪儿？', 'Où est le bus ?'],
    ['我叫艾娃，我住在阿比让。', 'Je m\'appelle Eva, j\'habite à Abidjan.'],
    ['请给我一杯水。', 'Donne-moi un verre d\'eau, s\'il te plaît.'],
    ['今天天气很好。', 'Il fait très beau aujourd\'hui.'],
    ['我每天学习中文。', 'J\'apprends le chinois tous les jours.'],
    ['市场在哪儿？', 'Où est le marché ?'],
    ['谢谢你的帮助。', 'Merci pour ton aide.'],
    ['见到你我很高兴。', 'Je suis content de te voir.'],
    ['我的家人很重要。', 'Ma famille est très importante.'],
  ],
};

List<List<String>> _cxPhrasesDe(String langue) =>
    _cxPhrases[langue] ?? _cxPhrases['en']!;

/// Mots d'une phrase (le chinois est découpé caractère par caractère).
List<String> _cxDecouper(String phrase, String langue) {
  if (langue == 'zh') {
    return phrase
        .replaceAll(RegExp(r'[，。？！、]'), '')
        .split('')
        .where((x) => x.trim().isNotEmpty)
        .toList();
  }
  return phrase.split(RegExp(r'\s+')).where((x) => x.isNotEmpty).toList();
}

String _cxSans(String s) {
  const a = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ';
  const b = 'aaaaaaceeeeiiiinooooouuuuyyoa';
  final l = s.toLowerCase();
  final o = StringBuffer();
  for (final ch in l.split('')) {
    final i = a.indexOf(ch);
    o.write(i >= 0 ? b[i] : ch);
  }
  return o.toString().replaceAll(RegExp(r"[^a-z0-9一-鿿]"), '');
}

/// Note de prononciation en % (mots communs, dans l'ordre).
int _cxNote(String attendu, String entendu, String langue) {
  List<String> norm(String s) => (langue == 'zh'
          ? s.replaceAll(RegExp(r'\s'), '').split('')
          : s.toLowerCase().split(RegExp(r'\s+')))
      .map(_cxSans)
      .where((x) => x.isNotEmpty)
      .toList();
  final a = norm(attendu);
  final b = norm(entendu);
  if (a.isEmpty || b.isEmpty) return 0;
  final dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      dp[i][j] = a[i - 1] == b[j - 1]
          ? dp[i - 1][j - 1] + 1
          : math.max(dp[i - 1][j], dp[i][j - 1]);
    }
  }
  return ((dp[a.length][b.length] * 100) / math.max(a.length, b.length))
      .round();
}

List<Map<String, String>> _cxTirer(List<Map<String, String>> mots, int n,
    {bool Function(Map<String, String>)? filtre}) {
  final l = [...mots]..shuffle(_cxR);
  final res = <Map<String, String>>[];
  final ts = <String>{};
  final ds = <String>{};
  for (final m in l) {
    if (filtre != null && !filtre(m)) continue;
    if (ts.contains(m['t']) || ds.contains(m['d'])) continue;
    ts.add(m['t']!);
    ds.add(m['d']!);
    res.add(m);
    if (res.length >= n) break;
  }
  return res;
}

Widget _cxBouton(String t, Color c, VoidCallback? f, {Color? texte}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: f,
        style: ElevatedButton.styleFrom(
          backgroundColor: c,
          foregroundColor: texte ?? Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(t,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );

Future<void> _cxDire(FlutterTts tts, String langue, String texte,
    {double vitesse = 0.42}) async {
  try {
    await tts.stop();
    await tts.setLanguage(_cxVoix[langue] ?? 'en-US');
    await tts.setSpeechRate(vitesse);
    await tts.speak(texte);
  } catch (_) {}
}

/// Écoute le micro (action Léxi listenSpeech). Renvoie '' si rien.
Future<String> _cxEcouter(String langue) async {
  try {
    final p = await SharedPreferences.getInstance();
    await p.setString('lexi_stt', _cxStt[langue] ?? 'en_US');
    return await listenSpeech();
  } catch (_) {
    return '';
  }
}

typedef _CxFin = void Function(int etoiles, int score,
    [Map<String, dynamic>? extra]);

/// Parties enregistrées des autres joueurs (« fantômes »), stockées dans
/// la collection duels avec type = 'partie'.
class _CxFantome {
  _CxFantome(this.pseudo, this.drapeau, this.data);
  final String pseudo;
  final String drapeau;
  final Map<String, dynamic> data;
}

int _cxEtoiles(int bons, int total) {
  if (total <= 0) return 0;
  final p = bons / total;
  if (p >= 0.9) return 3;
  if (p >= 0.75) return 2;
  if (p >= 0.6) return 1;
  return 0;
}

// ---------------------------------------------------------------------------
// Questions à choix (traduction, inverse, vrai/faux, écoute)

class _CxQ {
  _CxQ(this.type, this.enonce, this.choix, this.bon, {this.audio, this.aide});
  final String type; // qcm, inverse, vf, ecoute
  final String enonce;
  final List<String> choix;
  final int bon;
  final String? audio;
  final String? aide;
}

List<_CxQ> _cxQuestions(
    List<Map<String, String>> mots, int n, List<String> types) {
  final res = <_CxQ>[];
  final tires = _cxTirer(mots, n);
  for (var i = 0; i < tires.length; i++) {
    final m = tires[i];
    final type = types[i % types.length];
    List<String> autres(String cle) {
      final l = _cxTirer(mots, 8, filtre: (x) => x[cle] != m[cle])
          .map((x) => x[cle]!)
          .toSet()
          .take(3)
          .toList();
      return l;
    }

    if (type == 'vf') {
      final vrai = _cxR.nextBool();
      final faux = autres('d');
      final d = vrai || faux.isEmpty ? m['d']! : faux.first;
      res.add(_CxQ('vf', '${m['t']}  =  $d ?', ['Vrai', 'Faux'],
          vrai || faux.isEmpty ? 0 : 1,
          aide: '${m['t']} = ${m['d']}'));
    } else if (type == 'inverse') {
      final l = [m['t']!, ...autres('t')]..shuffle(_cxR);
      res.add(_CxQ('inverse', m['d']!, l, l.indexOf(m['t']!)));
    } else if (type == 'ecoute') {
      final l = [m['t']!, ...autres('t')]..shuffle(_cxR);
      res.add(_CxQ('ecoute', 'Qu\'est-ce que tu entends ?', l,
          l.indexOf(m['t']!),
          audio: m['t'], aide: '${m['t']} = ${m['d']}'));
    } else {
      final l = [m['d']!, ...autres('d')]..shuffle(_cxR);
      res.add(_CxQ('qcm', m['t']!, l, l.indexOf(m['d']!), audio: m['t']));
    }
  }
  return res;
}

/// Une question affichée. Appelle [repondu] après la correction.
class _CxQuestionVue extends StatefulWidget {
  const _CxQuestionVue({
    super.key,
    required this.q,
    required this.repondu,
    required this.tts,
    required this.langue,
    this.secondes = 0,
  });
  final _CxQ q;
  final void Function(bool juste) repondu;
  final FlutterTts tts;
  final String langue;
  final int secondes; // 0 = pas de chrono

  @override
  State<_CxQuestionVue> createState() => _CxQuestionVueState();
}

class _CxQuestionVueState extends State<_CxQuestionVue> {
  int? _choisi;
  Timer? _chrono;
  double _reste = 1;

  @override
  void initState() {
    super.initState();
    if (widget.q.type == 'ecoute') {
      Future.delayed(const Duration(milliseconds: 350),
          () => _cxDire(widget.tts, widget.langue, widget.q.audio ?? ''));
    }
    if (widget.secondes > 0) {
      final debut = DateTime.now();
      _chrono = Timer.periodic(const Duration(milliseconds: 100), (t) {
        final e = DateTime.now().difference(debut).inMilliseconds /
            (widget.secondes * 1000);
        if (!mounted) return;
        setState(() => _reste = (1 - e).clamp(0.0, 1.0).toDouble());
        if (e >= 1) _choisir(-1);
      });
    }
  }

  @override
  void dispose() {
    _chrono?.cancel();
    super.dispose();
  }

  void _choisir(int i) {
    if (_choisi != null) return;
    _chrono?.cancel();
    setState(() => _choisi = i);
    final juste = i == widget.q.bon;
    if (juste) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    Future.delayed(Duration(milliseconds: juste ? 650 : 1300), () {
      if (mounted) widget.repondu(juste);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    final q = widget.q;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (widget.secondes > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _reste,
              minHeight: 7,
              color: _reste > 0.3 ? _cxVert : _cxRouge,
              backgroundColor: p.bord,
            ),
          ),
        ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: p.carte,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.bord, width: 1.5),
        ),
        child: Column(children: [
          Text(
              q.type == 'qcm'
                  ? 'Que veut dire…'
                  : q.type == 'inverse'
                      ? 'Comment dit-on…'
                      : q.type == 'vf'
                          ? 'Vrai ou faux ?'
                          : 'Écoute bien 👂',
              style: TextStyle(color: p.gris, fontSize: 13.5)),
          const SizedBox(height: 8),
          if (q.type == 'ecoute')
            GestureDetector(
              onTap: () => _cxDire(widget.tts, widget.langue, q.audio ?? ''),
              child: Container(
                width: 74,
                height: 74,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: _cxOrange, shape: BoxShape.circle),
                child: const Icon(Icons.volume_up_rounded,
                    color: Colors.white, size: 38),
              ),
            )
          else
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(
                child: Text(q.enonce,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: p.texte,
                        fontSize: q.enonce.length > 24 ? 20 : 26,
                        fontWeight: FontWeight.w900)),
              ),
              if (q.type == 'qcm')
                IconButton(
                  onPressed: () =>
                      _cxDire(widget.tts, widget.langue, q.audio ?? ''),
                  icon: const Icon(Icons.volume_up_rounded,
                      color: _cxOrange),
                ),
            ]),
          if (_choisi != null && _choisi != q.bon && q.aide != null) ...[
            const SizedBox(height: 8),
            Text(q.aide!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _cxVert, fontWeight: FontWeight.w800)),
          ],
        ]),
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < q.choix.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _choisir(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: BoxDecoration(
                color: _choisi == null
                    ? p.carte
                    : i == q.bon
                        ? _cxVert.withOpacity(0.18)
                        : i == _choisi
                            ? _cxRouge.withOpacity(0.16)
                            : p.carte,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _choisi == null
                        ? p.bord
                        : i == q.bon
                            ? _cxVert
                            : i == _choisi
                                ? _cxRouge
                                : p.bord,
                    width: 2),
              ),
              child: Text(q.choix[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: p.texte,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Écran d'un concours : liste des 10 niveaux, puis le jeu, puis le résultat.

class _CxConcours extends StatefulWidget {
  const _CxConcours({
    super.key,
    required this.mode,
    required this.langue,
    required this.onRetour,
    this.onPoints,
    this.pseudo = 'Moi',
    this.drapeau = '🌍',
    this.onAmis,
    this.texteAmis = '',
  });
  final VoidCallback? onAmis;
  final String texteAmis;
  final String mode;
  final String langue;
  final VoidCallback onRetour;
  final Future<void> Function(int points)? onPoints;
  final String pseudo;
  final String drapeau;

  @override
  State<_CxConcours> createState() => _CxConcoursState();
}

class _CxConcoursState extends State<_CxConcours> {
  final FlutterTts _tts = FlutterTts();
  bool _charge = false;
  DocumentReference? _ref;
  List<Map<String, String>> _tous = [];
  final List<int> _ordre = [];
  Map<String, int> _prog = {};
  int? _niveau; // niveau en cours de jeu
  int _partie = 0; // pour relancer une partie
  List<int>? _resultat; // [niveau, étoiles, score]
  List<_CxFantome> _fantomes = [];
  List<String> _nomsJoueurs = [];
  List<List<String>> _classement = []; // [pseudo+drapeau, score, moi?]
  int _monRang = 0;
  bool _chargeClassement = false;

  int _entier(dynamic v) => v is num ? v.toInt() : 0;

  List<Object> get _info => _cxModes[widget.mode] ?? _cxModes['pays']!;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _tts.stop();
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
        final c = q.docs.first.data()['concoursNiv'];
        if (c is Map && c[widget.mode] is Map) {
          _prog = {
            for (final e in (c[widget.mode] as Map).entries)
              e.key.toString(): _entier(e.value)
          };
        }
      }
      try {
        await lexiParcours(widget.langue);
      } catch (_) {}
      final s = await db
          .collection('parcours')
          .where('langue', isEqualTo: widget.langue)
          .limit(450)
          .get();
      final docs = [...s.docs]
        ..sort((a, b) => _entier(a.data()['orderIndex'])
            .compareTo(_entier(b.data()['orderIndex'])));
      final l = <Map<String, String>>[];
      _ordre.clear();
      for (final doc in docs) {
        final m = doc.data();
        final t = (m['term'] ?? '').toString().trim();
        final d = (m['definition'] ?? '').toString().trim();
        if (t.isNotEmpty && d.isNotEmpty) {
          l.add({'t': t, 'd': d});
          _ordre.add(_entier(m['orderIndex']));
        }
      }
      _tous = l;
    } catch (_) {}
    if (mounted) setState(() => _charge = true);
  }

  List<Map<String, String>> _pool(int niveau) {
    final lim = 20 + 15 * niveau;
    final l = <Map<String, String>>[];
    for (var i = 0; i < _tous.length; i++) {
      if (_ordre[i] < lim) l.add(_tous[i]);
    }
    return l.length >= 14 ? l : _tous;
  }

  int _etoiles(int n) => _prog[n.toString()] ?? 0;
  bool _ouvert(int n) => n == 1 || _etoiles(n - 1) > 0;

  Future<void> _fin(int niveau, int etoiles, int score,
      [Map<String, dynamic>? extra]) async {
    final avant = _etoiles(niveau);
    _enregistrerPartie(niveau, etoiles, score, extra);
    setState(() {
      if (etoiles > avant) _prog[niveau.toString()] = etoiles;
      _resultat = [niveau, etoiles, score];
      _niveau = null;
    });
    if (etoiles > 0) {
      HapticFeedback.mediumImpact();
    }
    try {
      final maj = <String, dynamic>{
        'totalXp': FieldValue.increment(score),
        'concoursPts': FieldValue.increment(score),
      };
      if (etoiles > avant) {
        maj['concoursNiv.' + widget.mode + '.' + niveau.toString()] = etoiles;
      }
      if (score > 0 || etoiles > avant) await _ref?.update(maj);
    } catch (_) {}
    if (widget.mode == 'silence') {
      try {
        final pr = await SharedPreferences.getInstance();
        final n = DateTime.now();
        final cle = 'lexi_silence_${n.year}_${n.month}_${n.day}';
        if (score > (pr.getInt(cle) ?? 0)) await pr.setInt(cle, score);
      } catch (_) {}
    }
    if (score > 0 && widget.onPoints != null) {
      try {
        await widget.onPoints!(score);
      } catch (_) {}
    }
  }

  Future<List<Map<String, dynamic>>> _parties(int niveau) async {
    final q = await FirebaseFirestore.instance
        .collection('duels')
        .where('type', isEqualTo: 'partie')
        .where('mode', isEqualTo: widget.mode)
        .where('niveau', isEqualTo: niveau)
        .where('langue', isEqualTo: widget.langue)
        .limit(80)
        .get();
    return q.docs.map((d) => d.data()).toList();
  }

  Future<void> _enregistrerPartie(int niveau, int etoiles, int score,
      Map<String, dynamic>? extra) async {
    if (widget.mode == 'famille') return;
    try {
      await FirebaseFirestore.instance.collection('duels').add({
        'type': 'partie',
        'mode': widget.mode,
        'niveau': niveau,
        'langue': widget.langue,
        'uid': currentUserUid,
        'pseudo': widget.pseudo,
        'drapeau': widget.drapeau,
        'score': score,
        'etoiles': etoiles,
        'cree': DateTime.now().millisecondsSinceEpoch,
        if (extra != null) ...extra,
      });
    } catch (_) {}
    await _chargerClassement(niveau);
  }

  /// Classement en ligne du niveau : meilleur score de chaque joueur.
  Future<void> _chargerClassement(int niveau) async {
    if (mounted) setState(() => _chargeClassement = true);
    try {
      final l = await _parties(niveau);
      final best = <String, Map<String, dynamic>>{};
      for (final d in l) {
        final u = (d['uid'] ?? '').toString();
        if (u.isEmpty) continue;
        final s = (d['score'] as num?)?.toInt() ?? 0;
        if (!best.containsKey(u) ||
            s > ((best[u]!['score'] as num?)?.toInt() ?? 0)) {
          best[u] = d;
        }
      }
      final tri = best.values.toList()
        ..sort((a, b) => ((b['score'] as num?) ?? 0)
            .compareTo((a['score'] as num?) ?? 0));
      _classement = [
        for (final d in tri)
          [
            '${d['drapeau'] ?? ''} ${d['pseudo'] ?? 'Joueur'}',
            '${(d['score'] as num?)?.toInt() ?? 0}',
            d['uid'] == currentUserUid ? '1' : ''
          ]
      ];
      _monRang = tri.indexWhere((d) => d['uid'] == currentUserUid) + 1;
    } catch (_) {
      _classement = [];
    }
    if (mounted) setState(() => _chargeClassement = false);
  }

  /// Parties d'autres joueurs pour jouer contre eux (Ligue, Course).
  Future<void> _chargerFantomes(int niveau) async {
    _fantomes = [];
    if (widget.mode != 'ligue' && widget.mode != 'course') return;
    try {
      final l = await _parties(niveau);
      final cle = widget.mode == 'ligue' ? 'manches' : 'ev';
      _nomsJoueurs = {
        for (final d in l)
          if (d['uid'] != currentUserUid)
            '${d['pseudo'] ?? 'Joueur'} ${d['drapeau'] ?? ''}'.trim()
      }.toList();
      final vus = <String>{};
      final ok = l
          .where((d) =>
              d['uid'] != currentUserUid && d[cle] is List && (d[cle] as List).isNotEmpty)
          .toList()
        ..shuffle(_cxR);
      for (final d in ok) {
        final u = (d['uid'] ?? '').toString();
        if (vus.contains(u)) continue;
        vus.add(u);
        _fantomes.add(_CxFantome((d['pseudo'] ?? 'Joueur').toString(),
            (d['drapeau'] ?? '🌍').toString(), d));
        if (_fantomes.length >= 3) break;
      }
    } catch (_) {}
  }

  Future<void> _jouer(int n) async {
    if (_tous.length < 6 && widget.mode != 'accent') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Les mots se chargent… réessaie dans un instant.')));
      return;
    }
    await _chargerFantomes(n);
    if (!mounted) return;
    setState(() {
      _resultat = null;
      _classement = [];
      _niveau = n;
      _partie++;
    });
  }

  Widget _jeu(int n) {
    final mots = _pool(n);
    void fin(int e, int s, [Map<String, dynamic>? x]) => _fin(n, e, s, x);
    final k = ValueKey('${widget.mode}-$n-$_partie');
    switch (widget.mode) {
      case 'ligue':
        return _CxLigue(
            key: k, mots: mots, niveau: n, langue: widget.langue, tts: _tts,
            fin: fin, pseudo: widget.pseudo, drapeau: widget.drapeau,
            adversaire: _fantomes.isNotEmpty ? _fantomes.first : null,
            noms: _nomsJoueurs);
      case 'accent':
        return _CxAccent(
            key: k, mots: mots, niveau: n, langue: widget.langue, tts: _tts,
            fin: fin);
      case 'course':
        return _CxCourse(
            key: k, mots: mots, niveau: n, langue: widget.langue, tts: _tts,
            fin: fin, fantomes: _fantomes);
      case 'famille':
        return _CxFamille(
            key: k, mots: mots, niveau: n, langue: widget.langue, tts: _tts,
            fin: fin);
      case 'pendu':
        return _CxPendu(
            key: k, mots: mots, niveau: n, langue: widget.langue, tts: _tts,
            fin: fin);
      case 'phrase':
        return _CxPhrase(
            key: k, niveau: n, langue: widget.langue, tts: _tts, fin: fin);
      case 'silence':
        return _CxSerie(
            key: k,
            mots: mots,
            niveau: n,
            langue: widget.langue,
            tts: _tts,
            fin: fin,
            epreuves: const [
              ['Quiz bonus', 'qcm,inverse,ecoute,vf']
            ]);
      default:
        return _CxSerie(
            key: k,
            mots: mots,
            niveau: n,
            langue: widget.langue,
            tts: _tts,
            fin: fin,
            epreuves: const [
              ['Épreuve 1 · Traduction', 'qcm,inverse'],
              ['Épreuve 2 · Vrai ou faux', 'vf'],
              ['Épreuve 3 · Écoute', 'ecoute'],
            ]);
    }
  }

  Widget _entete(String titre, String sous, VoidCallback retour) {
    final p = _cxP();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      child: Row(children: [
        IconButton(
          onPressed: retour,
          icon: Icon(Icons.arrow_back_rounded, color: p.texte, size: 28),
        ),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: p.texte,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            Text(sous,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.gris, fontSize: 12.5)),
          ]),
        ),
      ]),
    );
  }

  Widget _grille() {
    final p = _cxP();
    final c = _info[3] as Color;
    final total = _prog.values.fold<int>(0, (a, b) => a + b);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
      children: [
        if (widget.mode == 'silence')
          _CxDuelSilence(langue: widget.langue, pseudo: widget.pseudo),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Text(_info[0] as String, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_info[4] as String,
                  style: TextStyle(
                      color: p.texte, fontSize: 13.5, height: 1.35)),
            ),
          ]),
        ),
        if (widget.onAmis != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: widget.onAmis,
              icon: Icon(Icons.group_rounded, color: c),
              label: Text(widget.texteAmis,
                  style: TextStyle(
                      color: c, fontSize: 15, fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c, width: 1.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text('⭐ $total / 30 étoiles',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: p.gris, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            for (var n = 1; n <= 10; n++)
              GestureDetector(
                onTap: () {
                  if (_ouvert(n)) {
                    _jouer(n);
                  } else {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text(
                              'Gagne le niveau ${n - 1} pour débloquer celui-ci 🔒')));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _ouvert(n) ? p.carte : p.doux,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _ouvert(n) && _etoiles(n) == 0 ? c : p.bord,
                        width: _ouvert(n) && _etoiles(n) == 0 ? 2.5 : 1.5),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ouvert(n)
                            ? Text('$n',
                                style: TextStyle(
                                    color: p.texte,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900))
                            : Icon(Icons.lock_rounded, color: p.gris, size: 26),
                        const SizedBox(height: 4),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          for (var e = 1; e <= 3; e++)
                            Icon(Icons.star_rounded,
                                size: 18,
                                color: e <= _etoiles(n) ? _cxJaune : p.bord),
                        ]),
                      ]),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _vueResultat() {
    final p = _cxP();
    final r = _resultat!;
    final gagne = r[1] > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
      children: [
        Text(gagne ? '🎉' : '💪',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 70)),
        const SizedBox(height: 6),
        Text(gagne ? 'Niveau ${r[0]} gagné !' : 'Presque !',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: p.texte, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var e = 1; e <= 3; e++)
            Icon(Icons.star_rounded,
                size: 46, color: e <= r[1] ? _cxJaune : p.bord),
        ]),
        const SizedBox(height: 8),
        Text('+${r[2]} points',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _cxOrange, fontSize: 20, fontWeight: FontWeight.w900)),
        if (widget.mode != 'famille') ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.carte,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.bord, width: 1.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _monRang > 0
                          ? '🌍 CLASSEMENT EN LIGNE · TU ES ${_monRang}E SUR ${_classement.length}'
                          : '🌍 CLASSEMENT EN LIGNE DU NIVEAU',
                      style: TextStyle(
                          color: p.gris,
                          fontSize: 11.5,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  if (_chargeClassement)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                                color: _cxOrange, strokeWidth: 2.5)))
                  else if (_classement.isEmpty)
                    Text('Tu es le premier à jouer ce niveau ! 🚀',
                        style: TextStyle(color: p.texte, fontSize: 14))
                  else
                    for (var i = 0; i < math.min(5, _classement.length); i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          SizedBox(
                              width: 30,
                              child: Text(
                                  i == 0
                                      ? '🥇'
                                      : i == 1
                                          ? '🥈'
                                          : i == 2
                                              ? '🥉'
                                              : '${i + 1}.',
                                  style: TextStyle(
                                      color: p.texte,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800))),
                          Expanded(
                              child: Text(_classement[i][0],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: _classement[i][2] == '1'
                                          ? _cxOrange
                                          : p.texte,
                                      fontSize: 15,
                                      fontWeight: _classement[i][2] == '1'
                                          ? FontWeight.w900
                                          : FontWeight.w600))),
                          Text('${_classement[i][1]} pts',
                              style: TextStyle(
                                  color: p.gris,
                                  fontWeight: FontWeight.w800)),
                        ]),
                      ),
                ]),
          ),
        ],
        if (!gagne) ...[
          const SizedBox(height: 8),
          Text(
              widget.mode == 'accent'
                  ? 'Il faut 80 % pour passer. Écoute bien le modèle et réessaie !'
                  : 'Réessaie : tu vas y arriver.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 14.5)),
        ],
        const SizedBox(height: 28),
        if (gagne && r[0] < 10) ...[
          _cxBouton('Niveau suivant ›', _cxOrange, () => _jouer(r[0] + 1)),
          const SizedBox(height: 10),
        ],
        _cxBouton('Rejouer', _cxViolet, () => _jouer(r[0])),
        const SizedBox(height: 10),
        _cxBouton('Retour aux niveaux', p.doux,
            () => setState(() => _resultat = null),
            texte: p.texte),
      ],
    );
  }

  Future<bool> _quitterPartie() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) {
        final p = _cxP();
        return AlertDialog(
          backgroundColor: p.carte,
          title: Text('Quitter la partie ?',
              style: TextStyle(color: p.texte, fontWeight: FontWeight.w800)),
          content: Text('Ta progression dans ce niveau sera perdue.',
              style: TextStyle(color: p.gris)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: Text('Continuer', style: TextStyle(color: p.gris))),
            TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                child: const Text('Quitter',
                    style: TextStyle(
                        color: _cxRouge, fontWeight: FontWeight.w800))),
          ],
        );
      },
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final p = _cxP();
    final titre = _info[1] as String;
    Widget corps;
    VoidCallback retour;
    String sous;
    if (!_charge) {
      corps = const Center(child: CircularProgressIndicator(color: _cxOrange));
      retour = widget.onRetour;
      sous = '';
    } else if (_niveau != null) {
      final n = _niveau!;
      corps = _jeu(n);
      sous = 'Niveau $n';
      retour = () async {
        _tts.stop();
        if (await _quitterPartie()) setState(() => _niveau = null);
      };
    } else if (_resultat != null) {
      corps = _vueResultat();
      sous = 'Résultat';
      retour = () => setState(() => _resultat = null);
    } else {
      corps = _grille();
      sous = _info[2] as String;
      retour = widget.onRetour;
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (fait) {
        if (!fait) retour();
      },
      child: Container(
        color: p.fond,
        child: Column(children: [
          _entete('${_info[0]} $titre', sous, retour),
          Expanded(child: corps),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Série d'épreuves (Coupe des Pays, quiz bonus du Duel du Silence)

class _CxSerie extends StatefulWidget {
  const _CxSerie({
    super.key,
    required this.mots,
    required this.niveau,
    required this.langue,
    required this.tts,
    required this.fin,
    required this.epreuves,
  });
  final List<Map<String, String>> mots;
  final int niveau;
  final String langue;
  final FlutterTts tts;
  final _CxFin fin;
  final List<List<String>> epreuves; // [titre, 'types,séparés']

  @override
  State<_CxSerie> createState() => _CxSerieState();
}

class _CxSerieState extends State<_CxSerie> {
  int _ep = 0;
  int _i = 0;
  int _bons = 0;
  int _total = 0;
  bool _pause = true;
  late List<_CxQ> _qs;

  int get _parEpreuve => 5 + (widget.niveau + 1) ~/ 2; // 6 → 10
  int get _secondes => math.max(5, 13 - widget.niveau); // 12 s → 5 s

  @override
  void initState() {
    super.initState();
    _preparer();
  }

  void _preparer() {
    _qs = _cxQuestions(
        widget.mots, _parEpreuve, widget.epreuves[_ep][1].split(','));
    _i = 0;
  }

  void _repondu(bool juste) {
    setState(() {
      _total++;
      if (juste) _bons++;
      _i++;
      if (_i >= _qs.length) {
        if (_ep + 1 < widget.epreuves.length) {
          _ep++;
          _preparer();
          _pause = true;
        } else {
          widget.fin(_cxEtoiles(_bons, _total), _bons * 5);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    if (_pause) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 40, 22, 30),
        children: [
          Text(_ep == 0 ? '🚀' : '👏',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 10),
          if (_ep > 0)
            Text('Bravo ! $_bons / $_total',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _cxVert,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(widget.epreuves[_ep][0],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: p.texte, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('${_qs.length} questions · $_secondes secondes chacune',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 14)),
          const SizedBox(height: 30),
          _cxBouton('C\'est parti !', _cxOrange,
              () => setState(() => _pause = false)),
        ],
      );
    }
    if (_qs.isEmpty) {
      return Center(
          child: Text('Pas assez de mots pour ce niveau.',
              style: TextStyle(color: p.gris)));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: [
        Row(children: [
          Text(widget.epreuves[_ep][0],
              style: TextStyle(
                  color: p.gris, fontSize: 12.5, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('${_i + 1} / ${_qs.length}',
              style: TextStyle(
                  color: p.texte, fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        _CxQuestionVue(
          key: ValueKey('q$_ep-$_i'),
          q: _qs[_i],
          repondu: _repondu,
          tts: widget.tts,
          langue: widget.langue,
          secondes: _secondes,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Match de Ligue : 5 manches de 3 questions contre un adversaire.

const _cxRivaux = [
  ['Kofi', '🇬🇭', '🐯'],
  ['Aminata', '🇸🇳', '🦁'],
  ['Yao', '🇨🇮', '🐸'],
  ['Fatou', '🇲🇱', '🐱'],
  ['Moussa', '🇧🇫', '🐻'],
  ['Grâce', '🇨🇲', '🦋'],
  ['Koffi', '🇹🇬', '🐼'],
  ['Mariam', '🇬🇳', '🦉'],
  ['Serge', '🇧🇯', '🐵'],
  ['Awa', '🇨🇮', '🦒'],
];

class _CxLigue extends StatefulWidget {
  const _CxLigue({
    super.key,
    required this.mots,
    required this.niveau,
    required this.langue,
    required this.tts,
    required this.fin,
    required this.pseudo,
    required this.drapeau,
    this.adversaire,
    this.noms = const [],
  });
  final List<Map<String, String>> mots;
  final int niveau;
  final String langue;
  final FlutterTts tts;
  final _CxFin fin;
  final String pseudo;
  final String drapeau;
  final _CxFantome? adversaire; // vrai joueur (partie enregistrée)
  final List<String> noms; // joueurs pour le tirage au sort

  @override
  State<_CxLigue> createState() => _CxLigueState();
}

/// Match en direct : tirage d'un adversaire, puis chaque question est jouée
/// en même temps par les deux joueurs. On voit l'adversaire réfléchir,
/// répondre, et son score monter.
class _CxLigueState extends State<_CxLigue> {
  late final List<String> _rival = widget.adversaire != null
      ? [widget.adversaire!.pseudo, widget.adversaire!.drapeau]
      : (() {
          final r = _cxRivaux[(widget.niveau - 1) % _cxRivaux.length];
          return [r[0], r[1]];
        })();
  late final List<int> _sesManches = widget.adversaire == null
      ? []
      : [
          for (final x in (widget.adversaire!.data['manches'] as List))
            (x as num).toInt()
        ];
  bool get _vrai => widget.adversaire != null;

  // phases : tirage, face, pause, jeu
  String _phase = 'tirage';
  String _nomTirage = '';
  Timer? _tTirage;

  int _manche = 0;
  int _i = 0;
  int _moi = 0;
  int _lui = 0;
  int _gagnees = 0;
  int _perdues = 0;
  int _bonsTotal = 0;
  String _bilan = '';
  late List<_CxQ> _qs;
  final List<int> _mesManches = [];

  // question en cours
  List<bool> _sesRep = []; // ses réponses de la manche
  final List<int?> _mesPoints = [null, null, null]; // 1 juste, 0 faux
  final List<int?> _sesPoints = [null, null, null];
  bool? _moiJuste; // ma réponse à la question en cours
  bool? _luiJuste; // sa réponse à la question en cours
  Timer? _tLui;
  int _reflexion = 0; // pour l'animation « réfléchit… »
  Timer? _tPoints;

  double get _force => math.min(0.92, 0.42 + widget.niveau * 0.05);

  @override
  void initState() {
    super.initState();
    _qs = _cxQuestions(widget.mots, 3, const ['qcm', 'inverse', 'vf']);
    _lancerTirage();
  }

  @override
  void dispose() {
    _tTirage?.cancel();
    _tLui?.cancel();
    _tPoints?.cancel();
    super.dispose();
  }

  void _lancerTirage() {
    final noms = <String>[
      ...widget.noms,
      for (final r in _cxRivaux) '${r[0]} ${r[1]}',
    ]..shuffle(_cxR);
    var n = 0;
    var delai = 70;
    void tour() {
      if (!mounted) return;
      setState(() => _nomTirage = noms[n % noms.length]);
      n++;
      delai = (delai * 1.12).round();
      if (delai > 420) {
        _tTirage = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          HapticFeedback.mediumImpact();
          setState(() {
            _nomTirage = '${_rival[0]} ${_rival[1]}';
            _phase = 'face';
          });
        });
        return;
      }
      _tTirage = Timer(Duration(milliseconds: delai), tour);
    }

    tour();
  }

  void _preparerManche() {
    final cible = _vrai
        ? (_manche < _sesManches.length ? _sesManches[_manche] : 0)
        : [0, 1, 2, 3].where((_) => _cxR.nextDouble() < _force).length.clamp(0, 3).toInt();
    _sesRep = List.generate(3, (k) => k < cible)..shuffle(_cxR);
    for (var k = 0; k < 3; k++) {
      _mesPoints[k] = null;
      _sesPoints[k] = null;
    }
    _moi = 0;
    _lui = 0;
    _i = 0;
  }

  void _commencerQuestion() {
    _moiJuste = null;
    _luiJuste = null;
    _tLui?.cancel();
    _tPoints?.cancel();
    // il répond entre 2 et 7 s (plus vite aux niveaux élevés)
    final base = math.max(1500, 4500 - widget.niveau * 250);
    final ms = base + _cxR.nextInt(2500);
    _tLui = Timer(Duration(milliseconds: ms), _luiRepond);
    _tPoints = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted && _luiJuste == null) setState(() => _reflexion++);
    });
  }

  void _luiRepond() {
    if (!mounted || _luiJuste != null) return;
    _tPoints?.cancel();
    final j = _i < _sesRep.length ? _sesRep[_i] : false;
    setState(() {
      _luiJuste = j;
      _sesPoints[_i] = j ? 1 : 0;
      if (j) _lui++;
    });
    if (_moiJuste != null) _suivante();
  }

  void _repondu(bool juste) {
    setState(() {
      _moiJuste = juste;
      _mesPoints[_i] = juste ? 1 : 0;
      if (juste) {
        _moi++;
        _bonsTotal++;
      }
    });
    if (_luiJuste != null) {
      _suivante();
    } else {
      // on attend qu'il réponde (au plus 3 s de plus)
      _tLui?.cancel();
      _tLui = Timer(Duration(milliseconds: 600 + _cxR.nextInt(2400)), _luiRepond);
    }
  }

  void _suivante() {
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _i++;
        if (_i < _qs.length) {
          _commencerQuestion();
          return;
        }
        _mesManches.add(_moi);
        if (_moi > _lui) {
          _gagnees++;
          _bilan = 'Manche gagnée ! $_moi – $_lui';
        } else if (_moi < _lui) {
          _perdues++;
          _bilan = 'Manche perdue… $_moi – $_lui';
        } else {
          _bilan = 'Égalité $_moi – $_lui';
        }
        _manche++;
        final restantes = 5 - _manche;
        final fini = _manche >= 5 ||
            _gagnees > _perdues + restantes ||
            _perdues > _gagnees + restantes;
        if (fini) {
          final etoiles = _gagnees > _perdues
              ? (_perdues == 0 ? 3 : (_gagnees - _perdues >= 2 ? 2 : 1))
              : 0;
          widget.fin(etoiles, _bonsTotal * 5 + (etoiles > 0 ? 20 : 0),
              {'manches': _mesManches, 'contre': _rival[0]});
          return;
        }
        _phase = 'pause';
        _qs = _cxQuestions(widget.mots, 3, const ['qcm', 'inverse', 'vf']);
      });
    });
  }

  void _jouerManche() {
    setState(() {
      _preparerManche();
      _phase = 'jeu';
    });
    _commencerQuestion();
  }

  Widget _points(List<int?> l, Color c) {
    final p = _cxP();
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (final v in l)
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: v == null ? p.bord : (v == 1 ? _cxVert : _cxRouge),
          ),
        ),
    ]);
  }

  Widget _joueur(String emoji, String nom, int manches, int pts,
      List<int?> l, Color c, {String? etat, Color? etatC}) {
    final p = _cxP();
    return Expanded(
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 34)),
        Text(nom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: p.texte, fontSize: 14, fontWeight: FontWeight.w800)),
        Text('$manches',
            style:
                TextStyle(color: c, fontSize: 28, fontWeight: FontWeight.w900)),
        if (_phase == 'jeu') ...[
          _points(l, c),
          const SizedBox(height: 6),
          SizedBox(
            height: 18,
            child: Text(etat ?? '',
                style: TextStyle(
                    color: etatC ?? p.gris,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    // 1. Tirage au sort de l'adversaire
    if (_phase == 'tirage' || _phase == 'face') {
      final trouve = _phase == 'face';
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
        children: [
          Text(trouve ? 'Adversaire trouvé !' : 'Recherche d\'un adversaire…',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: trouve ? _cxVert : p.gris,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: Column(children: [
                Text(widget.drapeau, style: const TextStyle(fontSize: 54)),
                const SizedBox(height: 6),
                Text(widget.pseudo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: p.texte,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
            const Text('VS',
                style: TextStyle(
                    color: _cxOrange,
                    fontSize: 30,
                    fontWeight: FontWeight.w900)),
            Expanded(
              child: Column(children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 120),
                  child: Text(trouve ? '😎' : '❓',
                      key: ValueKey(trouve),
                      style: const TextStyle(fontSize: 54)),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: trouve ? _cxViolet : p.doux,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_nomTirage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: trouve ? Colors.white : p.texte,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 28),
          if (trouve) ...[
            Text(
                _vrai
                    ? '🌍 ${_rival[0]} est un vrai joueur de ton niveau. Il joue en même temps que toi : 5 manches de 3 questions, le meilleur gagne !'
                    : '${_rival[0]} est un joueur Léxi. 5 manches de 3 questions, le meilleur gagne !',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.gris, fontSize: 14.5, height: 1.35)),
            const SizedBox(height: 24),
            _cxBouton('Commencer le match ⚔️', _cxViolet, _jouerManche),
          ] else
            const Center(
                child: CircularProgressIndicator(color: _cxViolet)),
        ],
      );
    }

    final reflechit = '.' * (1 + _reflexion % 3);
    final tableau = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: p.carte,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.bord, width: 1.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _joueur(widget.drapeau, widget.pseudo, _gagnees, _moi, _mesPoints,
            _cxOrange,
            etat: _moiJuste == null
                ? 'à toi !'
                : (_moiJuste! ? 'juste ✓' : 'faux ✗'),
            etatC: _moiJuste == null
                ? _cxOrange
                : (_moiJuste! ? _cxVert : _cxRouge)),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(children: [
            Text('MANCHE', style: TextStyle(color: p.gris, fontSize: 11)),
            Text('${math.min(_manche + 1, 5)} / 5',
                style: TextStyle(
                    color: p.texte, fontSize: 18, fontWeight: FontWeight.w900)),
            if (_phase == 'jeu')
              Text('Q${_i + 1} / 3',
                  style: TextStyle(color: p.gris, fontSize: 12)),
          ]),
        ),
        _joueur(_rival[1], _rival[0], _perdues, _lui, _sesPoints, _cxViolet,
            etat: _luiJuste == null
                ? 'réfléchit$reflechit'
                : (_luiJuste! ? 'a répondu ✓' : 'a répondu ✗'),
            etatC: _luiJuste == null
                ? p.gris
                : (_luiJuste! ? _cxVert : _cxRouge)),
      ]),
    );

    // 2. Entre les manches
    if (_phase == 'pause') {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        children: [
          tableau,
          const SizedBox(height: 26),
          Text(_bilan,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _bilan.startsWith('Manche gagnée')
                      ? _cxVert
                      : (_bilan.startsWith('Manche perdue')
                          ? _cxRouge
                          : p.texte),
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Prêt pour la manche ${_manche + 1} ?',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 14.5)),
          const SizedBox(height: 26),
          _cxBouton('Manche suivante', _cxViolet, _jouerManche),
        ],
      );
    }

    // 3. En jeu
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      children: [
        tableau,
        const SizedBox(height: 14),
        if (_moiJuste != null && _luiJuste == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('${_rival[0]} réfléchit encore$reflechit',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _cxViolet, fontWeight: FontWeight.w800)),
          ),
        IgnorePointer(
          ignoring: _moiJuste != null,
          child: _CxQuestionVue(
            key: ValueKey('l$_manche-$_i'),
            q: _qs[_i],
            repondu: _repondu,
            tts: widget.tts,
            langue: widget.langue,
            secondes: math.max(6, 12 - widget.niveau ~/ 2),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Concours de l'Accent : texte karaoké, le téléphone écoute et note en %.

class _CxAccent extends StatefulWidget {
  const _CxAccent({
    super.key,
    required this.mots,
    required this.niveau,
    required this.langue,
    required this.tts,
    required this.fin,
  });
  final List<Map<String, String>> mots;
  final int niveau;
  final String langue;
  final FlutterTts tts;
  final _CxFin fin;

  @override
  State<_CxAccent> createState() => _CxAccentState();
}

class _CxAccentState extends State<_CxAccent> {
  late final List<List<String>> _textes; // [texte, traduction]
  int _i = 0;
  final List<int> _notes = [];
  bool _ecoute = false;
  int _mot = -1; // mot surligné (karaoké)
  Timer? _karaoke;
  int? _note;
  String _entendu = '';

  @override
  void initState() {
    super.initState();
    final n = widget.niveau;
    if (n <= 3) {
      // des mots
      final m = _cxTirer(widget.mots, 5,
          filtre: (x) => !x['t']!.contains(' ') || n > 1);
      _textes = [
        for (final x in m) [x['t']!, x['d']!]
      ];
    } else {
      final ph = [..._cxPhrasesDe(widget.langue)];
      // phrases de plus en plus longues
      ph.sort((a, b) => a[0].length.compareTo(b[0].length));
      final debut = n <= 6
          ? ((n - 4) * ph.length / 6).floor()
          : (ph.length / 2).floor();
      final choix = ph.sublist(debut)..shuffle(_cxR);
      if (n <= 6) {
        _textes = choix.take(3).toList();
      } else {
        // paragraphes : 2 à 4 phrases collées
        final nb = n <= 8 ? 2 : (n == 9 ? 3 : 4);
        final morceaux = choix.take(nb).toList();
        _textes = [
          [
            morceaux.map((x) => x[0]).join(' '),
            morceaux.map((x) => x[1]).join(' ')
          ],
          if (choix.length > nb * 2)
            [
              choix.skip(nb).take(nb).map((x) => x[0]).join(' '),
              choix.skip(nb).take(nb).map((x) => x[1]).join(' ')
            ],
        ];
      }
    }
  }

  @override
  void dispose() {
    _karaoke?.cancel();
    super.dispose();
  }

  List<String> get _mots => _cxDecouper(_textes[_i][0], widget.langue);

  void _demarrerKaraoke(int msParMot) {
    _karaoke?.cancel();
    setState(() => _mot = 0);
    _karaoke = Timer.periodic(Duration(milliseconds: msParMot), (t) {
      if (!mounted) return;
      if (_mot >= _mots.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _mot++);
    });
  }

  Future<void> _modele() async {
    if (_ecoute) return;
    _demarrerKaraoke(widget.langue == 'zh' ? 380 : 480);
    await _cxDire(widget.tts, widget.langue, _textes[_i][0], vitesse: 0.4);
  }

  Future<void> _parler() async {
    if (_ecoute) return;
    await widget.tts.stop();
    setState(() {
      _ecoute = true;
      _note = null;
      _entendu = '';
    });
    _demarrerKaraoke(widget.langue == 'zh' ? 450 : 620);
    final e = await _cxEcouter(widget.langue);
    _karaoke?.cancel();
    if (!mounted) return;
    setState(() {
      _ecoute = false;
      _mot = -1;
      if (e == '#micro') {
        _entendu = 'Autorise le micro pour participer 🎤';
      } else if (e == '#indispo') {
        _entendu = 'Reconnaissance vocale indisponible sur ce téléphone.';
      } else if (e.trim().isEmpty) {
        _entendu = 'Je n\'ai rien entendu, réessaie 🎤';
      } else {
        _entendu = 'Tu as dit : « $e »';
        _note = _cxNote(_textes[_i][0], e, widget.langue);
      }
    });
  }

  void _suivant() {
    _notes.add(_note ?? 0);
    if (_i + 1 >= _textes.length) {
      final moy = _notes.fold<int>(0, (a, b) => a + b) ~/ _notes.length;
      final et = moy >= 95 ? 3 : (moy >= 88 ? 2 : (moy >= 80 ? 1 : 0));
      widget.fin(et, moy ~/ 2);
      return;
    }
    setState(() {
      _i++;
      _note = null;
      _entendu = '';
      _mot = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    final mots = _mots;
    final note = _note;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: [
        Text(
            widget.niveau <= 3
                ? 'Mot ${_i + 1} / ${_textes.length}'
                : widget.niveau <= 6
                    ? 'Phrase ${_i + 1} / ${_textes.length}'
                    : 'Paragraphe ${_i + 1} / ${_textes.length}',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: p.gris, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.carte,
            borderRadius: BorderRadius.circular(22),
            border:
                Border.all(color: _cxOrange.withOpacity(0.5), width: 1.5),
          ),
          child: Column(children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: widget.langue == 'zh' ? 2 : 7,
              runSpacing: 6,
              children: [
                for (var k = 0; k < mots.length; k++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: k == _mot
                          ? _cxOrange
                          : (k < _mot
                              ? _cxOrange.withOpacity(0.15)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(mots[k],
                        style: TextStyle(
                            color: k == _mot ? Colors.white : p.texte,
                            fontSize: widget.niveau <= 3
                                ? 34
                                : (widget.niveau <= 6 ? 24 : 20),
                            fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(_textes[_i][1],
                textAlign: TextAlign.center,
                style: TextStyle(color: p.gris, fontSize: 14)),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _CxRond(icone: Icons.volume_up_rounded, c: _cxOrange, f: _modele),
              const SizedBox(width: 26),
              _CxRond(
                  icone: _ecoute ? Icons.hearing_rounded : Icons.mic_rounded,
                  c: _cxViolet,
                  f: _parler),
            ]),
            const SizedBox(height: 8),
            Text(
                _ecoute
                    ? 'Je t\'écoute… lis en suivant le surligné'
                    : 'Écoute le modèle 🔊 puis appuie sur 🎤',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.gris, fontSize: 12.5)),
          ]),
        ),
        if (_entendu.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(_entendu,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.texte, fontSize: 14)),
        ],
        if (note != null) ...[
          const SizedBox(height: 6),
          Text('$note %',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: note >= 80
                      ? _cxVert
                      : (note >= 50 ? _cxOrange : _cxRouge),
                  fontSize: 40,
                  fontWeight: FontWeight.w900)),
          Text(
              note >= 95
                  ? 'Accent de champion ! 🏆'
                  : note >= 80
                      ? 'Très bien ! 👏'
                      : 'Tu peux réessayer autant que tu veux 💪',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 13.5)),
          const SizedBox(height: 16),
          _cxBouton(
              _i + 1 >= _textes.length ? 'Voir mon score' : 'Suivant ›',
              _cxOrange,
              _suivant),
        ],
      ],
    );
  }
}

class _CxRond extends StatelessWidget {
  const _CxRond({required this.icone, required this.c, required this.f});
  final IconData icone;
  final Color c;
  final VoidCallback f;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: f,
        child: Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: c.withOpacity(0.45), offset: const Offset(0, 4))
            ],
          ),
          child: Icon(icone, color: Colors.white, size: 34),
        ),
      );
}

// ---------------------------------------------------------------------------
// Course des Renards : premier arrivé à 30.

class _CxCourse extends StatefulWidget {
  const _CxCourse({
    super.key,
    required this.mots,
    required this.niveau,
    required this.langue,
    required this.tts,
    required this.fin,
    this.fantomes = const [],
  });
  final List<Map<String, String>> mots;
  final int niveau;
  final String langue;
  final FlutterTts tts;
  final _CxFin fin;
  final List<_CxFantome> fantomes; // vrais joueurs

  @override
  State<_CxCourse> createState() => _CxCourseState();
}

class _CxCourseState extends State<_CxCourse> {
  static const _arrivee = 30;
  static const _rivaux = [
    ['🐺', 'Loup'],
    ['🐆', 'Panthère'],
    ['🐗', 'Phacochère'],
  ];
  int _moi = 0;
  final List<double> _eux = [0, 0, 0];
  final List<List<int>> _mesEv = []; // [ms, position]
  DateTime _debut = DateTime.now();

  List<String> _rival(int r) => r < widget.fantomes.length
      ? ['🦊', '${widget.fantomes[r].drapeau} ${widget.fantomes[r].pseudo}']
      : _rivaux[r];

  /// Position d'un vrai joueur à l'instant t (rejoue sa partie enregistrée).
  double _posFantome(int r, int ms) {
    final ev = widget.fantomes[r].data['ev'] as List;
    var pos = 0.0;
    var dernierT = 0;
    for (final e in ev) {
      final t = ((e as List)[0] as num).toInt();
      if (t > ms) return pos;
      pos = (e[1] as num).toDouble();
      dernierT = t;
    }
    // sa partie s'est arrêtée avant l'arrivée : il continue à son rythme
    if (pos < _arrivee && dernierT > 0) {
      pos += (ms - dernierT) * (pos / dernierT) * 0.8;
    }
    return pos;
  }
  int _erreurs = 0;
  int _bons = 0;
  int _num = 0;
  bool _depart = false;
  bool _fini = false;
  Timer? _timer;
  late _CxQ _q;

  // cases par seconde des rivaux (le plus rapide finit en ~ X s)
  double _vitesse(int r) {
    final base = 0.20 + widget.niveau * 0.035; // 0.235 → 0.55
    return base * (0.8 + r * 0.12);
  }

  @override
  void initState() {
    super.initState();
    _nouvelle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nouvelle() {
    final l = _cxQuestions(widget.mots, 1,
        [(['qcm', 'inverse', 'vf'])[_num % 3]]);
    _q = l.isNotEmpty ? l.first : _CxQ('vf', '?', ['Vrai', 'Faux'], 0);
    _num++;
  }

  void _partir() {
    setState(() => _depart = true);
    _debut = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (t) {
      if (!mounted || _fini) return;
      final ms = DateTime.now().difference(_debut).inMilliseconds;
      setState(() {
        for (var r = 0; r < 3; r++) {
          if (r < widget.fantomes.length) {
            _eux[r] = _posFantome(r, ms);
          } else {
            _eux[r] += _vitesse(r) / 4 * (0.6 + _cxR.nextDouble() * 0.8);
          }
        }
      });
      if (_eux.any((x) => x >= _arrivee)) _terminer(false);
    });
  }

  void _terminer(bool gagne) {
    if (_fini) return;
    _fini = true;
    _timer?.cancel();
    final et = !gagne ? 0 : (_erreurs <= 2 ? 3 : (_erreurs <= 5 ? 2 : 1));
    widget.fin(et, _bons * 3 + (gagne ? 30 : 0), {'ev': _mesEv});
  }

  void _repondu(bool juste) {
    if (_fini) return;
    setState(() {
      if (juste) {
        _moi++;
        _bons++;
        _mesEv.add([DateTime.now().difference(_debut).inMilliseconds, _moi]);
      } else {
        _erreurs++;
        _moi = math.max(0, _moi - 1);
        _mesEv.add([DateTime.now().difference(_debut).inMilliseconds, _moi]);
      }
      _nouvelle();
    });
    if (_moi >= _arrivee) _terminer(true);
  }

  Widget _piste(String emoji, String nom, double pos, Color c) {
    final p = _cxP();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: LayoutBuilder(builder: (ctx, bc) {
        final largeur = bc.maxWidth - 34;
        final x = (pos.clamp(0, _arrivee) / _arrivee) * largeur;
        return Container(
          height: 38,
          decoration: BoxDecoration(
            color: c.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(children: [
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(
                  child: Text('🏁', style: TextStyle(fontSize: 16))),
            ),
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(nom,
                    style: TextStyle(
                        color: p.gris.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              left: x,
              top: 2,
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: [
        _piste('🦊', 'Toi · $_moi', _moi.toDouble(), _cxOrange),
        for (var r = 0; r < 3; r++)
          _piste(_rival(r)[0], _rival(r)[1], _eux[r],
              r < widget.fantomes.length ? _cxViolet : p.gris),
        const SizedBox(height: 10),
        if (!_depart) ...[
          const SizedBox(height: 10),
          if (widget.fantomes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                  '🌍 Course en ligne : tu cours contre ${widget.fantomes.length} vrai${widget.fantomes.length > 1 ? 's' : ''} joueur${widget.fantomes.length > 1 ? 's' : ''} de ton niveau !',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _cxViolet,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ),
          Text('Réponds vite et juste : chaque bonne réponse = 1 case. Une erreur = 1 case en arrière.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 14.5)),
          const SizedBox(height: 20),
          _cxBouton('3, 2, 1… Partez ! 🏁', _cxOrange, _partir),
        ] else
          _CxQuestionVue(
            key: ValueKey('c$_num'),
            q: _q,
            repondu: _repondu,
            tts: widget.tts,
            langue: widget.langue,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Le Pendu

class _CxPendu extends StatefulWidget {
  const _CxPendu({
    super.key,
    required this.mots,
    required this.niveau,
    required this.langue,
    required this.tts,
    required this.fin,
  });
  final List<Map<String, String>> mots;
  final int niveau;
  final String langue;
  final FlutterTts tts;
  final _CxFin fin;

  @override
  State<_CxPendu> createState() => _CxPenduState();
}

class _CxPenduState extends State<_CxPendu> {
  static const _dessin = ['😀', '😐', '😕', '😟', '😨', '😱', '💀'];
  late final List<Map<String, String>> _liste;
  int _i = 0;
  int _erreurs = 0;
  int _trouves = 0;
  int _erreursTotal = 0;
  final Set<String> _essais = {};
  bool _fini = false;

  int get _max => math.max(4, 7 - widget.niveau ~/ 3); // 7 → 4 erreurs
  int get _nb => 3 + widget.niveau ~/ 4; // 3 → 5 mots

  @override
  void initState() {
    super.initState();
    final lmin = 3 + widget.niveau ~/ 2;
    var l = _cxTirer(widget.mots, _nb, filtre: (m) {
      final t = _cxSans(m['t']!);
      return t.length >= lmin && t.length <= lmin + 5 && !m['t']!.contains(' ');
    });
    if (l.length < _nb) {
      l = _cxTirer(widget.mots, _nb,
          filtre: (m) => _cxSans(m['t']!).length >= 3);
    }
    _liste = l;
  }

  String get _mot => _cxSans(_liste[_i]['t']!);

  bool get _gagne => _mot.split('').every(_essais.contains);

  void _lettre(String l) {
    if (_fini || _essais.contains(l)) return;
    setState(() {
      _essais.add(l);
      if (!_mot.contains(l)) {
        _erreurs++;
        _erreursTotal++;
        HapticFeedback.heavyImpact();
      }
    });
    if (_gagne) {
      _trouves++;
      _cxDire(widget.tts, widget.langue, _liste[_i]['t']!);
      setState(() => _fini = true);
    } else if (_erreurs >= _max) {
      setState(() => _fini = true);
    }
  }

  void _suivant() {
    if (_i + 1 >= _liste.length) {
      final et = _trouves == _liste.length
          ? (_erreursTotal <= _liste.length ? 3 : 2)
          : (_trouves >= _liste.length - 1 && _trouves > 0 ? 1 : 0);
      widget.fin(et, _trouves * 10);
      return;
    }
    setState(() {
      _i++;
      _erreurs = 0;
      _essais.clear();
      _fini = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    if (_liste.isEmpty || widget.langue == 'zh') {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text(
              widget.langue == 'zh'
                  ? 'Le Pendu se joue avec des lettres : choisis l\'anglais, l\'espagnol ou le portugais.'
                  : 'Pas assez de mots pour ce niveau.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 15)),
          const SizedBox(height: 20),
          _cxBouton('Continuer', _cxOrange, () => widget.fin(1, 0)),
        ]),
      );
    }
    final mot = _mot;
    final perdu = _fini && !_gagne;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: [
        Text('Mot ${_i + 1} / ${_liste.length}',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.gris, fontSize: 13)),
        const SizedBox(height: 6),
        Text(_dessin[(_erreurs * (_dessin.length - 1) / _max).round()],
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 64)),
        Text('Erreurs : $_erreurs / $_max',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _erreurs >= _max - 1 ? _cxRouge : p.gris,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.doux,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('Indice : ${_liste[_i]['d']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: p.texte, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 16),
        Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
          for (final l in mot.split(''))
            Container(
              width: 30,
              padding: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: p.texte, width: 2.5))),
              child: Text(
                  _essais.contains(l) || perdu ? l.toUpperCase() : ' ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: perdu && !_essais.contains(l)
                          ? _cxRouge
                          : p.texte,
                      fontSize: 24,
                      fontWeight: FontWeight.w900)),
            ),
        ]),
        const SizedBox(height: 18),
        if (_fini) ...[
          Text(_gagne ? 'Bravo ! 🎉' : 'Le mot était « ${_liste[_i]['t']} »',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _gagne ? _cxVert : _cxRouge,
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _cxBouton(
              _i + 1 >= _liste.length ? 'Voir mon score' : 'Mot suivant ›',
              _cxOrange,
              _suivant),
        ] else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 6,
            children: [
              for (final l in 'abcdefghijklmnopqrstuvwxyz'.split(''))
                GestureDetector(
                  onTap: () => _lettre(l),
                  child: Container(
                    width: 36,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_essais.contains(l)
                          ? p.carte
                          : (mot.contains(l)
                              ? _cxVert.withOpacity(0.25)
                              : p.bord),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: p.bord),
                    ),
                    child: Text(l.toUpperCase(),
                        style: TextStyle(
                            color: _essais.contains(l) ? p.gris : p.texte,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Construis la phrase

class _CxPhrase extends StatefulWidget {
  const _CxPhrase({
    super.key,
    required this.niveau,
    required this.langue,
    required this.tts,
    required this.fin,
  });
  final int niveau;
  final String langue;
  final FlutterTts tts;
  final _CxFin fin;

  @override
  State<_CxPhrase> createState() => _CxPhraseState();
}

class _CxPhraseState extends State<_CxPhrase> {
  late final List<List<String>> _liste;
  int _i = 0;
  int _bons = 0;
  List<String> _melange = [];
  final List<int> _pris = [];
  bool? _juste;

  @override
  void initState() {
    super.initState();
    final ph = [..._cxPhrasesDe(widget.langue)]
      ..sort((a, b) => a[0].length.compareTo(b[0].length));
    // niveaux 1-3 : phrases courtes ; 8-10 : les plus longues
    final debut = ((widget.niveau - 1) * (ph.length - 4) / 9).floor();
    final zone = ph.sublist(debut, math.min(ph.length, debut + 6))
      ..shuffle(_cxR);
    _liste = zone.take(widget.niveau >= 7 ? 5 : 4).toList();
    _preparer();
  }

  List<String> get _bonOrdre => _cxDecouper(_liste[_i][0], widget.langue);

  void _preparer() {
    _melange = [..._bonOrdre]..shuffle(_cxR);
    // niveaux élevés : on ajoute des mots pièges d'une autre phrase
    if (widget.niveau >= 5 && widget.langue != 'zh') {
      final autres = _cxPhrasesDe(widget.langue)
          .where((x) => x[0] != _liste[_i][0])
          .toList()
        ..shuffle(_cxR);
      if (autres.isNotEmpty) {
        final pieges = _cxDecouper(autres.first[0], widget.langue)
            .where((w) => !_bonOrdre.contains(w))
            .take(widget.niveau >= 8 ? 2 : 1);
        _melange.addAll(pieges);
        _melange.shuffle(_cxR);
      }
    }
    _pris.clear();
    _juste = null;
  }

  void _verifier() {
    final rep = _pris.map((k) => _melange[k]).join(' ');
    final ok = rep == _bonOrdre.join(' ');
    setState(() => _juste = ok);
    if (ok) {
      _bons++;
      HapticFeedback.lightImpact();
      _cxDire(widget.tts, widget.langue, _liste[_i][0]);
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _suivant() {
    if (_i + 1 >= _liste.length) {
      widget.fin(_cxEtoiles(_bons, _liste.length), _bons * 10);
      return;
    }
    setState(() {
      _i++;
      _preparer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    final sep = widget.langue == 'zh' ? '' : ' ';
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: [
        Text('Phrase ${_i + 1} / ${_liste.length}',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.gris, fontSize: 13)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.doux,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(_liste[_i][1],
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: p.texte, fontSize: 17, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 14),
        Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: p.carte,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _juste == null
                    ? p.bord
                    : (_juste! ? _cxVert : _cxRouge),
                width: 2),
          ),
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            for (final k in _pris)
              GestureDetector(
                onTap: _juste != null
                    ? null
                    : () => setState(() => _pris.remove(k)),
                child: _etiquette(_melange[k], _cxOrange, Colors.white),
              ),
          ]),
        ),
        if (_juste == false) ...[
          const SizedBox(height: 8),
          Text('Bonne réponse : ${_bonOrdre.join(sep)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _cxVert, fontWeight: FontWeight.w800)),
        ],
        const SizedBox(height: 16),
        Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 8, children: [
          for (var k = 0; k < _melange.length; k++)
            Opacity(
              opacity: _pris.contains(k) ? 0.25 : 1,
              child: GestureDetector(
                onTap: _pris.contains(k) || _juste != null
                    ? null
                    : () => setState(() => _pris.add(k)),
                child: _etiquette(_melange[k], p.carte, p.texte),
              ),
            ),
        ]),
        const SizedBox(height: 22),
        if (_juste == null)
          _cxBouton('Vérifier', _cxViolet,
              _pris.isEmpty ? null : _verifier)
        else
          _cxBouton(
              _i + 1 >= _liste.length ? 'Voir mon score' : 'Phrase suivante ›',
              _cxOrange,
              _suivant),
      ],
    );
  }

  Widget _etiquette(String t, Color fond, Color texte) {
    final p = _cxP();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.bord, width: 1.5),
      ),
      child: Text(t,
          style: TextStyle(
              color: texte, fontSize: 16.5, fontWeight: FontWeight.w800)),
    );
  }
}

// ---------------------------------------------------------------------------
// Défi Famille : 3 jeux à plusieurs sur un téléphone.

class _CxFamille extends StatefulWidget {
  const _CxFamille({
    super.key,
    required this.mots,
    required this.niveau,
    required this.langue,
    required this.tts,
    required this.fin,
  });
  final List<Map<String, String>> mots;
  final int niveau;
  final String langue;
  final FlutterTts tts;
  final _CxFin fin;

  @override
  State<_CxFamille> createState() => _CxFamilleState();
}

class _CxFamilleState extends State<_CxFamille> {
  final List<TextEditingController> _noms = [
    TextEditingController(text: 'Joueur 1'),
    TextEditingController(text: 'Joueur 2'),
  ];
  List<int> _points = [];
  int _etape = 0; // 0 joueurs, 1 passe, 2 mime, 3 prononce, 4 fin
  int _joueur = 0;
  bool _pret = false;

  // Passe le téléphone
  List<_CxQ> _qs = [];
  int _q = 0;

  // Mime
  List<Map<String, String>> _aMimer = [];
  int _mime = 0;
  int _reste = 0;
  Timer? _chrono;

  // Prononce
  Map<String, String>? _motProno;
  int? _note;
  bool _ecoute = false;

  int get _parJoueur => 3 + widget.niveau ~/ 3;

  @override
  void dispose() {
    _chrono?.cancel();
    for (final c in _noms) {
      c.dispose();
    }
    super.dispose();
  }

  String _nom(int i) {
    final t = _noms[i].text.trim();
    return t.isEmpty ? 'Joueur ${i + 1}' : t;
  }

  void _commencer() {
    _points = List.filled(_noms.length, 0);
    _etape = 1;
    _joueur = 0;
    _pret = false;
    _qs = _cxQuestions(widget.mots, _parJoueur, const ['qcm', 'inverse', 'vf']);
    _q = 0;
    setState(() {});
  }

  void _joueurSuivant() {
    _joueur++;
    _pret = false;
    if (_joueur >= _noms.length) {
      _joueur = 0;
      _etape++;
    }
    if (_etape == 1) {
      _qs = _cxQuestions(
          widget.mots, _parJoueur, const ['qcm', 'inverse', 'vf']);
      _q = 0;
    } else if (_etape == 2) {
      _aMimer = _cxTirer(widget.mots, 12);
      _mime = 0;
    } else if (_etape == 3) {
      final l = _cxTirer(widget.mots, 1,
          filtre: (m) => widget.niveau > 5 || !m['t']!.contains(' '));
      _motProno = l.isNotEmpty ? l.first : null;
      _note = null;
    } else if (_etape >= 4) {
      _terminer();
    }
    setState(() {});
  }

  void _terminer() {
    final total = _points.fold<int>(0, (a, b) => a + b);
    final et = total >= _noms.length * 8
        ? 3
        : (total >= _noms.length * 5 ? 2 : (total > 0 ? 1 : 0));
    _etape = 4;
    _etoilesFin = et;
    _scoreFin = total * 2;
  }

  int _etoilesFin = 0;
  int _scoreFin = 0;

  void _demarrerMime() {
    setState(() {
      _pret = true;
      _reste = math.max(30, 70 - widget.niveau * 4);
    });
    _chrono?.cancel();
    _chrono = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _reste--);
      if (_reste <= 0) {
        t.cancel();
        HapticFeedback.heavyImpact();
      }
    });
  }

  Future<void> _prononcer() async {
    final m = _motProno;
    if (m == null || _ecoute) return;
    await widget.tts.stop();
    setState(() {
      _ecoute = true;
      _note = null;
    });
    final e = await _cxEcouter(widget.langue);
    if (!mounted) return;
    setState(() {
      _ecoute = false;
      _note = (e.startsWith('#') || e.trim().isEmpty)
          ? 0
          : _cxNote(m['t']!, e, widget.langue);
    });
  }

  Widget _titre(String emoji, String t, String sous) {
    final p = _cxP();
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 52)),
      Text(t,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: p.texte, fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(sous,
          textAlign: TextAlign.center,
          style: TextStyle(color: p.gris, fontSize: 14)),
      const SizedBox(height: 16),
    ]);
  }

  Widget _scores() {
    final p = _cxP();
    return Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 6, children: [
      for (var i = 0; i < _noms.length; i++)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: i == _joueur && _etape < 4 ? _cxOrange : p.doux,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${_nom(i)} · ${_points.length > i ? _points[i] : 0}',
              style: TextStyle(
                  color: i == _joueur && _etape < 4 ? Colors.white : p.texte,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    // 0 : les joueurs
    if (_etape == 0) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        children: [
          _titre('👨‍👩‍👧', 'Qui joue ?', 'De 2 à 6 joueurs sur ce téléphone'),
          for (var i = 0; i < _noms.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _noms[i],
                    style: TextStyle(color: p.texte, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: p.carte,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: p.bord)),
                    ),
                  ),
                ),
                if (_noms.length > 2)
                  IconButton(
                    onPressed: () => setState(() => _noms.removeAt(i)),
                    icon: Icon(Icons.close_rounded, color: p.gris),
                  ),
              ]),
            ),
          if (_noms.length < 6)
            TextButton.icon(
              onPressed: () => setState(() => _noms.add(
                  TextEditingController(text: 'Joueur ${_noms.length + 1}'))),
              icon: const Icon(Icons.person_add_rounded, color: _cxVert),
              label: const Text('Ajouter un joueur',
                  style: TextStyle(color: _cxVert, fontWeight: FontWeight.w800)),
            ),
          const SizedBox(height: 16),
          _cxBouton('Commencer', _cxVert, _commencer),
        ],
      );
    }
    // 4 : fin
    if (_etape == 4) {
      var meilleur = 0;
      for (var i = 1; i < _points.length; i++) {
        if (_points[i] > _points[meilleur]) meilleur = i;
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
        children: [
          _titre('🏆', '${_nom(meilleur)} gagne !', 'Bravo à toute l\'équipe'),
          for (final i in (List.generate(_points.length, (k) => k)
            ..sort((a, b) => _points[b].compareTo(_points[a]))))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.carte,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.bord),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(_nom(i),
                        style: TextStyle(
                            color: p.texte,
                            fontSize: 16,
                            fontWeight: FontWeight.w800))),
                Text('${_points[i]} pts',
                    style: const TextStyle(
                        color: _cxOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
          const SizedBox(height: 16),
          _cxBouton('Terminer le niveau', _cxVert,
              () => widget.fin(_etoilesFin, _scoreFin)),
        ],
      );
    }
    final infos = [
      ['', '', ''],
      ['📱', 'Passe le téléphone', '$_parJoueur questions chacun'],
      ['🤹', 'Mime le mot', 'Mime sans parler, les autres devinent en anglais'],
      ['🗣️', 'Qui prononce le mieux ?', 'Lis le mot, Léxi te note'],
    ][_etape];
    // Écran « passe le téléphone à… »
    if (!_pret) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        children: [
          _scores(),
          const SizedBox(height: 18),
          _titre(infos[0], infos[1], infos[2]),
          Text('Passe le téléphone à',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 15)),
          Text(_nom(_joueur),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _cxOrange, fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 22),
          _cxBouton(
              'Je suis prêt(e) !',
              _cxVert,
              _etape == 2
                  ? _demarrerMime
                  : () => setState(() => _pret = true)),
        ],
      );
    }
    // 1 : Passe le téléphone
    if (_etape == 1) {
      if (_qs.isEmpty) {
        return Center(child: _cxBouton('Suivant', _cxOrange, _joueurSuivant));
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        children: [
          _scores(),
          const SizedBox(height: 10),
          Text('${_nom(_joueur)} · question ${_q + 1} / ${_qs.length}',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 13)),
          const SizedBox(height: 8),
          _CxQuestionVue(
            key: ValueKey('f$_joueur-$_q'),
            q: _qs[_q],
            tts: widget.tts,
            langue: widget.langue,
            secondes: math.max(6, 14 - widget.niveau),
            repondu: (j) {
              setState(() {
                if (j) _points[_joueur] += 2;
                _q++;
              });
              if (_q >= _qs.length) _joueurSuivant();
            },
          ),
        ],
      );
    }
    // 2 : Mime
    if (_etape == 2) {
      final m = _mime < _aMimer.length ? _aMimer[_mime] : null;
      final fini = _reste <= 0 || m == null;
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        children: [
          _scores(),
          const SizedBox(height: 12),
          Text('⏱️ $_reste s',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _reste <= 10 ? _cxRouge : p.texte,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: p.carte,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _cxVert, width: 2),
            ),
            child: Column(children: [
              Text(fini ? 'Temps écoulé !' : 'Mime ce mot :',
                  style: TextStyle(color: p.gris, fontSize: 14)),
              const SizedBox(height: 6),
              if (!fini) ...[
                Text(m['t']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: p.texte,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                Text(m['d']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.gris, fontSize: 16)),
              ],
            ]),
          ),
          const SizedBox(height: 18),
          if (!fini)
            Row(children: [
              Expanded(
                  child: _cxBouton('Passer', p.doux,
                      () => setState(() => _mime++),
                      texte: p.texte)),
              const SizedBox(width: 10),
              Expanded(
                  child: _cxBouton('Trouvé ! ✅', _cxVert, () {
                HapticFeedback.lightImpact();
                setState(() {
                  _points[_joueur] += 2;
                  _mime++;
                });
              })),
            ])
          else
            _cxBouton('Joueur suivant ›', _cxOrange, () {
              _chrono?.cancel();
              _joueurSuivant();
            }),
        ],
      );
    }
    // 3 : Qui prononce le mieux
    final m = _motProno;
    final note = _note;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: [
        _scores(),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: p.carte,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _cxOrange.withOpacity(0.5), width: 1.5),
          ),
          child: Column(children: [
            Text(m?['t'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: p.texte, fontSize: 30, fontWeight: FontWeight.w900)),
            Text(m?['d'] ?? '',
                style: TextStyle(color: p.gris, fontSize: 15)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _CxRond(
                  icone: Icons.volume_up_rounded,
                  c: _cxOrange,
                  f: () => _cxDire(widget.tts, widget.langue, m?['t'] ?? '')),
              const SizedBox(width: 24),
              _CxRond(
                  icone: _ecoute ? Icons.hearing_rounded : Icons.mic_rounded,
                  c: _cxViolet,
                  f: _prononcer),
            ]),
          ]),
        ),
        if (note != null) ...[
          const SizedBox(height: 10),
          Text('$note %',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: note >= 80 ? _cxVert : (note >= 50 ? _cxOrange : _cxRouge),
                  fontSize: 38,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _cxBouton('Valider ma note', _cxOrange, () {
            _points[_joueur] += (note / 10).round();
            _joueurSuivant();
          }),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Duel du Silence : défier un ami, il accepte, puis compte à rebours.
// Les duels sont dans la collection « duels » avec type = 'silence'.

class _CxDuelSilence extends StatefulWidget {
  const _CxDuelSilence({required this.langue, required this.pseudo});
  final String langue;
  final String pseudo;

  @override
  State<_CxDuelSilence> createState() => _CxDuelSilenceState();
}

class _CxDuelSilenceState extends State<_CxDuelSilence> {
  final _db = FirebaseFirestore.instance;
  List<Map<String, String>> _amis = []; // uid, nom, avatar
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _duels = [];
  bool _charge = false;
  Timer? _tic;

  String get _uid => currentUserUid;

  @override
  void initState() {
    super.initState();
    _charger();
    _tic = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tic?.cancel();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final a = await _db
          .collection('amities')
          .where('uids', arrayContains: _uid)
          .limit(100)
          .get();
      final ids = <String>{};
      for (final d in a.docs) {
        for (final u in (d.data()['uids'] as List? ?? [])) {
          if (u != _uid) ids.add(u.toString());
        }
      }
      final l = <Map<String, String>>[];
      for (final id in ids.take(40)) {
        var nom = 'Ami';
        var av = '🦊';
        try {
          final j = await _db.collection('joueurs').doc(id).get();
          if (j.exists) {
            nom = (j.data()?['pseudo'] ?? nom).toString();
            av = (j.data()?['avatar'] ?? av).toString();
          } else {
            final q = await _db
                .collection('joueurs')
                .where('uid', isEqualTo: id)
                .limit(1)
                .get();
            if (q.docs.isNotEmpty) {
              nom = (q.docs.first.data()['pseudo'] ?? nom).toString();
              av = (q.docs.first.data()['avatar'] ?? av).toString();
            }
          }
        } catch (_) {}
        l.add({'uid': id, 'nom': nom, 'avatar': av});
      }
      _amis = l;
      await _chargerDuels();
    } catch (_) {}
    if (mounted) setState(() => _charge = true);
  }

  Future<void> _chargerDuels() async {
    final a = await _db
        .collection('duels')
        .where('membres', arrayContains: _uid)
        .limit(40)
        .get();
    _duels = a.docs
        .where((d) =>
            d.data()['type'] == 'silence' &&
            (d.data()['statut'] ?? '') != 'annule')
        .toList()
      ..sort((x, y) => _ms(y.data()['cree']).compareTo(_ms(x.data()['cree'])));
  }

  int _ms(dynamic v) {
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    if (v is num) return v.toInt();
    return 0;
  }

  Future<void> _defier() async {
    final p = _cxP();
    if (_amis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Ajoute d\'abord un ami avec son code (Profil → Trouver des amis) 🦊')));
      return;
    }
    String? ami;
    var duree = 30;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.carte,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => StatefulBuilder(
        builder: (c, maj) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Qui veux-tu défier ?',
                style: TextStyle(
                    color: p.texte, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView(shrinkWrap: true, children: [
                for (final a in _amis)
                  ListTile(
                    onTap: () => maj(() => ami = a['uid']),
                    leading:
                        Text(a['avatar']!, style: const TextStyle(fontSize: 28)),
                    title: Text(a['nom']!,
                        style: TextStyle(
                            color: p.texte, fontWeight: FontWeight.w700)),
                    trailing: Icon(
                        ami == a['uid']
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: ami == a['uid'] ? _cxOrange : p.gris),
                  ),
              ]),
            ),
            const SizedBox(height: 10),
            Text('Pendant combien de temps ?',
                style: TextStyle(color: p.gris, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              for (final d in [30, 60, 120])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => maj(() => duree = d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: duree == d ? _cxOrange : p.doux,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(d == 30 ? '30 min' : '${d ~/ 60} h',
                            style: TextStyle(
                                color: duree == d ? Colors.white : p.texte,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 18),
            _cxBouton('Envoyer le défi ⏳', _cxOrange,
                () => Navigator.of(c).pop(true)),
          ]),
        ),
      ),
    );
    if (ok != true || ami == null) return;
    final cible = _amis.firstWhere((a) => a['uid'] == ami);
    try {
      await _db.collection('duels').add({
        'type': 'silence',
        'de': _uid,
        'deNom': widget.pseudo,
        'pour': ami,
        'pourNom': cible['nom'],
        'membres': [_uid, ami],
        'duree': duree,
        'statut': 'attente',
        'cree': DateTime.now().millisecondsSinceEpoch,
      });
      await _chargerDuels();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Défi envoyé à ${cible['nom']} ! Le duel commence dès qu\'il appuie sur OK.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Oups, vérifie ta connexion et réessaie.')));
      }
    }
  }

  Future<void> _maj(DocumentReference r, Map<String, dynamic> m) async {
    try {
      await r.update(m);
      await _chargerDuels();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Widget _carteDuel(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final p = _cxP();
    final d = doc.data();
    final moiDe = d['de'] == _uid;
    final autre = (moiDe ? d['pourNom'] : d['deNom'] ?? 'Ami').toString();
    final duree = (d['duree'] as num?)?.toInt() ?? 30;
    final statut = (d['statut'] ?? 'attente').toString();
    final debut = _ms(d['debut']);
    final finMs = debut + duree * 60000;
    final maintenant = DateTime.now().millisecondsSinceEpoch;
    Widget action;
    String texte;
    if (statut == 'attente') {
      if (moiDe) {
        texte = 'En attente de $autre…';
        action = TextButton(
            onPressed: () => _maj(doc.reference, {'statut': 'annule'}),
            child: Text('Annuler', style: TextStyle(color: p.gris)));
      } else {
        texte = '$autre te défie : $duree min sans téléphone !';
        action = ElevatedButton(
          onPressed: () => _maj(doc.reference, {
            'statut': 'encours',
            'debut': DateTime.now().millisecondsSinceEpoch,
          }),
          style: ElevatedButton.styleFrom(
              backgroundColor: _cxVert,
              foregroundColor: Colors.white,
              elevation: 0),
          child: const Text('OK',
              style: TextStyle(fontWeight: FontWeight.w900)),
        );
      }
    } else if (statut == 'encours' && maintenant < finMs) {
      final r = ((finMs - maintenant) / 60000).ceil();
      texte = 'Duel contre $autre : encore $r min 🤫\nPose ton téléphone !';
      action = const Text('⏳', style: TextStyle(fontSize: 26));
    } else {
      final monScore = d[moiDe ? 'scoreDe' : 'scorePour'];
      final sonScore = d[moiDe ? 'scorePour' : 'scoreDe'];
      if (monScore == null) {
        texte = 'Silence terminé contre $autre ! Joue le quiz bonus ci-dessous '
            'puis appuie sur « Envoyer mon score ».';
        action = ElevatedButton(
          onPressed: () async {
            final s = await _meilleurScoreDuJour();
            _maj(doc.reference,
                {moiDe ? 'scoreDe' : 'scorePour': s, 'statut': 'fini'});
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: _cxOrange,
              foregroundColor: Colors.white,
              elevation: 0),
          child: const Text('Envoyer\nmon score',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        );
      } else if (sonScore == null) {
        texte = 'Ton score : $monScore. On attend $autre…';
        action = const Text('⌛', style: TextStyle(fontSize: 24));
      } else {
        final m = (monScore as num).toInt();
        final s = (sonScore as num).toInt();
        texte = m > s
            ? 'Tu as gagné contre $autre ! $m – $s 🏆'
            : (m < s
                ? '$autre gagne $s – $m. Revanche ?'
                : 'Égalité avec $autre : $m – $s');
        action = Text(m >= s ? '🏆' : '🤝',
            style: const TextStyle(fontSize: 26));
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.carte,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.bord, width: 1.5),
      ),
      child: Row(children: [
        Expanded(
            child: Text(texte,
                style: TextStyle(color: p.texte, fontSize: 14, height: 1.3))),
        const SizedBox(width: 8),
        action,
      ]),
    );
  }

  /// Le score envoyé = meilleur score du quiz bonus fait aujourd'hui.
  Future<int> _meilleurScoreDuJour() async {
    try {
      final pr = await SharedPreferences.getInstance();
      final n = DateTime.now();
      return pr.getInt('lexi_silence_${n.year}_${n.month}_${n.day}') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _cxP();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _cxBouton('⏳ Défier un ami', const Color(0xFF64748B), _defier),
      const SizedBox(height: 12),
      if (!_charge)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
              child: CircularProgressIndicator(color: _cxOrange)),
        )
      else
        for (final d in _duels.take(6)) _carteDuel(d),
      if (_charge && _duels.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Aucun duel en cours. Lance le premier !',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.gris, fontSize: 13.5)),
        ),
      const SizedBox(height: 4),
      Text('QUIZ BONUS',
          style: TextStyle(
              color: p.gris,
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
    ]);
  }
}
