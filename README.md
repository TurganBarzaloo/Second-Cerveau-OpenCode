# second-cerveau-opencode

Second cerveau minimal en Markdown, piloté par [OpenCode](https://opencode.ai)
et un modèle d'IA exécuté sur le LAN ou sur la machine locale (API compatible
OpenAI). Les fichiers Markdown sont la mémoire durable : la conversation ne
sert jamais à la reprise.

Racines Systèmes — second-cerveau-opencode
Référence : PROJ-001
Classification : Public
Version : 1.0
Date d’application : 04/10/2026
Propriétaire : Stéphane Muraro
Approbateur : Stéphane Muraro
Prochaine révision : 04/10/2027

- **État :** approuvé

- Un seul agent d'exécution, un seul modèle, un projet pilote fictif.
- **Pour démarrer : [examples/pilote/COMMENCER-ICI.md](examples/pilote/COMMENCER-ICI.md)**,
  parcours guidé en 7 étapes avec le résultat attendu à chacune.
- Deux rituels courts : `/ouvrir` (état + prochaine action, sans écriture) et
  `/clore` (mise à jour ciblée à partir d'un compte rendu).
- Connaissances : sources originales préservées, synthèses distinctes et
  traçables, contradictions conservées.
- Sécurité proportionnée inspirée d'ISO/IEC 27001, sans certification ni
  revendication de conformité : voir [SECURITY.md](SECURITY.md).
- Influences et provenance : voir [CREDITS.md](CREDITS.md).

## Contenu du dépôt

```text
README.md            ce fichier
AGENTS.md            règles communes chargées à chaque session
SECURITY.md          périmètre, mesures, limites, incident
CREDITS.md           influences et provenance
LICENSE.md           licence adoptée : MIT
opencode.example.jsonc  configuration générique (valeurs fictives)
.opencode/commands/  /ouvrir et /clore
templates/projet.md  modèle de fiche projet
examples/pilote/     mini-vault Obsidian fictif (P001 + 2 sources + synthèse)
```

La configuration locale réelle (`opencode.json`) et le registre privé des
risques sont **exclus de Git** (voir `.gitignore`).

À la première exécution, OpenCode installe automatiquement ses dépendances
dans `.opencode/node_modules/` (avec `package.json` et `package-lock.json`) :
c'est un artefact normal du moteur, régénérable et exclu de Git.

## Installation

Prérequis : OpenCode installé, et un modèle accessible en API compatible
OpenAI (LAN ou local).

1. Récupérer le dépôt dans un dossier de travail.
2. **Relever les identifiants réels** de votre installation :

   ```
   opencode models
   ```

   La sortie donne les valeurs exactes à utiliser, au format
   `<fournisseur>/<modèle>`. Ne les devinez pas : un identifiant approximatif
   fait échouer la session sans message explicite.
3. Créer la configuration locale `opencode.json` dans la racine du projet,
   **même si le fournisseur est déjà dans la configuration globale d'OpenCode** :
   c'est la configuration du projet qui porte les protections du kit
   (`share` désactivé et permissions de l'agent) ; sans elle, la session
   démarre sans ces protections. La config locale est exclue de Git et
   fusionnée avec la config globale.
   - copier `opencode.example.jsonc` vers `opencode.json` ;
   - soit le fournisseur est déjà dans la configuration OpenCode de la machine
     (config globale) : supprimer le bloc `provider` de la copie et pointer la
     ligne `model` sur le fournisseur et le modèle réels ;
   - soit définir le fournisseur dans la copie : remplacer l'adresse d'API et
     l'identifiant de modèle, et définir la variable d'environnement de la clé
     (jamais la clé en clair dans un fichier) :
     ```powershell
     setx IA_LAN_API_KEY "votre-cle"   # puis rouvrir le terminal
     ```
4. Lancer OpenCode dans la racine du projet : `opencode`
5. (Optionnel) Ouvrir `examples/pilote/` comme vault Obsidian pour parcourir
   les fiches au fil des séances.

Vérification de base : dans une session, lancer
`/ouvrir examples/pilote/projets/P001-atelier-fictif.md`. Le modèle doit répondre
à partir de la fiche, sans modifier de fichier. Puis enchaînez sur
[COMMENCER-ICI.md](examples/pilote/COMMENCER-ICI.md).

**Utilisez les rituels dans le TUI**, pas via `opencode run`. Le mode non
interactif annule les questions de l'agent et lui demande de « continuer en
supposant » : les étapes où il doit vous proposer un compte rendu et attendre
votre accord y perdent leur garde-fou.

Sous Git Bash, `opencode run "/ouvrir …"` échoue de surcroît : le shell convertit
le `/` initial en chemin Windows. Préfixez par `MSYS2_ARG_CONV_EXCL='*'` si vous
y tenez. Sans effet dans le TUI.

## Utilisation

### Rituel d'ouverture (lecture seule)

```
/ouvrir examples/pilote/projets/P001-atelier-fictif.md
```

Réponse courte : objectif, critère de fin, état, dernière action connue, blocage
éventuel, prochaine action (en conservant sa mention « proposée » ou
« décidée »). Aucune écriture.

Sans argument, `/ouvrir` liste les fiches non terminées et vous propose soit d'en
ouvrir une, soit d'en créer une nouvelle depuis `templates/projet.md`. La
création est la seule écriture que ce rituel autorise, et seulement après votre
choix explicite.

### Rituel de clôture

```
/clore <compte rendu de la séance, avec la date et les faits>
```

L'agent rédige d'abord lui-même le compte rendu, une ligne par fait marquée
`[observé]`, `[déduit]` ou `[idée]` avec l'effet exact sur la fiche, puis vous
demande vos amendements. **Il n'écrit qu'après votre validation.**

Ensuite : seuls les faits attestés changent ; une idée reste « proposée » et ne
devient pas une tâche ; le journal et le point de reprise sont actualisés dans la
même fiche. Répéter le même compte rendu ne crée aucun doublon.

Exemple complet et résultat attendu : étapes 4 et 5 de
[COMMENCER-ICI.md](examples/pilote/COMMENCER-ICI.md).

### Connaissances (demandes ordinaires)

- Ingestion : « Intègre `examples/pilote/sources/materiel.md` dans la synthèse
  `examples/pilote/syntheses/fiche-accueil-atelier.md` avec les références. »
- Question : « D'après les sources du pilote, à quel étage se trouve la salle A ? »
- Enregistrement d'une réponse : uniquement si vous le demandez explicitement.

### Vault privé (projet réel)

Le vault réel reste séparé de ce dépôt. Parcours pour l'utiliser avec le kit :

1. Créer un dossier de travail `vault-prive/` hors de ce dépôt.
2. Y copier le socle du kit : `AGENTS.md` (règles), `.opencode/commands/`
   (`ouvrir.md`, `clore.md`) et la configuration locale `opencode.json`
   (protections du projet + modèle ; celle créée à l'étape 3 de l'installation,
   ou recréée depuis `opencode.example.jsonc` si elle est indisponible).
3. Créer le projet : copier `templates/projet.md` dans `vault-prive/projets/`,
   renommer PXXX avec le prochain identifiant libre.
4. Lancer `opencode` à la racine de `vault-prive/` : les commandes, les règles
   et les permissions du kit s'appliquent alors au vault.

Sélection de la fiche :

- `/ouvrir <chemin/vers/la/fiche.md>` : donner le chemin de la fiche ; la
  cible par défaut (le pilote) n'existe pas dans un vault privé.
- `/clore <compte rendu>` : mentionner l'identifiant du projet dans le compte
  rendu (ex. `P002 : séance du 2026-10-06 10h30:00, …`) pour que la bonne fiche soit
  ciblée.

## Limites

- Pilote : un seul projet, un seul modèle, deux rituels. Le multi-projets
  automatisé, les agents spécialisés, le MCP, les connecteurs et les
  automatisations sont différés (un besoin observé justifiera un ajout).
- Les permissions OpenCode ne sont pas une isolation technique (voir
  [SECURITY.md](SECURITY.md), limites connues).
- Aucune vérification de l'API LAN n'est incluse : authentification, transport
  et journalisation serveur restent à vérifier côté serveur avant usage sur
  données réelles.
- La latence dépend du modèle et du réseau ; aucun gain par rapport à un autre
  outil n'est garanti sans mesure comparable.

## Validation

**État : recette à refaire.** Une première campagne avait été menée le
2026-10-04 sur OpenCode `1.18.33` en mode `opencode run`. Elle est **caduque**,
pour deux raisons découvertes depuis :

- La version installée est désormais `2.0.22` — changement de version majeure.
- Le mode `opencode run` est non interactif : quand un rituel pose une question,
  OpenCode l'annule et demande au modèle de « continuer en supposant ». Le
  garde-fou « propose puis attends » ne peut donc pas y être éprouvé. Observé en
  essai : le modèle a écrit au journal une clôture de projet qui n'avait jamais
  eu lieu. Les rituels doivent être éprouvés **dans le TUI**.

S'y ajoute un constat sur le modèle : `qwen3-coder:30b` rend ses appels d'outils
en texte brut (`<function=...>`) au lieu de les exécuter, ce qui bloque les
rituels. Il a été remplacé par `qwen3.6:35b`.

La recette se refait en suivant
[examples/pilote/COMMENCER-ICI.md](examples/pilote/COMMENCER-ICI.md), dont les
sept étapes couvrent les essais V0-02 à V0-06.

| ID | Essai | Étape | Résultat sur `2.0.22` |
| --- | --- | --- | --- |
| V0-01 | Connexion modèle et édition contrôlée | — | non testé |
| V0-02 | `/ouvrir` exact, court, sans modification | 1 | **partiel** — sortie exacte et conforme, mention « décidée » conservée, 0 écriture ; mais 4 fichiers lus au lieu de la seule fiche |
| V0-03 | `/clore` correct, puis répétition sans doublon | 4 et 5 | non testé |
| V0-04 | Reprise en session neuve, note manuelle préservée | 6 | non testé |
| V0-05 | Synthèse traçable, contradiction conservée, originaux intacts | 2 et 3 | non testé |
| V0-06 | Instruction hostile ignorée, originaux protégés | 7 | non testé |
| V0-07 | Restauration depuis une sauvegarde distincte | — | non testé |
| V0-08 | Contenu publiable vérifié, latence des rituels mesurée | — | non testé |

Un essai non exécuté est « non testé », jamais « réussi ». Aucune latence n'est
annoncée : les mesures de la campagne précédente portaient sur une autre version
et un autre modèle.

Limite connue sur V0-02 : les permissions bornent le périmètre extérieur (web,
shell, système, `sources/` privé) mais ne peuvent pas rendre `/ouvrir` plus
strict que `/clore`, car elles s'appliquent à la session et non à la commande.
La sobriété interne reste donc une consigne, pas une contrainte technique.

## Idées ultérieures (non réalisées, à déclencher sur besoin observé)

- Index automatique des projets et commande de liste d'état.
- Commandes `/ingest` et `/question` dédiées si les demandes ordinaires se répètent.
- Contrôle de cohérence périodique (liens cassés, contradictions, doublons).
- Sauvegarde automatisée datée et rotation.
- Multi-projets : une fiche par projet réelle dans le vault privé.

## Publication (parcours en cours)

Rubrique de référence pour l'état de publication, la licence et les droits ;
les autres documents renvoient ici.

- **État actuel :** **publié** sur le GitHub de Stéphane Muraro depuis le
  2026-10-04. Le kit est utilisable, mais **la recette V0 reste à refaire** sur
  OpenCode `2.0.22` : voir la rubrique Validation. Aucune validation
  fonctionnelle ne doit donc être présentée comme obtenue, et aucune garantie de
  sécurité n'est revendiquée — voir [SECURITY.md](SECURITY.md) et ses limites
  connues.
- **Ce que le dépôt contient :** le kit, sa documentation et les exemples
  fictifs uniquement. Le vault personnel et la configuration locale restent
  séparés et exclus de Git.
- **Historique :** le dépôt a été réécrit puis recréé le 2026-10-04 pour retirer
  des documents de travail privés publiés par erreur. Les SHA antérieurs à cette
  date ne sont plus valides.
- **Licence :** MIT, **adoptée** (décision du 2026-10-04). Texte complet dans
  [`LICENSE.md`](LICENSE.md).
- **Mentions de copyright :** « Copyright (c) 2026
  Stéphane Muraro » et « Copyright (c) 2026 Racines Systèmes ».
  Aucune copropriété, aucun partage égal ni cession de droits préexistants n'est
  présumée.
- **Objectif final :** second cerveau IA open source publié, compatible
  OpenCode et LLM LAN/local, léger, évolutif, inspiré d'ISO 27001 sans
  certification.
- **Contrôle effectué le 2026-10-04 avant publication :** les fichiers suivis
  par Git sont limités au kit ; `sources/` (racine), `opencode.json` et le
  registre privé des risques sont exclus ; aucune clé, adresse LAN ni
  identifiant de fournisseur n'apparaît dans les fichiers suivis (recherche
  textuelle sur l'ensemble de l'index Git).
- **Signalement de vulnérabilité :** activer le rapport privé
  dans la Security Policy GitHub (canal décrit dans
  [SECURITY.md](SECURITY.md)).