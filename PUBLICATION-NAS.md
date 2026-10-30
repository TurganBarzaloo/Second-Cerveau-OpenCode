# Publication du vault sur le NAS partagé (PUBLICATION-NAS.md)

- **Organisation :** Racines Systèmes — second-cerveau-opencode
- **Référence :** PUB-001
- **Classification :** public — document du kit, sans donnée sensible, chemins en valeur d'exemple
- **Version :** 1.1 (corrections en validation)
- **Date de rédaction :** 29/10/2026
- **Propriétaire :** Stéphane Muraro
- **Approbateur :** Stéphane Muraro
- **Prochaine révision :** 27/10/2027
- **État :** brouillon

Document de référence du mécanisme qui publie le vault vers le wiki partagé
d'équipe hébergé sur le NAS. Les autres documents renvoient ici. Décisions
validées le 27/10/2026 (compte rendu utilisateur) : matrice de visibilité,
scripts PowerShell, intégration OpenCode via `/publie`, déclencheurs
(`terminé`, 13h, 17h, manuel).

## Flux et principes

- **Flux unidirectionnel** : vault local (source) → NAS (destination). Le NAS
  n'est jamais une source : rien ne revient de là vers le vault.
- **Local souverain** : le vault reste la seule mémoire durable ; le NAS est
  une copie en lecture pour l'équipe, pas un espace de co-édition.
- **Publication contrôlée** : un fichier part seulement s'il est éligible
  (règles ci-dessous) **et** si sa classification l'autorise.
