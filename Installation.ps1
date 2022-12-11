#Les assembly sont nécéssaire pour le fonctionnement du script. Ne pas effacer
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.speech
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName presentationCore
Add-Type -AssemblyName Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles()

$driveletter = $pwd.drive.name #Retourne la Lettre du disque utilisé  exemple: D
$root = "$driveletter" + ":" #Rajoute : après la lettre trouvée. exemple: D: ,ceci permet de pouvoir l'utiliser lors des paths

$ErrorActionPreference = 'silentlycontinue'#Continuer même en cas d'erreur, cela évite que el scripte se ferme s'il rencontre une erreur

set-location "c:\_Tech\Applications\Installation" #met le path dans le dossier Installation au lieu du path de PowerShell.

#Vérifier la présence du dossier source dans la clé
function Sourceexist
{
$sourcefolder = Test-path "$root\_Tech\Applications\Installation\Source" #chemin du dossier source

    if(!($sourcefolder))
    {
        New-Item "$root\_Tech\Applications\Installation\Source" -ItemType Directory | Out-Null #Créer le dossier source si il n'est pas là
    }
}

function zipinstallation
{
    Sourceexist #appel la fonction qui test le chemin du dossier source
    #les 3 lignes ci-dessous permettent de tout wiper sauf winget
    Get-ChildItem -Path "$root\_Tech\Applications\Installation\source\Logiciels" -Exclude "Winget"  | Remove-Item -Recurse -Force
    Get-ChildItem -Path "$root\_Tech\Applications\Installation\source" -Exclude "Logiciels"  | Remove-Item -Recurse -Force
    Get-ChildItem -Path "$root\_Tech\Applications\Installation\" -Exclude "Source","Installation.ps1","RunAsInstallation.bat"  | Remove-Item -Recurse -Force

    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Source.zip' -OutFile "$root\_Tech\Applications\Installation\source.zip" | Out-Null #download le dossier source
    Expand-Archive "$root\_Tech\Applications\Installation\source.zip" "$root\_Tech\Applications\Installation\Source" -Force | Out-Null #dezip source
    Remove-Item "$root\_Tech\Applications\Installation\source.zip" | Out-Null #supprime zip source
}

zipinstallation

$Form = New-Object System.Windows.Forms.Form #Créer la fenêtre GUI
$Form.ClientSize = '1041,688' #Taille de la GUI
$Form.Text = "Installation Windows" #Titre de la GUI (apparait en haut à gauche)
$Form.StartPosition = 'Centerscreen' #position de démarrage
$Form.MaximizeBox = $false #Ne peut pas s'agrandir
$Form.AutoSize = $false #Ne peut pas modifier la taille de la fenêtre
$Form.icon = New-Object system.drawing.icon ("$root\_Tech\Applications\Installation\Source\Icone.ico") #chemin de l'icone. 

#titre du champ texte de la fenêtre (en dessous du titre de la Form)
$labeltitre = New-Object System.Windows.Forms.Label #Creer la label du titre
$labeltitre.Location = New-Object System.Drawing.Point(57,0) #position du titre par rapport à la fenêtre GUI
$labeltitre.AutoSize = $false #ne peut pas adapter sa taille en fonction de chaque taille d'écran (empêche les déformations)
$labeltitre.width = 925 #largeur du label
$labeltitre.height = 50 #hateur du label
$labeltitre.TextAlign = 'middlecenter' #comment le texte apparait (aligner et centrer)
$labeltitre.Font= 'Microsoft Sans Serif,16' #la sorte et taille de police
$labeltitre.BackColor = 'darkcyan' #couleur de l'arriere plan du label
$labeltitre.Text = "Configuration du Windows" #Texte affiché dans le label
$Form.Controls.Add($labeltitre) #ajoute officiellement le label. Il suffit de mettre cette ligne en commentaire et le label ne s'affichera plus

#progressbar manuel
$progres = New-Object System.Windows.Forms.Label #créer la barre de progres
$progres.Location = New-Object System.Drawing.Point(57,50) #position de la barre de progres
$progres.AutoSize = $false #ne peut pas adapter sa taille en fonction de chaque taille d'écran (empêche les déformations)
$progres.width = 925 #largeur du label
$progres.height = 20 #hateur du label
$progres.TextAlign = 'middlecenter' #comment le texte apparait (aligner et centrer)
$progres.Font= 'Consolas,12' #la sorte et taille de police
$progres.forecolor = 'white' #couleur de la police
$progres.BackColor = 'darkred' #couleur de l'arriere plan du label
$Form.Controls.Add($progres) #ajoute officiellement le label. Il suffit de mettre cette ligne en commentaire et le label ne s'affichera plus

