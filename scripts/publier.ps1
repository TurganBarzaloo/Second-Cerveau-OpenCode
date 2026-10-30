<#
.SYNOPSIS
    Publie les éléments validés du vault vers le wiki partagé du NAS.

.DESCRIPTION
    Flux unidirectionnel : le vault local est la source, le NAS une
    destination. Règles détaillées : PUBLICATION-NAS.md.

    Modes :
      - automatique (défaut) : les fiches projet à l'état « terminé » et les
        synthèses / livrables qui les référencent ;
      - -Projets PXXX : idem, restreint aux identifiants donnés ;
      - -Fichier <chemin> : publication ciblée (l'état du projet est ignoré,
        la classification non).

    Garde-fous (jamais contournables) :
      - un fichier sans classification, ou classé « confidentiel », est refusé ;
      - rien n'est supprimé du NAS : la version existante est archivée dans
        _historique/ avant d'être remplacée.

    Codes de sortie :
      0  succès (y compris « rien à publier »)
      1  erreur bloquante (NAS inaccessible, copie non vérifiée, manifest illisible)
      2  au moins un refus de publication (classification)

.EXAMPLE
    .\publier.ps1 -DryRun
.EXAMPLE
    .\publier.ps1 -Projets P001 -NAS \\NAS\WikiPartage
.EXAMPLE
    .\publier.ps1 -Fichier "livrables\guide-utilisateur.md"

.NOTES
    Conserver ce fichier en UTF-8 avec BOM : les accents des cartouches
    (« État ») font partie des motifs de reconnaissance.
#>
#requires -Version 5.1
[CmdletBinding()]
param(
    [string[]]$Projets,
    [string]$Fichier,
    [string]$NAS,
    [string]$Vault,
    [switch]$DryRun
)

# ============================ CONFIGURATION =============================
# Partage racine du wiki partagé (à adapter par installation, ou via -NAS).
$NASDefaut = "\\NAS\WikiPartage"

# Matrice de visibilité : type de document -> rôles destinataires.
#   Documentation  : projets/ + syntheses/
#   Livrables      : livrables/ hors dossiers tableaux-de-bord/
#   TableauxDeBord : livrables/tableaux-de-bord/
$Matrice = @{
    Documentation  = @("Developpeurs", "Hierarchie", "SSI", "Support")
    Livrables      = @("Developpeurs", "Hierarchie")
    TableauxDeBord = @("Developpeurs", "Hierarchie", "SSI", "Support")
}
$TousLesRoles = @("Developpeurs", "Hierarchie", "SSI", "Support")
# =========================================================================

$ErrorActionPreference = "Stop"

