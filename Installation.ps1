#Les assembly sont nécéssaire pour le fonctionnement du script. Ne pas effacer
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore,Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles() #it will use the built-in Windows theming to style controls instead of the "classic Windows" look and feel

$driveletter = $pwd.drive.name #Retourne la Lettre du disque utilisé  exemple: D
$root = "$driveletter" + ":" #Rajoute : après la lettre trouvée. exemple: D: ,ceci permet de pouvoir l'utiliser lors des paths

$ErrorActionPreference = 'silentlycontinue'#Continuer même en cas d'erreur, cela évite que el scripte se ferme s'il rencontre une erreur

set-location "$env:SystemDrive\_Tech\Applications\Installation" #met le path dans le dossier Installation au lieu du path de PowerShell.

Import-Module "$root\_Tech\Applications\Source\modules\task.psm1" | Out-Null #importe le module pour Task, qui supprime le dossier _Tech à la fin
Import-Module "$root\_Tech\Applications\Source\modules\choco.psm1" | Out-Null #Module pour chocolatey
Import-Module "$root\_Tech\Applications\Source\modules\winget.psm1" | Out-Null #Module pour Winget
import-module "$root\_Tech\Applications\Source\modules\Voice.psm1" | Out-Null #Module pour musicdebut et getvoice
import-module "$root\_Tech\Applications\Source\modules\Logs.psm1" | Out-Null #Module pour musicdebut et getvoice

#Vérifier la présence du dossier source
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

$Form.Show() | out-null #afficher la form, ne jamais enlever sinon plus d'affichage GUI

$executionpolicy = Get-ExecutionPolicy #policy de départ pour la remettre dans la fonction end
Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force #change la policy pour que le script se passe bien

#vérifier s'il y a internet 
function Testconnexion
{
    while (!(test-connection 8.8.8.8 -Count 1 -quiet)) #Ping Google et recommence jusqu'a ce qu'il y est internet
    {
    $Labeloutput.Text += "Une fois la connexion établie l'installation va débuter`r`n"
    start-sleep 5
    }
}

######Vrai début du script######
function Debut
{
    Testconnexion #appel la fonction qui test la connexion internet
    $version = (Get-WmiObject -class Win32_OperatingSystem).Caption
    $date = (Get-Date).ToString()
    addlog "installationlog.txt" "Installation de $version le $date"#ajoute la date dans le fichier texte de log
    $progres.Text = "Préparation"
    $Labeloutput.Text = "" #effacer le texte qui serait déja écrit par la fonction testconnexion
    $Labeloutput.Text += "Lancement de la configuration du Windows`r`n"
    MusicDebut "$root\_Tech\Applications\Installation\Source\Intro.mp3" #Appel la fonction qui joue la musique au début (se situe dans le module Voice.psm1)
    Chocoinstall #Download Choco
    Wingetinstall #Download Winget
}

#Mises à jour de Windows
function Msupdate
{
    $progres.Text = "Mises à jour de Windows"
    $Labeloutput.Text += "Installation des mises à jour de Windows"
    Install-PackageProvider -name Nuget -MinimumVersion 2.8.5.201 -Force | Out-Null #Prérequis pour download le module PSwindowsupdate
    Install-Module PSWindowsUpdate -Force | Out-Null #install le module pour les Update de Windows
    $path = test-path "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate" #vérifie le chemin du module
    if($path -eq $false) #si le module n'est pas là (Plan B)
    {
        choco install pswindowsupdate -y | out-null #Install le module avec Choco
    }
    Import-Module PSWindowsUpdate | out-null #Import le module
    Get-WindowsUpdate -MaxSize 250mb -Install -AcceptAll -IgnoreReboot | out-null #download et install les updates de moins de 250mb sans reboot
    $Labeloutput.Text += " -Mises à jour de Windows effectuées`r`n"
    addlog "installationlog.txt" "Mises à jour de Windows effectuées"
}

function Cortana
{
#desépingler Cortana de la taskbar
$cortanatask = get-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowCortanaButton' -ErrorAction SilentlyContinue
if($cortanatask)
{
    set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowCortanaButton' -value '0'
}

#désactivé Cortana du démarrage
$cortanastart = get-itemproperty "Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" -Name 'UserEnabledStartupOnce'
if($cortanastart)
{
    set-itemproperty "Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" -Name 'UserEnabledStartupOnce' -value '0'
}
}

