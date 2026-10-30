---
name: revue-publication
description: Examiner des fichiers avant une publication Git publique ou un partage NAS, sans publier ni modifier leur classification.
---

# Revue avant publication

Utiliser quand l'utilisateur demande de vérifier ce qui pourrait être partagé ou publié. Identifier les fichiers et la destination : Git public et NAS d'équipe ont des règles de diffusion différentes. Si la destination ou le périmètre est ambigu, demander la précision avant de conclure.

- Pour Git public, vérifier la liste exacte des fichiers suivis et envisagés, les fichiers non suivis que l'on prévoit d'ajouter et les exclusions. Un fichier `interne`, `confidentiel` ou de classification non établie n'est pas publiable. `.gitignore` n'exclut pas un fichier déjà suivi. Examiner également la portée de l'historique si celui-ci est destiné à être publié ; dire si elle n'a pas pu être contrôlée.
- Pour le NAS, lire `PUBLICATION-NAS.md`, la matrice des rôles et la classification initiale de chaque fichier. Les niveaux `public` et `interne` peuvent être éligibles pour les destinataires prévus ; `confidentiel`, absent ou ambigu sont refusés. Signaler qu'une ancienne copie ou archive peut subsister après une reclassification ou un retrait de rôle.
- Rechercher les secrets, données personnelles, adresses internes, droits et conditions de redistribution pertinents sans reproduire une valeur sensible dans le rapport. Une recherche limitée ne prouve pas l'absence de fuite.
- Rapporter ce qui peut partir, les refus, les incertitudes et les vérifications manquantes. Une étiquette seule ne prouve pas que le contenu est publiable. Le skill ne change ni la classification ni l'index Git et ne publie rien ; pour une publication NAS utiliser `/publie` avec prévisualisation et validation. Respecter les permissions et ne pas contourner un refus.
