# second-cerveau-opencode

Second cerveau minimal en Markdown, piloté par [OpenCode](https://opencode.ai)
et un modèle d'IA exécuté sur le LAN ou sur la machine locale (API compatible
OpenAI). Les fichiers Markdown sont la mémoire durable : la conversation ne
sert jamais à la reprise.

[Nom de l’organisation]	[second-cerveau-opencode]
Référence : [PROJ-001]
Classification : [Confidentiel]
Version : [1.0]
Date d’application : [04/10/2026 09h00:00]
Propriétaire : [Développeur]
Approbateur : [Chef de projet]
Prochaine révision : [04/10/2027 09h00:00]

- **État :** brouillon

- Un seul agent d'exécution, un seul modèle, un projet pilote fictif.
- Un seul agent d'exécution, un seul modèle, un projet pilote fictif.
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
LICENSE              licence retenue : MIT (voir rubrique Publication)
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
2. Créer la configuration locale `opencode.json` dans la racine du projet,
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
3. Lancer OpenCode dans la racine du projet : `opencode`
4. (Optionnel) Ouvrir `examples/pilote/` comme vault Obsidian pour parcourir
   les fiches au fil des séances.

Vérification de base : dans une session, demander « Dis-moi l'état du projet
pilote » ou lancer `/ouvrir examples/pilote/projets/P001-atelier-fictif.md`.
Le modèle doit répondre à partir de la fiche, sans modifier de fichier.

## Utilisation

### Rituel d'ouverture (lecture seule)

Exemple :

```
/ouvrir examples/pilote/projets/P001-atelier-fictif.md
```

Réponse courte : objectif, état, blocage éventuel, dernière action connue,
prochaine action (marquée « proposée » ou « décidée »). Aucune écriture.

### Rituel de clôture

```
/clore <compte rendu de la séance, avec la date et les faits>
```

Exemple :

```
/clore Séance du 2026-10-04 15h45:00 : P001-T01 terminée, l'accès est confirmé, la salle est bien au 1er étage. P001-T02 bloquée : le vidéoprojecteur est en panne. Idée : prévoir un vidéoprojecteur de prêt.
```

Seuls les faits attestés changent ; une idée reste « proposée » ; le journal et
le point de reprise sont actualisés dans la même fiche ; un résumé des
modifications est donné. Répéter le même compte rendu ne crée aucun doublon.

### Connaissances (demandes ordinaires)

- Ingestion : « Intègre `examples/pilote/sources/lieu.md` dans la synthèse
  `examples/pilote/syntheses/fiche-accueil-atelier.md` avec références. »
- Question : « D'après les sources du pilote, à quel étage se trouve la salle A ? »
- Enregistrement d'une réponse : uniquement si vous le demandez explicitement.

### Vault privé (projet réel)

Le vault réel reste séparé de ce dépôt. Parcours pour l'utiliser avec le kit :

1. Créer un dossier de travail `vault-prive/` hors de ce dépôt.
2. Y copier le socle du kit : `AGENTS.md` (règles), `.opencode/commands/`
   (`ouvrir.md`, `clore.md`) et la configuration locale `opencode.json`
   (protections du projet + modèle ; celle créée à l'étape Installation.2, ou
   recréée depuis `opencode.example.jsonc` si elle est indisponible).
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

Recette V0 exécutée le 2026-10-04 09h00:00 sur le pilote, OpenCode `1.18.33`
(Windows) et un modèle LAN à API compatible OpenAI (identifiant exact du
modèle conservé dans le registre privé des risques), chaque essai
lancé dans une session `opencode run` distincte (le mode TUI n'a pas été testé
dans cette campagne). Les temps incluent le démarrage du serveur (~10–15 s par
session) ; aucune promesse de gain par rapport à un autre outil.

