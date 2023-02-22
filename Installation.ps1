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
    ImportModules
    CreateFolder "_Tech\Applications\Installation\source"
    CheckInternetStatus
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Intro.mp3' -OutFile "$pathInstallation\Source\Intro.mp3" | Out-Null
}

$ErrorActionPreference = 'silentlycontinue'#Continuer même en cas d'erreur, cela évite que el scripte se ferme s'il rencontre une erreur
$pathInstallation = "$env:SystemDrive\_Tech\Applications\Installation"
$windowsVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
PrepareDependencies
#LaunchWPFApp

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

function Debut
{
    $actualDate = (Get-Date).ToString()
    Addlog "installationlog.txt" "Installation de $windowsVersion le $actualDate"
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
    Set-Volume -DriveLetter 'C' -NewFileSystemLabel "OS"
    $lblOutput.Text += "`r`nLe disque C: a été renommé OS`r`n"
    Addlog "installationlog.txt" "Le disque C: a été renommé OS"
}

Function ConfigureExplorer
{
    $lblProgres.Text = "Configuration des paramètres de l'explorateur de fichiers"
    set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo' -Type 'DWord' -Value '1'
    $lblOutput.Text += "L'accès rapide a été remplacé par Ce PC`r`n"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications' -Type 'DWord' -Value '0'
    $lblOutput.Text += "Le fournisseur de synchronisation a été decoché`r`n" 
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
    Addlog "installationlog.txt" "Bitlocker a été désactivé"
}

Function DisableFastBoot
{
    $lblProgres.Text = "Desactivation du demarrage rapide"
    powercfg /h off
    $lblOutput.Text += "Le démarrage rapide a été désactivé`r`n"
    Addlog "installationlog.txt" "Le démarrage rapide a été désactivé"
}

Function RemoveEngKeyboard
{
    $lblProgres.Text = "Suppression du clavier Anglais"
    $langList = Get-WinUserLanguageList #Gets the language list for the current user account
    $anglaisCanada = $langList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
    $langList.Remove($anglaisCanada) | Out-Null #supprimer la clavier sélectionner
    Set-WinUserLanguageList $langList -Force -WarningAction SilentlyContinue | Out-Null #applique le changement
    $lblOutput.Text += "Le clavier Anglais a été supprimé`r`n"
    Addlog "installationlog.txt" "Le clavier Anglais a été supprimé"
}

Function ConfigurePrivacy
{
    $lblProgres.Text = "Paramètres de confidentialité"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type 'DWord' -Value 0 
    $lblOutput.Text += "Les options de confidentialité ont été configuré`r`n"
    Addlog "installationlog.txt" "Les options de confidentialité ont été configuré"  
}