- **Aucune suppression sur le NAS** : le script n'ajoute et ne remplace que.
  Un fichier supprimé du vault ne fait pas disparaître sa copie NAS
  (intervention manuelle si besoin, c'est voulu).

## Architecture cible (NAS)

Partage d'exemple : `\\NAS\WikiPartage` — valeur à adapter par installation
(variable `$NASDefaut` dans `scripts/publier.ps1`, ou paramètre `-NAS`).

```text
\\NAS\WikiPartage\
├── Developpeurs\
│   ├── NOTICE.md
│   ├── projets\
│   ├── syntheses\
│   └── livrables\
├── Hierarchie\              (même arborescence que Developpeurs)
├── SSI\
│   ├── NOTICE.md
│   ├── projets\
│   ├── syntheses\
│   └── livrables\tableaux-de-bord\
└── Support\                 (même arborescence que SSI)
```

Chaque fichier est copié **en conservant son chemin relatif au vault** dans le
dossier de chacun de ses rôles destinataires. Un `NOTICE.md` est créé à la
racine de chaque dossier de rôle destinataire : il avertit que le dossier est une copie
alimentée automatiquement et que toute édition à la main serait écrasée.

## Matrice de visibilité

| Type de document | Emplacement source | Développeurs | Hiérarchie | SSI | Support |
| --- | --- | --- | --- | --- | --- |
| Fiche projet | `projets/` | oui | oui | oui | oui |
| Synthèse | `syntheses/` | oui | oui | oui | oui |
| Livrable | `livrables/` (hors tableaux de bord) | oui | oui | non | non |
| Tableau de bord | `livrables/tableaux-de-bord/` | oui | oui | oui | oui |

Matrice fixée le 27/10/2026 : le support ne voit pas les livrables ; la
hiérarchie les voit. Pour la modifier : variable `$Matrice` en tête de
`scripts/publier.ps1`, et permissions du partage NAS à mettre en cohérence.

## Règles d'éligibilité

- **Mode automatique** (aucun argument) : la fiche projet est publiée si et
  seulement si son état est `terminé`. Les synthèses et livrables publiés avec
  elle sont ceux qui **réfèrent le projet** (son identifiant `PXXX` figure dans
  le fichier). Un fichier qui ne réferre aucun projet éligible ne part pas.
- **Mode ciblé** (`-Fichier <chemin>`, ou un chemin en argument de `/publie`) :
  le fichier est publié quel que soit l'état du projet. C'est une décision
  explicite : le garde-fou d'état est contourné, **jamais** la classification.
- **Restriction de projet** (`-Projets PXXX`) : mode automatique restreint aux
  identifiants donnés ; le contrôle d'état reste opposable.

## Garde-fou de classification (jamais contournable)

| Classification du fichier | Résultat |
| --- | --- |
| `public` | publié |
| `interne` | publié |
| `confidentiel` | **refusé**, refus journalisé |
| absente, inconnue, ambiguë ou dupliquée | **refusé** |

Le contrôle s'applique fichier par fichier à chaque exécution, y compris en
prévisualisation et en mode ciblé. Le code de sortie du script est alors 2 :
c'est un signal à traiter, pas une erreur technique. En prévisualisation, les
refus sont affichés en console uniquement, aucun journal n'est écrit.

Le cartouche doit être au début du document : titre H1 facultatif, préambule en
citation éventuel et champs en liste (`- **Classification :** public`). Le corps,
une section ou un bloc de code termine le cartouche. Les classifications dans
des exemples du corps ne sont jamais utilisées. Un seul champ est accepté.
Une annotation explicative après ` — ` ou ` – ` est possible, sans autre niveau
de classification ni marqueur de choix/placeholder. `public | interne |
confidentiel` est refusé. Ce contrôle ne vérifie pas la sensibilité réelle du
contenu : sa classification reste de la responsabilité de son propriétaire.

## Historique et versions

- L'état « publié » est suivi par le fichier local `.publication/manifest.json`
  (exclu de Git), version 2 : hash SHA-256, date, type, classification, destination
  NAS et rôles destinataires. Les manifests version 1 sont relus et revérifiés.
- Un fichier n'est à jour que si la destination et les rôles correspondent,
  et si toutes les copies distantes ont le hash attendu. Une copie absente ou
  altérée est rétablie ; une nouvelle destination est alimentée.
- Un changement de rôles actualise le manifest. Un retrait de rôle signale les
  anciennes copies à traiter manuellement : aucune suppression automatique.
- Un échec partiel retourne 1 et laisse le fichier absent du manifest de succès.
  Les copies déjà réalisées peuvent subsister ; relancer après correction.
  Le manifest est remplacé atomiquement, mais les publications concurrentes
  d'un même vault ne sont pas prises en charge.
- Avant tout remplacement sur le NAS, la version antérieure est archivée dans
  `<rôle>\_historique\` (horodatage fin + identifiant unique + chemin aplati). Une archive
  existante ne peut jamais être écrasée ; sa copie est vérifiée avant remplacement.
- Côté vault, la gestion des versions reste à la charge de Git ; côté NAS,
  `_historique/` est un filet de repli, pas une sauvegarde — celle-ci relève
  du NAS (voir SECURITY.md).

## Déclencheurs

| Déclencheur | Mise en œuvre |
| --- | --- |
| Projet passé `terminé` | mode automatique de `publier.ps1`, via `/publie` ou la proposition de `/clore` |
| Quotidien, 13h et 17h | deux tâches planifiées, créées par `scripts\planifier-taches.ps1` |
| Manuel | `/publie` dans une session OpenCode, ou exécution directe du script |

Les tâches planifiées tournent sous le compte utilisateur qui les a installées
: la machine doit être allumée et le partage accessible à 13h et 17h.
`-StartWhenAvailable` relance la publication à la première occasion si la
machine était éteinte à l'heure prévue (limite de 10 minutes d'exécution).

## Scripts

`scripts\publier.ps1` — la publication :

| Paramètre | Effet |
| --- | --- |
| (aucun) | mode automatique : tout ce qui est éligible |
| `-Projets P001,P002` | restreint aux identifiants donnés |
| `-Fichier livrables\x.md` | publication ciblée (chemin relatif au vault) |
| `-NAS \\NAS\WikiPartage` | partage cible (défaut : `$NASDefaut`) |
| `-Vault C:\chemin\vault` | racine du vault (défaut : parent de `scripts/`) |
| `-DryRun` | prévisualise sans rien écrire |

Codes de sortie : `0` succès (y compris « rien à publier ») · `1` erreur
bloquante (NAS inaccessible, copie non vérifiée, manifest illisible) ·
`2` au moins un refus de publication.

`scripts\planifier-taches.ps1` — les tâches planifiées :

```powershell
# installer (crée les tâches de 13h et de 17h)
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\planifier-taches.ps1

# désinstaller
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\planifier-taches.ps1 -Desinstaller
```

## Journal et manifest

- Journal d'exécution : `logs/publication-AAAA-MM-JJ.log` (exclu de Git).
- État des publications : `.publication/manifest.json` (exclu de Git).
- Journal du vault : pour chaque fiche projet publiée, une ligne datée
  « publication NAS : … — [SYNC] » est ajoutée au journal de la fiche par
  `/publie` (la clôture `/clore` la propose, elle ne l'impose pas).

## Intégration OpenCode

- `/publie` (`.opencode/commands/publie.md`) : cerner la cible, prévisualiser
  en `-DryRun`, publier **seulement après validation**, ligne de journal
  `[SYNC]` par fiche publiée.
- `/clore` : étape 5 — si la fiche est `terminé` et que quelque chose est à
  publier, proposer la publication selon le déroulé de `/publie`.
- **Permission shell** : le profil d'exemple refuse le shell, sauf ces deux
  motifs (commande sans argument et avec arguments), tous deux en `ask` :
  `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/publier.ps1`
  et la même commande suivie d'un espace puis `*`. Le reste reste refusé.
  Examiner chaque commande, ses arguments et sa destination ; accorder une seule
  fois, sans `--auto` ni « always ». `scripts/**` est protégé en édition.
  Ces motifs ne sont pas un bac à sable et ne valident pas les arguments.
- L'installation des tâches se fait manuellement dans un terminal, hors agent ;
  elles tournent ensuite sans confirmation interactive. Si la permission ou
  le périmètre extérieur bloque l'appel depuis OpenCode, arrêter et rapporter
  le refus : ne pas contourner par un autre outil. Une exécution manuelle
  ultérieure reste une décision explicite du propriétaire.
- Syntaxe rapprochée de la [documentation officielle OpenCode](https://opencode.ai/docs/permissions/)
  le 29/10/2026 ; fonctionnement dans le TUI avec la configuration globale et
  le fournisseur réels restant à vérifier. Les commandes sont déjà livrées
  dans `.opencode/commands/` et leurs copies de distribution sont identiques.

## Limites et risques

- **Pas de chiffrement ajouté par le script** : la protection du transport
  SMB et du stockage relève du NAS et du réseau (VPN si le partage est
  joignable hors du LAN).
- **Identifiants NAS** : si le partage n'est pas accessible avec le compte
  courant aux heures planifiées, les tâches échouent — le journal du jour le
  dit.
- **Liens vers les sources cassés sur le NAS** : une synthèse publiée pointe
  vers `../sources/…` qui n'existe pas sur le NAS. C'est voulu : les
  originaux ne quittent jamais le vault.
- **Encodage des scripts** : les deux fichiers `.ps1` sont à conserver en
  UTF-8 avec BOM ; les accents des cartouches (« État ») font partie des
  motifs de reconnaissance du script.
- **Pas de réconciliation inverse** : des copies NAS modifiées à la main sont
  écrasées (après archivage) à la publication suivante.
- **Périmètre du dépôt kit** : ce dépôt publie le mécanisme, pas un vault réel.
  Le vault de production reste séparé (voir README, « Vault privé ») ; le
  chemin NAS réel et les comptes d'accès ne s'écrivent pas ici.

## Recette et statut

Le socle V0 conserve ses rapports historiques. Pour les ajouts NAS, exécuter :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/publication-nas.tests.ps1
```

Cette recette crée des données fictives et un faux NAS sous le TEMP local,
conserve un rapport JSON et ne touche ni au NAS réel ni aux tâches planifiées.
Résultats et limites : [recette du 29/10/2026](validation/recette-nas-2026-10-29.md).
Le document reste brouillon ; aucune approbation de production n'est présumée.

Une reclassification en confidentiel ne retire pas les copies déjà diffusées.
Le propriétaire doit examiner leur retrait, y compris dans les archives.
Les liens/jonctions et les chemins NAS/vault imbriqués sont refusés.
Les livrables doivent porter un cartouche textuel lisible ; aucun parseur de
classification PDF, DOCX ou autre format binaire n'est fourni.
