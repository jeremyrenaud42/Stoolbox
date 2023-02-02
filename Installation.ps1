#Les assembly sont nécéssaire pour le fonctionnement du script. Ne pas effacer
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore,Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles() #it will use the built-in Windows theming to style controls instead of the "classic Windows" look and feel

function ImportModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

function CheckInternetStatus
{
    while (!(test-connection 8.8.8.8 -Count 1 -quiet)) #Ping Google et recommence jusqu'a ce qu'il y est internet
    {
    [Microsoft.VisualBasic.Interaction]::MsgBox("Veuillez vous connecter à Internet et cliquer sur OK",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
    start-sleep 5
    }
}

function PrepareDependencies
{
    set-location $pathInstallation
    CreateFolder "_Tech\Applications\Installation\source"
    ImportModules
    CheckInternetStatus
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Source.zip' -OutFile "$pathInstallation\source.zip" | Out-Null
    Expand-Archive "$pathInstallation\source.zip" "$pathInstallation\Source" -Force | Out-Null
    Remove-Item "$pathInstallation\source.zip" | Out-Null 
}

$ErrorActionPreference = 'silentlycontinue'#Continuer même en cas d'erreur, cela évite que el scripte se ferme s'il rencontre une erreur
$pathInstallation = "$env:SystemDrive\_Tech\Applications\Installation"
$windowsVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
PrepareDependencies

$form = New-Object System.Windows.Forms.Form #Créer la fenêtre GUI
$form.ClientSize = '1041,688' #Taille de la GUI
$form.Text = "Installation Windows" #Titre de la GUI (apparait en haut à gauche)
$form.StartPosition = 'Centerscreen' #position de démarrage
$form.MaximizeBox = $false #Ne peut pas s'agrandir
$form.AutoSize = $false #Ne peut pas modifier la taille de la fenêtre
$form.icon = New-Object system.drawing.icon ("$env:SystemDrive\_Tech\Applications\Source\Images\Icone.ico") #chemin de l'icone. 

#titre du champ texte de la fenêtre (en dessous du titre de la Form)
$lblTitre = New-Object System.Windows.Forms.Label #Creer la label du titre
$lblTitre.Location = New-Object System.Drawing.Point(57,0) #position du titre par rapport à la fenêtre GUI
$lblTitre.AutoSize = $false #ne peut pas adapter sa taille en fonction de chaque taille d'écran (empêche les déformations)
$lblTitre.width = 925 #largeur du label
$lblTitre.height = 50 #hateur du label
$lblTitre.TextAlign = 'middlecenter' #comment le texte apparait (aligner et centrer)
$lblTitre.Font= 'Microsoft Sans Serif,16' #la sorte et taille de police
$lblTitre.BackColor = 'darkcyan' #couleur de l'arriere plan du label
$lblTitre.Text = "Configuration du Windows" #Texte affiché dans le label
$form.Controls.Add($lblTitre) #ajoute officiellement le label. Il suffit de mettre cette ligne en commentaire et le label ne s'affichera plus

#progressbar manuel
$lblProgres = New-Object System.Windows.Forms.Label #créer la barre de progres
$lblProgres.Location = New-Object System.Drawing.Point(57,50) #position de la barre de progres
$lblProgres.AutoSize = $false #ne peut pas adapter sa taille en fonction de chaque taille d'écran (empêche les déformations)
$lblProgres.width = 925 #largeur du label
$lblProgres.height = 20 #hateur du label
$lblProgres.TextAlign = 'middlecenter' #comment le texte apparait (aligner et centrer)
$lblProgres.Font= 'Consolas,12' #la sorte et taille de police
$lblProgres.forecolor = 'white' #couleur de la police
$lblProgres.BackColor = 'darkred' #couleur de l'arriere plan du label
$form.Controls.Add($lblProgres) #ajoute officiellement le label. Il suffit de mettre cette ligne en commentaire et le label ne s'affichera plus

#Zone ou les étapes s'affiche
$lblOutput = New-Object System.Windows.Forms.Label #Créer la zone
$lblOutput.Location = New-Object System.Drawing.Point(57,70) #position de la zone
$lblOutput.AutoSize = $false #ne peut pas adapter sa taille en fonction de chaque taille d'écran (empêche les déformations)
$lblOutput.width = 925 #largeur du label
$lblOutput.height = 600 #hateur du label
$lblOutput.TextAlign = 'topLeft' #comment le texte apparait (en haut à gauche)
$lblOutput.Font= 'Microsoft Sans Serif,11' #la sorte et taille de police
$lblOutput.BorderStyle = 'fixed3D' #Style de la bordure de la zone de texte
$form.Controls.Add($lblOutput) #ajoute officiellement le label. Il suffit de mettre cette ligne en commentaire et le label ne s'affichera plus

$form.Show() | out-null #afficher la form, ne jamais enlever sinon plus d'affichage GUI

######Vrai début du script######
function Debut
{
    $actualDate = (Get-Date).ToString()
    Addlog "installationlog.txt" "Installation de $windowsVersion le $actualDate"#ajoute la date dans le fichier texte de log
    $lblProgres.Text = "Préparation"
    $lblOutput.Text += "Lancement de la configuration du Windows`r`n"
    MusicDebut "$pathInstallation\Source\Intro.mp3" 
    Chocoinstall
    Wingetinstall
}

function PrepareWindowsUpdate
{
    Install-PackageProvider -name Nuget -MinimumVersion 2.8.5.201 -Force | Out-Null #Prérequis pour download le module PSwindowsupdate
    Install-Module PSWindowsUpdate -Force | Out-Null #install le module pour les Update de Windows
    $pathPSWindowsUpdateExist = test-path "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate" 
    if($pathPSWindowsUpdateExist -eq $false) #si le module n'est pas là (Plan B)
    {
        choco install pswindowsupdate -y | out-null
    }
    Import-Module PSWindowsUpdate | out-null 
}

function GetWindowsUpdate
{
    $lblProgres.Text = "Mises à jour de Windows"
    $lblOutput.Text += "Installation des mises à jour de Windows"
    PrepareWindowsUpdate 
    Get-WindowsUpdate -MaxSize 250mb -Install -AcceptAll -IgnoreReboot | out-null #download et install les updates de moins de 250mb sans reboot
    $lblOutput.Text += " -Mises à jour de Windows effectuées`r`n"
    Addlog "installationlog.txt" "Mises à jour de Windows effectuées"
}

function UnpinCortana
{
    $cortanaTaskbarStatus = get-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowCortanaButton' -ErrorAction SilentlyContinue
    if($cortanaTaskbarStatus)
    {
        set-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowCortanaButton' -value '0'
    }
}
function DisableCortanaStartup
{
    $cortanaStartStatus = get-itemproperty "Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" -Name 'UserEnabledStartupOnce'
    if($cortanaStartStatus)
    {
        set-itemproperty "Registry::HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupId" -Name 'UserEnabledStartupOnce' -value '0'
    }
}

Function RenameSystemDrive
{
    $lblProgres.Text = "Renommage du disque"
    Set-Volume -DriveLetter 'C' -NewFileSystemLabel "OS" #Renomme le disque C: par OS
    $lblOutput.Text += "`r`nLe disque C: a été renommé OS`r`n"
    #Get-Volume -DriveLetter 'C' | Select-Object -expand FileSystemLabel | Out-Null #donne comme résultat le nom du disque C.
    Addlog "installationlog.txt" "Le disque C: a été renommé OS"
}

Function ConfigureExplorer
{
    $lblProgres.Text = "Configuration des paramètres de l'explorateur de fichiers"
    set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo' -Type 'DWord' -Value '1'
    $lblOutput.Text += "L'accès rapide a été remplacé par Ce PC`r`n"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications' -Type 'DWord' -Value '0'
    $lblOutput.Text += "Le fournisseur de synchronisation a été decoché`r`n"
    #Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo'   
    #Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications'   
    Addlog "installationlog.txt" "Explorateur de fichiers configuré"  
}

 Function DisableBitlocker
{
    $lblProgres.Text = "Désactivation du bitlocker"
    $bitlockerStatus = Get-BitLockerVolume | Select-Object -expand VolumeStatus
        if ($bitlockerStatus -eq 'EncryptionInProgress')
        {
            $bitlockerVolume = Get-BitLockerVolume
            Disable-BitLocker -MountPoint $bitlockerVolume | Out-Null
            $lblOutput.Text += "Bitlocker a été désactivé`r`n"
        }
    #Get-BitLockerVolume | Select-Object -expand VolumeStatus #FullyDecrypted
    Addlog "installationlog.txt" "Bitlocker a été désactivé"
}

Function DisableFastBoot
{
    $lblProgres.Text = "Desactivation du demarrage rapide"
    powercfg /h off #désactive l'hibernation
    $lblOutput.Text += "Le démarrage rapide a été désactivé`r`n"
    Addlog "installationlog.txt" "Le démarrage rapide a été désactivé"
}
<#
$a = powercfg /a 
if(!($a -match "Hibernation is not available"))
{
    write-host "erreur"
}
#>

Function RemoveEngKeyboard
{
    $lblProgres.Text = "Suppression du clavier Anglais"
    $langList = Get-WinUserLanguageList #Gets the language list for the current user account
    $anglaisCanada = $langList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
    $langList.Remove($anglaisCanada) | Out-Null #supprimer la clavier sélectionner
    Set-WinUserLanguageList $langList -Force -WarningAction SilentlyContinue | Out-Null #applique le changement
    #if($anglaisCanada) {write-host "erreur"}
    $lblOutput.Text += "Le clavier Anglais a été supprimé`r`n"
    Addlog "installationlog.txt" "Le clavier Anglais a été supprimé"
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

Function ConfigurePrivacy
{
    $lblProgres.Text = "Paramètres de confidentialité"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type 'DWord' -Value 0 

    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" 
    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled"  
    #get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" 
    #get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs"

    $lblOutput.Text += "Les options de confidentialité ont été configuré`r`n"
    Addlog "installationlog.txt" "Les options de confidentialité ont été configuré"  
}

Function DisplayDesktopIcon
{
    $lblProgres.Text = "Installation des icones systèmes sur le bureau"
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
    $lblOutput.Text += "Les icones systèmes ont été installés sur le bureau`r`n"
    Addlog "installationlog.txt" "Les icones systèmes ont été installés sur le bureau"
    $lblOutput.Text += " `r`n" #Permet de créé un espace avant les logiciels
}

function UpdateMsStore
{
    $lblProgres.Text = "Mises à jour du Microsoft Store"
    $lblOutput.Text += "`r`nLancement des updates du Microsoft Store"   
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
    $wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
    $wmiObj.UpdateScanMethod() | Out-Null
    $lblOutput.Text += " -Mises à jour du Microsoft Store lancées`r`n"
    Addlog "installationlog.txt" "Mises à jour de Microsoft Store"
}
 
function Preverifsoft($softname,$softpath,$softpath32,$softpathdata)
{
   $pathexist = $false
   if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
   {
     $pathexist = $true
     $lblOutput.Text += " -$softname est déja installé`r`n"
   }
   return $pathexist
}

function Postverifsoft ($softname,$softpath,$softpath32,$softpathdata,$choconame)
{
    choco install $choconame -y | out-null
    if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
    {   
        $lblOutput.Text += " -$softname installé avec succès`r`n"
    }
    else
    {
        $lblOutput.Text += " -$softname a échoué`r`n"
    } 
}
    
function InstallSoftware($softname,$softpath,$softpath32,$softpathdata,$wingetname,$choconame)
{   
    $lblProgres.Text = "Installation de $softname"
    $lblOutput.Text += "Installation de $softname en cours"
    $pathexist = Preverifsoft $softname $softpath $softpath32 $softpathdata #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {  
            winget install -e --id $wingetname --accept-package-agreements --accept-source-agreements --silent | out-null 
            if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
            {
                $lblOutput.Text += " -$softname installé avec succès`r`n"  
            } 
            else
            {
                Postverifsoft $softname $softpath $softpath32 $softpathdata $choconame
            }
        }       
    Addlog "installationlog.txt" "Installation de $softname"      
}

function plancgoogle($softpath,$softpath32,$softpathdata)
{
    if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
    {}
    else
    {   
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Ninite Chrome Installer.exe' -OutFile "$pathInstallation\Source\Ninite Chrome Installer.exe" | Out-Null
        Start-Process "$pathInstallation\Source\Ninite Chrome Installer.exe" -Verb runAs #escape pour terminer
    }
}
function plancteamviewer($softpath,$softpath32,$softpathdata)
{
    if((Test-Path $softpath) -OR (Test-Path $softpath32) -OR (Test-Path $softpathdata))
    {}
    else
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Ninite TeamViewer 15 Installer.exe' -OutFile "$pathInstallation\Source\Ninite TeamViewer 15 Installer.exe" | Out-Null
        Start-Process "$pathInstallation\Source\Ninite TeamViewer 15 Installer.exe" -Verb runAs #escape pour terminer
    }
}

