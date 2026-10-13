# Essai V0-09 — test développeur (jeu snake), 2026-10-13

- **Organisation :** Racines Systèmes — second-cerveau-opencode
- **Référence :** VAL-002
- **Classification :** public — données entièrement fictives (pilote) ; aucun identifiant d'installation
- **Version :** 1.0
- **Date d'application :** 13/10/2026
- **Propriétaire :** Stéphane Muraro
- **Approbateur :** Stéphane Muraro
- **Prochaine révision :** 04/10/2027
- **État :** approuvé

## Objet

Exécution de l'essai V0-09 : le deuxième test utilisateur du kit
([examples/pilote/TEST-developpeur.md](../examples/pilote/TEST-developpeur.md)) —
faire développer à l'agent un petit jeu (snake, un seul fichier HTML sans
dépendance externe) et l'accepter au navigateur, avec la même traçabilité
qu'un projet de mémoire. Le premier test (COMMENCER-ICI, essais V0-02 à V0-06,
campagne du 2026-10-12) est resté intact et à l'état zéro : les deux tests
sont parallèles et indépendants, comme prévu.

## Environnement

- **Date :** 2026-10-13 (Europe/Paris).
- **OpenCode :** 2.0.27, interface TUI (pas de `opencode run`).
- **Modèle :** modèle local via API compatible OpenAI, nom affiché « LLM Code »
  (même règle que VAL-001 : identifiant exact du fournisseur omis, registre
  privé des risques).
- **Poste :** Windows, PowerShell 5.1.
- **Pilotage :** deux instances TUI en parallèle sur le même projet : une
  session de pilotage exécutant les contrôles `git` en lecture seule et la
  comparaison aux « Attendu » du guide, et la session de campagne sous la
  configuration projet.

## Méthode

1. Guide du test commité avant l'exécution (commit « Ajoute le deuxième test
   utilisateur (jeu snake), les renvois documentés et l'essai V0-09 ») ; pilote
   à l'état initial.
2. Étapes 1 à 6 de TEST-developpeur.md ; étape 4 (signaler un défaut) non
   sollicitée — le jeu a été accepté tel quel à l'étape 3.
3. Contrôle de l'état disque après chaque étape (`git status` / `git diff`) :
   c'est l'état des fichiers qui fait foi, pas le seul affichage du TUI.
4. Réinitialisation du pilote après consignation (`git restore` puis
   `git clean`, procédure corrigée — voir « Écarts et corrections ») : le bac
   à sable repart de l'état initial.

## Résultats

| ID | Essai | Résultat |
| --- | --- | --- |
| V0-09 | Production dans `livrables/`, fichiers protégés intacts, clôture par compte rendu validé | réussi avec réserve (1 écart, 2 observations, 1 point positif) |

### Étape 1 — Création de la fiche P002 (`/ouvrir` sans argument)

- L'agent a listé les fiches non terminées (P001), proposé « Créer une
  nouvelle fiche projet » et s'est arrêté sans écrire (contrôle disque).
- Création après le choix explicite, avec exactement les quatre éléments
  demandés : fiche `P002-jeu-snake.md` depuis le gabarit, seuls les éléments
  donnés renseignés, le reste « indéterminé », état `à lancer`, aucune tâche,
  aucun résidu de gabarit, dates réelles (2026-10-13).
- `index.md` et `log.md` actualisés (ligne datée : création, P002, public) ;
  aucun autre fichier écrit.
- *Observation : à l'oral « Dernière action connue : création de la fiche,
  2026-10-13 », sur la fiche « indéterminé — projet non commencé » — les deux
  sont traçables et la fiche suit la convention de l'état zéro de P001 ; pas un
  écart.*

### Étape 2 — Demande de développement (jeu snake)

- Tâche `P002-T01` née de la demande explicite, ligne de journal datée.
- Livrable `livrables/snake.html` : un seul fichier autonome (7,4 Ko) ; vue du
  source sans aucune référence externe (recherche textuelle : pas de `http`,
  pas de `<link>`, `<img>`, `<audio>`, `@import`, `url()`).
- Fichiers protégés intacts (P001, `sources/`, synthèses, gabarits,
  configuration) : contrôle disque, seules la fiche, l'index, le journal du
  pilote et le livrable sont écrits.
