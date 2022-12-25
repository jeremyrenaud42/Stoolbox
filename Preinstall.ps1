#Ce script ne se met pas à jour.
#Partie 1: Tout se passe dans la clé USB
#Si nécéssaire, Créer les fondamentaux. soit le dossier applications et source, qui contient images et scripts.
#Si internet, Download les fichiers nécéssaire. Download a neuf à chaque execution afin d'être à jour tout le temp.
#Partie2: Tout se pase sur le C:
#Vérifie la présence du menu dans le C:. si existe, l,execute sinno créer le dossier _tech
#Copie/colle tout le dossier _Tech de la clé USB vers le C:

Add-Type -AssemblyName Microsoft.VisualBasic

function Testconnexion
{
    while (!(test-connection 8.8.8.8 -Count 1 -quiet)) #Ping Google et recommence jusqu'a ce qu'il y est internet
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Veuillez vous connecter à Internet",'OKOnly,SystemModal,Information', "Menu") | Out-Null
        start-sleep 5
    }
}

function SourceMenu #Créer dossier et met à jours tout ce qui touche menu, sauf preinstall.ps1 (lui meme) , tout ce passe dans la clé USB
{
    #Création des dossiers
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
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsMenu.bat' -OutFile "$Psscriptroot\applications\source\scripts\RunAsMenu.bat" | Out-Null  
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
}

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
Testconnexion
SourceMenu
Launch