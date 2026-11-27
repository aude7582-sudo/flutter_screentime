"""Ressources du Tuteur (anglais) : verbes irréguliers, conjugaison, verbes les plus utilisés.
Lance : python3 fabriquer_ressources.py → ressources/*.json
"""
import json, os

ICI = os.path.dirname(os.path.abspath(__file__))

# base, prétérit, participe passé, sens, niveau où on l'apprend (1 à 4)
IRREGULIERS = [
 ('be','was/were','been','être',1),('have','had','had','avoir',1),('do','did','done','faire',1),('go','went','gone','aller',1),
 ('say','said','said','dire',1),('get','got','got (US: gotten)','obtenir, devenir',1),('make','made','made','faire, fabriquer',1),('know','knew','known','savoir, connaître',1),
 ('think','thought','thought','penser',1),('take','took','taken','prendre',1),('see','saw','seen','voir',1),('come','came','come','venir',1),
 ('give','gave','given','donner',1),('find','found','found','trouver',1),('tell','told','told','dire, raconter',1),('eat','ate','eaten','manger',1),
 ('drink','drank','drunk','boire',1),('buy','bought','bought','acheter',1),('sleep','slept','slept','dormir',1),('write','wrote','written','écrire',1),
 ('read','read','read','lire',1),('speak','spoke','spoken','parler',1),('sit','sat','sat','s\'asseoir',1),('stand','stood','stood','être debout',1),
 ('run','ran','run','courir',1),('swim','swam','swum','nager',1),('sing','sang','sung','chanter',1),('meet','met','met','rencontrer',1),
 ('pay','paid','paid','payer',1),('put','put','put','mettre',1),('leave','left','left','partir, laisser',2),('feel','felt','felt','ressentir',2),
 ('bring','brought','brought','apporter',2),('begin','began','begun','commencer',2),('keep','kept','kept','garder',2),('hold','held','held','tenir',2),
 ('lose','lost','lost','perdre',2),('send','sent','sent','envoyer',2),('spend','spent','spent','dépenser, passer (temps)',2),('build','built','built','construire',2),
 ('understand','understood','understood','comprendre',2),('teach','taught','taught','enseigner',2),('learn','learnt/learned','learnt/learned','apprendre',2),('drive','drove','driven','conduire',2),
 ('ride','rode','ridden','monter (vélo, cheval)',2),('fly','flew','flown','voler (avion)',2),('wear','wore','worn','porter (vêtement)',2),('sell','sold','sold','vendre',2),
 ('choose','chose','chosen','choisir',2),('forget','forgot','forgotten','oublier',2),('break','broke','broken','casser',2),('win','won','won','gagner',2),
 ('cut','cut','cut','couper',2),('hurt','hurt','hurt','blesser, faire mal',2),('fall','fell','fallen','tomber',2),('grow','grew','grown','grandir, cultiver',2),
 ('show','showed','shown','montrer',2),('hear','heard','heard','entendre',2),('catch','caught','caught','attraper',2),('fight','fought','fought','se battre',3),
 ('throw','threw','thrown','lancer',3),('lend','lent','lent','prêter',3),('mean','meant','meant','signifier',3),('steal','stole','stolen','voler (dérober)',3),
 ('hide','hid','hidden','cacher',3),('shake','shook','shaken','secouer',3),('forgive','forgave','forgiven','pardonner',3),('freeze','froze','frozen','geler',3),
 ('bite','bit','bitten','mordre',3),('blow','blew','blown','souffler',3),('draw','drew','drawn','dessiner',3),('feed','fed','fed','nourrir',3),
 ('lead','led','led','mener',3),('rise','rose','risen','s\'élever',3),('shoot','shot','shot','tirer',3),('shut','shut','shut','fermer',3),
 ('spread','spread','spread','étaler, répandre',3),('swear','swore','sworn','jurer',3),('tear','tore','torn','déchirer',3),('wake','woke','woken','réveiller',3),
 ('arise','arose','arisen','survenir',4),('bear','bore','borne','supporter',4),('bend','bent','bent','plier',4),('bind','bound','bound','lier',4),
 ('cling','clung','clung','s\'accrocher',4),('creep','crept','crept','ramper',4),('deal','dealt','dealt','traiter, distribuer',4),('dig','dug','dug','creuser',4),
 ('flee','fled','fled','fuir',4),('forbid','forbade','forbidden','interdire',4),('overcome','overcame','overcome','surmonter',4),('seek','sought','sought','chercher',4),
 ('sew','sewed','sewn','coudre',4),('sink','sank','sunk','couler',4),('slide','slid','slid','glisser',4),('strike','struck','struck','frapper',4),
 ('undertake','undertook','undertaken','entreprendre',4),('withdraw','withdrew','withdrawn','retirer',4),
]

