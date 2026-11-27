"""Leçons du niveau 1 (Débutant, A1) du Tuteur Léxi — anglais.
Lance : python3 fabriquer_n1.py  → écrit n1/l01.json … n1/l10.json

Types d'étapes :
  explication : texte du prof (fr + en) + exemples
  vocabulaire : liste de mots (en, fr, pron = prononciation approchée pour francophones)
  dialogue    : lignes (qui = prof|eleve|autre, en, fr)
  qcm         : question, choix, bonne (index), explication
  ordre       : remettre les mots dans l'ordre (en), aide en français
  traduire    : traduire du français vers l'anglais (reponses acceptées)
  repeter     : répéter une phrase au micro
  ecoute      : écouter la phrase, choisir le sens
"""
import json, os

ICI = os.path.dirname(os.path.abspath(__file__))

def E(fr, en='', ex=None):
    d = {'type': 'explication', 'fr': fr, 'en': en}
    if ex: d['exemples'] = [{'en': a, 'fr': b} for a, b in ex]
    return d

def V(*mots):
    return {'type': 'vocabulaire', 'mots': [{'en': a, 'fr': b, 'pron': c} for a, b, c in mots]}

def D(*lignes):
    return {'type': 'dialogue', 'lignes': [{'qui': q, 'en': a, 'fr': b} for q, a, b in lignes]}

def Q(question, choix, bonne, explication):
    return {'type': 'qcm', 'question': question, 'choix': choix, 'bonne': bonne, 'explication': explication}

def O(en, fr):
    return {'type': 'ordre', 'en': en, 'fr': fr}

def T(fr, *reponses):
    return {'type': 'traduire', 'fr': fr, 'reponses': list(reponses)}

def R(en, fr):
    return {'type': 'repeter', 'en': en, 'fr': fr}

def L(en, choix, bonne):
    return {'type': 'ecoute', 'en': en, 'choix': choix, 'bonne': bonne}