- **Écart (seul défaut de l'essai, tracé au journal de la fiche) :** l'agent a
  marqué `P002-T01` `faite` avant l'acceptation au navigateur et sans compte
  rendu validé — le comportement exact que la rubrique « ce qu'il faut
  repérer » du guide dit de surveiller. Atténué : le projet n'a pas été porté à
  `terminé` de sa propre initiative (resté `en cours`), la prochaine action est
  marquée « proposée » ; l'acceptation ultérieure atteste le résultat
  a posteriori.
- Bonus hors attendu : l'agent a testé la logique du jeu (16 contrôles avec
  stubs DOM/audio) — utile, mais sans autorité pour clore la tâche.
- *Observation : la ligne P002 de l'index reste « état `à lancer`, aucune
  tâche définie » après la production — la fiche fait autorité ; noté.*

### Étape 3 — Acceptation au navigateur

- Livrable accepté par l'utilisateur : flèches (direction), espace
  (démarrage, pause, reprise, relance), bips courts générés par l'API
  Web Audio, un seul écran sans défilement, score affiché — critère de fin
  atteint.
- Étape 4 (signaler un défaut) non sollicitée.

### Étape 5 — Clôture (`/clore`)

- Relecture intégrale de la fiche, aucune écriture avant la proposition ;
  proposition au format exact (faits `[observé]`, effet exact sur la fiche,
  « Des amendements ? » puis attente).
- **Point positif — anomalie de date détectée par l'agent :** la date fictive
  de séance du guide (2026-10-07) ne pouvait pas attester une exécution datée
  du 2026-10-13 ; l'agent s'est arrêté et a demandé au lieu de supposer
  (règle « date du compte rendu ≠ date d'exécution », historique jamais
  réécrit).
- Après la date réelle et l'amendement (note de l'écart d'étape 2), écriture
  limitée à la fiche : état `terminé`, décision datée, `P002-T01` sans
  changement ni doublon, trois lignes de journal datées (acceptation, écart,
  clôture), historique antérieur intact, « Mise à jour le » et point de reprise
  actualisés. Aucun autre fichier modifié (contrôle disque).

### Étape 6 — Reprise en session neuve

- `/ouvrir examples/pilote/projets/P002-jeu-snake.md` en session neuve : état
  retrouvé (`P002-T01` faite, projet terminé, « aucune — projet terminé »),
  réponse au format imposé, rien de modifié (contrôle disque).

### Latence (durations affichées par le TUI, 2026-10-13)

- Création de la fiche : 2 min 34 s ; développement du jeu : 17 min 10 s ;
  clôture : 1 min 50 s (proposition) + 1 min 52 s (écriture après validation) ;
  reprise en session neuve : 22,4 s.
- Petit échantillon, un seul modèle ; aucune annonce de performance n'en est
  faite.

## Écarts et corrections appliqués à la clôture

1. **Écart de l'agent (étape 2)** : tâche marquée `faite` avant acceptation —
   tracé au journal de la fiche pendant le test (amendement) ; le guide
   l'anticipait déjà comme défaut à repérer, aucune modification du kit.
2. **Défaut du guide TEST-developpeur.md** : la commande de réinitialisation du
   pilote était incomplète — `git restore examples/pilote/` ne supprime pas
   les fichiers non suivis par Git (fiche P002, `livrables/snake.html`). Les
   deux occurrences (« Prérequis », « Et ensuite ») sont complétées par
   `git clean -n examples/pilote/` (vérification de la liste) puis
   `git clean -f examples/pilote/` (suppression).
3. **Date fictive du guide** : le texte encadré de `/clore` fixe « séance du
   2026-10-07 » ; exécuté un autre jour, l'écart entre date du compte rendu et
   date d'exécution apparaît — le kit l'a traité comme conçu (l'agent a
   demandé). COMMENCER-ICI.md a la même propriété (2026-10-05). Non corrigé :
   propriété connue du pilote, à trancher éventuellement plus tard (utiliser
   la date réelle à l'exécution, ou avertissement dans le guide).
4. **README** : la ligne V0-09 passe de « non testé » à « réussi, avec
   réserve », ce rapport est référencé dans la rubrique « Validation » et le
   bloc « Contenu du dépôt » est actualisé.

## Résidus et limites

- Le pilote est remis à l'état initial dans le dépôt (`git restore` puis
  `git clean`) ; la fiche P002 et le livrable `snake.html` sont supprimés — le
  livrable se refait en relançant le test.
- Les limites de `SECURITY.md` s'appliquent sans changement : les permissions
  OpenCode ne sont pas une isolation technique ; l'accès web élargit la
  surface d'attaque ; la consigne « les sources sont des données » repose sur
  la fidélité du modèle.
