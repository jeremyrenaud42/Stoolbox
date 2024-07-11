#V2.55
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
    #Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Intro.mp3' -OutFile "$pathInstallation\Source\Intro.mp3" | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Apps.JSON' -OutFile "$pathInstallation\Source\Apps.JSON" | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/MainWindow.xaml' -OutFile "$pathInstallation\Source\MainWindow.xaml" | Out-Null
}

function GetManufacturer
{
    $manufacturerBrand = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Manufacturer #Chercher la marque de l'ordinateur
    #Get-CimInstance -Class Win32_BaseBoard | Select-Object -Property Manufacturer # + rapide
    return $manufacturerBrand
}

#$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'silentlycontinue'#Continuer même en cas d'erreur, cela évite que le script se ferme s'il rencontre une erreur
$pathInstallation = "$env:SystemDrive\_Tech\Applications\Installation"
$windowsVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
PrepareDependencies
#WPF - appMenuChoice
$inputXML = importXamlFromFile "$pathInstallation\source\MainWindow.xaml"
$formatedXaml = FormatXamlFile $inputXML
$ObjectXaml = CreateXamlObject $formatedXaml
$window = LoadWPFWindowFromXaml $ObjectXaml
$formControlsMenuApp = GetWPFObjects $formatedXaml $window

#ajout des events, cases a cocher
#Default Install setup
$formControlsMenuApp.chkboxAdobe.IsChecked = $true
$formControlsMenuApp.chkboxGoogleChrome.IsChecked = $true
$manufacturerBrand = GetManufacturer
if($manufacturerBrand -match 'LENOVO')
{
    $formControlsMenuApp.chkboxLenovoVantage.IsChecked = $true
    $formControlsMenuApp.chkboxLenovoSystemUpdate.IsChecked = $true
}
elseif($manufacturerBrand -match 'HP')
{        
    $formControlsMenuApp.chkboxHPSA.IsChecked = $true
}
elseif($manufacturerBrand -match 'DELL')
{
    $formControlsMenuApp.chkboxDellsa.IsChecked = $true
}
elseif($manufacturerBrand -like '*Micro-Star*')
{
    $formControlsMenuApp.chkboxMSICenter.IsChecked = $true
}
$VideoController = Get-WmiObject win32_VideoController | Select-Object -Property name
if($VideoController -match 'NVIDIA')
{
    $formControlsMenuApp.chkboxGeForce.IsChecked = $true
}
#$formControlsMenuApp.btnGo.Add_Click({})

LaunchWPFAppDialog $window