LECONS = [
  # 1 -------------------------------------------------------------------
  dict(titre='Hello! Se présenter', objectifs=['Dire bonjour et au revoir', 'Dire son prénom et son âge', 'Demander « Comment vas-tu ? »'],
    etapes=[
      E('Bienvenue dans ton premier cours ! Aujourd\'hui, on apprend à se présenter. En anglais, pour dire bonjour, on dit « Hello ». Entre amis, on dit aussi « Hi ».',
        'Hello! Hi!', [('Hello!', 'Bonjour !'), ('Hi!', 'Salut !'), ('Goodbye! / Bye!', 'Au revoir ! / Salut !')]),
      V(('hello', 'bonjour', 'hè-lo'), ('hi', 'salut', 'haï'), ('goodbye', 'au revoir', 'goud-baï'), ('good morning', 'bonjour (le matin)', 'goud mor-ning'),
        ('good evening', 'bonsoir', 'goud iv-ning'), ('my name', 'mon nom', 'maï nèïm'), ('years old', 'ans (âge)', 'yirz old')),
      E('Pour dire ton nom : « My name is … » ou plus court « I\'m … ». « I\'m » veut dire « je suis ». Attention : en anglais, « je » s\'écrit toujours avec une majuscule : I.',
        'My name is Kenza. I\'m Kenza.', [('My name is Kevin.', 'Je m\'appelle Kevin.'), ('I\'m Kevin.', 'Je suis Kevin.')]),
      E('Pour l\'âge, on utilise aussi « I am », jamais « I have » ! En français on « a » 20 ans, en anglais on « est » 20 ans.',
        'I\'m twenty years old.', [('I\'m 20.', 'J\'ai 20 ans.'), ('I\'m 20 years old.', 'J\'ai 20 ans.')]),
      D(('prof', 'Hello! My name is Kenza. What\'s your name?', 'Bonjour ! Je m\'appelle Kenza. Comment tu t\'appelles ?'),
        ('eleve', 'Hi! I\'m Awa.', 'Salut ! Je suis Awa.'),
        ('prof', 'Nice to meet you, Awa! How are you?', 'Enchantée, Awa ! Comment vas-tu ?'),
        ('eleve', 'I\'m fine, thank you. And you?', 'Je vais bien, merci. Et toi ?'),
        ('prof', 'Very well, thanks!', 'Très bien, merci !')),
      Q('Comment dit-on « J\'ai 18 ans » ?', ['I have 18 years.', 'I\'m 18 years old.', 'I am 18 years.'], 1,
        'On utilise « I am » (je suis) + l\'âge + « years old ». « I have 18 years » est une faute très fréquente.'),
      Q('Ton ami te dit « How are you? ». Que réponds-tu ?', ['I\'m fine, thank you.', 'My name is Paul.', 'Goodbye!'], 0, '« How are you? » = « Comment vas-tu ? ».'),
      O('My name is Kevin', 'Je m\'appelle Kevin'),
      T('Bonjour, je suis Malik.', 'Hello, I\'m Malik.', 'Hello, I am Malik.', 'Hi, I\'m Malik.', 'Hi, I am Malik.', 'Hello, my name is Malik.'),
      L('Nice to meet you!', ['Enchanté !', 'Au revoir !', 'Merci !'], 0),
      R('Hello! My name is … and I\'m … years old.', 'Bonjour ! Je m\'appelle … et j\'ai … ans.'),
    ],
    resume='Hello / Hi = bonjour, salut. My name is … / I\'m … = je m\'appelle / je suis. I\'m 20 (years old) = j\'ai 20 ans. How are you? → I\'m fine, thank you.',
    devoir='Ce soir, présente-toi à voix haute en anglais : ton prénom, ton âge, et « Nice to meet you! ».'),
  # 2 -------------------------------------------------------------------
  dict(titre='Where are you from?', objectifs=['Dire d\'où l\'on vient', 'Le verbe « be » (être) au présent', 'Poser des questions simples'],
    etapes=[
      E('Le verbe le plus important en anglais, c\'est « to be » : être. Il change avec chaque personne.', 'I am, you are, he is, she is.',
        [('I am (I\'m)', 'je suis'), ('you are (you\'re)', 'tu es / vous êtes'), ('he is (he\'s)', 'il est'), ('she is (she\'s)', 'elle est'),
         ('we are (we\'re)', 'nous sommes'), ('they are (they\'re)', 'ils / elles sont')]),
      E('Pour dire d\'où tu viens : « I\'m from … ». Pour la nationalité : « I\'m Ivorian ». Les nationalités prennent toujours une majuscule en anglais.',
        'I\'m from Abidjan. I\'m Ivorian.', [('I\'m from Côte d\'Ivoire.', 'Je viens de Côte d\'Ivoire.'), ('She\'s Senegalese.', 'Elle est sénégalaise.'), ('He\'s French.', 'Il est français.')]),
      V(('Ivorian', 'ivoirien(ne)', 'aï-vo-rian'), ('Senegalese', 'sénégalais(e)', 'sé-né-ga-liz'), ('Ghanaian', 'ghanéen(ne)', 'ga-né-yan'),
        ('Nigerian', 'nigérian(e)', 'naï-dji-rian'), ('French', 'français(e)', 'frènch'), ('American', 'américain(e)', 'a-mé-ri-kan'), ('country', 'pays', 'kan-tri'), ('city', 'ville', 'si-ti')),
      E('Pour poser une question avec « be », on inverse : « You are » devient « Are you…? ». Et « Where » veut dire « Où ».', 'Where are you from? Are you Ivorian?',
        [('Where are you from?', 'D\'où viens-tu ?'), ('Is she from Ghana?', 'Est-ce qu\'elle vient du Ghana ?'), ('Yes, she is. / No, she isn\'t.', 'Oui. / Non.')]),
      D(('prof', 'Where are you from, Awa?', 'D\'où viens-tu, Awa ?'), ('eleve', 'I\'m from Bouaké. I\'m Ivorian.', 'Je viens de Bouaké. Je suis ivoirienne.'),
        ('prof', 'Is your friend Ivorian too?', 'Ton amie est ivoirienne aussi ?'), ('eleve', 'No, she isn\'t. She\'s from Dakar.', 'Non. Elle vient de Dakar.')),
      Q('Complète : « They ___ from Ghana. »', ['is', 'am', 'are'], 2, '« They » (ils) va avec « are ».'),
      Q('Comment dit-on « Elle est ivoirienne » ?', ['She is ivorian.', 'She is Ivorian.', 'She are Ivorian.'], 1, 'She + is, et une majuscule à Ivorian.'),
      O('Where are you from', 'D\'où viens-tu'),
      T('Je viens d\'Abidjan.', 'I\'m from Abidjan.', 'I am from Abidjan.'),
      L('He isn\'t French.', ['Il n\'est pas français.', 'Il est français.', 'Elle n\'est pas française.'], 0),
      R('I\'m from Côte d\'Ivoire. I\'m Ivorian.', 'Je viens de Côte d\'Ivoire. Je suis ivoirien(ne).'),
    ],
    resume='I am, you are, he/she is, we are, they are. Question : Are you…? Where are you from? → I\'m from… Nationalités avec majuscule.',
    devoir='Écris 3 phrases sur 3 personnes que tu connais : d\'où elles viennent et leur nationalité.'),
  # 3 -------------------------------------------------------------------
  dict(titre='My family', objectifs=['Présenter sa famille', 'Les possessifs my, your, his, her', 'have got (avoir)'],
    etapes=[
      V(('mother / mum', 'mère / maman', 'ma-zeur / meum'), ('father / dad', 'père / papa', 'fa-zeur / dad'), ('sister', 'sœur', 'sis-teur'),
        ('brother', 'frère', 'bra-zeur'), ('son', 'fils', 'sann'), ('daughter', 'fille (enfant)', 'do-teur'), ('grandmother', 'grand-mère', 'grann-ma-zeur'),
        ('uncle', 'oncle', 'eun-keul'), ('aunt', 'tante', 'ant'), ('cousin', 'cousin(e)', 'ka-zinn')),
      E('Les possessifs : my (mon/ma/mes), your (ton/ta/tes), his (son/sa — pour un homme), her (son/sa — pour une femme). Différence avec le français : on choisit his ou her selon le PROPRIÉTAIRE, pas selon l\'objet.',
        'his mother = la mère de lui ; her mother = la mère d\'elle', [('Kevin and his sister', 'Kevin et sa sœur'), ('Kenza and her brother', 'Kenza et son frère')]),
      E('Pour dire « j\'ai » (une sœur, deux frères), on utilise « I have got » ou simplement « I have ». À la 3e personne : « she has got ».',
        'I\'ve got two brothers.', [('I\'ve got one sister.', 'J\'ai une sœur.'), ('She has got three children.', 'Elle a trois enfants.'), ('Have you got a brother?', 'As-tu un frère ?')]),
      D(('prof', 'Have you got brothers and sisters?', 'As-tu des frères et sœurs ?'), ('eleve', 'Yes, I\'ve got one brother and two sisters.', 'Oui, j\'ai un frère et deux sœurs.'),
        ('prof', 'What\'s your brother\'s name?', 'Comment s\'appelle ton frère ?'), ('eleve', 'His name is Yao.', 'Il s\'appelle Yao.')),
      Q('Kenza parle de son père. Elle dit : « ___ father is a teacher. »', ['His', 'Her', 'My'], 2, 'Kenza parle de SON propre père : « My father ».'),
      Q('Tu parles du frère d\'Awa : « Awa and ___ brother ».', ['his', 'her', 'your'], 1, 'Awa est une fille → her.'),
      O('I have got two sisters', 'J\'ai deux sœurs'),
      T('Mon oncle s\'appelle Koffi.', 'My uncle\'s name is Koffi.', 'My uncle is called Koffi.'),
      L('Her daughter is ten.', ['Sa fille a dix ans.', 'Son fils a dix ans.', 'Sa sœur a dix ans.'], 0),
      R('This is my family. I\'ve got one brother and two sisters.', 'Voici ma famille. J\'ai un frère et deux sœurs.'),
    ],
    resume='my / your / his (à lui) / her (à elle). I\'ve got = j\'ai ; she has got = elle a. Vocabulaire : mother, father, sister, brother…',
    devoir='Montre une photo de ta famille à quelqu\'un et présente-la en anglais.'),
  # 4 -------------------------------------------------------------------
  dict(titre='Numbers, time and days', objectifs=['Compter jusqu\'à 100', 'Dire l\'heure', 'Les jours et les mois'],
    etapes=[
      V(('one, two, three', '1, 2, 3', 'wann, tou, sri'), ('ten, eleven, twelve', '10, 11, 12', 'tèn, i-lè-veun, twèlv'), ('thirteen', '13', 'seur-tine'),
        ('thirty', '30', 'seur-ti'), ('fifteen / fifty', '15 / 50', 'fif-tine / fif-ti'), ('a hundred', '100', 'e hann-dred')),
      E('Piège classique : -teen (13 à 19) et -ty (20, 30… 90). Dans « thirteen » on appuie sur la FIN (thir-TEEN). Dans « thirty » on appuie sur le DÉBUT (THIR-ty).',
        'thirTEEN (13) / THIRty (30)', [('fourteen', '14'), ('forty', '40')]),
      E('Pour l\'heure : « What time is it? ». On répond « It\'s … o\'clock » pour les heures pile. « half past » = et demie, « quarter past » = et quart, « quarter to » = moins le quart.',
        'It\'s seven o\'clock.', [('It\'s 7 o\'clock.', 'Il est 7 h.'), ('It\'s half past seven.', 'Il est 7 h 30.'), ('It\'s quarter to eight.', 'Il est 8 h moins le quart.')]),
      V(('Monday', 'lundi', 'mann-dé'), ('Tuesday', 'mardi', 'tiouz-dé'), ('Wednesday', 'mercredi', 'wènz-dé'), ('Thursday', 'jeudi', 'seurz-dé'),
        ('Friday', 'vendredi', 'fraï-dé'), ('Saturday', 'samedi', 'sa-teur-dé'), ('Sunday', 'dimanche', 'sann-dé')),
      E('Les jours et les mois prennent une majuscule. Et on dit « on Monday » (le lundi), « in January » (en janvier).', '', [('on Friday', 'vendredi'), ('in December', 'en décembre')]),
      Q('Comment dit-on 15 ?', ['fifty', 'fifteen', 'five-ten'], 1, 'fifteen = 15 ; fifty = 50.'),
      Q('« It\'s half past six » =', ['6 h 30', '5 h 30', '6 h 15'], 0, 'half past six = 6 heures et demie.'),
      O('What time is it', 'Quelle heure est-il'),
      T('Il est 9 heures.', 'It\'s nine o\'clock.', 'It is nine o\'clock.', 'It\'s 9 o\'clock.'),
      L('See you on Wednesday!', ['À mercredi !', 'À mardi !', 'À jeudi !'], 0),
      R('Today is Monday. It\'s half past eight.', 'Aujourd\'hui c\'est lundi. Il est 8 h 30.'),
    ],
    resume='-teen (13-19) accent à la fin, -ty (20-90) accent au début. What time is it? It\'s … o\'clock / half past / quarter past / quarter to. on Monday, in January.',
    devoir='Dis l\'heure en anglais 3 fois aujourd\'hui, chaque fois que tu regardes ton téléphone.'),
  # 5 -------------------------------------------------------------------
  dict(titre='My day', objectifs=['Raconter sa journée', 'Le présent simple (I, you, we, they)', 'Les mots de fréquence'],
    etapes=[
      E('Le présent simple sert pour les habitudes : ce que tu fais tous les jours. Avec I, you, we, they, le verbe ne change pas.', 'I wake up at six.',
        [('I wake up at 6.', 'Je me réveille à 6 h.'), ('We eat at noon.', 'Nous mangeons à midi.'), ('They go to school.', 'Ils vont à l\'école.')]),
      V(('wake up', 'se réveiller', 'wèïk eup'), ('get up', 'se lever', 'guèt eup'), ('have a shower', 'prendre une douche', 'hav e chaou-eur'),
        ('have breakfast', 'prendre le petit-déjeuner', 'hav brèk-feust'), ('go to work', 'aller au travail', 'go tou weurk'), ('come back home', 'rentrer à la maison', 'kam bak hom'),
        ('cook', 'cuisiner', 'kouk'), ('go to bed', 'aller se coucher', 'go tou bèd')),
      E('Pour dire « souvent, toujours, jamais », on met le mot AVANT le verbe : always (toujours), usually (d\'habitude), often (souvent), sometimes (parfois), never (jamais).',
        'I always drink tea.', [('I always get up early.', 'Je me lève toujours tôt.'), ('We never eat late.', 'Nous ne mangeons jamais tard.')]),
      E('La négation : « don\'t » + verbe. La question : « Do you … ? ».', 'I don\'t work on Sunday. Do you work on Sunday?',
        [('I don\'t like coffee.', 'Je n\'aime pas le café.'), ('Do you cook?', 'Est-ce que tu cuisines ?'), ('Yes, I do. / No, I don\'t.', 'Oui. / Non.')]),
      D(('prof', 'What time do you get up?', 'À quelle heure tu te lèves ?'), ('eleve', 'I usually get up at half past five.', 'Je me lève d\'habitude à 5 h 30.'),
        ('prof', 'Wow, early! Do you have breakfast?', 'Waouh, tôt ! Tu prends un petit-déjeuner ?'), ('eleve', 'Yes, I always have bread and tea.', 'Oui, je prends toujours du pain et du thé.')),
      Q('Où mettre « often » ? « I ___ go ___ to the market ___. »', ['I often go to the market.', 'I go often to the market.', 'I go to the market often always.'], 0, 'Le mot de fréquence se place avant le verbe.'),
      Q('Négation de « I work on Sunday »', ['I not work on Sunday.', 'I don\'t work on Sunday.', 'I doesn\'t work on Sunday.'], 1, 'don\'t + verbe.'),
      O('I never go to bed late', 'Je ne me couche jamais tard'),
      T('Nous prenons le petit-déjeuner à 7 h.', 'We have breakfast at 7.', 'We have breakfast at seven.', 'We have breakfast at 7 o\'clock.', 'We have breakfast at seven o\'clock.'),
      L('Do you cook every day?', ['Tu cuisines tous les jours ?', 'Tu manges tous les jours ?', 'Tu travailles tous les jours ?'], 0),
      R('I usually wake up at six and I go to work at seven.', 'Je me réveille d\'habitude à 6 h et je vais au travail à 7 h.'),
    ],
    resume='Présent simple = habitudes. I/you/we/they + verbe. Négation : don\'t. Question : Do you…? always, usually, often, sometimes, never AVANT le verbe.',
    devoir='Raconte ta journée de demain en 5 phrases avec always, usually ou never.'),
  # 6 -------------------------------------------------------------------
  dict(titre='He works, she studies', objectifs=['Parler du travail des autres', 'Le -s de la 3e personne', 'does / doesn\'t'],
    etapes=[
      E('LA règle que tout le monde oublie : avec he, she, it, on ajoute un -s au verbe au présent simple.', 'He works. She lives in Yamoussoukro.',
        [('I work → he works', 'je travaille → il travaille'), ('I live → she lives', 'je vis → elle vit'), ('I study → she studies', 'j\'étudie → elle étudie'), ('I go → he goes', 'je vais → il va')]),
      E('Questions et négations avec he/she : on utilise « does » et « doesn\'t », et le -s disparaît du verbe !', 'Does she work? She doesn\'t work.',
        [('Does he speak English?', 'Est-ce qu\'il parle anglais ?'), ('She doesn\'t like rice.', 'Elle n\'aime pas le riz.')]),
      V(('teacher', 'enseignant(e)', 'ti-tcheur'), ('nurse', 'infirmier / infirmière', 'neurs'), ('doctor', 'médecin', 'dok-teur'), ('driver', 'chauffeur', 'draï-veur'),
        ('seller', 'vendeur / vendeuse', 'sè-leur'), ('student', 'étudiant(e)', 'stiou-deunt'), ('engineer', 'ingénieur', 'èn-dji-nir'), ('tailor', 'couturier / tailleur', 'tèï-leur')),
      E('Pour le métier, on met « a » ou « an » devant : « She\'s a nurse », « He\'s an engineer » (an devant un son de voyelle).', '',
        [('She\'s a doctor.', 'Elle est médecin.'), ('He\'s an engineer.', 'Il est ingénieur.')]),
      D(('prof', 'What does your mother do?', 'Que fait ta mère ?'), ('eleve', 'She\'s a nurse. She works in a hospital.', 'Elle est infirmière. Elle travaille dans un hôpital.'),
        ('prof', 'Does she work at night?', 'Elle travaille la nuit ?'), ('eleve', 'Yes, she sometimes works at night.', 'Oui, elle travaille parfois la nuit.')),
      Q('Choisis la bonne phrase.', ['She work in a bank.', 'She works in a bank.', 'She working in a bank.'], 1, 'she → works (avec -s).'),
      Q('« Does he ___ English? »', ['speaks', 'speak', 'speaking'], 1, 'Après does, pas de -s : does he speak.'),
      O('My brother is a taxi driver', 'Mon frère est chauffeur de taxi'),
      T('Elle étudie à l\'université.', 'She studies at university.', 'She studies at the university.'),
      L('He doesn\'t live in Abidjan.', ['Il ne vit pas à Abidjan.', 'Il vit à Abidjan.', 'Elle ne vit pas à Abidjan.'], 0),
      R('My father is a teacher. He works in a big school.', 'Mon père est enseignant. Il travaille dans une grande école.'),
    ],
    resume='he/she/it + verbe-s (works, lives, studies, goes). Does he…? / He doesn\'t… (sans -s). a nurse, an engineer.',
    devoir='Écris le métier de 4 personnes de ton entourage avec une phrase chacune (He works… / She studies…).'),
  # 7 -------------------------------------------------------------------
  dict(titre='At the market', objectifs=['Acheter au marché', 'there is / there are', 'Demander un prix'],
    etapes=[
      V(('rice', 'riz', 'raïss'), ('fish', 'poisson', 'fich'), ('tomatoes', 'tomates', 'to-ma-toz'), ('onions', 'oignons', 'eun-yeunz'),
        ('plantain', 'banane plantain', 'plann-tinn'), ('bread', 'pain', 'brèd'), ('oil', 'huile', 'oïl'), ('cheap / expensive', 'pas cher / cher', 'tchip / iks-pèn-siv')),
      E('« There is » = il y a (pour une chose), « there are » = il y a (pour plusieurs).', 'There is a big market. There are many sellers.',
        [('There is some rice.', 'Il y a du riz.'), ('There are three fish.', 'Il y a trois poissons.'), ('Is there any bread?', 'Est-ce qu\'il y a du pain ?')]),
      E('« some » dans les phrases affirmatives, « any » dans les questions et les négations.', '',
        [('I want some tomatoes.', 'Je veux des tomates.'), ('There aren\'t any onions.', 'Il n\'y a pas d\'oignons.')]),
      E('Pour le prix : « How much is it? » (une chose) ou « How much are they? » (plusieurs). Pour demander poliment : « Can I have …, please? »', '',
        [('How much is the fish?', 'Combien coûte le poisson ?'), ('It\'s two thousand francs.', 'C\'est 2 000 francs.'), ('Can I have one kilo, please?', 'Je peux avoir un kilo, s\'il vous plaît ?')]),
      D(('autre', 'Good morning! Can I help you?', 'Bonjour ! Je peux vous aider ?'), ('eleve', 'Yes, please. How much are the tomatoes?', 'Oui, s\'il vous plaît. Combien coûtent les tomates ?'),
        ('autre', 'Five hundred francs a kilo.', '500 francs le kilo.'), ('eleve', 'That\'s expensive! Four hundred?', 'C\'est cher ! 400 ?'),
        ('autre', 'OK, four hundred for you.', 'D\'accord, 400 pour toi.'), ('eleve', 'Great, thank you!', 'Super, merci !')),
      Q('« ___ are many people at the market. »', ['There is', 'There are', 'It is'], 1, 'many people = plusieurs → There are.'),
      Q('« Is there ___ oil? »', ['some', 'any', 'a'], 1, 'Dans une question : any.'),
      O('How much is the bread', 'Combien coûte le pain'),
      T('Je peux avoir du riz, s\'il vous plaît ?', 'Can I have some rice, please?', 'Can I have rice, please?'),
      L('It\'s too expensive!', ['C\'est trop cher !', 'C\'est pas cher !', 'C\'est trop loin !'], 0),
      R('Good morning! How much are the onions, please?', 'Bonjour ! Combien coûtent les oignons, s\'il vous plaît ?'),
    ],
    resume='There is (1) / There are (plusieurs). some (affirmation) / any (question, négation). How much is it? Can I have…, please?',
    devoir='La prochaine fois que tu fais des courses, dis dans ta tête le nom de 5 produits en anglais.'),
  # 8 -------------------------------------------------------------------
  dict(titre='I can swim!', objectifs=['Dire ce qu\'on sait faire', 'can / can\'t', 'Parler de ses loisirs'],
    etapes=[
      E('« can » = pouvoir / savoir faire. Il ne change jamais (pas de -s, même avec he/she), et le verbe après ne prend pas « to ».', 'I can dance. She can sing.',
        [('I can swim.', 'Je sais nager.'), ('He can drive.', 'Il sait conduire.'), ('I can\'t cook.', 'Je ne sais pas cuisiner.')]),
      E('Pour la question, on inverse : « Can you…? ». Réponse courte : « Yes, I can. / No, I can\'t. »', 'Can you play football?',
        [('Can you speak English?', 'Tu sais parler anglais ?'), ('Yes, a little.', 'Oui, un peu.')]),
      V(('swim', 'nager', 'swim'), ('dance', 'danser', 'dannss'), ('sing', 'chanter', 'sing'), ('drive', 'conduire', 'draïv'),
        ('play football', 'jouer au foot', 'plé fout-bol'), ('draw', 'dessiner', 'dro'), ('ride a bike', 'faire du vélo', 'raïd e baïk'), ('play the guitar', 'jouer de la guitare', 'plé ze gui-tar')),
      E('Prononciation : « can » est court (kn), « can\'t » est long et appuyé (kânt). C\'est comme ça qu\'on entend la différence !', 'I can swim. I CAN\'T swim.'),
      D(('prof', 'Can you dance, Kevin?', 'Tu sais danser, Kevin ?'), ('autre', 'Yes, I can! I love coupé-décalé!', 'Oui ! J\'adore le coupé-décalé !'),
        ('prof', 'And can you sing?', 'Et tu sais chanter ?'), ('autre', 'No, I can\'t. But I can play the guitar.', 'Non. Mais je sais jouer de la guitare.')),
      Q('Choisis la bonne phrase.', ['She cans swim.', 'She can swims.', 'She can swim.'], 2, 'can ne change pas, et le verbe reste simple.'),
      Q('« Can you drive? » — Non.', ['No, I can\'t.', 'No, I don\'t.', 'No, I not can.'], 0, 'Réponse courte : No, I can\'t.'),
      O('Can you ride a bike', 'Tu sais faire du vélo'),
      T('Je ne sais pas nager.', 'I can\'t swim.', 'I cannot swim.'),
      L('My sister can draw very well.', ['Ma sœur dessine très bien.', 'Ma sœur danse très bien.', 'Ma sœur conduit très bien.'], 0),
      R('I can dance but I can\'t sing.', 'Je sais danser mais je ne sais pas chanter.'),
    ],
    resume='can + verbe (jamais de -s, jamais de to). can\'t = ne pas pouvoir/savoir. Can you…? Yes, I can. / No, I can\'t.',
    devoir='Fais une liste de 3 choses que tu sais faire et 2 que tu ne sais pas faire, en anglais.'),
  # 9 -------------------------------------------------------------------
  dict(titre='Right now', objectifs=['Dire ce qu\'on est en train de faire', 'Le présent continu', 'Différence avec le présent simple'],
    etapes=[
      E('Pour une action en train de se passer MAINTENANT, on utilise « be + verbe-ing ». C\'est le présent continu.', 'I am eating. She is sleeping.',
        [('I\'m eating.', 'Je suis en train de manger.'), ('She\'s talking on the phone.', 'Elle est au téléphone.'), ('They\'re watching TV.', 'Ils regardent la télé.')]),
      E('Orthographe : make → making (on enlève le e), swim → swimming (on double la consonne), study → studying.', '', [('write → writing', 'écrire'), ('run → running', 'courir')]),
      E('Présent simple = habitude (tous les jours). Présent continu = maintenant. Les mots « now », « right now », « at the moment » appellent le présent continu.', '',
        [('I usually walk to work.', 'D\'habitude, je marche jusqu\'au travail.'), ('Today I\'m taking a taxi.', 'Aujourd\'hui, je prends un taxi.')]),
      V(('now', 'maintenant', 'naou'), ('at the moment', 'en ce moment', 'at ze mo-meunt'), ('wait', 'attendre', 'wèït'), ('rain', 'pleuvoir', 'rèïn'),
        ('listen', 'écouter', 'li-seunn'), ('look for', 'chercher', 'louk for')),
      D(('autre', 'Hi! What are you doing?', 'Salut ! Qu\'est-ce que tu fais ?'), ('eleve', 'I\'m waiting for the bus. It\'s raining!', 'J\'attends le bus. Il pleut !'),
        ('autre', 'Oh no! Are you going to work?', 'Oh non ! Tu vas au travail ?'), ('eleve', 'Yes, I am. I\'m late!', 'Oui. Je suis en retard !')),
      Q('« Look! The children ___ football. »', ['play', 'are playing', 'plays'], 1, '« Look! » = maintenant → présent continu.'),
      Q('« I ___ to church every Sunday. »', ['go', 'am going', 'goes'], 0, '« every Sunday » = habitude → présent simple.'),
      O('What are you doing now', 'Qu\'est-ce que tu fais maintenant'),
      T('Il pleut en ce moment.', 'It\'s raining at the moment.', 'It is raining at the moment.', 'It\'s raining now.'),
      L('She\'s cooking dinner.', ['Elle prépare le dîner.', 'Elle mange le dîner.', 'Elle achète le dîner.'], 0),
      R('Right now, I\'m learning English with Léxi!', 'En ce moment, j\'apprends l\'anglais avec Léxi !'),
    ],
    resume='be + verbe-ing = maintenant (I\'m eating). Présent simple = habitude. now, right now, at the moment → -ing.',
    devoir='Ce soir, décris en anglais 3 choses que font les gens autour de toi (« My brother is… »).'),
  # 10 ------------------------------------------------------------------
  dict(titre='Yesterday', objectifs=['Parler du passé', 'was / were', 'Les verbes réguliers en -ed'],
    etapes=[
      E('Le passé de « be » : I/he/she/it → was ; you/we/they → were.', 'I was tired. We were at home.',
        [('I was at the market.', 'J\'étais au marché.'), ('They were happy.', 'Ils étaient contents.'), ('Was it good?', 'C\'était bien ?')]),
      E('Pour les verbes réguliers, on ajoute -ed : work → worked, play → played, watch → watched. La même forme pour toutes les personnes !', 'I worked yesterday.',
        [('I watched a film.', 'J\'ai regardé un film.'), ('She cooked attiéké.', 'Elle a cuisiné de l\'attiéké.'), ('We visited our grandmother.', 'Nous avons rendu visite à notre grand-mère.')]),
      E('Négation et question au passé : « didn\'t » + verbe simple, « Did you…? ». Le -ed disparaît avec did !', '',
        [('I didn\'t work.', 'Je n\'ai pas travaillé.'), ('Did you watch the match?', 'Tu as regardé le match ?')]),
      V(('yesterday', 'hier', 'yès-teur-dé'), ('last night', 'hier soir', 'last naït'), ('last week', 'la semaine dernière', 'last wik'), ('ago', 'il y a (temps)', 'e-go'),
        ('visit', 'rendre visite / visiter', 'vi-zit'), ('stay', 'rester', 'stèï')),
      E('Prononciation du -ed : parfois « t » (worked = workt), parfois « d » (played = plèïd), et « id » après t ou d (visited = vi-zi-tid).', ''),
      D(('prof', 'Hi! How was your weekend?', 'Salut ! Comment était ton week-end ?'), ('eleve', 'It was great! I visited my aunt in Grand-Bassam.', 'C\'était super ! J\'ai rendu visite à ma tante à Grand-Bassam.'),
        ('prof', 'Nice! Did you go to the beach?', 'Sympa ! Tu es allé(e) à la plage ?'), ('eleve', 'No, I didn\'t. We stayed at home and cooked.', 'Non. Nous sommes resté(e)s à la maison et nous avons cuisiné.')),
      Q('« We ___ at the party last night. »', ['was', 'were', 'are'], 1, 'we → were.'),
      Q('« Did you ___ the film? »', ['watched', 'watch', 'watching'], 1, 'Après did : verbe simple.'),
      O('I visited my grandmother last week', 'J\'ai rendu visite à ma grand-mère la semaine dernière'),
      T('Je n\'ai pas travaillé hier.', 'I didn\'t work yesterday.', 'I did not work yesterday.'),
      L('It was a long day.', ['C\'était une longue journée.', 'C\'est une longue journée.', 'C\'était une belle journée.'], 0),
      R('Yesterday I worked, I cooked and I watched TV.', 'Hier j\'ai travaillé, j\'ai cuisiné et j\'ai regardé la télé.'),
    ],
    resume='was (I/he/she/it) / were (you/we/they). Verbes réguliers + -ed. didn\'t + verbe ; Did you + verbe ? yesterday, last week, two days ago.',
    devoir='Raconte ta journée d\'hier en 5 phrases au passé.'),
]