function PreverifSystemUpdate
{
   $pathexist = $false
   $SystemUpdatepath = Test-Path "$env:SystemDrive\Program Files (x86)\Lenovo\System Update\tvsu.exe" 
   if($SystemUpdatepath -eq $true)
   {
     $pathexist = $true
     $lblOutput.Text += " -Lenovo System Update est déja installé`r`n"
   }
   return $pathexist
}
function PostverifSystemUpdate
{
    choco install lenovo-thinkvantage-system-update -y | out-null
    $SystemUpdatepath = Test-Path "$env:SystemDrive\Program Files (x86)\Lenovo\System Update\tvsu.exe"         
    if($SystemUpdatepath -eq $true)
    {   
        $lblOutput.Text += " -Lenovo System Update installé avec succès`r`n"
    }
    else
    {
        $lblOutput.Text += " -Lenovo System Update a échoué`r`n"
    } 
}

function InstallSystemUpdate
{   
    $lblProgres.Text = "Installation de Lenovo System Update"
    $lblOutput.Text += "Installation de Lenovo System Update en cours"
    $pathexist = PreverifSystemUpdate
        if($pathexist -eq $false)
        {   
            winget install -e --id Lenovo.SystemUpdate --accept-package-agreements --accept-source-agreements --silent | out-null  
            $SystemUpdatepath = Test-Path "$env:SystemDrive\Program Files (x86)\Lenovo\System Update\tvsu.exe"
            if($SystemUpdatepath)
            {
                $lblOutput.Text += " -Lenovo System Update installé avec succès`r`n"  
            } 
            else
            {
                PostverifSystemUpdate
            }         
        }             
    Addlog "installationlog.txt" "Installation de Lenovo System Update"      
}

