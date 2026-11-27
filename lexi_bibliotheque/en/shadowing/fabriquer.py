"""Phrases de Shadowing (anglais) : 4 niveaux, 30 phrases chacun.
Lance : python3 fabriquer.py → shadowing.json
"""
import json, os
ICI = os.path.dirname(os.path.abspath(__file__))

NIVEAUX = [
 ('facile', 'Facile', [
  ('Hello, how are you?', 'Bonjour, comment vas-tu ?'), ('My name is Awa.', 'Je m\'appelle Awa.'), ('I am from Abidjan.', 'Je viens d\'Abidjan.'),
  ('Nice to meet you.', 'Enchanté.'), ('Thank you very much.', 'Merci beaucoup.'), ('See you tomorrow.', 'À demain.'),
  ('I like rice and fish.', 'J\'aime le riz et le poisson.'), ('Where is the market?', 'Où est le marché ?'), ('How much is it?', 'Combien ça coûte ?'),
  ('I am very happy today.', 'Je suis très content aujourd\'hui.'), ('Can you help me, please?', 'Peux-tu m\'aider, s\'il te plaît ?'), ('What time is it?', 'Quelle heure est-il ?'),
  ('It is hot today.', 'Il fait chaud aujourd\'hui.'), ('I have two sisters.', 'J\'ai deux sœurs.'), ('I go to school every day.', 'Je vais à l\'école tous les jours.'),
  ('Open the door, please.', 'Ouvre la porte, s\'il te plaît.'), ('I am hungry.', 'J\'ai faim.'), ('Good morning, teacher!', 'Bonjour, professeur !'),
  ('This is my phone.', 'C\'est mon téléphone.'), ('I love my family.', 'J\'aime ma famille.'), ('Let\'s go!', 'Allons-y !'),
  ('I don\'t understand.', 'Je ne comprends pas.'), ('Please speak slowly.', 'Parle lentement, s\'il te plaît.'), ('See you soon!', 'À bientôt !'),
  ('My favourite colour is blue.', 'Ma couleur préférée est le bleu.'), ('I can swim.', 'Je sais nager.'), ('Have a nice day!', 'Bonne journée !'),
  ('The bus is late.', 'Le bus est en retard.'), ('I need some water.', 'J\'ai besoin d\'eau.'), ('Good night!', 'Bonne nuit !'),
 ]),
 ('intermediaire', 'Intermédiaire', [
  ('Last weekend, I visited my grandmother.', 'Le week-end dernier, j\'ai rendu visite à ma grand-mère.'),
  ('I\'m going to travel next month.', 'Je vais voyager le mois prochain.'), ('Could you tell me the way to the station?', 'Pourriez-vous m\'indiquer le chemin de la gare ?'),
  ('I\'d like a glass of orange juice, please.', 'Je voudrais un verre de jus d\'orange, s\'il vous plaît.'), ('Have you ever been to Ghana?', 'Es-tu déjà allé au Ghana ?'),
  ('If it rains, we will stay at home.', 'S\'il pleut, nous resterons à la maison.'), ('You should drink more water.', 'Tu devrais boire plus d\'eau.'),
  ('My brother is taller than me.', 'Mon frère est plus grand que moi.'), ('What do you usually do on Sundays?', 'Que fais-tu d\'habitude le dimanche ?'),
  ('I was cooking when you called me.', 'Je cuisinais quand tu m\'as appelé.'), ('The film was really exciting.', 'Le film était vraiment passionnant.'),
  ('I\'m sorry, I didn\'t hear you.', 'Désolé, je ne t\'ai pas entendu.'), ('Can I leave a message?', 'Puis-je laisser un message ?'),
  ('She works in a big hospital.', 'Elle travaille dans un grand hôpital.'), ('We have to finish this today.', 'Nous devons finir ça aujourd\'hui.'),
  ('How long does it take to get there?', 'Combien de temps faut-il pour y aller ?'), ('I think it\'s a good idea.', 'Je pense que c\'est une bonne idée.'),
  ('The woman who lives next door is a doctor.', 'La femme qui habite à côté est médecin.'), ('I\'ve already finished my homework.', 'J\'ai déjà fini mes devoirs.'),
  ('Don\'t worry, everything will be fine.', 'Ne t\'inquiète pas, tout ira bien.'), ('What a beautiful day!', 'Quelle belle journée !'),
  ('I\'m looking for a new job.', 'Je cherche un nouveau travail.'), ('It\'s too expensive for me.', 'C\'est trop cher pour moi.'),
  ('Let me check my phone.', 'Laisse-moi vérifier mon téléphone.'), ('We met at the university.', 'Nous nous sommes rencontrés à l\'université.'),
  ('Turn left at the roundabout.', 'Tournez à gauche au rond-point.'), ('I usually go to bed at ten.', 'Je me couche d\'habitude à dix heures.'),
  ('Would you like to come with us?', 'Veux-tu venir avec nous ?'), ('The meeting starts at nine.', 'La réunion commence à neuf heures.'), ('I\'ll call you back later.', 'Je te rappellerai plus tard.'),
 ]),
 ('difficile', 'Difficile', [
  ('I\'ve been learning English for three months.', 'J\'apprends l\'anglais depuis trois mois.'), ('When I was a child, I used to climb mango trees.', 'Quand j\'étais enfant, je grimpais aux manguiers.'),
  ('By the time I arrived, the bus had already left.', 'Quand je suis arrivé, le bus était déjà parti.'), ('If I had more money, I would start a business.', 'Si j\'avais plus d\'argent, je créerais une entreprise.'),
  ('The bridge was built more than fifty years ago.', 'Le pont a été construit il y a plus de cinquante ans.'), ('She told me that she was very tired.', 'Elle m\'a dit qu\'elle était très fatiguée.'),
  ('Although it was raining, we went to the beach.', 'Bien qu\'il pleuvait, nous sommes allés à la plage.'), ('In my opinion, social media can be useful.', 'À mon avis, les réseaux sociaux peuvent être utiles.'),
  ('I see your point, but I don\'t completely agree.', 'Je comprends ton point de vue, mais je ne suis pas tout à fait d\'accord.'),
  ('Our flight has been delayed by two hours.', 'Notre vol a été retardé de deux heures.'), ('I\'m writing to apply for the position of assistant.', 'Je vous écris pour postuler au poste d\'assistant.'),
  ('He asked me whether I could start on Monday.', 'Il m\'a demandé si je pouvais commencer lundi.'), ('I\'m not used to waking up so early.', 'Je n\'ai pas l\'habitude de me lever si tôt.'),
  ('What would you do if you won the lottery?', 'Que ferais-tu si tu gagnais à la loterie ?'), ('The car broke down on the way to Yamoussoukro.', 'La voiture est tombée en panne sur la route de Yamoussoukro.'),
  ('Cocoa is grown in many regions of the country.', 'Le cacao est cultivé dans de nombreuses régions du pays.'), ('I\'d rather stay at home tonight.', 'Je préfère rester à la maison ce soir.'),
  ('Could you possibly change my room?', 'Pourriez-vous changer ma chambre ?'), ('Please find attached my curriculum vitae.', 'Veuillez trouver ci-joint mon curriculum vitae.'),
  ('I look forward to hearing from you.', 'Dans l\'attente de votre réponse.'), ('It was the best decision I\'ve ever made.', 'C\'était la meilleure décision de ma vie.'),
  ('She hasn\'t replied to my message yet.', 'Elle n\'a pas encore répondu à mon message.'), ('They were watching the match when the lights went off.', 'Ils regardaient le match quand le courant a coupé.'),
  ('Since I moved here, my life has changed a lot.', 'Depuis que j\'ai déménagé ici, ma vie a beaucoup changé.'), ('He is said to be the best tailor in town.', 'On dit qu\'il est le meilleur couturier de la ville.'),
  ('Unless you hurry, you\'ll miss the bus.', 'Si tu ne te dépêches pas, tu vas rater le bus.'), ('I wish I had more time to read.', 'J\'aimerais avoir plus de temps pour lire.'),
  ('Let\'s discuss this tomorrow morning.', 'Discutons-en demain matin.'), ('It turned out to be a great surprise.', 'Ça s\'est avéré être une belle surprise.'), ('Thank you for your patience.', 'Merci pour votre patience.'),
 ]),
 ('expert', 'Expert', [
  ('Never have I seen such a passionate audience.', 'Jamais je n\'ai vu un public aussi passionné.'), ('What really matters is how you treat other people.', 'Ce qui compte vraiment, c\'est la façon dont tu traites les autres.'),
  ('Had I known about the traffic, I would have left earlier.', 'Si j\'avais su pour les embouteillages, je serais parti plus tôt.'), ('Should you require any further information, do not hesitate to contact us.', 'Si vous avez besoin d\'informations supplémentaires, n\'hésitez pas à nous contacter.'),
  ('She must have forgotten about our appointment.', 'Elle a dû oublier notre rendez-vous.'), ('Not only did he win the race, but he also broke the record.', 'Non seulement il a gagné la course, mais il a aussi battu le record.'),
  ('The findings suggest that young people tend to read less.', 'Les résultats suggèrent que les jeunes ont tendance à lire moins.'), ('Granted, the project is expensive; however, it is a long-term investment.', 'Certes, le projet est cher ; cependant, c\'est un investissement à long terme.'),
  ('It was only then that I realised how lucky I had been.', 'Ce n\'est qu\'alors que j\'ai réalisé la chance que j\'avais eue.'), ('Little did they know that the company was about to close.', 'Ils étaient loin de se douter que l\'entreprise allait fermer.'),
  ('With all due respect, I see things a little differently.', 'Avec tout le respect que je vous dois, je vois les choses un peu autrement.'), ('By the end of the year, we will have trained over a thousand teachers.', 'D\'ici la fin de l\'année, nous aurons formé plus de mille enseignants.'),
  ('The more you practise, the more confident you become.', 'Plus tu pratiques, plus tu prends confiance.'), ('He can\'t have finished the report already.', 'Il ne peut pas avoir déjà fini le rapport.'),
  ('Ladies and gentlemen, thank you for being here tonight.', 'Mesdames et messieurs, merci d\'être là ce soir.'), ('Let me wrap up with one final thought.', 'Permettez-moi de conclure avec une dernière pensée.'),
  ('To a certain extent, the government is responsible for this situation.', 'Dans une certaine mesure, le gouvernement est responsable de cette situation.'), ('We need to come up with a more sustainable solution.', 'Nous devons trouver une solution plus durable.'),
  ('I can no longer put up with such behaviour.', 'Je ne peux plus supporter un tel comportement.'), ('Rarely do we get an opportunity like this.', 'Il est rare d\'avoir une telle opportunité.'),
  ('All things considered, it was a remarkable achievement.', 'Tout bien considéré, c\'était une réussite remarquable.'), ('That said, we cannot ignore the risks involved.', 'Cela dit, nous ne pouvons pas ignorer les risques.'),
  ('It appears that the economy is gradually recovering.', 'Il semble que l\'économie se redresse progressivement.'), ('Imagine a world where every child can read.', 'Imaginez un monde où chaque enfant sait lire.'),
  ('Under no circumstances should you share your password.', 'En aucun cas vous ne devez partager votre mot de passe.'), ('The reason why I\'m late is that the road was flooded.', 'Si je suis en retard, c\'est parce que la route était inondée.'),
  ('By and large, the results were better than expected.', 'Dans l\'ensemble, les résultats étaient meilleurs que prévu.'), ('I\'ll look into it and get back to you as soon as possible.', 'Je vais examiner ça et je reviens vers vous dès que possible.'),
  ('Learning a language opens doors you never knew existed.', 'Apprendre une langue ouvre des portes dont tu ignorais l\'existence.'), ('In a nutshell, practice makes perfect.', 'En résumé, c\'est en forgeant qu\'on devient forgeron.'),
 ]),
]

def main():
    doc = {'langue': 'en', 'niveaux': [{'id': i, 'nom': n, 'phrases': [{'en': a, 'fr': b} for a, b in p]} for i, n, p in NIVEAUX]}
    json.dump(doc, open(os.path.join(ICI, 'shadowing.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(sum(len(n[2]) for n in NIVEAUX), 'phrases')

if __name__ == '__main__':
    main()