Function DisplayDesktopIcon
{
    $lblProgres.Text = "Installation des icones systèmes sur le bureau"
    if (!(Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"))
		{
			New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force
		}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type 'DWord' -Value 0
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
 
<#
$32bitsApp.add("VLC", "Path32")
$32bitsApp.add("7Zip", "Path32")
$32bitsApp.add("Armoury Crate", "Path32")
$32bitsApp.add("Steam", "Path32")
$32bitsApp.add("MyAsus", "Path32")
$32bitsApp.add("MSI Center", "Path32")
$32bitsApp.add("Zoom", "Path32")
$32bitsApp.add("Discord", "Path32")
$32bitsApp.add("Firefox", "Path32")
$32bitsApp.add("Libre Office", "Path32")
$32bitsApp.add("CDBurnerXP", "Path32")
#>

$64bitsApp = @{} #initialiser la hashtable
$64bitsApp.add("Adobe Reader", "$env:SystemDrive\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe")
$64bitsApp.add("Google chrome", "$env:SystemDrive\Program Files\Google\Chrome\Application\chrome.exe")
$64bitsApp.add("Teamviewer", "$env:SystemDrive\Program Files\TeamViewer\TeamViewer.exe")
$64bitsApp.add("Lenovo Vantage", $null)
$64bitsApp.add("Lenovo System Update", $null)
$64bitsApp.add("GeForce Experience", "$env:SystemDrive\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe")
$64bitsApp.add("Dell Command Update", $null)
$64bitsApp.add("HP Support Assistant", $null)

$32bitsApp = @{} #initialiser la hashtable
$32bitsApp.add("Adobe Reader", "$env:SystemDrive\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe")
$32bitsApp.add("Google chrome", "$env:SystemDrive\Program Files (x86)\Google\Chrome\Application\chrome.exe")
$32bitsApp.add("Teamviewer", "$env:SystemDrive\Program Files (x86)\TeamViewer\TeamViewer.exe")
$32bitsApp.add("Lenovo Vantage", $null)
$32bitsApp.add("Lenovo System Update", "$env:SystemDrive\Program Files (x86)\Lenovo\System Update\tvsu.exe")
$32bitsApp.add("GeForce Experience", $null)
$32bitsApp.add("Dell Command Update", "$env:SystemDrive\Program Files (x86)\Dell\CommandUpdate\dellcommandupdate.exe")
$32bitsApp.add("HP Support Assistant", "$env:SystemDrive\Program Files (x86)\HP\HP Support Framework\hpsupportassistant.dll")

$appDataApp = @{} #initialiser la hashtable
$appDataApp.add("Adobe Reader", "$env:SystemDrive\Users\$env:username\AppData\Roaming\Adobe\Acrobat\DC")
$appDataApp.add("Google chrome", "$env:SystemDrive\Users\$env:username\AppData\Local\Google\Chrome\Application\chrome.exe")
$appDataApp.add("Teamviewer", "$env:SystemDrive\Users\$env:username\AppData\Roaming\TeamViewer")
$appDataApp.add("Lenovo Vantage", "$env:SystemDrive\Users\$env:username\AppData\Local\Packages\E046963F.LenovoCompanion_k1h2ywk1493x8")
#$appDataApp.add("Lenovo System Update", "$env:SystemDrive\Users\$env:username\AppData\Local\Packages\E046963F.LenovoCompanion_k1h2ywk1493x8")
$appDataApp.add("GeForce Experience", $null)
$appDataApp.add("Dell Command Update", $null)
$appDataApp.add("HP Support Assistant", $null)

$wingetName = @{} #initialiser la hashtable
$wingetName.add("Adobe Reader", "Adobe.Acrobat.Reader.64-bit")
$wingetName.add("Google chrome", "Google.Chrome")
$wingetName.add("Teamviewer", "TeamViewer.TeamViewer")
$wingetName.add("Lenovo Vantage", "9WZDNCRFJ4MV")
$wingetName.add("Lenovo System Update", "Lenovo.SystemUpdate")
$wingetName.add("GeForce Experience", "Nvidia.GeForceExperience")
$wingetName.add("Dell Command Update", "Dell.CommandUpdate")
$wingetName.add("HP Support Assistant", $null)

$chocoName = @{} #initialiser la hashtable
$chocoName.add("Adobe Reader", "adobereader")
$chocoName.add("Google chrome", "googlechrome")
$chocoName.add("Teamviewer", "teamviewer")
$chocoName.add("Lenovo Vantage", $null)
$chocoName.add("Lenovo System Update", "lenovo-thinkvantage-system-update")
$chocoName.add("GeForce Experience", "geforce-experience")
$chocoName.add("Dell Command Update", "dellcommandupdate")
$chocoName.add("HP Support Assistant", "hpsupportassistant")

$niniteName = @{} #initialiser la hashtable
$niniteName.add("Adobe Reader", $null)
$niniteName.add("Google chrome", "$pathInstallation\Source\Ninite Chrome Installer.exe")
$niniteName.add("Teamviewer", "$pathInstallation\Source\Ninite TeamViewer 15 Installer.exe")
$niniteName.add("Lenovo Vantage", $null)
$niniteName.add("Lenovo System Update", $null)
$niniteName.add("GeForce Experience", $null)
$niniteName.add("Dell Command Update", $null)
$niniteName.add("HP Support Assistant", $null)

$niniteGithubLink = @{} #initialiser la hashtable
$niniteGithubLink.add("Adobe Reader", $null)
$niniteGithubLink.add("Google chrome", "https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Ninite Chrome Installer.exe")
$niniteGithubLink.add("Teamviewer", "https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Ninite TeamViewer 15 Installer.exe")
$niniteGithubLink.add("Lenovo Vantage", $null)
$niniteGithubLink.add("Lenovo System Update", $null)
$niniteGithubLink.add("GeForce Experience", $null)
$niniteGithubLink.add("Dell Command Update", $null)
$niniteGithubLink.add("HP Support Assistant", $null)

<#
#JSON
$JSONFilePath = "$env:SystemDrive\_Tech\Applications\Installation\Source\Apps.JSON"
$jsonString = Get-Content -Raw $JSONFilePath
$appsInfo = ConvertFrom-Json $jsonString

$appNames = $appsInfo.psobject.Properties.Name
#Iterate over the applications in the JSON and interpolate the variables
$appNames | ForEach-Object {
    $appName = $_
    $appsInfo.$appName.path64 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path64)
    $appsInfo.$appName.path32 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path32)
    $appsInfo.$appName.pathAppData = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.pathAppData)
    $appsInfo.$appName.NiniteName = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.NiniteName)
}