#Zone ou les étapes s'affiche
$Labeloutput = New-Object System.Windows.Forms.Label #Créer la zone
$Labeloutput.Location = New-Object System.Drawing.Point(57,70) #position de la zone
$Labeloutput.AutoSize = $false #ne peut pas adapter sa taille en fonction de chaque taille d'écran (empêche les déformations)
$Labeloutput.width = 925 #largeur du label
$Labeloutput.height = 600 #hateur du label
$Labeloutput.TextAlign = 'topLeft' #comment le texte apparait (en haut à gauche)
$Labeloutput.Font= 'Microsoft Sans Serif,11' #la sorte et taille de police
$Labeloutput.BorderStyle = 'fixed3D' #Style de la bordure de la zone de texte
$Form.Controls.Add($Labeloutput) #ajoute officiellement le label. Il suffit de mettre cette ligne en commentaire et le label ne s'affichera plus

#Start-Process ".\Source\LogoSTO.exe" #Lancer le splashscreen
#Start-Sleep -s 7 #Permet un bel affichage assez long du Logo

$Form.Show() | out-null #afficher la form, ne jamais enlever sinon plus d'affichage GUI
#Stop-Process -name LogoSTO -Force #Fermer le splashscreen

$executionpolicy = Get-ExecutionPolicy #policy de départ pour la remettre dans la fonction end
Set-ExecutionPolicy unrestricted -Force #change la policy pour que le script se passe bien

#Permet de documenter chaque étape
function AddLog ($message)
{
    $logfilepath="$root\_Tech\Applications\Installation\\Source\Log.txt" #chemin du fichier texte
    $message + "`r`n" | Out-file -filepath $logfilepath -append -force #ajoute le texte dans le fichier
}

#Permet de documenter les erreurs 
function AddErrorsLog ($message)
{
    $errorslogfilepath="$root\_Tech\Applications\Installation\\Source\\Logs\\ErrorsLog.txt" #chemin du fichier texte
    (Get-Date).ToString() + " - " + $message + "`r`n" | Out-file -filepath $errorslogfilepath -append -force #ajoute le texte dans le fichier
}

#vérifier s'il y a internet 
function Testconnexion
{
    while (!(test-connection 8.8.8.8 -Count 1 -quiet)) #Ping Google
    {
    write-warning "Veuillez vous connecter à Internet"
    $Labeloutput.Text += "Une fois la connexion établie l'installation va débuter`r`n"
    start-sleep 5
    }
}

#Download fichiers winget depuis github
function zipwinget
{
$logicielpath = test-Path "$root\_Tech\Applications\Installation\Source\Logiciels"
$wingetpath = test-Path "$root\_Tech\Applications\Installation\Source\Logiciels\winget"
    if($wingetpath -eq $false)
    {
        if($logicielpath -eq $false)
        {
            New-Item "$root\_Tech\Applications\Installation\Source\Logiciels" -ItemType Directory
        }
Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Winget.zip' -OutFile "$root\_Tech\Applications\Installation\Source\Logiciels\Winget.zip"
Expand-Archive "$root\_Tech\Applications\Installation\Source\Logiciels\Winget.zip" ".\Source\Logiciels"
Remove-Item "$root\_Tech\Applications\Installation\Source\Logiciels\Winget.zip"
    }
}

#Vérifier si Choco est déja installé
function Preverifchoco 
{
    $chocoexist = $false
    $chocopath = Test-Path C:\ProgramData\chocolatey
    if ($chocopath -eq $true)
    {
       $chocoexist = $true 
    } 
    return $chocoexist
}

#Vérifier si winget est déja installé
function Preverifwinget
{
   $wingetpath = $false
   $wingetpath = test-path "C:\Users\$env:username\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe"
   if($wingetpath -eq $true)
   {
     $wingetpath = $true
   }
   return $wingetpath
}

#Vérifier si choco s'est bien installé
function Postverifchoco 
{
    $chocopath = Test-Path C:\ProgramData\chocolatey
    if ($chocopath -eq $false)
    {
        $ErrorMessage = $_.Exception.Message
        Write-Warning "Choco n'a pas pu s'installer !!!! $ErrorMessage"
        #AddErrorsLog $ErrorMessage
    }
}

