#requires -Version 5.1
<#
.SYNOPSIS
    Recette autonome du publisher sur un faux NAS local, sans Pester.
.DESCRIPTION
    Crée uniquement une zone unique sous le TEMP local. Ne contacte aucun
    partage réseau et ne change aucune tâche planifiée. Les résultats restent
    dans cette zone pour inspection. Aucun nettoyage récursif automatique.
#>
[CmdletBinding()]
param([string]$Publisher)
$ErrorActionPreference = 'Stop'
if (-not $Publisher) { $Publisher = Join-Path (Split-Path -Parent $PSScriptRoot) 'scripts\publier.ps1' }
$Publisher = [IO.Path]::GetFullPath($Publisher)
if (-not [IO.File]::Exists($Publisher)) { throw 'Script de publication introuvable' }
$tempRecette = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
if ($tempRecette.StartsWith('\\')) { throw 'TEMP doit être un disque local, pas un partage réseau' }
$zoneRecette = Join-Path $tempRecette ('second-cerveau-recette-' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($zoneRecette) | Out-Null
$resultats = New-Object 'System.Collections.Generic.List[object]'
$runs = New-Object 'System.Collections.Generic.List[object]'
$script:dernierCode = 0
$script:derniereSortie = ''

function CheminTest([string]$p) {
    $abs = [IO.Path]::GetFullPath($p)
    if (-not $abs.StartsWith($zoneRecette + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "hors zone de test : $abs" }
    return $abs
}
function Ecrire([string]$p, [string]$texte) {
    $p = CheminTest $p
    [IO.Directory]::CreateDirectory((Split-Path -Parent $p)) | Out-Null
    [IO.File]::WriteAllText($p, $texte, (New-Object Text.UTF8Encoding($true)))
}
function Cas([string]$nom) {
    $dir = CheminTest (Join-Path $zoneRecette $nom)
    $v = Join-Path $dir 'vault'; $n = Join-Path $dir 'nas'
    [IO.Directory]::CreateDirectory($v) | Out-Null
    [IO.Directory]::CreateDirectory($n) | Out-Null
    return @{ Vault = $v; NAS = $n }
}
function Document([string]$classification = 'public', [string]$corps = 'Version 1') {
    return "# Document fictif`r`n`r`n- **Classification :** $classification`r`n- **Propriétaire :** Test fictif`r`n`r`n## Contenu`r`n$corps`r`n"
}
function Publier($cas, [hashtable]$options = @{}, [string]$script = $Publisher) {
    $arguments = @{Vault=$cas.Vault; NAS=$cas.NAS}
    foreach ($k in $options.Keys) { $arguments[$k] = $options[$k] }
    $script:derniereSortie = (& $script @arguments *>&1 | Out-String)
    $script:dernierCode = $LASTEXITCODE
    $runs.Add([pscustomobject]@{Options=$arguments; Code=$script:dernierCode; Sortie=$script:derniereSortie})
}
function Verifier([string]$nom, [bool]$condition) {
    $resultats.Add([pscustomobject]@{Test=$nom; Reussi=$condition})
    if (-not $condition) { throw "ECHEC : $nom`r`n$script:derniereSortie" }
    Write-Host "OK : $nom"
}
function MemeFichier([string]$a, [string]$b) {
    return ([IO.File]::Exists($a) -and [IO.File]::Exists($b) -and
        (Get-FileHash -LiteralPath $a).Hash -eq (Get-FileHash -LiteralPath $b).Hash)
}
function Manifest($c) { return (Get-Content -LiteralPath (Join-Path $c.Vault '.publication/manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json) }
function Entree($c, [string]$rel) { return (Manifest $c).fichiers.PSObject.Properties[$rel].Value }
function Instantane([string]$dir) {
    $lignes = foreach ($f in (Get-ChildItem -LiteralPath $dir -Recurse -Force | Sort-Object FullName)) {
        # Rafraîchir les métadonnées : l'énumération NTFS peut conserver un
        # horodatage de dossier antérieur à la création de ses enfants.
        $f.Refresh()
        $hash = if ($f.PSIsContainer) { 'DIR' } else { (Get-FileHash -LiteralPath $f.FullName).Hash }
        '{0}|{1}|{2}|{3}' -f $f.FullName, $hash, $f.CreationTimeUtc.Ticks, $f.LastWriteTimeUtc.Ticks
    }
    return ($lignes -join "`n")
}

try {
    Write-Host "PowerShell : $($PSVersionTable.PSVersion) ; zone : $zoneRecette"
    $rel = 'livrables/guide.md'
    $c = Cas 'cycle'
    $source = Join-Path $c.Vault $rel
    $dest = Join-Path $c.NAS "Developpeurs/$rel"
    Ecrire $source (Document 'public' 'Version 1')
    Publier $c @{Fichier=$rel}
    Verifier 'Premiere publication ciblee : code 0 et deux copies exactes' ($dernierCode -eq 0 -and (MemeFichier $source $dest) -and (MemeFichier $source (Join-Path $c.NAS "Hierarchie/$rel")))
    Verifier 'Notice creee pour chaque role destinataire, aucun acces SSI ajoute' ([IO.File]::Exists((Join-Path $c.NAS 'Hierarchie/NOTICE.md')) -and -not (Test-Path -LiteralPath (Join-Path $c.NAS "SSI/$rel")))
    Verifier 'Manifest version 2 enregistre la destination et les roles' ((Manifest $c).version -eq 2 -and (Entree $c $rel).destination -eq $c.NAS -and (Entree $c $rel).roles.Count -eq 2)
    $nasAvant = Instantane $c.NAS
    $manifestAvant = Get-FileHash -LiteralPath (Join-Path $c.Vault '.publication/manifest.json')
    Publier $c @{Fichier=$rel}
    Verifier 'Deuxieme passage : copies et manifest inchanges' ($dernierCode -eq 0 -and $nasAvant -eq (Instantane $c.NAS) -and $manifestAvant.Hash -eq (Get-FileHash -LiteralPath (Join-Path $c.Vault '.publication/manifest.json')).Hash -and $derniereSortie -match '1 à jour')
    foreach ($version in @(2,3,4)) {
        Ecrire $source (Document 'public' "Version $version")
        Publier $c @{Fichier=$rel}
        Verifier "Mise a jour version $version" ($dernierCode -eq 0 -and (MemeFichier $source $dest))
    }
    $archives = @(Get-ChildItem -LiteralPath (Join-Path $c.NAS 'Developpeurs/_historique') -File)
    $contenus = @($archives | ForEach-Object { [IO.File]::ReadAllText($_.FullName) })
    Verifier 'Trois archives distinctes horodatees, versions 1 a 3 conservees' ($archives.Count -eq 3 -and @($archives | Where-Object Name -NotMatch '^\d{8}_\d{6}_\d{7}_[a-f0-9]{32}_').Count -eq 0 -and ($contenus -join ' ') -match 'Version 1' -and ($contenus -join ' ') -match 'Version 2' -and ($contenus -join ' ') -match 'Version 3')
    [IO.File]::Delete((CheminTest $dest))
    Publier $c @{Fichier=$rel}
    Verifier 'Copie distante supprimee : restauree' ($dernierCode -eq 0 -and (MemeFichier $source $dest))
    Ecrire $dest 'ALTERATION FICTIVE'
    Publier $c @{Fichier=$rel}
    $archives = @(Get-ChildItem -LiteralPath (Join-Path $c.NAS 'Developpeurs/_historique') -File)
    Verifier 'Copie alteree : archivee puis remplacee' ($dernierCode -eq 0 -and (MemeFichier $source $dest) -and @($archives | Where-Object { [IO.File]::ReadAllText($_.FullName) -eq 'ALTERATION FICTIVE' }).Count -eq 1)
    $c.NAS = Join-Path (Split-Path -Parent $c.NAS) 'nas2'
    [IO.Directory]::CreateDirectory((CheminTest $c.NAS)) | Out-Null
    Publier $c @{Fichier=$rel}
    Verifier 'Nouvelle destination : copies creees et manifest actualise' ($dernierCode -eq 0 -and (MemeFichier $source (Join-Path $c.NAS "Developpeurs/$rel")) -and (Entree $c $rel).destination -eq $c.NAS)

    # La matrice est une configuration du script : variante uniquement en TEMP.
    $variante = Join-Path $zoneRecette 'publisher-roles.ps1'
    $code = [IO.File]::ReadAllText($Publisher)
    $codeEtendu = $code.Replace('Livrables      = @("Developpeurs", "Hierarchie")', 'Livrables      = @("Developpeurs", "Hierarchie", "Support")')
    Verifier 'Variante de matrice effectivement construite' ($codeEtendu -ne $code)
    Ecrire $variante $codeEtendu
    Publier $c @{Fichier=$rel} $variante
    Verifier 'Ajout de role : nouvelle copie et nouveau manifest' ($dernierCode -eq 0 -and (MemeFichier $source (Join-Path $c.NAS "Support/$rel")) -and (Entree $c $rel).roles.Count -eq 3)
    Publier $c @{Fichier=$rel}
    Verifier 'Retrait de role : avertissement, aucune suppression silencieuse' ($dernierCode -eq 0 -and $derniereSortie -match 'anciens rôles' -and [IO.File]::Exists((Join-Path $c.NAS "Support/$rel")) -and (Entree $c $rel).roles.Count -eq 2)

    $invalides = [ordered]@{
        'absente' = "# Fictif`n`n## Contenu`nSans classification"
        'inconnue' = (Document 'secret')
        'choix-template' = (Document 'public | interne | confidentiel')
        'choix-slash' = (Document 'public/interne')
        'confidentielle' = (Document 'confidentiel')
        'contradictoire' = "# Fictif`n- **Classification :** public`n- **Classification :** confidentiel`n## Contenu"
        'dupliquee' = "# Fictif`n- **Classification :** public`n- **Classification :** public`n## Contenu"
        'exemple-section' = "# Fictif`n## Exemple`n- **Classification :** public"
        'exemple-code' = ('# Fictif' + "`n" + '```markdown' + "`n- **Classification :** public`n" + '```')
        'exemple-corps' = "# Fictif`nVoici un exemple :`n- **Classification :** public"
        'annotation-ambigue' = (Document 'public — ou confidentiel')
    }
    foreach ($nom in $invalides.Keys) {
        $ic = Cas "refus-$nom"
        Ecrire (Join-Path $ic.Vault $rel) $invalides[$nom]
        Publier $ic @{Fichier=$rel}
        Verifier "Classification $nom : refus sans copie" ($dernierCode -eq 2 -and @(Get-ChildItem -LiteralPath $ic.NAS -Recurse -Force).Count -eq 0)
    }
    foreach ($valeur in @('interne', 'Public — données fictives.', 'public – exemple fictif')) {
        $ac = Cas ('accepte-' + [guid]::NewGuid().ToString('N'))
        Ecrire (Join-Path $ac.Vault $rel) (Document $valeur)
        Publier $ac @{Fichier=$rel}
        Verifier "Classification acceptee : $valeur" ($dernierCode -eq 0)
    }
    $sc = Cas 'synthese'
    Ecrire (Join-Path $sc.Vault 'syntheses/fiche.md') "# Synthèse fictive`n`n> **SYNTHÈSE PRODUITE PAR L'IA** — distincte des sources.`n> Chaque fait renvoie à sa source.`n>`n> - **Classification :** public — données fictives.`n> - **Propriétaire :** Test`n`n## Faits`nExemple"
    Publier $sc @{Fichier='syntheses/fiche.md'}
    Verifier 'Cartouche de synthese citee : accepte' ($dernierCode -eq 0)

    $dc = Cas 'dryrun'
    Ecrire (Join-Path $dc.Vault $rel) (Document)
    $avant = Instantane $zoneRecette
    Publier $dc @{Fichier=$rel;DryRun=$true}
    Verifier 'DryRun vierge : aucun fichier, dossier, hash ou horodatage modifie' ($dernierCode -eq 0 -and $avant -eq (Instantane $zoneRecette) -and $derniereSortie -match 'serait publié')
    Publier $dc @{Fichier=$rel}
    Ecrire (Join-Path $dc.Vault $rel) (Document 'public' 'Version 2')
    $avant = Instantane $zoneRecette
    Publier $dc @{Fichier=$rel;DryRun=$true}
    Verifier 'DryRun avec logs et manifest existants : zero ecriture' ($dernierCode -eq 0 -and $avant -eq (Instantane $zoneRecette))
    $dc.NAS = Join-Path $zoneRecette 'nas-inexistant'
    $avant = Instantane $zoneRecette
    Publier $dc @{Fichier=$rel;DryRun=$true}
    Verifier 'DryRun NAS absent : aucune creation' ($dernierCode -eq 0 -and $avant -eq (Instantane $zoneRecette))
    Ecrire (Join-Path $dc.Vault $rel) (Document 'confidentiel')
    $avant = Instantane $zoneRecette
    Publier $dc @{Fichier=$rel;DryRun=$true}
    Verifier 'DryRun refus : code 2 et aucune ecriture' ($dernierCode -eq 2 -and $avant -eq (Instantane $zoneRecette))

    $pc = Cas 'perimetre'
    Ecrire (Join-Path $pc.Vault 'sources/original.md') (Document)
    $originalAvant = Get-FileHash -LiteralPath (Join-Path $pc.Vault 'sources/original.md')
    Publier $pc @{Fichier='sources/original.md'}
    Verifier 'Source originale refusee et intacte' ($dernierCode -eq 1 -and $originalAvant.Hash -eq (Get-FileHash -LiteralPath (Join-Path $pc.Vault 'sources/original.md')).Hash)
    $hors = Join-Path (Split-Path -Parent $pc.Vault) 'hors.md'
    Ecrire $hors (Document)
    Publier $pc @{Fichier='../hors.md'}
    Verifier 'Chemin hors vault refuse' ($dernierCode -eq 1)

    $fc = Cas 'echec-partiel'
    Ecrire (Join-Path $fc.Vault $rel) (Document)
    [IO.Directory]::CreateDirectory((CheminTest (Join-Path $fc.NAS "Hierarchie/$rel"))) | Out-Null
    Publier $fc @{Fichier=$rel}
    Verifier 'Echec partiel : code 1, une copie possible mais aucun succes global' ($dernierCode -eq 1 -and [IO.File]::Exists((Join-Path $fc.NAS "Developpeurs/$rel")) -and $null -eq (Entree $fc $rel) -and $derniereSortie -notmatch '\[publié\]')

    $ec = Cas 'echec-apres-succes'
    Ecrire (Join-Path $ec.Vault $rel) (Document)
    Publier $ec @{Fichier=$rel}
    Ecrire (Join-Path $ec.Vault $rel) (Document 'public' 'Version modifiee')
    $verrou = [IO.File]::Open((Join-Path $ec.NAS "Hierarchie/$rel"), 'Open', 'ReadWrite', 'None')
    try { Publier $ec @{Fichier=$rel} }
    finally { $verrou.Dispose() }
    Verifier 'Echec apres succes : ancien enregistrement invalide' ($dernierCode -eq 1 -and $null -eq (Entree $ec $rel))
    Publier $ec @{Fichier=$rel}
    Verifier 'Reprise apres echec : toutes les copies verifiees' ($dernierCode -eq 0 -and (MemeFichier (Join-Path $ec.Vault $rel) (Join-Path $ec.NAS "Hierarchie/$rel")))

    $auto = Cas 'automatique'
    Ecrire (Join-Path $auto.Vault 'projets/P001-fictif.md') "# P001 — fictif`n- **Classification :** public`n- **État :** terminé`n`n## Journal`nFictif"
    Ecrire (Join-Path $auto.Vault 'projets/P002-fictif.md') "# P002 — fictif`n- **Classification :** public`n- **État :** en cours`n`n## Journal`nFictif"
    Ecrire (Join-Path $auto.Vault $rel) (Document 'public' 'Lie au projet P001')
    Publier $auto
    Verifier 'Mode automatique : projet termine et livrable lie uniquement' ($dernierCode -eq 0 -and [IO.File]::Exists((Join-Path $auto.NAS "Developpeurs/$rel")) -and [IO.File]::Exists((Join-Path $auto.NAS 'Support/projets/P001-fictif.md')) -and -not (Test-Path -LiteralPath (Join-Path $auto.NAS 'Support/projets/P002-fictif.md')))
    Publier $auto @{Projets=@('P002')}
    Verifier 'Restriction a un projet non termine : rien a publier' ($dernierCode -eq 0 -and $derniereSortie -match 'rien à publier')
    Ecrire (Join-Path $auto.Vault '.publication/manifest.json') '{invalide'
    $avant = Instantane $auto.NAS
    Publier $auto
    Verifier 'Manifest illisible : code 1 et NAS intact' ($dernierCode -eq 1 -and $avant -eq (Instantane $auto.NAS))

    Write-Host "REUSSITE : $($resultats.Count)/$($resultats.Count) controles"
} catch {
    Write-Host $_.Exception.Message
    $resultats.Add([pscustomobject]@{Test='Execution complete';Reussi=$false;Erreur=$_.Exception.Message})
} finally {
    $rapport = [pscustomobject]@{
        PowerShell=$PSVersionTable.PSVersion.ToString()
        PublisherSHA256=(Get-FileHash -LiteralPath $Publisher).Hash
        Resultats=@($resultats.ToArray())
        Executions=@($runs.ToArray())
    }
    Ecrire (Join-Path $zoneRecette 'resultats.json') ($rapport | ConvertTo-Json -Depth 8)
    Write-Host "Rapport : $(Join-Path $zoneRecette 'resultats.json')"
}
if (@($resultats | Where-Object { -not $_.Reussi }).Count) { exit 1 }
exit 0
