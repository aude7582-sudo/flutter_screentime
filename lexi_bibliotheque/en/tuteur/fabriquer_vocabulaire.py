"""Banques de vocabulaire du Tuteur (anglais), par niveau et par thème.
Lance : python3 fabriquer_vocabulaire.py → ressources/vocabulaire_n1.json … n5.json
"""
import json, os
ICI = os.path.dirname(os.path.abspath(__file__))

def th(nom, emoji, mots):
    return {'theme': nom, 'emoji': emoji, 'mots': [{'en': a, 'fr': b} for a, b in (m.split('=') for m in mots)]}

N = {
1: [
 th('Le corps', '🧍', ['head=tête','hair=cheveux','eye=œil','ear=oreille','nose=nez','mouth=bouche','tooth / teeth=dent / dents','neck=cou','arm=bras','hand=main','finger=doigt','leg=jambe','foot / feet=pied / pieds','back=dos','stomach=ventre']),
 th('La maison', '🏠', ['house=maison','room=pièce','bedroom=chambre','kitchen=cuisine','bathroom=salle de bain','living room=salon','door=porte','window=fenêtre','bed=lit','table=table','chair=chaise','fridge=réfrigérateur','fan=ventilateur','yard=cour','roof=toit']),
 th('L\'école', '🏫', ['school=école','classroom=salle de classe','teacher=enseignant','pupil=élève','book=livre','notebook=cahier','pen=stylo','pencil=crayon','ruler=règle','bag=sac','board=tableau','homework=devoirs','lesson=leçon','test=contrôle','break=récréation']),
 th('Les vêtements', '👕', ['shirt=chemise','T-shirt=t-shirt','trousers=pantalon','skirt=jupe','dress=robe','shoes=chaussures','sandals=sandales','hat=chapeau','cap=casquette','jacket=veste','socks=chaussettes','loincloth / wax fabric=pagne','headscarf=foulard','belt=ceinture','uniform=uniforme']),
 th('Les couleurs', '🎨', ['red=rouge','blue=bleu','green=vert','yellow=jaune','orange=orange','purple=violet','pink=rose','black=noir','white=blanc','grey=gris','brown=marron','light=clair','dark=foncé','gold=doré','silver=argenté']),
 th('La nourriture', '🍲', ['rice=riz','cassava=manioc','yam=igname','plantain=banane plantain','chicken=poulet','fish=poisson','meat=viande','egg=œuf','beans=haricots','sauce=sauce','pepper=piment','salt=sel','sugar=sucre','fruit=fruit','vegetables=légumes']),
 th('Les animaux', '🐘', ['dog=chien','cat=chat','chicken / hen=poule','goat=chèvre','sheep=mouton','cow=vache','horse=cheval','elephant=éléphant','lion=lion','monkey=singe','snake=serpent','bird=oiseau','fish=poisson','mosquito=moustique','turtle=tortue']),
 th('Les transports', '🚌', ['car=voiture','bus=bus','taxi=taxi','motorbike=moto','bike=vélo','train=train','plane=avion','boat=bateau','canoe=pirogue','road=route','bus stop=arrêt de bus','station=gare','airport=aéroport','ticket=ticket','driver=chauffeur']),
 th('Les émotions', '😊', ['happy=heureux','sad=triste','angry=en colère','tired=fatigué','hungry=affamé','thirsty=assoiffé','scared=effrayé','bored=ennuyé','excited=excité','surprised=surpris','worried=inquiet','proud=fier','calm=calme','nervous=nerveux','sick=malade']),
 th('Les verbes de tous les jours', '🔁', ['wake up=se réveiller','wash=laver','eat=manger','drink=boire','go=aller','come=venir','work=travailler','study=étudier','play=jouer','cook=cuisiner','clean=nettoyer','buy=acheter','sell=vendre','sleep=dormir','pray=prier']),
],
2: [
 th('En ville', '🏙️', ['street=rue','square=place','bank=banque','hospital=hôpital','pharmacy=pharmacie','post office=poste','market=marché','supermarket=supermarché','church=église','mosque=mosquée','police station=commissariat','town hall=mairie','bridge=pont','traffic jam=embouteillage','pavement=trottoir']),
 th('La santé', '🩺', ['doctor=médecin','nurse=infirmier','patient=patient','appointment=rendez-vous','prescription=ordonnance','pill=comprimé','injection=piqûre','malaria=paludisme','fever=fièvre','cough=toux','cold=rhume','wound=blessure','pain=douleur','recover=guérir','health insurance=assurance maladie']),
 th('Le travail', '💼', ['job=emploi','boss=patron','colleague=collègue','office=bureau','salary=salaire','meeting=réunion','contract=contrat','interview=entretien','skills=compétences','unemployed=au chômage','retire=prendre sa retraite','shift=service (horaires)','overtime=heures sup','promotion=promotion','training=formation']),
 th('Les voyages', '✈️', ['trip=voyage','passport=passeport','visa=visa','luggage=bagages','suitcase=valise','flight=vol','booking=réservation','hotel=hôtel','tourist=touriste','map=carte','border=frontière','currency=devise','souvenir=souvenir','beach=plage','abroad=à l\'étranger']),
 th('La technologie', '📱', ['phone=téléphone','charger=chargeur','screen=écran','app=application','password=mot de passe','download=télécharger','upload=mettre en ligne','message=message','network=réseau','data=données','computer=ordinateur','keyboard=clavier','website=site web','account=compte','update=mise à jour']),
 th('Le sport', '⚽', ['football=football','basketball=basket','match=match','team=équipe','player=joueur','coach=entraîneur','goal=but','score=score','win=gagner','lose=perdre','draw=match nul','referee=arbitre','stadium=stade','fan=supporter','training=entraînement']),
 th('L\'argent', '💰', ['money=argent','cash=liquide','coin=pièce','note=billet','price=prix','change=monnaie','discount=réduction','receipt=reçu','debt=dette','save=économiser','borrow=emprunter','lend=prêter','mobile money=mobile money','fee=frais','budget=budget']),
 th('La nature', '🌳', ['tree=arbre','forest=forêt','river=fleuve, rivière','lake=lac','sea=mer','mountain=montagne','hill=colline','sky=ciel','sun=soleil','moon=lune','star=étoile','rain=pluie','wind=vent','field=champ','lagoon=lagune']),
],
3: [
 th('Les médias', '📰', ['news=informations','newspaper=journal','journalist=journaliste','article=article','headline=gros titre','interview=interview','broadcast=diffuser','channel=chaîne','audience=public','advertisement=publicité','social media=réseaux sociaux','influencer=influenceur','fake news=fausse information','source=source','podcast=podcast']),
 th('L\'environnement', '🌍', ['pollution=pollution','waste=déchets','recycle=recycler','climate change=changement climatique','global warming=réchauffement','drought=sécheresse','flood=inondation','deforestation=déforestation','plastic=plastique','solar energy=énergie solaire','protect=protéger','species=espèce','endangered=menacé','resources=ressources','sustainable=durable']),
 th('L\'éducation', '🎓', ['degree=diplôme universitaire','exam=examen','pass=réussir','fail=échouer','grade / mark=note','subject=matière','scholarship=bourse','university=université','lecture=cours magistral','student=étudiant','research=recherche','thesis=mémoire','graduate=être diplômé','tuition fees=frais de scolarité','apprenticeship=apprentissage']),
 th('Les relations', '🤝', ['friendship=amitié','relationship=relation','partner=partenaire','engaged=fiancé','wedding=mariage','divorce=divorce','neighbour=voisin','trust=confiance','argue=se disputer','get along=bien s\'entendre','apologise=s\'excuser','support=soutenir','respect=respect','jealous=jaloux','loyal=fidèle']),
 th('Les sentiments nuancés', '💭', ['grateful=reconnaissant','disappointed=déçu','embarrassed=gêné','confused=perdu, confus','relieved=soulagé','anxious=anxieux','confident=confiant','frustrated=frustré','lonely=seul (sentiment)','curious=curieux','ashamed=honteux','delighted=ravi','upset=contrarié','hopeful=plein d\'espoir','overwhelmed=débordé']),
 th('Le monde des affaires', '🏢', ['company=entreprise','customer=client','supplier=fournisseur','profit=bénéfice','loss=perte','market=marché','product=produit','service=service','invest=investir','loan=prêt','sales=ventes','competitor=concurrent','brand=marque','manager=responsable','entrepreneur=entrepreneur']),
],
4: [
 th('Société et politique', '🏛️', ['government=gouvernement','citizen=citoyen','law=loi','vote=voter','election=élection','candidate=candidat','policy=politique (mesure)','rights=droits','equality=égalité','corruption=corruption','democracy=démocratie','protest=manifestation','reform=réforme','poverty=pauvreté','welfare=aide sociale']),
 th('Économie', '📈', ['economy=économie','growth=croissance','inflation=inflation','tax=impôt','unemployment rate=taux de chômage','export=exporter','import=importer','trade=commerce','investment=investissement','income=revenu','wealth=richesse','debt=dette','crisis=crise','supply and demand=offre et demande','GDP=PIB']),
 th('Sciences et santé', '🔬', ['experiment=expérience','evidence=preuve','discovery=découverte','vaccine=vaccin','disease=maladie','treatment=traitement','gene=gène','survey=enquête, sondage','data=données','theory=théorie','laboratory=laboratoire','outbreak=épidémie','immune=immunisé','side effect=effet secondaire','cure=remède']),
 th('Le droit', '⚖️', ['court=tribunal','judge=juge','lawyer=avocat','trial=procès','witness=témoin','guilty=coupable','innocent=innocent','sentence=peine','fine=amende','crime=crime','theft=vol','evidence=preuves','appeal=faire appel','contract=contrat','sue=poursuivre en justice']),
 th('Expressions idiomatiques', '💬', ['a piece of cake=très facile','break the ice=briser la glace','under the weather=pas en forme','over the moon=aux anges','an arm and a leg=les yeux de la tête','call it a day=s\'arrêter là','hit the books=se mettre à étudier','once in a blue moon=très rarement','get the hang of it=prendre le coup','the ball is in your court=la balle est dans ton camp','cost a fortune=coûter une fortune','on the same page=d\'accord','keep an eye on=surveiller','in hot water=dans le pétrin','spill the beans=vendre la mèche']),
],
5: [
 th('Anglais académique', '📚', ['analyse=analyser','assess=évaluer','approach=approche','concept=concept','context=contexte','framework=cadre','hypothesis=hypothèse','interpret=interpréter','methodology=méthodologie','significant=significatif','consistent=cohérent','derive=découler','imply=impliquer','furthermore=en outre','thereby=de ce fait']),
 th('Connecteurs formels', '🔗', ['nevertheless=néanmoins','notwithstanding=nonobstant','whereas=tandis que','hence=d\'où','thus=ainsi','consequently=par conséquent','moreover=de plus','albeit=bien que','insofar as=dans la mesure où','in light of=à la lumière de','with regard to=en ce qui concerne','on the contrary=au contraire','by contrast=en revanche','to that end=à cette fin','in essence=en substance']),
 th('Nuances et style', '🎭', ['subtle=subtil','blunt=direct, brutal','eloquent=éloquent','ambiguous=ambigu','compelling=convaincant','flawed=imparfait','nuanced=nuancé','candid=franc','tentative=hésitant','profound=profond','trivial=insignifiant','ironic=ironique','understatement=euphémisme','rhetorical=rhétorique','persuasive=persuasif']),
 th('Verbes à particule avancés', '🧩', ['come across=tomber sur','bounce back=rebondir','figure out=comprendre','come up with=trouver (idée)','put up with=supporter','run out of=manquer de','look into=examiner','settle in=s\'installer','kick in=commencer à agir','phase out=supprimer progressivement','rule out=écarter','set back=retarder','brush up on=réviser','carry out=mener à bien','account for=expliquer, représenter']),
],
}

def main():
    d = os.path.join(ICI, 'ressources')
    os.makedirs(d, exist_ok=True)
    total = 0
    for n, themes in N.items():
        total += sum(len(t['mots']) for t in themes)
        json.dump({'langue': 'en', 'niveau': n, 'themes': themes}, open(os.path.join(d, 'vocabulaire_n%d.json' % n), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(total, 'mots')

if __name__ == '__main__':
    main()