if (-not $Vault) { $Vault = Split-Path -Parent $PSScriptRoot }
if (-not $NAS)   { $NAS = $NASDefaut }
$NAS = [System.IO.Path]::GetFullPath($NAS).TrimEnd('\', '/')
$Vault = [System.IO.Path]::GetFullPath($Vault).TrimEnd('\', '/').Replace('\', '/')
$DateJour     = Get-Date -Format "yyyy-MM-dd"
$LogDir       = Join-Path $Vault "logs"
$LogFile      = Join-Path $LogDir "publication-$DateJour.log"
$ManifestPath = Join-Path $Vault ".publication/manifest.json"

function Log([string]$niveau, [string]$msg) {
    if ($DryRun) {
        Write-Host ("{0} [{1}] {2}" -f (Get-Date -Format "HH:mm:ss"), $niveau, $msg)
        return
    }
    $horaire = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if (-not (Test-Path -LiteralPath $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    [System.IO.File]::AppendAllText($LogFile, "$horaire $niveau : $msg`r`n", (New-Object System.Text.UTF8Encoding($false)))
    Write-Host ("{0} [{1}] {2}" -f (Get-Date -Format "HH:mm:ss"), $niveau, $msg)
}

function CheminRelatif([string]$chemin) {
    # Join-Path (PS 5.1) concatène un chemin enfant absolu : le traiter à part.
    if ([System.IO.Path]::IsPathRooted($chemin)) {
        $abs = [System.IO.Path]::GetFullPath($chemin)
    } else {
        $abs = [System.IO.Path]::GetFullPath((Join-Path $Vault ($chemin.Replace('/', '\'))))
    }
    $rel = $abs.Replace('\', '/').TrimEnd('/')
    if (-not $rel.StartsWith($Vault + "/", [StringComparison]::OrdinalIgnoreCase)) {
        throw "fichier hors du vault : $chemin"
    }
    VerifierCheminSansLien $abs
    if ($rel.Substring($Vault.Length + 1) -match '[:*?]') { throw "chemin non pris en charge : $chemin" }
    return $rel.Substring($Vault.Length + 1)
}

function CheminAbsolu([string]$rel) {
    return (Join-Path $Vault ($rel.Replace('/', '\')))
}

function TypeDeDocument([string]$rel) {
    # -match est insensible à la casse sous Windows
    if ($rel -match '^projets/[^/]+')             { return "Documentation" }
    if ($rel -match '^syntheses/[^/]+')           { return "Documentation" }
    if ($rel -match '^livrables/tableaux-de-bord/') { return "TableauxDeBord" }
    if ($rel -match '^livrables/')                { return "Livrables" }
    return $null
}

function VerifierCheminSansLien([string]$chemin) {
    # Refuse les jonctions/liens, même lorsque leur cible reste dans le vault.
    $p = [IO.Path]::GetFullPath($chemin)
    while ($p) {
        if (Test-Path -LiteralPath $p) {
            $item = Get-Item -LiteralPath $p -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "lien ou jonction refusé : $p"
            }
        }
        $parent = Split-Path -Parent $p
        if ($parent -eq $p) { break }
        $p = $parent
    }
}

function CartoucheDe([string]$texte) {
    # Cartouche initial seulement : titre H1 facultatif, préambule cité,
    # champs en liste et lignes vides. Le corps, les sections et le code
    # arrêtent la lecture ; leur classification ne peut pas autoriser la copie.
    $debut = $true
    foreach ($ligne in ($texte -split '\r?\n')) {
        if ($ligne -match '^\s*$' -or $ligne -match '^>\s*$') { continue }
        if ($debut -and $ligne -match '^# [^#]') { $debut = $false; continue }
        $debut = $false
        if ($ligne -match '^\s*>?\s*(```|~~~|#{1,6}\s)') { break }
        if ($ligne -match '^\s*>?\s*-\s+\*\*[^*]+') { $ligne; continue }
        if ($ligne -match '^>\s*(?![-*]?\s*Classification\b)') { continue }
        break
    }
}

function ValeursChamp([string]$texte, [string]$champ) {
    $motif = '^\s*>?\s*-\s+\*\*' + [regex]::Escape($champ) + '\s*(?::\s*\*\*|\*\*\s*:)\s*(.*?)\s*$'
    foreach ($ligne in @(CartoucheDe $texte)) {
        $m = [regex]::Match($ligne, $motif, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($m.Success) { $m.Groups[1].Value }
    }
}

function EtatDe([string]$texte) {
    $valeurs = @(ValeursChamp $texte 'État')
    if ($valeurs.Count -eq 0) { $valeurs = @(ValeursChamp $texte 'Etat') }
    if ($valeurs.Count -eq 1) { return $valeurs[0].Trim() }
    return ""
}

function ClassificationDe([string]$texte) {
    $valeurs = @(ValeursChamp $texte 'Classification')
    if ($valeurs.Count -ne 1) { return $null }
    # Annotation explicative après un tiret cadratin/semi-cadratin seulement.
    # Aucun choix multiple, placeholder, second niveau ou doublon de champ.
    $m = [regex]::Match($valeurs[0], '^(public|interne|confidentiel)(?:\s+[—–]\s+(.+))?$', 'IgnoreCase')
    if (-not $m.Success) { return $null }
    if ($m.Groups[2].Success -and $m.Groups[2].Value -match '(?i)\b(public|interne|confidentiel)\b|[|<>\[\]]') { return $null }
    return $m.Groups[1].Value.ToLowerInvariant()
}

function ReferenceProjet([string]$texte, [string]$id) {
    return [regex]::IsMatch($texte, "(?<![A-Za-z0-9])$id(?![A-Za-z0-9])")
}

function HashDe([string]$chemin) {
    return (Get-FileHash -LiteralPath $chemin -Algorithm SHA256).Hash
}

function ChargerManifest {
    if (-not (Test-Path -LiteralPath $ManifestPath)) { return @{ version = 2; fichiers = @{} } }
    $j = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($null -eq $j -or $j.version -notin @(1, 2) -or $null -eq $j.fichiers -or
        $j.fichiers -isnot [pscustomobject]) { throw "manifest invalide ou version inconnue" }
    $f = @{}
    foreach ($p in $j.fichiers.PSObject.Properties) { $f[$p.Name] = $p.Value }
    return @{ version = 2; fichiers = $f }
}

function SauverManifest($m) {
    $dir = Split-Path -Parent $ManifestPath
    [IO.Directory]::CreateDirectory($dir) | Out-Null
    $objF = [ordered]@{}
    foreach ($k in ($m.fichiers.Keys | Sort-Object)) { $objF[$k] = [pscustomobject]$m.fichiers[$k] }
    $doc = [pscustomobject]@{
        version = 2
        miseAJourLe = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        fichiers = [pscustomobject]$objF
    }
    $tmp = Join-Path $dir (([guid]::NewGuid().ToString('N')) + '.tmp')
    try {
        [IO.File]::WriteAllText($tmp, ($doc | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
        if ([IO.File]::Exists($ManifestPath)) { [IO.File]::Replace($tmp, $ManifestPath, [NullString]::Value) }
        else { [IO.File]::Move($tmp, $ManifestPath) }
    } finally {
        if ([IO.File]::Exists($tmp)) { [IO.File]::Delete($tmp) }
    }
}

function EstAJour($ancien, [string]$hash, [string]$rel, [string[]]$roles) {
    if (-not $ancien -or $ancien.hash -ne $hash -or $ancien.destination -ne $NAS) { return $false }
    if ((@($ancien.roles | Sort-Object) -join '|') -ne (@($roles | Sort-Object) -join '|')) { return $false }
    foreach ($r in $roles) {
        $dest = Join-Path (Join-Path $NAS $r) $rel
        VerifierCheminSansLien $dest
        if (-not [IO.File]::Exists($dest) -or (HashDe $dest) -ne $hash) { return $false }
        if (-not [IO.File]::Exists((Join-Path (Join-Path $NAS $r) 'NOTICE.md'))) { return $false }
    }
    return $true
}

function PreparerRole([string]$role) {
    $dir = Join-Path $NAS $role
    VerifierCheminSansLien $dir
    [IO.Directory]::CreateDirectory($dir) | Out-Null
    $notice = Join-Path $dir 'NOTICE.md'
    VerifierCheminSansLien $notice
    if (-not (Test-Path -LiteralPath $notice)) {
        [IO.File]::WriteAllText($notice, "# Notice — copie publiée`r`n`r`nCopie alimentée depuis le vault. Ne pas modifier ici : toute évolution passe par le vault. Une copie altérée est archivée puis remplacée à la publication suivante.`r`n", (New-Object Text.UTF8Encoding($true)))
    } elseif (-not [IO.File]::Exists($notice)) { throw "notice invalide : $notice" }
}

function Archiver([string]$dest, [string]$role, [string]$rel) {
    $dir = Join-Path (Join-Path $NAS $role) '_historique'
    VerifierCheminSansLien $dir
    [IO.Directory]::CreateDirectory($dir) | Out-Null
    $nom = '{0}_{1}_{2}' -f (Get-Date -Format 'yyyyMMdd_HHmmss_fffffff'), ([guid]::NewGuid().ToString('N')), ($rel -replace '/', '__')
    $archive = Join-Path $dir $nom
    $hashAvant = HashDe $dest
    # overwrite=false : une collision ne peut pas écraser une archive.
    [IO.File]::Copy($dest, $archive, $false)
    if ((HashDe $archive) -ne $hashAvant) { throw "archive non vérifiée : $archive" }
    Log 'info' "version antérieure archivée : $archive"
}

function FichiersSansLien([string]$dir) {
    VerifierCheminSansLien $dir
    foreach ($item in (Get-ChildItem -LiteralPath $dir -Force)) {
        VerifierCheminSansLien $item.FullName
        if ($item.PSIsContainer) { FichiersSansLien $item.FullName }
        else { $item }
    }
}

function CollecterCandidats {
    $candidats = [ordered]@{}

    if ($Fichier) {
        $rel = CheminRelatif $Fichier
        if (-not (Test-Path -LiteralPath (CheminAbsolu $rel) -PathType Leaf)) {
            throw "fichier introuvable : $Fichier"
        }
        $type = TypeDeDocument $rel
        if (-not $type) {
            throw "fichier hors des zones publiables (projets/, syntheses/, livrables/) : $rel"
        }
        $texte = Get-Content -LiteralPath (CheminAbsolu $rel) -Raw -Encoding UTF8
        $ids = [regex]::Matches($texte, '(?<![A-Za-z0-9])(P\d{3})(?![0-9])') |
               ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
        $candidats[$rel] = @{ type = $type; projets = @($ids); mode = "ciblée" }
        return $candidats
    }

    $dirProjets = Join-Path $Vault "projets"
    if (-not (Test-Path -LiteralPath $dirProjets)) { return $candidats }

    foreach ($f in (Get-ChildItem -LiteralPath $dirProjets -Filter "*.md" -File | Sort-Object Name)) {
        $m = [regex]::Match($f.Name, '^(P\d{3})')
        if (-not $m.Success) {
            Log "info" "fiche ignorée (pas d'identifiant PXXX) : $($f.Name)"
            continue
        }
        $id = $m.Groups[1].Value
        if ($Projets.Count -gt 0 -and $Projets -notcontains $id) { continue }

        VerifierCheminSansLien $f.FullName
        $texte = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
        $etat = EtatDe $texte
        if ($etat -ne "terminé") {
            if ($etat) {
                Log "info" "projet non éligible : $id (état : '$etat')"
            } else {
                Log "info" "projet non éligible : $id (état absent du cartouche)"
            }
            continue
        }

        $candidats["projets/$($f.Name)"] = @{ type = "Documentation"; projets = @($id); mode = "automatique" }

        foreach ($zone in @("syntheses", "livrables")) {
            $dir = Join-Path $Vault $zone
            if (-not (Test-Path -LiteralPath $dir)) { continue }
            foreach ($f2 in (FichiersSansLien $dir | Sort-Object FullName)) {
                $rel2 = CheminRelatif $f2.FullName
                if (ReferenceProjet (Get-Content -LiteralPath $f2.FullName -Raw -Encoding UTF8) $id) {
                    if ($candidats.Contains($rel2)) {
                        if ($candidats[$rel2].projets -notcontains $id) {
                            $candidats[$rel2].projets = @($candidats[$rel2].projets) + $id
                        }
                    } else {
                        $candidats[$rel2] = @{ type = (TypeDeDocument $rel2); projets = @($id); mode = "lié à $id" }
                    }
                }
            }
        }
    }
    return $candidats
}

# ============================== EXÉCUTION ===============================
$erreurs = 0; $refus = 0; $publies = 0; $ajour = 0
$resultat = 0

try {
    VerifierCheminSansLien $Vault
    VerifierCheminSansLien $LogFile
    VerifierCheminSansLien $ManifestPath
    VerifierCheminSansLien $NAS
    $nasNormal = $NAS.Replace('\', '/')
    if ($nasNormal -eq $Vault -or $nasNormal.StartsWith($Vault + '/', [StringComparison]::OrdinalIgnoreCase) -or
        $Vault.StartsWith($nasNormal + '/', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'le NAS et le vault doivent être des dossiers distincts, non imbriqués'
    }
    if ($Fichier -and $Projets.Count -gt 0) { throw '-Fichier et -Projets sont exclusifs' }
    $mode = if ($DryRun) { ' (prévisualisation, aucune écriture)' } else { '' }
    Log 'info' "publication$mode — vault : $Vault — NAS : $NAS"
    if (-not (Test-Path -LiteralPath $NAS -PathType Container)) {
        if ($DryRun) { Log 'avert' 'NAS inaccessible : prévisualisation locale uniquement' }
        else { throw "NAS inaccessible : $NAS" }
    }
    $manifest = ChargerManifest
    $candidats = CollecterCandidats
    foreach ($rel in $candidats.Keys) {
        $info = $candidats[$rel]
        $type = $info.type
        $abs = CheminAbsolu $rel
        VerifierCheminSansLien $abs
        # Instantané unique : la classification, le hash et les copies portent
        # sur les mêmes octets, même si le fichier source change ensuite.
        $octets = [IO.File]::ReadAllBytes($abs)
        $texte = [Text.Encoding]::UTF8.GetString($octets).TrimStart([char]0xFEFF)
        $cls = ClassificationDe $texte
        if ($cls -notin @('public', 'interne')) {
            Log 'refus' "$rel — classification absente, ambiguë, inconnue ou confidentielle"
            $refus++
            if (-not $DryRun -and $manifest.fichiers.ContainsKey($rel)) {
                $manifest.fichiers.Remove($rel)
                SauverManifest $manifest
                Log 'avert' "$rel — copie antérieure possible sur le NAS : retrait manuel à examiner"
            }
            continue
        }
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $hash = [BitConverter]::ToString($sha.ComputeHash($octets)).Replace('-', '') }
        finally { $sha.Dispose() }
        $roles = @($Matrice[$type])
        if ($roles.Count -eq 0) { throw "aucun rôle pour $rel" }
        $ancien = $manifest.fichiers[$rel]
        if ($ancien -and $ancien.destination -eq $NAS) {
            $retires = @($ancien.roles | Where-Object { $_ -notin $roles })
            if ($retires.Count) { Log 'avert' "$rel — anciens rôles à traiter manuellement : $($retires -join ', ') ; aucune copie supprimée" }
        }
        if (EstAJour $ancien $hash $rel $roles) {
            Log 'info' "à jour : $rel (copies distantes vérifiées)"
            $ajour++
            continue
        }
        if ($DryRun) {
            Log 'info' "serait publié : $rel [$type, $cls] vers $($roles -join ', ')"
            $publies++
            continue
        }
        # Invalider avant toute copie : même une interruption ne laisse pas
        # d'ancien enregistrement prétendant à un succès pour cette cible.
        $manifest.fichiers.Remove($rel)
        SauverManifest $manifest
        $ok = $true
        foreach ($r in $roles) {
            $dest = Join-Path (Join-Path $NAS $r) $rel
            try {
                VerifierCheminSansLien $dest
                PreparerRole $r
                if ([IO.File]::Exists($dest)) {
                    if ((HashDe $dest) -eq $hash) { continue }
                    Archiver $dest $r $rel
                }
                [IO.Directory]::CreateDirectory((Split-Path -Parent $dest)) | Out-Null
                [IO.File]::WriteAllBytes($dest, $octets)
                if ((HashDe $dest) -ne $hash) { throw 'hash post-copie différent' }
            } catch {
                Log 'erreur' "copie non vérifiée : $rel -> $dest ($($_.Exception.Message))"
                $ok = $false
                $erreurs++
            }
        }
        if ($ok) {
            $manifest.fichiers[$rel] = @{
                hash = $hash; destination = $NAS
                publieLe = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
                type = $type; classification = $cls
                projets = @($info.projets); roles = $roles
            }
            SauverManifest $manifest
            Log 'publié' "$rel [$type, $cls] vers $($roles -join ', ')"
            $publies++
        }
    }
    if ($candidats.Count -eq 0) { Log 'info' 'rien à publier' }
} catch {
    # Console seulement : une erreur de chemin/log ne doit pas être contournée.
    Write-Host ("[erreur] {0}" -f $_.Exception.Message)
    $resultat = 1
}
if ($erreurs -gt 0) { $resultat = 1 }
elseif ($refus -gt 0 -and $resultat -eq 0) { $resultat = 2 }
$libelle = if ($DryRun) { 'prévu(s)' } else { 'publié(s)' }
Write-Host ("bilan : {0} {1}, {2} à jour, {3} refus, {4} erreur(s) ; code {5}" -f $publies, $libelle, $ajour, $refus, $erreurs, $resultat)
if (-not $DryRun) { Write-Host "log : $LogFile" }
exit $resultat
