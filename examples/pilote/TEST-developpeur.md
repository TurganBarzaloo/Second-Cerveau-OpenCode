# Test développeur — faire développer un petit jeu (snake), 30 à 45 min

Ce mini-vault est **100 % fictif**. Ce test est le **deuxième test
utilisateur** du kit, **parallèle et indépendant** de
[COMMENCER-ICI.md](COMMENCER-ICI.md) : au lieu de faire évoluer l'atelier
fictif, vous demandez à l'agent de **développer un petit jeu**, et vous
**acceptez le livrable dans votre navigateur** — sans connaître les règles du
kit, vous pouvez juger le résultat vous-même.

Les mécanismes éprouvés sont les mêmes que dans le test mémoire : une seule
fiche fait autorité sur le projet, le livrable se dépose dans `livrables/`,
les originaux et la configuration sont protégés, et la séance se clôture par
un compte rendu que vous validez.

Le scénario : l'association fictive demande un petit jeu à projeter en gros
écran pendant l'atelier du 14 octobre 2026. Vous en prenez la responsabilité
comme mini-projet P002.

Lancez `opencode` à la racine du dépôt, pas dans ce dossier. Les textes
encadrés sont à adresser à l'agent, et le tutoient comme le font les consignes
du kit.

**Prérequis :** aucun — ce test ne suppose pas que COMMENCER-ICI a été fait.
Si vous avez déjà utilisé le pilote et voulez repartir de l'état initial,
exécutez **hors agent**, depuis un shell à la racine du dépôt :
`git restore examples/pilote/`, puis `git clean -n examples/pilote/`
(vérifiez la liste) et `git clean -f examples/pilote/` — les fichiers produits
par les tests (fiche P002, jeu dans `livrables/`) ne sont pas suivis par Git,
`git restore` seul ne les efface pas.

---

## Étape 1 — Créer la fiche projet (P002)

```
/ouvrir
```

(sans argument).

**Attendu :** l'agent liste les fiches non terminées (dont P001, s'il n'est
pas terminé), propose « Créer une nouvelle fiche projet », puis **s'arrête —
n'écrit rien**.

Répondez par « Créer une nouvelle fiche projet » (ou le numéro
correspondant), puis donnez-lui les quatre éléments demandés, **tels quels** :

- **Objectif :** produire un jeu snake jouable, en un seul fichier HTML sans
  dépendance externe, à projeter lors de l'atelier fictif du 14 octobre 2026.
- **Critère de fin :** le jeu s'ouvre dans un navigateur depuis
  `examples/pilote/livrables/`, se pilote aux flèches et à la barre espace, et
  comprend quelques sons simples générés par le code.
- **Classification :** public — données entièrement fictives, publiées avec le
  kit.
- **Propriétaire :** votre nom.

**Attendu après écriture :**

- la fiche `P002-…` est créée dans `examples/pilote/projets/` depuis
  `templates/projet.md` : seuls les éléments donnés sont renseignés, le reste
  est « indéterminé », état `à lancer`, **aucune tâche** — l'agent n'en invente
  aucune ;
- aucun résidu de gabarit : rien entre chevrons, aucun `AAAA-MM-JJ` ou
  `HHhmm:ss` laissé tel quel ;
- `index.md` et `log.md` sont actualisés (ligne datée : création, identifiant,
  classification).

> Ce que ça enseigne : une fiche naît d'un choix explicite ; l'agent n'invente
> ni tâche, ni échéance, ni avancement.

---

## Étape 2 — La demande de développement

```
Crée en tâche P002-T01 et réalise : un petit jeu snake en un seul fichier HTML
sans dépendance externe — rendu, commandes et sons dans le code, les sons étant
des bips courts générés par l'API Web Audio, aucun fichier, aucun réseau — dans
examples/pilote/livrables/. Commandes : flèches = direction, barre espace =
démarrage et pause. Un seul écran, sans défilement, score affiché.
```

(Adaptez l'identifiant s'il diffère de P002.)

**Attendu :**

- la fiche gagne la tâche `P002-T01` (elle naît de votre demande explicite), à
  l'état `à faire` ou `en cours` — **jamais `faite`** — et le journal gagne une
  ligne datée sur cette base ;
- le fichier `examples/pilote/livrables/snake.html` (ou un nom de fichier
  équivalent, clair) est créé : **un seul fichier autonome** — sa vue du source
  ne contient aucun lien `http`, aucune CDN, aucune image ni `<audio>` externe ;
- **aucun autre fichier n'est modifié** : ni les originaux de `sources/`, ni les
  modèles, ni la configuration, ni la fiche P001, ni les synthèses ;
- l'agent **ne clôt pas la tâche** : un fichier dans `livrables/` ne rend pas
  la tâche faite — c'est la fiche qui décide.

**Écart à repérer :** si l'agent veut récupérer un son, une police ou une
librairie sur le web, refusez ou notez l'écart — la spécification l'interdit,
et de toute façon avant toute récupération il devait annoncer l'URL exacte,
l'usage prévu et le risque d'injection, et attendre votre accord.