#Vérifier si winget s'est bien installé
function Postverifwinget
{
   $wingetpath = test-path "C:\Users\$env:username\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe"
   if($wingetpath -eq $false)
   {
       $ErrorMessage = $_.Exception.Message
       Write-Warning "Winget n'a pas pu s'installer !!!! $ErrorMessage"
       #AddErrorsLog $ErrorMessage
   }
}

#Install le package manager Choco
function Chocoinstall
{
    $progressPreference = 'SilentlyContinue' #cache la barre de progres
    $chocoexist = Preverifchoco
    if($chocoexist -eq $false)
    {
        Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression | Out-Null #install le module choco
        $env:Path += ";C:\ProgramData\chocolatey" #permet de pouvoir installer les logiciels sans reload powershell
    }
    Postverifchoco
}

#Install le package manager Winget
function Wingetinstall
{
    $progressPreference = 'SilentlyContinue' #cache la barre de progres
    $wingetpath = Preverifwinget
    if($wingetpath -eq $false)
    {
        zipwinget
        Add-AppxPackage -path "$root\_Tech\Applications\Installation\Source\Logiciels\winget\Microsoft.VCLibs.x64.14.00.Desktop.appx"  | out-null #prérequis pour winget
        Add-AppxPackage -path "$root\_Tech\Applications\Installation\Source\Logiciels\winget\Microsoft.UI.Xaml.2.7.appx" | out-null #prérequis pour winget
        Add-AppPackage -path "$root\_Tech\Applications\Installation\Source\Logiciels\winget\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" | out-null #installeur de winget
    }
    Postverifwinget
}

#Importe le module qui gère la Voix et la musique
import-module "$root\_Tech\Applications\Installation\Source\Voice.psm1" #Module pour musicdebut et getvoice

######Vrai début du script######
function Debut
{
    Testconnexion #appel la fonction qui test la connexion internet
    addlog (Get-Date).ToString() #ajoute la date dans le fichier texte de log
    $progres.Text = "Préparation"
    $Labeloutput.Text = "" #effacer le texte qui serait déja écrit par la fonction testconnexion
    $Labeloutput.Text += "Lancement de la configuration du Windows`r`n"
    MusicDebut #Appel la fonction qui joue la musique au début (se situe dans le module Voice.psm1)
    Chocoinstall #Download Choco
    Wingetinstall #Download Winget
}

#Mises à jour de Windows
function Msupdate
{
    $progres.Text = "Mises à jour de Windows"
    $Labeloutput.Text += "Installation des mises à jour de Windows"
    
    Install-PackageProvider -name Nuget -MinimumVersion 2.8.5.201 -Force | Out-Null
    Install-Module PSWindowsUpdate -Force | Out-Null #install le module
    $path = test-path "C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate" #vérifie le chemin du module
    if($path -eq $false) #si le module n'est pas là
    {
        choco install pswindowsupdate -y | out-null #Install le module avec Choco
    }
    Import-Module PSWindowsUpdate | out-null #Import le module
    Get-WindowsUpdate -MaxSize 250mb -Install -AcceptAll -IgnoreReboot | out-null #download et install les updates de moins de 250mb sans reboot

    $Labeloutput.Text += " -Mises à jour de Windows effectuées`r`n"
    addlog "Mises à jour de Windows effectuées"
}

#Renommer Disque
Function LabelHDD
{
    $progres.Text = "Renommage du disque"
    Set-Volume -DriveLetter 'C' -NewFileSystemLabel "OS" #Renomme le disque C: par OS
    $Labeloutput.Text += "`r`nLe disque C: a été renommé OS`r`n"
    addlog "Le disque C: a été renommé OS"
}

#Dossiers
Function Dossiers
{
    $progres.Text = "Configuration des paramètres de l'explorateur de fichiers"
    set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -Type DWord -Value 1
    $Labeloutput.Text += "L'accès rapide a été remplacé par Ce PC`r`n"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowSyncProviderNotifications -Type DWord -Value 0
    $Labeloutput.Text += "Le fournisseur de synchronisation a été decoché`r`n"      
    addlog "Explorateur de fichiers configuré"  
}

 #Désactiver bitlocker
 Function Bitlocker
{
    $progres.Text = "Désactivation du bitlocker"
    $BLVE = Get-BitLockerVolume | Select-Object -expand VolumeStatus
        if ($blvE -eq 'EncryptionInProgress')
        {
            $BLV = Get-BitLockerVolume
            Disable-BitLocker -MountPoint $BLV | Out-Null
            $Labeloutput.Text += "Bitlocker a été désactivé`r`n"
        }
    addlog "Bitlocker a été désactivé"
}

