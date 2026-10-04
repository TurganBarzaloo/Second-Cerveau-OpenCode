---
description: Ouvrir une séance sur une fiche projet (lecture seule, sauf création demandée)
---

Fiche visée : $ARGUMENTS

## Si $ARGUMENTS contient un chemin

Lis **cette seule fiche**. Rien d'autre : ni index, ni journal, ni source, ni
autre fiche. N'écris dans aucun fichier. Puis réponds selon le format ci-dessous.

## Si $ARGUMENTS est vide

1. Repère les fiches de `projets/`, sinon de `examples/pilote/projets/`. Pour
   rester sobre, recherche les lignes `- **Identifiant :**`, `- **Objectif :**`
   et `- **État :**` au lieu d'ouvrir les fiches.
2. Garde celles dont l'état n'est ni `terminé` ni `abandonné`. État absent ou
   non reconnu : garde la fiche et signale-le.
3. Affiche le choix, puis **STOP — attends ma réponse, n'écris rien :**

   ```
   1. P001 — <titre> — <état>
   N. Créer une nouvelle fiche projet
   ```

   Aucune fiche trouvée : dis-le, propose seulement la création.
4. Si je choisis une fiche existante : lis-la, puis réponds.
5. Si je choisis la création : demande-moi l'objectif et le critère de fin,
   prends le premier identifiant libre (`P001`, `P002`, …), copie
   `templates/projet.md` dans le dossier `projets/`, ne renseigne **que** ce que
   je t'ai donné (le reste « indéterminé », état `à lancer`, aucune tâche), puis
   réponds.

C'est la seule écriture permise par cette commande, et seulement après mon choix.

## Réponse — quelques lignes, pas plus

Objectif · critère de fin · état · dernière action connue avec sa date ·
blocage éventuel et l'identifiant de sa tâche · prochaine action, **avec sa
mention « proposée » ou « décidée » reprise telle quelle**.

Élément absent de la fiche → « indéterminé ». Fiche introuvable → dis-le.
N'invente rien.