#Renommer Disque
Function LabelHDD
{
    $progres.Text = "Renommage du disque"
    Set-Volume -DriveLetter 'C' -NewFileSystemLabel "OS" #Renomme le disque C: par OS
    $Labeloutput.Text += "`r`nLe disque C: a été renommé OS`r`n"
    #Get-Volume -DriveLetter 'C' | Select-Object -expand FileSystemLabel | Out-Null #donne comme résultat le nom du disque C.
    addlog "installationlog.txt" "Le disque C: a été renommé OS"
}

#Dossiers
Function Dossiers
{
    $progres.Text = "Configuration des paramètres de l'explorateur de fichiers"
    set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo' -Type 'DWord' -Value '1'
    $Labeloutput.Text += "L'accès rapide a été remplacé par Ce PC`r`n"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications' -Type 'DWord' -Value '0'
    $Labeloutput.Text += "Le fournisseur de synchronisation a été decoché`r`n"
    #Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo'   
    #Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications'   
    addlog "installationlog.txt" "Explorateur de fichiers configuré"  
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
    #Get-BitLockerVolume | Select-Object -expand VolumeStatus #FullyDecrypted
    addlog "installationlog.txt" "Bitlocker a été désactivé"
}

#Fast boot
Function DisableFastBoot
{
    $progres.Text = "Desactivation du demarrage rapide"
    powercfg /h off #désactive l'hibernation
    $Labeloutput.Text += "Le démarrage rapide a été désactivé`r`n"
    addlog "installationlog.txt" "Le démarrage rapide a été désactivé"
}
<#
$a = powercfg /a 
if(!($a -match "Hibernation is not available"))
{
    write-host "erreur"
}
#>

#supprimer le clavier anglais canada
Function Langue
{
    $progres.Text = "Suppression du clavier Anglais"
    $LangList = Get-WinUserLanguageList #Gets the language list for the current user account
    $AnglaisCanada = $LangList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
    $LangList.Remove($AnglaisCanada) | Out-Null #supprimer la clavier sélectionner
    Set-WinUserLanguageList $LangList -Force -WarningAction SilentlyContinue | Out-Null #applique le changement
    #if($AnglaisCanada) {write-host "erreur"}
    $Labeloutput.Text += "Le clavier Anglais a été supprimé`r`n"
    addlog "installationlog.txt" "Le clavier Anglais a été supprimé"
}
<#
Ne survit pas à 22h2
# Set WinUserLanguageList as a variable
$lang = Get-WinUserLanguageList 
$lang
# Clear the WinUserLanguageList
$lang.Clear()
# Add language to the language list
$lang.add("fr-CA")
$lang
# Remove whatever input method is present
$lang[0].InputMethodTips.Clear()
# Add this keyboard as keyboard language
$lang[0].InputMethodTips.Add('0C0C:00001009')
# Set this language list as default
Set-WinUserLanguageList $lang -Force
#https://scribbleghost.net/2018/04/30/add-keyboard-language-to-windows-10-with-powershell/
#>

#Confidentialité
Function Privacy
{
    $progres.Text = "Paramètres de confidentialité"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type 'DWord' -Value 0 

    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" 
    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled"  
    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" 
    #get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs"

    $Labeloutput.Text += "Les options de confidentialité ont été configuré`r`n"
    addlog "installationlog.txt" "Les options de confidentialité ont été configuré"  
}

#Icones sur le bureau
Function IconeBureau
{
    $progres.Text = "Installation des icones systèmes sur le bureau"
    if (!(Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) #vérifie si le chemin du registre existe
		{
			New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force #s'il n'existe pas le créé
		}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type 'DWord' -Value 0

    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 
    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" 
    $Labeloutput.Text += "Les icones systèmes ont été installés sur le bureau`r`n"
    addlog "installationlog.txt" "Les icones systèmes ont été installés sur le bureau"
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
    addlog "installationlog.txt" "Mises à jour de Microsoft Store"
}
 

function Preverifsoft($softname,$softpath,$softpath32,$softpathdata)
{
   $pathexist = $false
   if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
   {
     $pathexist = $true
     $Labeloutput.Text += " -$softname est déja installé`r`n"
   }
   return $pathexist
}

function Postverifsoft ($softname,$softpath,$softpath32,$softpathdata,$choconame)
{
    choco install $choconame -y | out-null
    if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
    {   
        $Labeloutput.Text += " -$softname installé avec succès`r`n"
    }
    else
    {
        $Labeloutput.Text += " -$softname a échoué`r`n"
    } 
}
    
function Software($softname,$softpath,$softpath32,$softpathdata,$wingetname,$choconame)
{   
    $progres.Text = "Installation de $softname"
    $Labeloutput.Text += "Installation de $softname en cours"
    $pathexist = Preverifsoft $softname $softpath $softpath32 $softpathdata #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {  
            winget install -e --id $wingetname --accept-package-agreements --accept-source-agreements --silent | out-null 
            if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
            {
                $Labeloutput.Text += " -$softname installé avec succès`r`n"  
            } 
            else
            {
                Postverifsoft $softname $softpath $softpath32 $softpathdata $choconame
            }
        }       
    addlog "installationlog.txt" "Installation de $softname"      
}

