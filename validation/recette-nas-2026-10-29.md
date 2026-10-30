# Recette locale des corrections de publication NAS — 29 octobre 2026

- **Organisation :** Racines Systèmes — second-cerveau-opencode
- **Référence :** REC-NAS-2026-10-29
- **Classification :** public — scénarios et données entièrement fictifs
- **Version :** 1.0
- **Date de rédaction :** 29/10/2026
- **Propriétaire :** Stéphane Muraro
- **Approbateur :** approbation non recueillie
- **Prochaine révision :** avant déploiement sur un NAS réel
- **État :** résultats techniques constatés ; approbation de production non acquise

## Résultat et périmètre

**41 contrôles sur 41 réussis**, code de sortie 0, sous Windows PowerShell
**5.1.26100.9711**. La recette exécute le script de publication sur des
dossiers temporaires locaux distincts (vault fictif et faux NAS).
Aucun partage réseau, modèle, fournisseur IA ou tâche planifiée n'est utilisé.

SHA-256 du script `scripts/publier.ps1` testé :
`EBF767F68DDBB4381FF81EB3FC76C0BFB46F49165D4168E19E6E28556426F355`

Les scripts de publication et de planification ainsi que la recette passent
l'analyse syntaxique ; leur encodage est UTF-8 avec BOM. Le script de
planification n'a pas été exécuté et n'a pas été modifié.

## Reproduire

Depuis la racine du kit, dans un terminal Windows PowerShell 5.1 :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/publication-nas.tests.ps1
```

Le test crée sa propre zone unique sous le TEMP local. Le chemin du rapport
`resultats.json` est affiché en fin d'exécution. Ce JSON contient la version de
PowerShell, le hash du publisher, chaque contrôle et la sortie des exécutions.
Les données fictives sont conservées dans cette zone pour inspection.
Le test n'effectue aucun nettoyage récursif et ne modifie pas le kit.

## Preuves couvertes

| Domaine | Vérifications réussies |
| --- | --- |
| Première publication | Deux copies de livrable exactes, notices des rôles destinataires, absence de copie SSI, manifest avec destination et rôles |
| Idempotence | Deuxième passage sans copie ni modification du manifest ; fichiers et horodatages du faux NAS identiques |
| Archives | Versions 1 à 3 conservées séparément après trois mises à jour ; noms horodatés uniques ; archivage d'une copie altérée |
| Réparation | Restauration d'une copie supprimée, remplacement d'une copie altérée, alimentation d'une nouvelle destination |
| Rôles | Ajout de Support dans une variante temporaire du script ; retrait signalé sans suppression silencieuse des anciennes copies |
| Classification | Refus des valeurs absentes, inconnues, confidentielles, multiples, contradictoires ou dupliquées ; refus d'une classification placée seulement dans le corps, une section ou un bloc de code |
| Cartouches acceptés | `interne`, casse différente, annotation après tiret et cartouche de synthèse en citation |
| DryRun | Aucun changement de fichiers, dossiers, hashes ou horodatages de création/modification ; cas vierge, manifest/journal existants, NAS absent et refus de classification |
| Périmètre | Refus d'une source originale, source intacte, refus d'un chemin sortant du vault |
| Erreurs | Échec d'un seul rôle : code 1 et absence du fichier au manifest ; invalidation d'un succès antérieur ; reprise réussie après levée du blocage |
| Mode automatique | Projet terminé et livrable associé copiés ; projet en cours non éligible ; restriction par identifiant respectée |
| Manifest corrompu | Code 1 et faux NAS inchangé |

L'instantané de contrôle rafraîchit les métadonnées des entrées NTFS avant
comparaison. Les dates d'accès, susceptibles d'évoluer lors d'une simple lecture,
ne sont pas utilisées comme preuve d'écriture.

## Corrections et journal du 29/10/2026

- `scripts/publier.ps1` : cartouche initial strict, instantané des octets source,
  archives uniques sans écrasement, copies distantes vérifiées, destination et
  rôles dans le manifest, prévisualisation sans écriture et gestion des erreurs
  partielles. Manifest remplacé atomiquement, compatible PowerShell 5.1.
- `.gitignore` : exclusions ciblées de quatre documents internes, sans
  suppression ni changement de classification. Les commandes réutilisables
  restent distribuables. Aucun de ces quatre fichiers n'était suivi par Git
  lors du contrôle préalable ; aucune modification de l'index n'est requise.
- `AGENTS.md`, `README.md`, `SECURITY.md`, `PUBLICATION-NAS.md` et
  `opencode.example.jsonc` : détails d'installation retirés, permissions et
  statut harmonisés ; nouveaux scripts protégés contre l'édition par l'agent.
- Commandes `publie.md` et `clore.md`, dans `.opencode/commands/` et leurs
  copies dans `livrables/commandes/` : instructions harmonisées, refus et erreurs
  distingués d'un état « à jour ».
- `tests/publication-nas.tests.ps1` et ce rapport : recette reproductible et
  preuves locales. Base des écritures : défauts reproduits et tests exécutés.

## Limites et validations restantes

- Les rapports V0 des 12 et 13 octobre sont conservés sans modification : ils
  portent sur le socle antérieur, pas sur les ajouts NAS ni les permissions modifiées.
- La syntaxe des permissions a été rapprochée de la
  [documentation officielle OpenCode](https://opencode.ai/docs/permissions/),
  consultée le 29/10/2026. Le JSONC d'exemple est syntaxiquement valide.
  Aucune session TUI n'a été exécutée avec cette nouvelle configuration ; sa
  fusion avec les réglages globaux et les agents reste à vérifier.
- Aucun test SMB réel, ACL de partage, transport, panne réseau ou déclenchement
  planifié. La recette locale ne vaut pas autorisation de production.
- Les publications concurrentes d'un même vault ne sont pas prises en charge.
  Le manifest atomique n'est pas un verrou de coordination.
- Le retrait d'un rôle ou une reclassification ne supprime pas les copies et
  archives déjà diffusées : revue et retrait manuels nécessaires.
- La classification reste déclarative. Les formats binaires sans cartouche
  textuel ne disposent pas d'un parseur dédié. Les liens et jonctions sont refusés.
- La recherche de références internes et de motifs courants de secrets ne
  constitue pas un audit exhaustif des données ou de tout l'historique Git.

Le kit peut être proposé avec ces limites explicites et les ajouts NAS présentés
en validation. Une version annoncée stable sur NAS exige encore une recette
réelle et une approbation du propriétaire.
