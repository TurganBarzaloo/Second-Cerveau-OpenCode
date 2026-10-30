---
description: Publier sur le NAS les éléments validés (fiches terminées, ou cible désignée)
---

Cible donnée, éventuellement vide : $ARGUMENTS

## 1. Cerner la cible

- **Vide** : tout ce qui est éligible — les fiches projet à l'état `terminé`
  et les synthèses ou livrables qui les référencent.
- **Un identifiant `PXXX`** : relire l'état de la fiche. État `terminé` :
  continuer. Autre état : le dire, rappeler que la publication forcée
  contournerait le garde-fou d'état (jamais celui de la classification), et
  **STOP — attends ma réponse**.
- **Un chemin de fichier** : publication ciblée ; l'état du projet est
  ignoré, la classification reste opposable.

## 2. Prévisualiser — rien n'est écrit

Depuis la racine du vault, utiliser l'appel canonique ci-dessous. Le profil
d'exemple refuse le reste du shell ; cet appel est soumis à confirmation.
Ne pas utiliser `--auto`, « always » ni contourner un refus. Si l'appel est
bloqué, rapporter le refus et attendre la décision du propriétaire :

```
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/publier.ps1 -DryRun
```

avec `-Projets PXXX` ou `-Fichier <chemin>` selon la cible. Relayer
fidèlement la sortie : ce qui serait publié et vers quels rôles, ce qui est
déjà à jour, chaque refus avec son motif.

## 3. Publier — seulement après ma validation

Relancer la même commande sans `-DryRun`, puis :

- code de sortie **2** : des refus existent (confidentiel, classification
  absente, inconnue ou ambiguë) ; les signaler tels quels, ce n'est pas une erreur technique ;
- code de sortie **1** : rapporter le message d'erreur et la fin du log,
  n'écrire dans aucun fichier ;
- code de sortie **0** : pour **chaque fiche projet publiée**, ajouter une
  ligne au journal de sa fiche, à la forme du template
  (`Date du compte rendu` = aujourd'hui, `Exécution` = aujourd'hui, fait :
  « publication NAS : <n> fichiers (<liste brève>) — [SYNC] »), et actualiser
  « Mise à jour le » dans son cartouche. Aucune autre écriture.

## 4. Rendre compte

Fichiers publiés et rôles destinataires · refus et motif · code de sortie ·
log du jour en exécution réelle (`logs/publication-AAAA-MM-JJ.log`).
En `-DryRun`, console uniquement : aucun journal ni manifest modifié.
Rien à publier : le dire,
n'écrire dans aucun fichier.