function InstallLenovoVantage
{
    $lblProgres.Text = "Installation de Lenovo Vantage"
    $lblOutput.Text += "Installation de Lenovo Vantage"
    winget install -e --id 9WZDNCRFJ4MV --accept-package-agreements --accept-source-agreements --silent | out-null
    $lblOutput.Text += " -Lenovo Vantage installé avec succès`r`n" 
    Addlog "installationlog.txt" "Installation de Lenovo Vantage" 
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
     $lblOutput.Text += " -Lenovo Vantage est déja installé`r`n"
   }
   return $pathexist
}
#>

function PreverifDellSA
{
   $pathexist = $false
   $DellSApath = Test-Path "$env:SystemDrive\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe" 
   if($DellSApath -eq $true)
   {
     $pathexist = $true
     $lblOutput.Text += " -Dell Command Update est déja installé`r`n"
   }
   return $pathexist
}

function PostverifDellSA
{
    choco install dellcommandupdate -y | out-null
    $DellSApath = Test-Path "$env:SystemDrive\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe"         
    if($DellSApath -eq $true)
    {   
        $lblOutput.Text += " -Dell Command Update installé avec succès`r`n"
    }
    else
    {
        $lblOutput.Text += " -Dell Command Update a échoué`r`n"
    } 
}
 