#Access the updated data
#$appsInfo
#Test
#$appsInfo."Google Chrome".path64
#>
function AppInfo($appName)
{
    $appInfo = [PSCustomObject]@{
        path64 = $64bitsApp[$appName]
        path32 = $32bitsApp[$appName]
        pathAppData = $appDataApp[$appName]
        WingetName = $wingetName[$appName]
        ChocoName = $chocoName[$appName]
        NiniteName = $niniteName[$appName]
        NiniteGithubLink= $niniteGithubLink[$appName]
    }
    return $appInfo
}

 function CheckSoftwarePresence($appInfo)
{
   $SoftwareInstallationStatus= $false
   if (($appInfo.path64 -AND (Test-Path $appInfo.path64)) -OR 
   ($appInfo.path32 -AND (Test-Path $appInfo.path32)) -OR 
   ($appInfo.pathAppData -AND (Test-Path $appInfo.pathAppData)))
   {
     $SoftwareInstallationStatus = $true
   }
   return $SoftwareInstallationStatus
}

function InstallSoftware($appInfo)
{
    $lblProgres.Text = "Installation de $appName"
    $lblOutput.Text += "Installation de $appName en cours"
    $SoftwareInstallationStatus = CheckSoftwarePresence $appInfo #s'il est déja installé il ne va pas poursuivre
        if($SoftwareInstallationStatus)
        {
            $lblOutput.Text += " -$appName est déja installé`r`n"
        }
        elseif($SoftwareInstallationStatus -eq $false)
        {  
            InstallSoftwareWithWinget $appInfo
        }
    Addlog "installationlog.txt" "Installation de $appName" 
}

function InstallSoftwareWithWinget($appInfo)
{
    if($appInfo.WingetName)
    {
        winget install -e --id $appInfo.wingetname --accept-package-agreements --accept-source-agreements --silent | out-null
    } 
    $SoftwareInstallationStatus = CheckSoftwarePresence $appInfo #s'il est déja installé il ne va pas poursuivre
        if($SoftwareInstallationStatus)
        {
            $lblOutput.Text += " -$appName installé avec succès`r`n"  
        } 
        else
        {
            InstallSoftwareWithChoco $appInfo
        }     
}

function InstallSoftwareWithChoco($appInfo)
{
    if($appInfo.ChocoName)
    {
        choco install $appInfo.ChocoName -y | out-null
    }
    $SoftwareInstallationStatus = CheckSoftwarePresence $appInfo
    if($SoftwareInstallationStatus)
    {   
        $lblOutput.Text += " -$appName installé avec succès`r`n"
    }
    else
    {
        $lblOutput.Text += " -$appName a échoué`r`n"
        InstallSoftwareWithNinite $appInfo
    } 
}

function InstallSoftwareWithNinite($appInfo)
{
    if($appInfo.NiniteName)
    {
    Invoke-WebRequest $appInfo.NiniteGithubLink -OutFile $appInfo.NiniteName | Out-Null
    Start-Process $appInfo.NiniteName -Verb runAs
    }
}

function InstallDellSA
{
    $appName = "Dell Command Update"
    $appInfo = AppInfo $appName
    InstallSoftware $appInfo
}

function InstallHPSA
{  
    $appName = "Hp Support Assistant"
    $appInfo = AppInfo $appName
    InstallSoftware $appInfo
}

Function UpdateDrivers
{
    $lblProgres.Text = "Vérification des pilotes"
    $x = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Manufacturer #Chercher la marque de l'ordinateur
    #Get-CimInstance -Class Win32_BaseBoard | Select-Object -Property Manufacturer # + rapide
    if($x -match 'LENOVO')
    {

        $appName = "Lenovo Vantage"
        $appInfo = AppInfo $appName
        InstallSoftware $appInfo

        $appName = "Lenovo System Update"
        $appInfo = AppInfo $appName
        InstallSoftware $appInfo

         #InstallSystemUpdate
         #InstallLenovoVantage
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

function InstallGeForceExperience
{   
$VideoController = Get-WmiObject win32_VideoController | Select-Object -Property name
    if($VideoController -match 'NVIDIA')
    {
        $appName = "GeForce Experience"
        $appInfo = AppInfo $appName
        InstallSoftware $appInfo
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

function Fin
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

$appName = "Adobe Reader"
$appInfo = AppInfo $appName
InstallSoftware $appInfo

$appName = "Google chrome"
$appInfo = AppInfo $appName
InstallSoftware $appInfo

$appName = "Teamviewer"
$appInfo = AppInfo $appName
InstallSoftware $appInfo

UpdateDrivers
InstallGeForceExperience
CheckActivationStatus
UpdateMsStore
GetWindowsUpdate
Fin
}
Main