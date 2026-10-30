<#
.SYNOPSIS
    Enregistre ou supprime les tâches planifiées de publication NAS (13h et 17h).

.DESCRIPTION
    Crée deux tâches planifiées Windows exécutant scripts\publier.ps1 en mode
    automatique, chaque jour à 13h et à 17h, sous le compte utilisateur
    courant. Les tâches s'exécutent quand l'utilisateur est connecté et que la
    machine est allumée ; -StartWhenAvailable relance la publication à la
    première occasion si la machine était éteinte à l'heure prévue.

    Avant installation : adapter le partage NAS (variable $NASDefaut dans
    scripts\publier.ps1, ou -NAS ici) et vérifier que le partage est accessible
    avec le compte courant.

.PARAMETER Vault
    Racine du vault (défaut : le dossier parent de scripts/).
.PARAMETER NAS
    Partage NAS à utiliser (défaut : celui de scripts\publier.ps1).
.PARAMETER Desinstaller
    Supprimer les deux tâches au lieu de les (re)créer.

.EXAMPLE
    .\planifier-taches.ps1
.EXAMPLE
    .\planifier-taches.ps1 -NAS \\NAS\WikiPartage -Desinstaller

.NOTES
    Conserver ce fichier en UTF-8 avec BOM.
#>
[CmdletBinding()]
param(
    [string]$Vault,
    [string]$NAS,
    [switch]$Desinstaller
)

$ErrorActionPreference = "Stop"

if (-not $Vault) { $Vault = Split-Path -Parent $PSScriptRoot }
if (-not $NAS)   { $NAS = "\\NAS\WikiPartage" }

$scriptPub = Join-Path $Vault "scripts\publier.ps1"
if (-not (Test-Path -LiteralPath $scriptPub)) {
    throw "script de publication introuvable : $scriptPub"
}

$psExe  = (Get-Command powershell.exe).Source
$argStr = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPub`" -NAS `"$NAS`""

$Taches = @(
    @{ Nom = "SecondCerveau-Publication-13h"; Heure = "13:00" }
    @{ Nom = "SecondCerveau-Publication-17h"; Heure = "17:00" }
)

foreach ($t in $Taches) {
    $existante = Get-ScheduledTask -TaskName $t.Nom -ErrorAction SilentlyContinue
    if ($Desinstaller) {
        if ($existante) {
            Unregister-ScheduledTask -TaskName $t.Nom -Confirm:$false
            Write-Host "tâche supprimée : $($t.Nom)"
        } else {
            Write-Host "tâche absente (rien à faire) : $($t.Nom)"
        }
        continue
    }
    if ($existante) {
        Unregister-ScheduledTask -TaskName $t.Nom -Confirm:$false
    }
    $action   = New-ScheduledTaskAction -Execute $psExe -Argument $argStr
    $trigger  = New-ScheduledTaskTrigger -Daily -At $t.Heure
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
    Register-ScheduledTask -TaskName $t.Nom `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Description "Publication du vault SecondCerveau vers $NAS (chaque jour à $t.Heure)" | Out-Null
    Write-Host "tâche enregistrée : $($t.Nom) — chaque jour à $($t.Heure)"
}

Write-Host ""
if ($Desinstaller) {
    Write-Host "Vérification : Get-ScheduledTask -TaskName 'SecondCerveau-Publication-*'"
} else {
    Write-Host "Commande exécutée par les tâches : $psExe $argStr"
    Write-Host "Vérification : Get-ScheduledTask -TaskName 'SecondCerveau-Publication-*' | Format-List TaskName, State"
    Write-Host "Test immédiat : Start-ScheduledTask -TaskName 'SecondCerveau-Publication-13h'"
}