function InstallDellSA
{   
    $lblProgres.Text = "Installation de  Dell Command Update"
    $lblOutput.Text += "Installation de  Dell Command Update en cours"
    $pathexist = PreverifDellSA #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {   
            winget install -e --id Dell.CommandUpdate --accept-package-agreements --accept-source-agreements --silent | out-null
            $DellSApath = Test-Path "$env:SystemDrive\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe"         
            if($DellSApath)
            {
                $lblOutput.Text += " -Dell Command Update installé avec succès`r`n" 
            } 
            else
            {
                PostverifDellSA
            }  
        }         
    Addlog "installationlog.txt" "Installation de  Dell Command Update"      
}

function PreverifHP
{
   $pathexist = $false
   $HPpath = Test-Path "$env:SystemDrive\Program Files (x86)\HP\HP Support Framework\hpsupportassistant.dll" 
   if($HPpath -eq $true)
   {
     $pathexist = $true
     $lblOutput.Text += " -Hp Support Assistant est déja installé`r`n"
   }
   return $pathexist
}

function InstallHPSA
{   
    $lblProgres.Text = "Installation de Hp Support Assistant"
    $lblOutput.Text += "Installation de Hp Support Assistant en cours"
    $pathexist = PreverifHP #s'il est déja installé il ne va pas poursuivre
        if($pathexist -eq $false)
        {   
            choco install hpsupportassistant -y | out-null
            $HPpath = Test-Path "$env:SystemDrive\Program Files (x86)\HP\HP Support Framework\hpsupportassistant.dll" 
            if($HPpath) #Pas de winget de dispo, donc pas de postverif
            {
                $lblOutput.Text += " -Hp Support Assistant avec succès`r`n"
                
            }
            else 
            {
                $lblOutput.Text += " -Hp Support Assistant a échoué`r`n"
            }  
        }  
    Addlog "installationlog.txt" "Installation de Hp Support Assistant"      
}