#Fast boot
Function DisableFastBoot
{
    $progres.Text = "Desactivation du demarrage rapide"
    powercfg /h off #désactive l'hibernation
    $Labeloutput.Text += "Le démarrage rapide a été désactivé`r`n"
    addlog "Le démarrage rapide a été désactivé"
}

#supprimer le clavier anglais canada
Function Langue
{
    $progres.Text = "Suppression du clavier Anglais"
    $LangList = Get-WinUserLanguageList #Gets the language list for the current user account
    $AnglaisCanada = $LangList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
    $LangList.Remove($AnglaisCanada) | Out-Null #supprimer la clavier sélectionner
    Set-WinUserLanguageList $LangList -Force -WarningAction SilentlyContinue | Out-Null #applique le changement
    $Labeloutput.Text += "Le clavier Anglais a été supprimé`r`n"
    addlog "Le clavier Anglais a été supprimé"
}

#Confidentialité
Function Privacy
{
    $progres.Text = "Paramètres de confidentialité"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338393Enabled -Type DWord -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-353694Enabled -Type DWord -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-353696Enabled -Type DWord -Value 0 
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Start_TrackProgs -Type DWord -Value 0 
    $Labeloutput.Text += "Les options de confidentialité ont été configuré`r`n"
    addlog "Les options de confidentialité ont été configuré"  
}

#Icones sur le bureau
Function IconeBureau
{
    $progres.Text = "Installation des icones systèmes sur le bureau"
    if (!(Test-Path -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel)) #vérifie si le chemin du registre existe
		{
			New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel -Force #s'il n'existe pas le créé
		}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type DWord -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
    $Labeloutput.Text += "Les icones systèmes ont été installés sur le bureau`r`n"
    addlog "Les icones systèmes ont été installés sur le bureau"
}

#Mises à jour des applis du Microsoft store
function Msstore
{
    $progres.Text = "Mises à jour du Microsoft Store"
    $Labeloutput.Text += "`r`nLancement des updates du Microsoft Store"   
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
    $wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
    $result = $wmiObj.UpdateScanMethod()
    $Labeloutput.Text += " -Mises à jour du Microsoft Store lancées`r`n"
    addlog "Mises à jour de Microsoft Store"
}
 
#Adobe
function PreverifAdobe
{
   $pathexist = $false
   $adobereaderpath = Test-Path "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
   $adobereaderpath32 = Test-Path "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"   
   if(($adobereaderpath) -OR ($adobereaderpath32))
   {
     $pathexist = $true
     $Labeloutput.Text += " -Adobe Reader est déja installé`r`n"
   }
   return $pathexist
}

function PostverifAdobe
{
    choco install adobereader -params "/DesktopIcon" -y | out-null 
    $adobereaderpath = Test-Path "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe" 
    $adobereaderpath32 = Test-Path "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"        
    if(($adobereaderpath) -OR ($adobereaderpath32))
    {   
        #iconeadobe
        $Labeloutput.Text += " -Adobe Reader installé avec succès`r`n"
    }
    else
    {
        Write-Warning "Erreur lors de l'installation de Adobe Reader!!!!"
        $Labeloutput.Text += " -Adobe Reader a échoué`r`n"
    } 
}
    
function AdobeReader
{   
    $progres.Text = "Installation de Adobe Reader"
    $Labeloutput.Text += "`r`nInstallation d'Adobe Reader en cours"
    $pathexist = PreverifAdobe #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {   
            winget install -e --id Adobe.Acrobat.Reader.64-bit --accept-package-agreements --accept-source-agreements --silent | out-null
            $adobereaderpath = Test-Path "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe" 
            $adobereaderpath32 = Test-Path "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe" 
            if(($adobereaderpath) -OR ($adobereaderpath32))
            {
                #iconeadobe
                $Labeloutput.Text += " -Adobe Reader installé avec succès`r`n" 
            } 
            else
            {
                PostverifAdobe
            }
        }             
    addlog "Installation de Adobe"      
}

#Google
function PreverifGoogle
{
   $pathexist = $false
   $googlepath = Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe" 
   $googlepath32 = Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" 
   $googleappdatapath = Test-Path "C:\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe"
   if(($googlepath) -OR ($googlepath32) -OR ($googleappdatapath))
   {
     $pathexist = $true
     $Labeloutput.Text += " -Google Chrome est déja installé`r`n"
   }
   return $pathexist
}