# Examen de fin du niveau 1 (débloque le niveau 2) et test de placement « je dis que je suis Débutant+ ».
EXAMEN = [
  Q('« J\'ai 25 ans » =', ['I have 25 years.', 'I\'m 25.', 'I am 25 year.'], 1, 'I\'m 25 (years old).'),
  Q('« They ___ from Senegal. »', ['is', 'are', 'am'], 1, 'They are.'),
  Q('Kevin et ___ sœur.', ['her', 'his', 'its'], 1, 'Kevin est un garçon → his.'),
  Q('« It\'s quarter to nine » =', ['9 h 15', '8 h 45', '9 h 45'], 1, 'quarter to nine = 9 h moins le quart.'),
  Q('« She ___ in a hospital. »', ['work', 'works', 'working'], 1, 'she → works.'),
  Q('« Is there ___ bread? »', ['some', 'any', 'many'], 1, 'question → any.'),
  Q('« He ___ drive. »', ['cans', 'can', 'can to'], 1, 'can ne change pas.'),
  Q('« Look! It ___. »', ['rains', 'is raining', 'rain'], 1, 'Look! = maintenant.'),
  Q('« We ___ tired yesterday. »', ['was', 'were', 'are'], 1, 'we → were.'),
  Q('« Did you ___ him? »', ['called', 'call', 'calls'], 1, 'did + verbe simple.'),
  T('Elle ne travaille pas le dimanche.', 'She doesn\'t work on Sunday.', 'She does not work on Sunday.', 'She doesn\'t work on Sundays.'),
  O('What does your father do', 'Que fait ton père'),
]

def main():
    dossier = os.path.join(ICI, 'n1')
    os.makedirs(dossier, exist_ok=True)
    for i, l in enumerate(LECONS, start=1):
        doc = {'id': 'en-n1-l%02d' % i, 'langue': 'en', 'niveau': 1, 'lecon': i, 'cecrl': 'A1', **l}
        with open(os.path.join(dossier, 'l%02d.json' % i), 'w', encoding='utf-8') as f:
            json.dump(doc, f, ensure_ascii=False, indent=1)
    with open(os.path.join(dossier, 'examen.json'), 'w', encoding='utf-8') as f:
        json.dump({'id': 'en-n1-examen', 'langue': 'en', 'niveau': 1, 'reussite': 9, 'etapes': EXAMEN}, f, ensure_ascii=False, indent=1)
    print(len(LECONS), 'leçons écrites')

if __name__ == '__main__':
    main()
