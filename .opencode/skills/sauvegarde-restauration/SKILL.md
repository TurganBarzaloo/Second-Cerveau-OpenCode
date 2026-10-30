---
name: sauvegarde-restauration
description: Préparer et vérifier une sauvegarde du vault ou une restauration de contrôle dans un emplacement distinct, sans écraser les données de production.
---

# Sauvegarde et restauration

Utiliser pour examiner une sauvegarde ou préparer une restauration de contrôle. Identifier le périmètre, la source, la destination et les droits applicables. Si une destination ou une sauvegarde ne peut pas être identifiée de manière sûre, demander les informations manquantes. Ne pas inventer une réussite.

1. Proposer une copie distincte de la source, adaptée à la classification des données, puis une restauration dans un nouveau répertoire de test distinct de la source et de la sauvegarde. Ne jamais exposer les secrets ou chemins sensibles dans un rapport public.
2. Avant toute commande qui copie, écrase, supprime, déplace ou transmet des données, préciser les chemins, le contenu, les effets et le retour arrière, puis obtenir la confirmation requise par `AGENTS.md`. Respecter les permissions effectives ; un refus shell n'est pas contournable. Ne pas installer d'outil ni modifier une tâche planifiée sans autorisation applicable.
3. Comparer les fichiers restaurés à la sauvegarde par liste et empreinte lorsque les outils disponibles le permettent ; rapporter les absences, erreurs et limites. Vérifier aussi que la destination est distincte et que les originaux n'ont pas été altérés.
4. Fournir un bilan daté : périmètre, méthode, résultat réellement observé et emplacement de la trace appropriée. Une comparaison réussie n'établit pas la disponibilité future ni la sécurité de la sauvegarde. Enregistrer un bilan seulement si demandé, avec classification et trace adaptées.