function PostverifGoogle
{
    choco install googlechrome -y | out-null
    $googlepath = Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
    $googlepath32 = Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    $googleappdatapath = Test-Path "C:\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe"
    if (($googlepath) -OR ($googlepath32) -OR ($googleappdatapath))
    {   
        iconeadobe
        $Labeloutput.Text += " -Google Chrome installé avec succès`r`n"
    }
    else
    {
        Write-Warning "Erreur lors de l'installation de Google Chrome!!!!"
        $Labeloutput.Text += " -Google Chrome a échoué`r`n"
        plancgoogle
    } 
}
    
function Googlechrome
{   
    $progres.Text = "Installation de Google Chrome"
    $Labeloutput.Text += "Installation de Google Chrome en cours"
    $pathexist = PreverifGoogle #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {  
            winget install -e --id Google.Chrome --accept-package-agreements --accept-source-agreements --silent | out-null 
            $googlepath = Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
            $googlepath32 = Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
            $googleappdatapath = Test-Path "C:\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe"
            if (($googlepath) -OR ($googlepath32) -OR ($googleappdatapath))
            {
                $Labeloutput.Text += " -Google Chrome installé avec succès`r`n"  
            } 
            else
            {
                PostverifGoogle
            }
        }       
    addlog "Installation de Google Chrome"      
}

#Teamviewer
function PreverifTeamViewer
{
   $pathexist = $false
   $teamviewerpath = Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe" 
   $teamviewerpath32 = Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe" 
   if(($teamviewerpath) -OR ($teamviewerpath32))
   {
     $pathexist = $true
     $Labeloutput.Text += " -TeamViewer est déja installé`r`n"
   }
   return $pathexist
}

function PostverifTeamViewer
{
    choco install teamviewer -y | out-null
    $teamviewerpath = Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe"         
    $teamviewerpath32 = Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe" 
    if(($teamviewerpath) -OR ($teamviewerpath32))
    {   
        $Labeloutput.Text += " -TeamViewer installé avec succès`r`n"
    }
    else
    {
        Write-Warning "Erreur lors de l'installation de TeamViewer!!!!"
        $Labeloutput.Text += " -TeamViewer a échoué`r`n"
        plancteamviewer
    } 
}
 
function Teamviewer
{   
    $progres.Text = "Installation de Teamviewer"
    $Labeloutput.Text += "Installation de Teamviewer en cours"
    $pathexist = PreverifTeamViewer #s'il est déja installé il ne va pas poursuivre
    if($pathexist -eq $false)
    {   
        winget install -e --id TeamViewer.TeamViewer --accept-package-agreements --accept-source-agreements --silent | out-null
        $teamviewerpath = Test-Path "C:\Program Files\TeamViewer\TeamViewer.exe" 
        $teamviewerpath32 = Test-Path "C:\Program Files (x86)\TeamViewer\TeamViewer.exe" 
        if(($teamviewerpath) -OR ($teamviewerpath32))
        {
            $Labeloutput.Text += " -Teamviewer installé avec succès`r`n"  
        } 
        else
        {
            PostverifTeamViewer
        }
    }         
    addlog "Installation de Teamviewer"      
}

function plancteamviewer
{
Start-Process "$root\_Tech\Applications\Installation\Source\Ninite TeamViewer 15 Installer.exe" -Verb runAs #escape pour terminer
}
function plancgoogle
{
Start-Process "$root\_Tech\Applications\Installation\Source\Ninite Chrome Installer.exe" -Verb runAs #escape pour terminer
}
<#
function verifierSiLogicielEstDejaInstalle {
    param (
        [PSCustomObject] $infoApp
    )

    $pathexist = $false
    $emplacementExecutable = Test-Path $infoApp.emplacementExecutable
    if($emplacementExecutable -eq $true)
    {
        $pathexist = $true
        $Labeloutput.Text += " -" + $infoApp.nomAffiche + " est déja installé`r`n"
    }
    return $pathexist
}

function verifierApresInstallation {
    param (
        [PSCustomObject] $infoApp
    )

    $emplacementExecutable = Test-Path $infoApp.emplacementExecutable
    if($emplacementExecutable -eq $true)
    {
        $Labeloutput.Text += " -" + $infoApp.nomAffiche + " installé avec succès`r`n"
    }
    else
    {
        Write-Warning "Erreur lors de l'installation de " + $infoApp.nomAffiche + "!!!!"
    }    
}

