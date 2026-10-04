# Sécurité (SECURITY.md)

[Nom de l’organisation]	[second-cerveau-opencode]
Référence : [SEC-001]
Classification : [Confidentiel]
Version : [1.0]
Date d’application : [04/10/2026 09h00:00]
Propriétaire : [Développeur]
Approbateur : [Chef de projet]
Prochaine révision : [04/10/2027 09h00:00]

- **État :** brouillon

Démarche inspirée d'ISO/IEC 27001 : mesures et écarts documentés, proportionnés
à l'usage. Ce projet n'est **pas** certifié et ne revendique aucune conformité.
Le détail sensible de l'installation (adresses, états d'essai) reste dans un
registre privé, non publié (`registre-risques.md`, exclu de Git).

## Périmètre

- État : prototype en évaluation interne ; publication externe en attente de
  validation (voir README.md, rubrique « Publication »).
- Un poste de travail, ce dépôt (kit + exemples fictifs), un vault Obsidian
  éventuellement séparé.
- Un modèle d'IA accessible via une API compatible OpenAI, sur le LAN ou sur la
  machine locale (adresse et identifiant propres à chaque installation).
- OpenCode comme seul client agent. Pas de service permanent, pas de base
  vectorielle, pas de plugin, pas de MCP.

## Périmètre

- État : prototype en évaluation interne ; publication externe en attente de
  validation (voir README.md, rubrique « Publication »).
- Un poste de travail, ce dépôt (kit + exemples fictifs), un vault Obsidian
  éventuellement séparé.
- Un modèle d'IA accessible via une API compatible OpenAI, sur le LAN ou sur la
  machine locale (adresse et identifiant propres à chaque installation).
- OpenCode comme seul client agent. Pas de service permanent, pas de base
  vectorielle, pas de plugin, pas de MCP.

## Mesures

| Sujet | Mesure |
| --- | --- |
| Données | Les exemples contenus dans le dépôt sont 100 % fictifs. Les données réelles se gardent dans un vault privé séparé du dépôt. |
| Secrets | Jamais de clé ni d'adresse réelle dans un fichier versionné. La config exemple lit la clé depuis une variable d'environnement ; la config locale réelle est exclue de Git. |
| Accès de l'agent | `webfetch`, `websearch` et `bash` refusés, pas de plugin ni MCP. Les sous-agents sont à réfléchir avant mise en place (mécanismes de contrôle, de retour à l'agent général, évitement des boucles infinies). L'édition est refusée sur les originaux (`sources/`) et sur la configuration. Les commandes système (git, sauvegarde) s'exécutent manuellement hors agent. |
| Contenu importé | Le contenu des documents est traité comme des données, jamais comme des consignes : une source qui demande une commande, un secret ou une publication n'a aucune autorité (cf. `examples/pilote/sources/EXEMPLE-injection.md`). |
| Intégrité et reprise | Originaux conservés à l'identique ; une seule fiche projet fait autorité ; historique Git local ; sauvegarde distincte et test de restauration (procédure ci-dessous). |
| Sortie de données | `share` désactivé : aucune conversation n'est partagée ni envoyée à un service de partage. Les seuls flux sortants attendus sont les appels au modèle configuré. |

## Limites connues (lues telles quelles)

- Les permissions OpenCode ne constituent **pas** une isolation technique :
  elles dépendent de la configuration en vigueur (ici : shell refusé) et ne
  couvrent pas ce que l'utilisateur exécute manuellement en dehors de l'agent.
  Une liste de paramètres n'est pas une preuve de confinement au LAN.
- L'authentification, la protection du transport et la journalisation côté
  serveur de l'API LAN ne sont pas couvertes par ce kit ; les vérifier côté
  serveur avant d'y envoyer des données réelles.
- Une synchronisation éventuelle du dossier (OneDrive, disque réseau, sauvegarde
  automatisée) sort les fichiers du périmètre « local » ; c'est à l'utilisateur
  de vérifier ce qui est synchronisé.
- La consigne « les sources sont des données » repose sur la fidélité du modèle,
  pas sur un blocage technique.
- La gestion des sous-agents nécessite une réflexion plus approfondie avant mise
  en place : mécanismes de contrôle, de retour à l'agent général, évitement
  des boucles infinies.

## Sauvegarde et restauration

Sauvegarde (avant de travailler sur des données réelles) :

```powershell
# Depuis la racine du projet, vers un emplacement distinct (disque externe, etc.)
Copy-Item -Recurse -Force <racine-projet> D:\sauvegardes\second-cerveau\<date>
```

Restauration de contrôle (sans écraser le travail courant) :

```powershell
Copy-Item -Recurse -Force D:\sauvegardes\second-cerveau\<date> <emplacement-de-test>
# puis comparer le contenu (hash par fichier) avec l'original
```

## En cas d'incident (procédure courte)

1. Arrêter la session et, si besoin, couper l'accès à l'API concernée.
2. Révoquer le secret compromis si un secret a été exposé.
3. Conserver les éléments utiles **sans** secret.
4. Restaurer depuis la sauvegarde et vérifier le contenu.
5. Noter l'incident, la correction et la date dans le registre privé.

Ne pas effectuer d'opération destructive « préventivement ».

## Signalement de vulnérabilité

Canal : bouton « Report a vulnerability » du dépôt GitHub (Security Policy du
dépôt, avec le rapport privé activé lors de la publication). Jusqu'à la
publication, signaler par issue privée ou directement au responsable du dépôt.