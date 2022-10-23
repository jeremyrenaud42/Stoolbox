$verif = Test-Path "C:\_Tech\menu.ps1"
if($verif)
{
    Start-Process powershell.exe "C:\_Tech\Applications\source\scripts\intermediatebat.ps1" -WindowStyle Hidden
}
else
{
    Write-Host "Le dossier C:\_Tech a été créé"
    New-Item -ItemType Directory "C:\_Tech" -Force #Créer le dossier _Tech sur le C:
    write-host "Copie des fichiers sur le C:"
    Copy-Item "$PSscriptroot\*" "C:\_TECH" -Recurse -Force #copy tous le dossier _Tech de la clé USB vers le dossier _Tech du C:
    Start-Process powershell.exe "C:\_Tech\Applications\source\scripts\intermediatebat.ps1" -WindowStyle Hidden
}