function installerLogiciel {
    param (
        [PSCustomObject] $infoApp
    )
    
    $progres.Text = "Installation de " + $infoApp.nomAffiche
    $Labeloutput.Text += "Installation de " + $infoApp.nomAffiche + " en cours"
    $pathexist = verifierSiLogicielEstDejaInstalle $infoApp
    if($pathexist -eq $false)
    {
        choco install $infoApp.idChocolatey -y | out-null
        $Labeloutput.Text += " -" + $infoApp.nomAffiche + " installé avec succès`r`n"
    }

    verifierApresInstallation $infoApp

    addlog "Installation de " + $infoApp.nomAffiche
}


$infoApp = [PSCustomObject]@{
    nomAffiche = "Teamviewer"
    emplacementExecutable = "C:\Program Files\TeamViewer\TeamViewer.exe"
    idWinget = "teamviewer"
    idChocolatey = "teamviewer"
}

installerLogiciel $infoApp
 #> 

#Gérer les pilotes
#Lenovo
function PreverifSystemUpdate
{
   $pathexist = $false
   $SystemUpdatepath = Test-Path "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe" 
   if($SystemUpdatepath -eq $true)
   {
     $pathexist = $true
     $Labeloutput.Text += " -Lenovo System Update est déja installé`r`n"
   }
   return $pathexist
}
function PostverifSystemUpdate
{
    choco install lenovo-thinkvantage-system-update -y | out-null
    $SystemUpdatepath = Test-Path "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"         
    if($SystemUpdatepath -eq $true)
    {   
        $Labeloutput.Text += " -Lenovo System Update installé avec succès`r`n"
    }
    else
    {
        Write-Warning "Erreur lors de l'installation de System Update!!!!"
        $Labeloutput.Text += " -Lenovo System Update a échoué`r`n"
    } 
}

function SystemUpdate
{   
    $progres.Text = "Installation de Lenovo System Update"
    $Labeloutput.Text += "Installation de Lenovo System Update en cours"
    $pathexist = PreverifSystemUpdate #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {   
            winget install -e --id Lenovo.SystemUpdate --accept-package-agreements --accept-source-agreements --silent | out-null  
            $SystemUpdatepath = Test-Path "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
            if($SystemUpdatepath)
            {
                $Labeloutput.Text += " -Lenovo System Update installé avec succès`r`n"  
            } 
            else
            {
                PostverifSystemUpdate
            }         
        }             
    addlog "Installation de Lenovo System Update"      
}

<#Lenovo Vantage

function PreverifVantage
{
   $pathexist = $false
   $Vantagepath = Test-Path "C:\ProgramData\Lenovo\Vantage" #si déja ouvert.
   if($Vantagepath -eq $true)
   {
     $pathexist = $true
     $Labeloutput.Text += " -Lenovo Vantage est déja installé`r`n"
   }
   return $pathexist
}

winget install -e --id 9WZDNCRFJ4MV --accept-package-agreements --accept-source-agreements --silent | out-null
#>




#Dell
function PreverifDellSA
{
   $pathexist = $false
   $DellSApath = Test-Path "C:\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe" 
   if($DellSApath -eq $true)
   {
     $pathexist = $true
     $Labeloutput.Text += " -Dell Command Update est déja installé`r`n"
   }
   return $pathexist
}

function PostverifDellSA
{
    choco install dellcommandupdate -y | out-null
    $DellSApath = Test-Path "C:\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe"         
    if($DellSApath -eq $true)
    {   
        $Labeloutput.Text += " -Dell Command Update installé avec succès`r`n"
    }
    else
    {
        Write-Warning "Erreur lors de l'installation de  Dell Command Update!!!!"
        $Labeloutput.Text += " -Dell Command Update a échoué`r`n"
    } 
}
 
function DellSA
{   
    $progres.Text = "Installation de  Dell Command Update"
    $Labeloutput.Text += "Installation de  Dell Command Update en cours"
    $pathexist = PreverifDellSA #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {   
            winget install -e --id Dell.CommandUpdate --accept-package-agreements --accept-source-agreements --silent | out-null
            $DellSApath = Test-Path "C:\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe"         
            if($DellSApath)
            {
                $Labeloutput.Text += " -Dell Command Update installé avec succès`r`n" 
            } 
            else
            {
                PostverifDellSA
            }  
        }         
    addlog "Installation de  Dell Command Update"      
}

#HP
function PreverifHP
{
   $pathexist = $false
   $HPpath = Test-Path "C:\Program Files (x86)\HP\HP Support Framework\hpsupportassistant.dll" 
   if($HPpath -eq $true)
   {
     $pathexist = $true
     $Labeloutput.Text += " -Hp Support Assistant est déja installé`r`n"
   }
   return $pathexist
}