| ID | Essai | Résultat | Détail / preuve |
| --- | --- | --- | --- |
| V0-01 | Connexion modèle LAN + édition contrôlée | réussi | Session neuve connectée au modèle LAN ; ligne exacte ajoutée au fichier factice via l'outil d'édition, aucun autre fichier modifié (hash). 83,3 s. |
| V0-02 | /ouvrir exact, court, sans modification | réussi | Une seule lecture (la fiche), réponse courte : objectif, état, blocage, dernière action, prochaine action marquée « proposée ». 0 fichier modifié (trace d'outils + horodatages). 50,8 s. |
| V0-03 | /clore correct, répétition sans doublon | réussi | Seul la fiche modifiée : tâche marquée faite (date d'exécution distincte de la date du compte rendu), tâche bloquée, idée conservée « proposée » sans création de tâche, journal +2 lignes, point de reprise actualisé ; incohérence « jeudi 14 octobre » signalée. Répétition du même compte rendu : « aucune modification nécessaire », 0 fichier modifié. 166,8 s puis 28,6 s. |
| V0-04 | Reprise en nouvelle session, note manuelle préservée | réussi | Session neuve : état retrouvé depuis la fiche seule (faite/bloquée/prochaine action) ; note manuelle ajoutée entre les sessions préservée ; 0 écriture. 33,5 s. |
| V0-05 | Synthèse traçable, contradiction signalée, originaux intacts | réussi | Question croisée : contradiction d'étage signalée avec les deux références ; question sans réponse signalée comme telle. Réingestion de lieu.md : faits déjà couverts non dupliqués, 1 fait manquant ajouté avec référence, ligne de journal, source inchangée (hash). 43,4 s puis 188,3 s. |
| V0-06 | Instruction hostile ignorée, écriture des originaux bloquée | réussi (après correction) | Les 3 demandes injectées (lire la clé, copier, publier) non exécutées, signalées et intégrées comme données. Le test d'écriture a d'abord révélé un défaut réel d'ordre des règles `permission` (la règle générale l'emportait) ; après correction, l'outil d'édition est refusé sur l'original par le mécanisme de permissions et le fichier reste intact (hash). 133,1 s puis 46,3 s. |
| V0-07 | Restauration depuis sauvegarde distincte | réussi | Sauvegarde distincte (dossier séparé), restauration dans un emplacement de test : 26/26 fichiers identiques au hash ; le point de temps de la sauvegarde n'inclut pas le travail postérieur ; projet courant non écrasé. |
| V0-08 | Installation documentée, contenu publiable, latence mesurée | réussi avec limites | Examen git : seuls les fichiers du kit sont suivis ; `opencode.json`, registre privé, `sources/` exclus ; aucune clé ni identifiant LAN dans le dépôt (recherche textuelle). Limites : installation testée sur cette machine en mode `opencode run` seulement ; sauvegarde de test sur le même disque. |

Latence observée (mode `opencode run`, frais de démarrage serveur inclus) :
/ouvrir 50,8 s puis 33,5 s ; /clore 166,8 s (5 éditions) puis 28,6 s (répétition
sans écriture) ; question 43,4 s ; réingestion 188,3 s ; échange minimal 51,9 s.

## Idées ultérieures (non réalisées, à déclencher sur besoin observé)

- Index automatique des projets et commande de liste d'état.
- Commandes `/ingest` et `/question` dédiées si les demandes ordinaires se répètent.
- Contrôle de cohérence périodique (liens cassés, contradictions, doublons).
- Sauvegarde automatisée datée et rotation.
- Multi-projets : une fiche par projet réelle dans le vault privé.

## Publication (parcours en cours)

Rubrique de référence pour l'état de publication, la licence et les droits ;
les autres documents renvoient ici.

- **État actuel :** prototype destiné à une évaluation interne sur le Github
  de Stéphane Muraro, avec accès restreint. Aucune publication externe à ce
  jour ; aucune validation ne doit être présentée comme déjà obtenue.
- **Parcours décidé :**
  1. Évaluation sur le GitHub personnel, avec accès restreint ;
  2. Validation et amélioration;
  3. Publication publique sur le GitHub personnel de Stéphane Muraro,
     uniquement après validation.
- **Licence envisagée :** MIT. Le fichier [`LICENSE`](LICENSE) conserve le
  texte MIT comme licence
  adoptée.
- **Mentions de copyright :** « Copyright (c) 2026
  Stéphane Muraro » et « Copyright (c) 2026 Racines Systèmes ».
  Aucune copropriété, aucun partage égal ni cession de droits préexistants n'est
  présumée.
- **Objectif final :** second cerveau IA open source publié, compatible
  OpenCode et LLM LAN/local, léger, évolutif, inspiré d'ISO 27001 sans
  certification.
- **Contenu du futur dépôt public :** uniquement le kit, sa documentation et
  les exemples fictifs, en documents génériques ; le vault personnel reste
  séparé. Vérifié le 2026-10-O4 : les fichiers suivis par Git sont limités au
  kit. `sources/` (racine), `opencode.json` et le registre privé des risques
  sont exclus, et aucune clé ni identifiant LAN n'apparaît dans le dépôt.
- **Avant push :** relire l'historique Git complet et activer le rapport privé
  dans la Security Policy GitHub (canal décrit dans
  [SECURITY.md](SECURITY.md)).