function InstallCheckedSoftware
{
    if($formControlsMenuApp.chkboxAdobe.IsChecked -eq $true)
    {
        $appName = "Adobe Reader"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxGoogleChrome.IsChecked -eq $true)
    {
        $appName = "Google chrome"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxTeamviewer.IsChecked -eq $true)
    {
        $appName = "Teamviewer"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxLenovoSystemUpdate.IsChecked -eq $true)
    {
        $appName = "Lenovo System Update"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxLenovoVantage.IsChecked -eq $true)
    {
        $appName = "Lenovo Vantage"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxHPSA.IsChecked -eq $true)
    {   
        InstallHPSA
    }
    if($formControlsMenuApp.chkboxDellsa.IsChecked -eq $true)
    {
        InstallDellSA
    }
    if($formControlsMenuApp.chkboxMyAsus.IsChecked -eq $true)
    {
        $appName = "MyAsus"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxMSICenter.IsChecked -eq $true)
    {
        $appName = "MSI Center"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxGeForce.IsChecked -eq $true)
    {
        $appName = "GeForce Experience"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxVLC.IsChecked -eq $true)
    {
        $appName = "VLC"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkbox7zip.IsChecked -eq $true)
    {
        $appName = "7Zip"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxSteam.IsChecked -eq $true)
    {
        $appName = "Steam"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxZoom.IsChecked -eq $true)
    {
        $appName = "Zoom"
        InstallSoftware $appsInfo.$appName
    }
    if($formControlsMenuApp.chkboxDiscord.IsChecked -eq $true)
    {
        $appName = "Discord"
        InstallSoftware $appsInfo.$appName
    }    
    if($formControlsMenuApp.chkboxFirefox.IsChecked -eq $true)
    {
        $appName = "Firefox"
        InstallSoftware $appsInfo.$appName
    }   
    if($formControlsMenuApp.chkboxLibreOffice.IsChecked -eq $true)
    {
        $appName = "Libre Office"
        InstallSoftware $appsInfo.$appName
    }   
    if($formControlsMenuApp.chkboxCdburnerxp.IsChecked -eq $true)
    {
        $appName = "CDBurnerXP"
        InstallSoftware $appsInfo.$appName
    } 
    if($formControlsMenuApp.chkboxIntel.IsChecked -eq $true)
    {
        $appName = "IntelDriver"
        InstallSoftware $appsInfo.$appName
    }  
    if($formControlsMenuApp.chkboxMacrium.IsChecked -eq $true)
    {
        $appName = "Macrium"
        InstallSoftware $appsInfo.$appName
    }  
    if($formControlsMenuApp.chkboxSpotify.IsChecked -eq $true)
    {
        $appName = "Spotify"
        InstallSoftware $appsInfo.$appName
    }  
    if($formControlsMenuApp.chkboxOpera.IsChecked -eq $true)
    {
        $appName = "Opera"
        InstallSoftware $appsInfo.$appName
    }     
}

#WPF - Main GUI
Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/MainWindow1.xaml' -OutFile "$pathInstallation\Source\MainWindow1.xaml" | Out-Null
$inputXML = importXamlFromFile "$pathInstallation\source\MainWindow1.xaml"
$formatedXaml = FormatXamlFile $inputXML
$ObjectXaml = CreateXamlObject $formatedXaml
$window = LoadWPFWindowFromXaml $ObjectXaml
$formControlsMain = GetWPFObjects $formatedXaml $window

LaunchWPFApp $window