function HPSA
{   
    $progres.Text = "Installation de Hp Support Assistant"
    $Labeloutput.Text += "Installation de Hp Support Assistant en cours"
    $pathexist = PreverifHP #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {   
            choco install hpsupportassistant -y | out-null
            $HPpath = Test-Path "C:\Program Files (x86)\HP\HP Support Framework\hpsupportassistant.dll" 
            if($HPpath) #Pas de winget de dispo, donc pas de postverif
            {
                $Labeloutput.Text += " -Hp Support Assistant avec succès`r`n"
                
            }
            else 
            {
                $ErrorMessage = $_.Exception.Message
                Write-Warning "Hp Support Assistant n'a pas pu s'installer !!!! $ErrorMessage"
                $Labeloutput.Text += " -Hp Support Assistant a échoué`r`n"
            }  
        }  
    addlog "Installation de Hp Support Assistant"      
}

Function Pilotes
{
    $progres.Text = "Vérification des pilotes"
    $x = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Manufacturer #Chercher la marque de l'ordinateur
    #Get-CimInstance -Class Win32_BaseBoard | Select-Object -Property Manufacturer, product # + rapide
    if($x -match 'LENOVO')
    {
        SystemUpdate
    }

    elseif($x -match 'HP')
    {        
        HPSA
    }

    elseif($x -match 'DELL')
    {
        DellSA
    }
    <#
    elseif($x -match 'MSI')
    {
        
    }
    elseif($x -like 'ASUS*')
    {
        
    }
    #>
}

#Geforce
function PreverifGeForce
{
   $pathexist = $false
   $GeForcepath = Test-Path "C:\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe" 
   if($GeForcepath -eq $true)
   {
     $pathexist = $true
     $Labeloutput.Text += " -GeForce Experience est déja installé`r`n"
   }
   return $pathexist
}

function PostverifGeForce
{
    winget install -e --id Nvidia.GeForceExperience --accept-package-agreements --accept-source-agreements --silent | out-null
    $GeForcepath = Test-Path "C:\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"         
    if($GeForcepath -eq $true)
    {   
        $Labeloutput.Text += " -GeForce Experience installé avec succès`r`n"
    }
    else
    {
        Write-Warning "Erreur lors de l'installation de GeForce Experience!!!!"
        $Labeloutput.Text += " -GeForce Experience a échoué`r`n"
    } 
}
 
function GeForce
{   
    $nvidia = Get-WmiObject win32_VideoController | Select-Object -Property name
    if($nvidia -match 'NVIDIA')
    {
        $progres.Text = "Installation de GeForce Experience"
        $Labeloutput.Text += "Installation de GeForce Experience en cours"
        $pathexist = PreverifGeForce #s'il est déja installé il ne va pas poursuivre
            if($pathexist -eq $false)
            {   
                choco install geforce-experience -y | out-null 
                $GeForcepath = Test-Path "C:\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"     
                if($GeForcepath)
                {
                    $Labeloutput.Text += " -GeForce Experience installé avec succès`r`n"  
                } 
                else
                {
                    PostverifGeForce
                } 
            }                     
        addlog "Installation de GeForce Experience"
    }      
}

#Antivirus
#Function Antivirus
#{
#    #$progres.Text = "Paramètre de Defender : Progrès 75%"
#    $Labeloutput.Text += "Antivirus configuré`r`n"
#    start-Process "windowsdefender:"
#    #Start-Sleep -s 3
#    [Microsoft.VisualBasic.Interaction]::MsgBox("Vérifier que l'antivirus est bien configuré, puis cliquer sur OK",'OKOnly,SystemModal,Information', "Windows -Antivirus") | Out-Null
#    #[System.Windows.MessageBox]::Show("Vérifier que l'antivirus est bien configuré, puis cliquer sur OK","Windows -Antivirus",0) | Out-Null
#    #start-sleep -s 3
#}


function License
{
    $version = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $activated = Get-CIMInstance -query "select LicenseStatus from SoftwareLicensingProduct where LicenseStatus=1" |Select-Object -ExpandProperty LicenseStatus 
    $activated
    if($activated -eq "1")
    {
        $Labeloutput.Text += "`r`n$version est activé sur cet ordinateur`r`n"
    }
    else 
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Windows n'est pas activé",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        $Labeloutput.Text += "`r`nWindows n'est pas activé`r`n"
    }  
}

