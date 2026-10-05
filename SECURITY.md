# Sécurité (SECURITY.md)

- **Organisation :** Racines Systèmes — second-cerveau-opencode
- **Référence :** SEC-001
- **Classification :** Public
- **Version :** 1.0
- **Date d'application :** 04/10/2026
- **Propriétaire :** Stéphane Muraro
- **Approbateur :** Stéphane Muraro
- **Prochaine révision :** 04/10/2027
- **État :** approuvé

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

## Mesures

| Sujet | Mesure |
| --- | --- |
| Données | Les exemples contenus dans le dépôt sont 100 % fictifs. Les données réelles se gardent dans un vault privé séparé du dépôt. |
| Secrets | Jamais de clé ni d'adresse réelle dans un fichier versionné. La config exemple lit la clé depuis une variable d'environnement ; la config locale réelle est exclue de Git. |
| Accès de l'agent | `bash`, `task` et `websearch` refusés, pas de plugin ni MCP. L'édition est refusée sur les originaux (`sources/`), les modèles et la configuration ; elle est autorisée ailleurs, notamment dans `livrables/`. `external_directory` refusé : rien hors du projet, ce qui couvre la configuration globale d'OpenCode. Les commandes système (git, sauvegarde) s'exécutent manuellement hors agent. |
| Accès web | `webfetch` en `ask`, avec liste blanche de domaines : chaque récupération hors liste demande un accord explicite. C'est OpenCode qui télécharge la page depuis le poste — le contenu ne quitte pas le réseau local, seule l'URL visée est connue du site visité. `websearch` refusé : il ne fonctionne pas avec un fournisseur local et exigerait un service tiers. |
| Sources distantes | Une page consultée ne peut pas être conservée comme original. Elle est enregistrée via `templates/source-web.md` : URL, date de consultation, passages utilisés, nature de la source et instructions éventuellement rencontrées. Sans cette fiche, une affirmation perd son origine dès que la page change. |
| Sobriété de lecture | `read`, `glob` et `grep` passent par une liste blanche de chemins, le reste en `ask`. Rien ne peut être lu ni ratissé silencieusement. Limite : voir ci-dessous. |
| Contenu importé | Le contenu des documents est traité comme des données, jamais comme des consignes : une source qui demande une commande, un secret ou une publication n'a aucune autorité (cf. `examples/pilote/sources/EXEMPLE-injection.md`). |
| Intégrité et reprise | Originaux conservés à l'identique ; une seule fiche projet fait autorité ; historique Git local ; sauvegarde distincte et test de restauration (procédure ci-dessous). |
| Sortie de données | `share` désactivé : aucune conversation n'est partagée ni envoyée à un service de partage. Les seuls flux sortants attendus sont les appels au modèle configuré. |

## Limites connues (lues telles quelles)

- Les permissions OpenCode ne constituent **pas** une isolation technique :
  elles dépendent de la configuration en vigueur (ici : shell refusé) et ne
  couvrent pas ce que l'utilisateur exécute manuellement en dehors de l'agent.
  Une liste de paramètres n'est pas une preuve de confinement au LAN.
- **`bash: "deny"` n'épuise pas les voies d'exécution.** En essai, le modèle a
  déclenché un outil `execute` évaluant du code (`tools.opencode.session_move`)
  alors que le shell était refusé. Cet outil ne figure pas dans la liste de
  permissions documentée. Ne pas présenter le refus du shell comme une garantie
  qu'aucun code ne s'exécute.
- **L'accès web élargit réellement la surface d'attaque.** Tant que `webfetch`
  était refusé, le scénario d'injection restait théorique. Il est désormais
  effectif : toute page récupérée est un texte d'auteur inconnu qui peut tenter
  de commander l'agent. La protection repose sur `AGENTS.md`, donc sur la
  fidélité du modèle — pas sur un blocage technique. En essai, un modèle s'est
  inventé une exception à une règle écrite « sans exception », et a proposé à
  l'utilisateur de contourner lui-même un refus de permission. Accordez les
  domaines un par un, et ne laissez pas `webfetch` en `allow` général.
- **`websearch` : ce qu'il fait exactement.** OpenCode le réserve à ses propres
  fournisseurs hébergés, ou l'active via `OPENCODE_ENABLE_EXA` /
  `OPENCODE_ENABLE_PARALLEL`. Dans ce cas, selon sa documentation, « the tool
  connects directly to the backend's hosted MCP service without authentication ».
  Quatre faits en découlent, à peser vous-même :
  1. **Un flux sortant vers un tiers hébergé** apparaît — le seul de
     l'installation, puisque le modèle est local.
  2. **La requête n'est pas rédigée par vous mais par le modèle**, à partir de son
     contexte : fiche projet, synthèses, corpus. Dans un navigateur vous savez ce
     qui sort ; ici, vous ne choisissez pas la formulation.
  3. **Une requête est plus révélatrice qu'une URL.** `webfetch` indique à un site
     qu'une page a été consultée ; une requête indique à un tiers ce que vous
     cherchez à savoir, dans vos termes.
  4. **« Sans authentification » n'est pas « anonyme ».** Aucun compte, donc rien
     n'est rattaché à une identité — mais l'adresse IP part, et surtout il n'y a
     **aucun contrat** : pas de conditions acceptées, pas de responsable de
     traitement identifié, pas de rétention annoncée ni de droit à l'effacement.
     Un sous-traitant sans conditions lisibles est plus difficile à documenter
     qu'un fournisseur sous contrat.

  Ce n'est pas une faille, c'est un compromis. En `ask`, chaque appel demande
  votre accord ; vérifiez à la première requête si OpenCode vous la **montre**
  avant l'envoi — si oui, l'objection 2 tombe en grande partie. Si vous l'activez,
  consignez-le au registre avec ces quatre faits. Une alternative réellement
  souveraine existe : voir « Recherche souveraine » dans le README.
- **La sobriété de lecture reste partiellement déclarative.** Les permissions
  s'appliquent à la session, pas à la commande : `/ouvrir` ne peut donc pas être
  rendu plus strict que `/clore`, qui a besoin des sources et des synthèses. En
  essai, l'agent a lu 4 fichiers du pilote pour en ouvrir un seul — autorisé par
  la liste blanche. Les permissions bornent le périmètre extérieur ; à
  l'intérieur, la sobriété dépend de la docilité du modèle.
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