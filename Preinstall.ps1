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

$intermediatebat = test-path "$root\_Tech\applications\source\scripts\Intermediatebat.ps1"
if($intermediatebat -eq $false)
{
    New-Item "$root\_Tech\Applications\Source\scripts" -ItemType Directory -Force | Out-Null 
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Intermediatebat.ps1' -OutFile "$root\_Tech\applications\source\scripts\Intermediatebat.ps1" | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/delete.ps1' -OutFile "$root\_Tech\applications\source\scripts\delete.ps1" | Out-Null 
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsMenu.bat' -OutFile "$root\_Tech\applications\source\scripts\RunAsMenu.bat" | Out-Null  
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.bat' -OutFile "$root\_Tech\Remove.bat" | Out-Null  
}