function Edge
{
    $edgeversion = (Get-AppxPackage -Name "Microsoft.MicrosoftEdge.Stable").Version
    if($edgeversion -lt 100)
    {
        $Labeloutput.Text += "Mise à jour de Microsoft Edge en cours"
        winget upgrade -e -h --id Microsoft.Edge --accept-package-agreements --accept-source-agreements --silent
    }  
}

<#
$msgBoxInput = [System.Windows.MessageBox]:: Show('Épingler Google Chrome dans la barre des tâches','Title','OKCancel','Information')
switch ($msgBoxInput) 
{
    'Ok' {Write-Host "You pressed Ok"}
    'Cancel' {continue}
}
#>

function Pintotaskbar
{
#$targetdir = "C:\Users\$env:username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
#$pinnedgoogle = Get-ChildItem $targetdir -recurse -Filter "Goo*" | Select-Object -expand name
#$pinpath = Test-Path "$targetdir\*Google*Chrome*"

#while($pinpath -eq $false)
    #{
        [Microsoft.VisualBasic.Interaction]::MsgBox("Épingler Google Chrome dans la barre des tâches",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        #$pinpath = test-path "$targetdir\Google Chrome.lnk"
    #}
}

function Defaultpdf
{
#$pdf = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice | Select-Object -ExpandProperty ProgId
    #while($pdf -notlike "*.Document.DC")
    #{
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre Adobe Reader par défaut",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        #$pdf = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice | Select-Object -ExpandProperty ProgId
    #} 
}

function Defaultbrowser
{
#$http = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\http\UserChoice | Select-Object -ExpandProperty ProgId
#$https = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\https\UserChoice | Select-Object -ExpandProperty ProgId
    #while(($http -notlike "ChromeHTML*") -and ($https -notlike "ChromeHTML*"))
    #{
        Start-Process ms-settings:defaultapps
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre Google Chrome par défaut",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
        #$http = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\http\UserChoice | Select-Object -ExpandProperty ProgId
        #$https = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\https\UserChoice | Select-Object -ExpandProperty ProgId
    #}  
}

function Postverif
{
    #default browser
    $http = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\http\UserChoice | Select-Object -ExpandProperty ProgId
    $https = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\https\UserChoice | Select-Object -ExpandProperty ProgId
    if(($http -notlike "ChromeHTML*") -and ($https -notlike "ChromeHTML*"))
    {
        Start-Process ms-settings:defaultapps
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre Google Chrome par défaut",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
    }
    #PDF
    $pdf = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice | Select-Object -ExpandProperty ProgId
    if($pdf -notlike "*.Document.DC")
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre Adobe Reader par défaut",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
    }
    #taskbar
    $targetdir = "C:\Users\$env:username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    $pinpath = Test-Path "$targetdir\*Google*Chrome*"
    if($pinpath -eq $false)
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Épingler Google Chrome dans la barre des tâches",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
    } 
}

function End
{
    AddLog "Installation de Windows effectué avec Succès"
    [Audio]::Volume = 0.25
    [console]::beep(1000,666)
    Start-Sleep -s 1
    [Audio]::Volume = 0.75
    getvoice -Verb runAs
    changevoice -Verb runAs
    speak
    $reboot = get-wurebootstatus -Silent #vérifie si ordi doit reboot à cause de windows update
    if($reboot -eq $true)
    {
        Set-ExecutionPolicy $executionpolicy
        $Labeloutput.Text += "`r`nL'ordinateur va redémarrer pour finaliser l'installation des mises à jour"
        start-sleep -s 3
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre les logiciels par défaut et épingler Google Chrome à la barre des tâches. Cliquer sur OK pour redémarrer l'ordinateur",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        Postverif
        #Pintotaskbar
        #Defaultpdf
        #Defaultbrowser
        #start-sleep -s 3
        #Restart-Computer -Force
        shutdown /r /t 60à
        Start-Process "c:\temp\Remove.bat" | Out-Null #Exécuter remove.bat
    }
    else 
    {
        Set-ExecutionPolicy $executionpolicy
        Postverif
        #Pintotaskbar
        #Defaultpdf
        #Defaultbrowser
        Start-Process "c:\temp\Remove.bat" | Out-Null #Exécuter remove.bat
        exit
    }     
}
#https://gist.github.com/alirobe/7f3b34ad89a159e6daa1





function Main
{
Debut
Msstore
LabelHDD
Dossiers
Bitlocker
DisableFastBoot
Langue
Privacy
IconeBureau
AdobeReader
Googlechrome
Teamviewer
Edge
Pilotes
GeForce
License
Msstore
Msupdate
End
}
Main