function plancgoogle($softpath,$softpath32,$softpathdata)
{
    if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
    {}
    else
    {
        Start-Process "$root\_Tech\Applications\Installation\Source\Ninite Chrome Installer.exe" -Verb runAs #escape pour terminer
    }
}
function plancteamviewer($softpath,$softpath32,$softpathdata)
{
    if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
    {}
    else
    {
        Start-Process "$root\_Tech\Applications\Installation\Source\Ninite TeamViewer 15 Installer.exe" -Verb runAs #escape pour terminer
    }
}

#Gérer les pilotes
#Lenovo
function PreverifSystemUpdate
{
   $pathexist = $false
   $SystemUpdatepath = Test-Path "$env:SystemDrive\Program Files (x86)\Lenovo\System Update\tvsu.exe" 
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
    $SystemUpdatepath = Test-Path "$env:SystemDrive\Program Files (x86)\Lenovo\System Update\tvsu.exe"         
    if($SystemUpdatepath -eq $true)
    {   
        $Labeloutput.Text += " -Lenovo System Update installé avec succès`r`n"
    }
    else
    {
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
            $SystemUpdatepath = Test-Path "$env:SystemDrive\Program Files (x86)\Lenovo\System Update\tvsu.exe"
            if($SystemUpdatepath)
            {
                $Labeloutput.Text += " -Lenovo System Update installé avec succès`r`n"  
            } 
            else
            {
                PostverifSystemUpdate
            }         
        }             
    addlog "installationlog.txt" "Installation de Lenovo System Update"      
}

Lenovo Vantage
function LenovoVantage
{
    $progres.Text = "Installation de Lenovo Vantage"
    $Labeloutput.Text += "Installation de Lenovo Vantage"
    winget install -e --id 9WZDNCRFJ4MV --accept-package-agreements --accept-source-agreements --silent | out-null
    $Labeloutput.Text += " -Lenovo Vantage installé avec succès`r`n" 
    addlog "installationlog.txt" "Installation de Lenovo Vantage" 
}

<#
function PreverifVantage
{
   $pathexist = $false
   $Vantagepath = Test-Path "C:\ProgramData\Lenovo\Vantage" #si déja ouvert.
   #$Prevantagepsth Test-Path "C:\Users\test\AppData\Local\Packages\E046963F.LenovoCompanion_k1h2ywk1493x8" #si jamais ouvert
   if($Vantagepath -eq $true)
   {
     $pathexist = $true
     $Labeloutput.Text += " -Lenovo Vantage est déja installé`r`n"
   }
   return $pathexist
}
#>

#Dell
function PreverifDellSA
{
   $pathexist = $false
   $DellSApath = Test-Path "$env:SystemDrive\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe" 
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
    $DellSApath = Test-Path "$env:SystemDrive\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe"         
    if($DellSApath -eq $true)
    {   
        $Labeloutput.Text += " -Dell Command Update installé avec succès`r`n"
    }
    else
    {
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
            $DellSApath = Test-Path "$env:SystemDrive\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe"         
            if($DellSApath)
            {
                $Labeloutput.Text += " -Dell Command Update installé avec succès`r`n" 
            } 
            else
            {
                PostverifDellSA
            }  
        }         
    addlog "installationlog.txt" "Installation de  Dell Command Update"      
}

#HP
function PreverifHP
{
   $pathexist = $false
   $HPpath = Test-Path "$env:SystemDrive\Program Files (x86)\HP\HP Support Framework\hpsupportassistant.dll" 
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
            $HPpath = Test-Path "$env:SystemDrive\Program Files (x86)\HP\HP Support Framework\hpsupportassistant.dll" 
            if($HPpath) #Pas de winget de dispo, donc pas de postverif
            {
                $Labeloutput.Text += " -Hp Support Assistant avec succès`r`n"
                
            }
            else 
            {
                $ErrorMessage = $_.Exception.Message
                $Labeloutput.Text += " -Hp Support Assistant a échoué`r`n"
            }  
        }  
    addlog "installationlog.txt" "Installation de Hp Support Assistant"      
}