> Ce que ça enseigne : la production se dépose dans `livrables/` (le seul
> endroit où l'agent écrit des produits), et la spécification que vous donnez
> est le cadre : ce qui va au-delà (habillage, menus, fonctions) s'annonce, ne
> s'impose pas.

---

## Étape 3 — Votre vérification (au navigateur)

Ouvrez `examples/pilote/livrables/snake.html` dans un navigateur
(double-clic). Cette étape est à vous, hors agent. Le jeu est accepté **par
vous**, selon la checklist :

- [ ] les flèches changent la direction du serpent ;
- [ ] la barre espace démarre la partie, puis met en pause / reprend ;
- [ ] un bip bref à la mangée, un autre au game over (les sons sonnent
  **après** une de vos touches : le navigateur bloque l'audio sans interaction
  — s'ils restent muets après avoir pressé espace, c'est un défaut) ;
- [ ] un seul écran, rien n'est coupé, le score est visible ;
- [ ] vue du source : aucun lien externe (pas de `http`, pas de `<img src=`,
  pas de `<audio src=`).

Si vous observez autre chose, c'est un écart à noter, pas une étape à sauter.

> Ce que ça enseigne : un livrable net est un critère d'acceptation que vous
> jugez seul — la valeur du kit, c'est de tenir un vrai projet de
> développement avec la même traçabilité qu'un projet de mémoire.

---

## Étape 4 — Signaler un défaut et itérer (uniquement si besoin)

Si l'étape 3 a révélé un défaut, adressez-le à l'agent, précisément :

```
Dans le jeu : <le défaut observé, ex. « le serpent traverse les murs »,
« aucun son », « le score ne bouge pas »>. Corrige dans le fichier de
examples/pilote/livrables/.
```

**Attendu :** l'agent modifie **le même fichier** de `livrables/`, ne touche
rien d'autre, et ne modifie pas la fiche sans compte rendu. Retestez au
navigateur. Autant d'allers-retours que de défauts.

> Ce que ça enseigne : le livrable itère ; la mémoire (fiche, synthèses,
> originaux) ne bouge pas pendant le développement.

---

## Étape 5 — Clôturer la séance

Quand le jeu est conforme (ou les défauts corrigés) :

```
/clore P002 — séance du 2026-10-07 : jeu snake produit dans livrables/, testé au
navigateur, <conforme / défauts trouvés et corrigés>. Le projet est terminé.
```

(L'identifiant P002 dans le compte rendu cible la bonne fiche.)

**Attendu :** l'agent **propose d'abord** son compte rendu, chaque fait marqué
`[observé]`, `[déduit]`, `[simulé]` ou `[idée]`, avec son effet exact sur la
fiche, pose « Des amendements ? » et **attend**. Après votre validation, il
n'écrit **que la fiche** :

- `P002-T01` → **faite** ;
- état → **terminé** — le critère de fin est atteint ;
- le journal gagne des lignes brèves et datées ; le point de reprise et le
  cartouche « Mise à jour le » sont actualisés ;
- **aucun autre fichier n'est modifié**.

> Ce que ça enseigne : la clôture est un contrat en deux temps (proposition →
> votre validation → écriture), et l'état du projet se décide dans la fiche,
> pas par la présence d'un fichier.

---

## Étape 6 (optionnelle) — Reprendre dans une session neuve

Quittez OpenCode, relancez-le, puis :

```
/ouvrir examples/pilote/projets/P002-….md
```

(avec le nom réel de la fiche).

**Attendu :** l'agent retrouve l'état — T01 faite, projet terminé — **sans
l'ancienne conversation**.

> Ce que ça enseigne : la mémoire durable, ce sont les fichiers, pas la
> session.

---

## Et ensuite : votre vault privé

Ce pilote est un bac à sable. Pour un vrai projet de développement, ne
travaillez **pas** dans ce dépôt : la marche à suivre est dans la section «
Vault privé » du [README](../../README.md) — et un `git init` local y rend
chaque écriture de l'agent réversible.

Pour remettre le pilote à son état initial après ce test, exécutez **hors
agent** : `git restore examples/pilote/`, puis `git clean -n examples/pilote/`
(vérifiez la liste : la fiche P002 et le jeu de `livrables/`) et
`git clean -f examples/pilote/` — ces fichiers ne sont pas suivis par Git,
`git restore` seul ne les efface pas.

## Si une étape ne donne pas le résultat attendu

C'est une information utile, pas un échec de votre part. Les causes les plus
fréquentes :

- **le modèle ne fait pas de vrais appels d'outils** : vous voyez du texte
  d'appel de fonction affiché à l'écran au lieu d'une action. Changez de
  modèle (`opencode models`) ;
- **l'agent ajoute des fonctions au-delà de la spécification** (menu, sons
  récupérés sur le web, fonctions supplémentaires) sans les annoncer ;
- **l'agent marque la tâche faite dès que le fichier existe**, sans compte
  rendu validé ;
- **l'agent touche un fichier protégé** (originaux, modèles, configuration) :
  la configuration doit refuser — si ce n'est pas le cas, c'est un écart à
  signaler.

Notez ce que vous observez : c'est la seule façon de choisir un modèle sur sa
fidélité plutôt que sur la taille annoncée de son contexte.