Function UpdateDrivers
{
    $lblProgres.Text = "Vérification des pilotes"
    $x = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Manufacturer #Chercher la marque de l'ordinateur
    #Get-CimInstance -Class Win32_BaseBoard | Select-Object -Property Manufacturer # + rapide
    if($x -match 'LENOVO')
    {
        InstallSystemUpdate
        InstallLenovoVantage
    }

    elseif($x -match 'HP')
    {        
        InstallHPSA
    }

    elseif($x -match 'DELL')
    {
        InstallDellSA
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

function PreverifGeForce
{
   $pathexist = $false
   $GeForcepath = Test-Path "$env:SystemDrive\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe" 
   if($GeForcepath -eq $true)
   {
     $pathexist = $true
     $lblOutput.Text += " -GeForce Experience est déja installé`r`n"
   }
   return $pathexist
}

function PostverifGeForce
{
    winget install -e --id Nvidia.GeForceExperience --accept-package-agreements --accept-source-agreements --silent | out-null
    $GeForcepath = Test-Path "$env:SystemDrive\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"         
    if($GeForcepath -eq $true)
    {   
        $lblOutput.Text += " -GeForce Experience installé avec succès`r`n"
    }
    else
    {
        $lblOutput.Text += " -GeForce Experience a échoué`r`n"
    } 
}
 
function InstallGeForce
{   
    $nvidia = Get-WmiObject win32_VideoController | Select-Object -Property name
    if($nvidia -match 'NVIDIA')
    {
        $lblProgres.Text = "Installation de GeForce Experience"
        $lblOutput.Text += "Installation de GeForce Experience en cours"
        $pathexist = PreverifGeForce #s'il est déja installé il ne va pas poursuivre
            if($pathexist -eq $false)
            {   
                choco install geforce-experience -y | out-null 
                $GeForcepath = Test-Path "$env:SystemDrive\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe"     
                if($GeForcepath)
                {
                    $lblOutput.Text += " -GeForce Experience installé avec succès`r`n"  
                } 
                else
                {
                    PostverifGeForce
                } 
            }                     
        Addlog "installationlog.txt" "Installation de GeForce Experience"
    }      
}

#Function Antivirus
#{
#    start-Process "windowsdefender:"
#    [Microsoft.VisualBasic.Interaction]::MsgBox("Vérifier que l'antivirus est bien configuré, puis cliquer sur OK",'OKOnly,SystemModal,Information', "Windows -Antivirus") | Out-Null
#    #[System.Windows.MessageBox]::Show("Vérifier que l'antivirus est bien configuré, puis cliquer sur OK","Windows -Antivirus",0) | Out-Null
#}

function CheckActivationStatus
{
    $activated = Get-CIMInstance -query "select LicenseStatus from SoftwareLicensingProduct where LicenseStatus=1" | Select-Object -ExpandProperty LicenseStatus 
    $activated
    if($activated -eq "1")
    {
        $lblOutput.Text += "`r`n$windowsVersion est activé sur cet ordinateur`r`n"
    }
    else 
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Windows n'est pas activé",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        $lblOutput.Text += "`r`nWindows n'est pas activé`r`n"
    }  
}

function UpdateEdge
{
        $lblOutput.Text += "Mise à jour de Microsoft Edge"
        winget upgrade -e -h --id Microsoft.Edge --accept-package-agreements --accept-source-agreements --silent
}

function SetDefaultBrowser
{
    $currentHttpAssocation = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\http\UserChoice | Select-Object -ExpandProperty ProgId
    $currentHttpsAssocation = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\https\UserChoice | Select-Object -ExpandProperty ProgId
    if(($currentHttpAssocation -notlike "ChromeHTML*") -and ($currentHttpsAssocation -notlike "ChromeHTML*"))
    {
        Start-Process ms-settings:defaultapps
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre Google Chrome par défaut",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
    }
}
   
function SetDefaultPDFViewer
{
    $currentDefaultPdfViewer = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice | Select-Object -ExpandProperty ProgId
    if($currentDefaultPdfViewer -notlike "*.Document.DC")
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Mettre Adobe Reader par défaut",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
    }
}
    