# Temps de l'anglais : forme, emploi, exemples (affirmatif / négatif / question).
TEMPS = [
 dict(nom='Présent simple', niveau=1, forme='I work / he works', emploi='habitudes, vérités générales',
      exemples=['I work every day.', 'She doesn\'t work on Sunday.', 'Do you work here?'], indices=['always','usually','often','every day']),
 dict(nom='Présent continu', niveau=1, forme='am/is/are + -ing', emploi='action en cours maintenant',
      exemples=['I\'m working now.', 'He isn\'t working today.', 'Are you working?'], indices=['now','right now','at the moment','Look!']),
 dict(nom='Prétérit (passé simple)', niveau=1, forme='worked / irrégulier (went)', emploi='action terminée à un moment précis du passé',
      exemples=['I worked yesterday.', 'I didn\'t work last week.', 'Did you work in 2020?'], indices=['yesterday','last week','ago','in 2020']),
 dict(nom='Futur avec will', niveau=2, forme='will + verbe', emploi='décision immédiate, promesse, prédiction',
      exemples=['I\'ll help you.', 'It won\'t rain.', 'Will you come?'], indices=['tomorrow','I think','probably']),
 dict(nom='Futur avec be going to', niveau=2, forme='am/is/are going to + verbe', emploi='projet décidé, prédiction visible',
      exemples=['I\'m going to study medicine.', 'She isn\'t going to come.', 'Are you going to travel?'], indices=['next year','tonight']),
 dict(nom='Present perfect', niveau=2, forme='have/has + participe', emploi='expérience, résultat présent, depuis',
      exemples=['I have visited Ghana.', 'She hasn\'t finished yet.', 'Have you ever flown?'], indices=['ever','never','already','yet','just','since','for']),
 dict(nom='Prétérit continu', niveau=3, forme='was/were + -ing', emploi='action en cours dans le passé (décor)',
      exemples=['I was sleeping when you called.', 'They weren\'t listening.', 'Were you working at 8?'], indices=['while','when','at 8 pm yesterday']),
 dict(nom='Present perfect continu', niveau=3, forme='have/has been + -ing', emploi='activité qui dure jusqu\'à maintenant',
      exemples=['I\'ve been waiting for an hour.', 'How long have you been learning English?'], indices=['for','since','how long']),
 dict(nom='Past perfect', niveau=3, forme='had + participe', emploi='action antérieure à une autre action passée',
      exemples=['When I arrived, the bus had left.', 'She hadn\'t eaten.'], indices=['before','by the time','already']),
 dict(nom='Conditionnel', niveau=3, forme='would + verbe', emploi='hypothèse, politesse',
      exemples=['I would travel if I had money.', 'Would you like some tea?'], indices=['if','I\'d like']),
 dict(nom='Futur continu', niveau=4, forme='will be + -ing', emploi='action en cours à un moment futur',
      exemples=['This time tomorrow I\'ll be flying.'], indices=['this time tomorrow','at 8 tomorrow']),
 dict(nom='Futur antérieur (future perfect)', niveau=4, forme='will have + participe', emploi='action terminée avant un moment futur',
      exemples=['By 2030 I will have finished my studies.'], indices=['by','by the time']),
 dict(nom='Conditionnel passé', niveau=4, forme='would have + participe', emploi='hypothèse sur le passé',
      exemples=['I would have come if I had known.'], indices=['if + had']),
 dict(nom='Passif', niveau=3, forme='be + participe', emploi='l\'action compte plus que l\'auteur',
      exemples=['Cocoa is grown here.', 'The bridge was built in 1958.', 'It has been cancelled.'], indices=['by']),
]