function Debut
{
    $actualDate = (Get-Date).ToString()
    Addlog "installationlog.txt" "Installation de $windowsVersion le $actualDate"
    $formControlsMain.lblProgress.content = "Préparation"
    [System.Windows.Forms.Application]::DoEvents()
    $formControlsMain.richTxtBxOutput.AppendText("Lancement de la configuration du Windows`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    #MusicDebut "$pathInstallation\Source\Intro.mp3" 
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
    $formControlsMain.lblProgress.Content = "Mises à jour de Windows"
    [System.Windows.Forms.Application]::DoEvents()
    $formControlsMain.richTxtBxOutput.AppendText("Installation des mises à jour de Windows")
    [System.Windows.Forms.Application]::DoEvents()
    PrepareWindowsUpdate 
    Get-WindowsUpdate -MaxSize 250mb -Install -AcceptAll -IgnoreReboot | out-null #download et install les updates de moins de 250mb sans reboot
    $formControlsMain.richTxtBxOutput.AppendText(" -Mises à jour de Windows effectuées`r`n")
    [System.Windows.Forms.Application]::DoEvents()
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
    $formControlsMain.lblProgress.Content = "Renommage du disque"
    [System.Windows.Forms.Application]::DoEvents()
    Set-Volume -DriveLetter 'C' -NewFileSystemLabel "OS"
    $formControlsMain.richTxtBxOutput.AppendText("`r`nLe disque C: a été renommé OS`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    Addlog "installationlog.txt" "Le disque C: a été renommé OS"
}

Function ConfigureExplorer
{
    $formControlsMain.lblProgress.Content = "Configuration des paramètres de l'explorateur de fichiers"
    [System.Windows.Forms.Application]::DoEvents()
    set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo' -Type 'DWord' -Value '1'
    $formControlsMain.richTxtBxOutput.AppendText("L'accès rapide a été remplacé par Ce PC`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications' -Type 'DWord' -Value '0'
    $formControlsMain.richTxtBxOutput.AppendText("Le fournisseur de synchronisation a été decoché`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    Addlog "installationlog.txt" "Explorateur de fichiers configuré" 
}

 Function DisableBitlocker
{
    $formControlsMain.lblProgress.Content = "Désactivation du bitlocker"
    [System.Windows.Forms.Application]::DoEvents()
    $bitlockerStatus = Get-BitLockerVolume | Select-Object -expand VolumeStatus
        if ($bitlockerStatus -eq 'EncryptionInProgress')
        {
            $bitlockerVolume = Get-BitLockerVolume
            Disable-BitLocker -MountPoint $bitlockerVolume | Out-Null
            $formControlsMain.richTxtBxOutput.AppendText("Bitlocker a été désactivé`r`n")
            [System.Windows.Forms.Application]::DoEvents()
        }
    Addlog "installationlog.txt" "Bitlocker a été désactivé"
}

Function DisableFastBoot
{
    $formControlsMain.lblProgress.Content = "Desactivation du demarrage rapide"
    [System.Windows.Forms.Application]::DoEvents()
    set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name 'HiberbootEnabled' -Type 'DWord' -Value '0'
    #powercfg /h off
    $formControlsMain.richTxtBxOutput.AppendText("Le démarrage rapide a été désactivé`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    Addlog "installationlog.txt" "Le démarrage rapide a été désactivé"
}

Function RemoveEngKeyboard
{
    $formControlsMain.lblProgress.Content = "Suppression du clavier Anglais"
    [System.Windows.Forms.Application]::DoEvents()
    $langList = Get-WinUserLanguageList #Gets the language list for the current user account
    $anglaisCanada = $langList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
    $langList.Remove($anglaisCanada) | Out-Null #supprimer la clavier sélectionner
    Set-WinUserLanguageList $langList -Force -WarningAction SilentlyContinue | Out-Null #applique le changement
    $formControlsMain.richTxtBxOutput.AppendText("Le clavier Anglais a été supprimé`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    Addlog "installationlog.txt" "Le clavier Anglais a été supprimé"
}

Function ConfigurePrivacy
{
    $formControlsMain.lblProgress.Content = "Paramètres de confidentialité"
    [System.Windows.Forms.Application]::DoEvents()
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type 'DWord' -Value 0 
    $formControlsMain.richTxtBxOutput.AppendText("Les options de confidentialité ont été configuré`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    Addlog "installationlog.txt" "Les options de confidentialité ont été configuré"
    [System.Windows.Forms.Application]::DoEvents()  
}

Function DisplayDesktopIcon
{
    $formControlsMain.lblProgress.Content = "Installation des icones systèmes sur le bureau"
    [System.Windows.Forms.Application]::DoEvents()
    if (!(Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"))
		{
			New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force
		}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type 'DWord' -Value 0
    $formControlsMain.richTxtBxOutput.AppendText("Les icones systèmes ont été installés sur le bureau`r`n")
    $formControlsMain.richTxtBxOutput.AppendText(" `r`n") #Permet de créé un espace avant les logiciels
    Addlog "installationlog.txt" "Les icones systèmes ont été installés sur le bureau"
    [System.Windows.Forms.Application]::DoEvents()
}

function UpdateMsStore
{
    $formControlsMain.lblProgress.Content = "Mises à jour du Microsoft Store"
    $formControlsMain.richTxtBxOutput.AppendText("`r`nLancement des updates du Microsoft Store")
    [System.Windows.Forms.Application]::DoEvents()   
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
    $wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
    $wmiObj.UpdateScanMethod() | Out-Null
    $formControlsMain.richTxtBxOutput.AppendText(" -Mises à jour du Microsoft Store lancées`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    Addlog "installationlog.txt" "Mises à jour de Microsoft Store"
}

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
    $formControlsMain.lblProgress.Content = "Installation de $appName"
    $formControlsMain.richTxtBxOutput.AppendText("Installation de $appName en cours")
    [System.Windows.Forms.Application]::DoEvents()
    $SoftwareInstallationStatus = CheckSoftwarePresence $appInfo
        if($SoftwareInstallationStatus)
        {
            $formControlsMain.richTxtBxOutput.AppendText(" -$appName est déja installé`r`n")
            [System.Windows.Forms.Application]::DoEvents()
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
    $SoftwareInstallationStatus = CheckSoftwarePresence $appInfo
        if($SoftwareInstallationStatus)
        {
            $formControlsMain.richTxtBxOutput.AppendText(" -$appName installé avec succès`r`n")
            [System.Windows.Forms.Application]::DoEvents()
        } 
        else
        {
            InstallSoftwareWithChoco $appInfo
        }     
}

function InstallSoftwareWithChoco($apsInfo)
{
    if($appInfo.ChocoName)
    {
        choco install $appInfo.ChocoName -y | out-null
    }
    $SoftwareInstallationStatus = CheckSoftwarePresence $apsInfo
    if($SoftwareInstallationStatus)
    {   
        $formControlsMain.richTxtBxOutput.AppendText(" -$appName installé avec succès`r`n")
        [System.Windows.Forms.Application]::DoEvents()
    }
    else
    {
        $formControlsMain.richTxtBxOutput.AppendText(" -$appName a échoué`r`n")
        [System.Windows.Forms.Application]::DoEvents()
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
    InstallSoftware $appsInfo.$appName
}

function InstallHPSA
{  
    $appName = "Hp Support Assistant"
    InstallSoftware $appsInfo.$appName
}

function InstallLenovoSA
{
    $appName = "Lenovo Vantage"
    InstallSoftware $appsInfo.$appName

    $appName = "Lenovo System Update"
    InstallSoftware $appsInfo.$appName
}

Function UpdateDrivers
{
    $formControlsMain.lblProgress.Content = "Vérification des pilotes"
    [System.Windows.Forms.Application]::DoEvents()
    $manufacturerBrand = GetManufacturer
    if($manufacturerBrand -match 'LENOVO')
    {
        InstallLenovoSA
    }

    elseif($manufacturerBrand -match 'HP')
    {        
        InstallHPSA
    }

    elseif($manufacturerBrand -match 'DELL')
    {
        InstallDellSA
    }
    
    elseif($manufacturerBrand -match 'MSI')
    {   
        $appName = "MSI Center"
        InstallSoftware $appsInfo.$appName
    }
    <#
    elseif($manufacturerBrand -like 'ASUS*')
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
        InstallSoftware $appsInfo.$appName
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
        $formControlsMain.richTxtBxOutput.AppendText("`r`n$windowsVersion est activé sur cet ordinateur`r`n")
        [System.Windows.Forms.Application]::DoEvents()
    }
    else 
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Windows n'est pas activé",'OKOnly,SystemModal,Information', "Installation Windows") | Out-Null
        $formControlsMain.richTxtBxOutput.AppendText("`r`nWindows n'est pas activé`r`n")
        [System.Windows.Forms.Application]::DoEvents()
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
    Speak "Vous avez terminer la configuration du Windows."
    SetDefaultBrowser
    SetDefaultPDFViewer
    PinGoogleTaskbar
    Stop-Process -Name "ninite" -Force -erroraction ignore
    $rebootStatus = get-wurebootstatus -Silent #vérifie si ordi doit reboot à cause de windows update
    if($rebootStatus)
    {
        $formControlsMain.richTxtBxOutput.AppendText("`r`nL'ordinateur devra redémarrer pour finaliser l'installation des mises à jour")
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
InstallCheckedSoftware
CheckActivationStatus
UpdateMsStore
GetWindowsUpdate
Fin
}
Main