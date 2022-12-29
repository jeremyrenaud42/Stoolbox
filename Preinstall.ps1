Add-Type -AssemblyName Microsoft.VisualBasic

function Admin
{
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
     {
        Start-Process powershell.exe -ArgumentList ("-NoProfile -windowstyle hidden -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit #permet de fermer la session non-Admin
    }
}
Admin

function SourceMenu
{
    #Création des dossiers
    $TECH = test-path "C:\_Tech" 
    if($TECH -eq $false)
    {
        New-Item -ItemType Directory "C:\_Tech" -Force | Out-Null #Créer le dossier _Tech sur le C:
    }
    $Applications = test-path "$Psscriptroot\Applications" 
    if($Applications -eq $false)
    {
        New-Item "$Psscriptroot\Applications" -ItemType Directory -Force | Out-Null
    }

    $Source = test-path "$Psscriptroot\Applications\Source"  
    if($Source -eq $false)
    {
        New-Item "$Psscriptroot\Applications\Source" -ItemType Directory -Force | Out-Null
    }
    
    $scripts = test-path "$Psscriptroot\Applications\Source\scripts" 
    if($scripts -eq $false)
    {
        New-Item "$Psscriptroot\Applications\Source\scripts" -ItemType Directory -Force | Out-Null
    }
    
    $images = test-path "$Psscriptroot\Applications\Source\images" 
    if($images -eq $false)
    {
        New-Item "$Psscriptroot\Applications\Source\images" -ItemType Directory -Force | Out-Null
    }
    start-sleep -s 2

    #Download des files
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/delete.ps1' -OutFile "$Psscriptroot\applications\source\scripts\delete.ps1" | Out-Null 
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.bat' -OutFile "$Psscriptroot\Remove.bat" | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.bat' -OutFile "$Psscriptroot\Menu.bat" | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.ps1' -OutFile "$Psscriptroot\Menu.ps1" | Out-Null     
    $a = Test-Path "$Psscriptroot\applications\source\Images\fondpluiesize.gif"
    $b = Test-path  "$Psscriptroot\applications\source\Images\Icone.ico" 
    if($a -and $b -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' -OutFile "$Psscriptroot\applications\source\Images\fondpluiesize.gif" | Out-Null #Download le fond
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' -OutFile "$Psscriptroot\applications\source\Images\Icone.ico" | Out-Null #Download l'icone
    }
    Start-Process "C:\_Tech\Menu.bat" -WindowStyle Hidden #On va pouvoir juste executer menu, car runasmenu est rendu stoolbox.bat
    exit
}

<#
function Launch #Copie tout dans la clé ou lance le script
{
    $menups1 = Test-Path "C:\_Tech\Menu.ps1" 
    $menubat = Test-Path "C:\_Tech\Applications\Source\scripts\RunAsMenu.bat"

    if($menups1 -and $menubat)
    {
        Start-Process "C:\_Tech\Applications\Source\scripts\RunAsMenu.bat" -WindowStyle Hidden
        exit
    }
    else
    {
        Write-Host "Le dossier C:\_Tech a été créé"
        Start-Sleep -s 1
        New-Item -ItemType Directory "C:\_Tech" -Force | Out-Null #Créer le dossier _Tech sur le C:
        write-host "Copie des fichiers sur le C:"
        Start-Sleep -s 1
        Copy-Item "$Psscriptroot\*" "C:\_TECH" -Recurse -Force | Out-Null #copy tous le dossier _Tech de la clé USB vers le dossier _Tech du C:
        Start-Sleep -s 1
        Start-Process "C:\_Tech\Applications\Source\scripts\RunAsMenu.bat" -WindowStyle Hidden
        exit
    }
}
#>
SourceMenu