Function Pilotes
{
    $progres.Text = "Vérification des pilotes"
    $x = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Manufacturer #Chercher la marque de l'ordinateur
    #Get-CimInstance -Class Win32_BaseBoard | Select-Object -Property Manufacturer, product # + rapide
    if($x -match 'LENOVO')
    {
        SystemUpdate
        LenovoVantage
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
   $GeForcepath = Test-Path "$env:SystemDrive\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe" 
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
    $GeForcepath = Test-Path "$env:SystemDrive\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"         
    if($GeForcepath -eq $true)
    {   
        $Labeloutput.Text += " -GeForce Experience installé avec succès`r`n"
    }
    else
    {
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
                $GeForcepath = Test-Path "$env:SystemDrive\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"     
                if($GeForcepath)
                {
                    $Labeloutput.Text += " -GeForce Experience installé avec succès`r`n"  
                } 
                else
                {
                    PostverifGeForce
                } 
            }                     
        addlog "installationlog.txt" "Installation de GeForce Experience"
    }      
}

#Function Antivirus
#{
#    start-Process "windowsdefender:"
#    [Microsoft.VisualBasic.Interaction]::MsgBox("Vérifier que l'antivirus est bien configuré, puis cliquer sur OK",'OKOnly,SystemModal,Information', "Windows -Antivirus") | Out-Null
#    #[System.Windows.MessageBox]::Show("Vérifier que l'antivirus est bien configuré, puis cliquer sur OK","Windows -Antivirus",0) | Out-Null
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
        $Labeloutput.Text += "Mise à jour de Microsoft Edge"
        winget upgrade -e -h --id Microsoft.Edge --accept-package-agreements --accept-source-agreements --silent
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
    $targetdir = "$env:SystemDrive\Users\$env:username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    $pinpath = Test-Path "$targetdir\*Google*Chrome*"
    if($pinpath -eq $false)
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Épingler Google Chrome dans la barre des tâches",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
    } 
}

function End
{
    addlog "installationlog.txt" "Installation de Windows effectué avec Succès"
    Copy-Item "$root\_Tech\Applications\Installation\Source\Log.txt" -Destination "$env:SystemDrive\TEMP" -Force | out-null     
    [Audio]::Volume = 0.25
    [console]::beep(1000,666)
    Start-Sleep -s 1
    [Audio]::Volume = 0.75
    Getvoice -Verb runAs
    Changevoice -Verb runAs
    Speak "Vous avez terminer la configuration du Windows."
    $reboot = get-wurebootstatus -Silent #vérifie si ordi doit reboot à cause de windows update
    if($reboot -eq $true)
    {
        Set-ExecutionPolicy $executionpolicy
        $Labeloutput.Text += "`r`nL'ordinateur va redémarrer pour finaliser l'installation des mises à jour"
        start-sleep -s 3
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre les logiciels par défaut et épingler Google Chrome à la barre des tâches. Cliquer sur OK pour redémarrer l'ordinateur",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        Postverif
        Task #tâche planifié qui delete tout après une minute
        shutdown /r /t 60
    }
    else 
    {
        Set-ExecutionPolicy $executionpolicy
        Postverif
        Task #tâche planifié qui delete tout après une minute  
    }     
}

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
Software "Adobe Reader" "$env:SystemDrive\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe" "$env:SystemDrive\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe" "$env:SystemDrive\Users\$env:username\AppData\Roaming\Adobe\Acrobat\DC" "Adobe.Acrobat.Reader.64-bit" "adobereader"
Software "Google chrome" "$env:SystemDrive\Program Files\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe" "Google.Chrome" "googlechrome"
plancgoogle "$env:SystemDrive\Program Files\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe"
Software "Teamviewer" "$env:SystemDrive\Program Files\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Program Files (x86)\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Users\$env:username\AppData\Roaming\TeamViewer" "TeamViewer.TeamViewer" "teamviewer"
plancteamviewer "$env:SystemDrive\Program Files\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Program Files (x86)\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Users\$env:username\AppData\Roaming\TeamViewer"
Pilotes
GeForce
License
Msstore
Msupdate
End
}
Main