function PinGoogleTaskbar
{
    $taskbardir = "$env:SystemDrive\Users\$env:username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    $chromeTaskbarStatus= Test-Path "$taskbardir\*Google*Chrome*"
    if($chromeTaskbarStatus-eq $false)
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Épingler Google Chrome dans la barre des tâches",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null   
    } 
}

function End
{
    Addlog "installationlog.txt" "Installation de Windows effectué avec Succès"
    CopyLog "installationlog.txt" "$env:SystemDrive\TEMP"  
    [Audio]::Volume = 0.25
    [console]::beep(1000,666)
    Start-Sleep -s 1
    [Audio]::Volume = 0.75
    Getvoice -Verb runAs
    Changevoice -Verb runAs
    Speak "Vous avez terminer la configuration du Windows."
    SetDefaultBrowser
    SetDefaultPDFViewer
    PinGoogleTaskbar
    $rebootStatus = get-wurebootstatus -Silent #vérifie si ordi doit reboot à cause de windows update
    if($rebootStatus)
    {
        $lblOutput.Text += "`r`nL'ordinateur devra redémarrer pour finaliser l'installation des mises à jour"
        [Microsoft.VisualBasic.Interaction]::MsgBox("L'ordinateur devra redémarrer pour finaliser l'installation des mises à jour",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        shutdown /r /t 300
        Task #tâche planifié qui delete tout
    }
    else 
    {
        Task #tâche planifié qui delete tout  
    }     
}

function Main
{
Debut
UpdateMsStore
RenameSystemDrive
ConfigureExplorer
DisableBitlocker
DisableFastBoot
RemoveEngKeyboard
ConfigurePrivacy
DisplayDesktopIcon
InstallSoftware "Adobe Reader" "$env:SystemDrive\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe" "$env:SystemDrive\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe" "$env:SystemDrive\Users\$env:username\AppData\Roaming\Adobe\Acrobat\DC" "Adobe.Acrobat.Reader.64-bit" "adobereader"
InstallSoftware "Google chrome" "$env:SystemDrive\Program Files\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe" "Google.Chrome" "googlechrome"
plancgoogle "$env:SystemDrive\Program Files\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Program Files (x86)\Google\Chrome\Application\chrome.exe" "$env:SystemDrive\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe"
InstallSoftware "Teamviewer" "$env:SystemDrive\Program Files\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Program Files (x86)\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Users\$env:username\AppData\Roaming\TeamViewer" "TeamViewer.TeamViewer" "teamviewer"
plancteamviewer "$env:SystemDrive\Program Files\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Program Files (x86)\TeamViewer\TeamViewer.exe" "$env:SystemDrive\Users\$env:username\AppData\Roaming\TeamViewer"
UpdateDrivers
InstallGeForce
CheckActivationStatus
UpdateMsStore
GetWindowsUpdate
End
}
Main