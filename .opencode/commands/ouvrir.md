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
5. Si je choisis la création :
   1. demande-moi l'**objectif**, le **critère de fin**, la **classification** et
      le **propriétaire**. Un critère de fin doit être observable : s'il est
      vague, demande une précision avant d'écrire. Si son décompte diffère du
      nombre de livrables énumérés, **ne conclus pas à une erreur** — c'est
      souvent un seuil voulu (« 3 des 4 suffisent »). Demande lequel, puis
      inscris le seuil explicitement ;
   2. prends le premier identifiant libre (`P001`, `P002`, …) ;
   3. copie `templates/projet.md` dans le dossier `projets/` et ne renseigne
      **que** ce que je t'ai donné : le reste « indéterminé », état `à lancer`,
      aucune tâche ;
   4. **retire du résultat tout ce qui appartient au gabarit** : textes entre
      chevrons, lignes d'aide (« États possibles : … », « Date = … »), et tout
      marqueur de date ou d'heure non remplacé. Un `HHhmm:ss` ou un `AAAA-MM-JJ`
      laissé tel quel est un défaut : utilise la date et l'heure réelles ;
   5. **actualise `index.md`** (le projet y figure) **et `log.md`** (une ligne
      datée : création, identifiant, classification). Sans ça le vault annonce
      un état faux ;
   6. puis réponds.

C'est la seule écriture permise par cette commande, et seulement après mon choix.

## Réponse — quelques lignes, pas plus

Classification · objectif · critère de fin · état · dernière action connue avec
sa date · blocage éventuel et l'identifiant de sa tâche · prochaine action,
**avec sa mention « proposée » ou « décidée » reprise telle quelle**.

Signale, sans rien modifier :

- une **revue échue** (date de prochaine revue dépassée) ;
- une **classification manquante** : demande-la avant d'écrire quoi que ce soit
  dans cette fiche par la suite.

Élément absent de la fiche → « indéterminé ». Fiche introuvable → dis-le.
N'invente rien.