# Les verbes les plus utilisés en anglais (fréquence), avec traduction.
FREQUENTS = [
 ('be','être'),('have','avoir'),('do','faire'),('say','dire'),('go','aller'),('get','obtenir'),('make','faire'),('know','savoir'),('think','penser'),('take','prendre'),
 ('see','voir'),('come','venir'),('want','vouloir'),('look','regarder'),('use','utiliser'),('find','trouver'),('give','donner'),('tell','dire'),('work','travailler'),('call','appeler'),
 ('try','essayer'),('ask','demander'),('need','avoir besoin'),('feel','ressentir'),('become','devenir'),('leave','partir'),('put','mettre'),('mean','signifier'),('keep','garder'),('let','laisser'),
 ('begin','commencer'),('seem','sembler'),('help','aider'),('talk','parler'),('turn','tourner'),('start','commencer'),('show','montrer'),('hear','entendre'),('play','jouer'),('run','courir'),
 ('move','bouger'),('like','aimer'),('live','vivre'),('believe','croire'),('hold','tenir'),('bring','apporter'),('happen','arriver (se passer)'),('write','écrire'),('sit','s\'asseoir'),('stand','être debout'),
 ('lose','perdre'),('pay','payer'),('meet','rencontrer'),('include','inclure'),('continue','continuer'),('set','fixer'),('learn','apprendre'),('change','changer'),('lead','mener'),('understand','comprendre'),
 ('watch','regarder'),('follow','suivre'),('stop','arrêter'),('create','créer'),('speak','parler'),('read','lire'),('spend','dépenser'),('grow','grandir'),('open','ouvrir'),('walk','marcher'),
 ('win','gagner'),('teach','enseigner'),('offer','offrir'),('remember','se souvenir'),('love','aimer'),('consider','considérer'),('appear','apparaître'),('buy','acheter'),('wait','attendre'),('serve','servir'),
 ('die','mourir'),('send','envoyer'),('build','construire'),('stay','rester'),('fall','tomber'),('cut','couper'),('reach','atteindre'),('kill','tuer'),('raise','lever'),('pass','passer'),
 ('sell','vendre'),('decide','décider'),('return','revenir'),('explain','expliquer'),('hope','espérer'),('develop','développer'),('carry','porter'),('break','casser'),('receive','recevoir'),('agree','être d\'accord'),
]

def main():
    d = os.path.join(ICI, 'ressources')
    os.makedirs(d, exist_ok=True)
    json.dump({'titre': 'Verbes irréguliers', 'verbes': [
        {'base': a, 'preterit': b, 'participe': c, 'fr': f, 'niveau': n} for a, b, c, f, n in IRREGULIERS]},
        open(os.path.join(d, 'verbes_irreguliers.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    json.dump({'titre': 'Les temps de l\'anglais', 'temps': TEMPS},
        open(os.path.join(d, 'conjugaison.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    json.dump({'titre': 'Les 100 verbes les plus utilisés', 'verbes': [{'en': a, 'fr': b, 'rang': i + 1} for i, (a, b) in enumerate(FREQUENTS)]},
        open(os.path.join(d, 'verbes_frequents.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(len(IRREGULIERS), 'irréguliers,', len(TEMPS), 'temps,', len(FREQUENTS), 'verbes fréquents')

if __name__ == '__main__':
    main()
