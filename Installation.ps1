Add-Type -AssemblyName PresentationFramework,System.speech,System.Drawing,presentationCore

function Get-RequiredModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

function Get-Dependencies
{
    Get-RequiredModules
    Set-Location $pathInstallation #pour log
    Get-InternetStatusLoop
    Get-RemoteFile "InstallationApps.JSON" 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/InstallationApps.JSON' "$pathInstallationSource"
    Get-RemoteFile "MainWindow.xaml" 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/MainWindow.xaml' "$pathInstallationSource"
    Get-RemoteFile "MainWindow1.xaml" 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/MainWindow1.xaml' "$pathInstallationSource"
}

function Get-Manufacturer
{
    #$manufacturerBrand = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property Manufacturer #Chercher la marque de l'ordinateur
    $manufacturerBrand = Get-CimInstance -Class Win32_BaseBoard | Select-Object -Property Manufacturer # + rapide
    return $manufacturerBrand
}

$ErrorActionPreference = 'silentlycontinue'#Continuer même en cas d'erreur, cela évite que le script se ferme s'il rencontre une erreur
$pathInstallation = "$env:SystemDrive\_Tech\Applications\Installation"
$pathInstallationSource = "$env:SystemDrive\_Tech\Applications\Installation\source"
$windowsVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
$actualDate = (Get-Date).ToString()
$applicationPath = "$env:SystemDrive\_Tech\Applications"
$sourceFolderPath = "$applicationPath\source"
$installationLockFile = "$sourceFolderPath\Installation.lock"
Get-Dependencies
$logFileName = Initialize-LogFile $pathInstallationSource
$adminStatus = Get-AdminStatus
if($adminStatus -eq $false)
{
    Restart-Elevated -Path $pathInstallation\Installation.ps1
}
$Global:installationIdentifier = "Installation.ps1"
Test-ScriptInstance $installationLockFile $Global:installationIdentifier
############################GUI####################################
#WPF - appMenuChoice
$xamlFileMenuApp = "$pathInstallationSource\MainWindow.xaml"
$xamlContentMenuApp = Read-XamlFileContent $xamlFileMenuApp
$formatedXamlFileMenuApp = Format-XamlFile $xamlContentMenuApp
$xamlDocMenuApp = Convert-ToXmlDocument $formatedXamlFileMenuApp
$XamlReaderMenuApp = New-XamlReader $xamlDocMenuApp
$windowMenuApp = New-WPFWindowFromXaml $XamlReaderMenuApp
$formControlsMenuApp = Get-WPFControlsFromXaml $xamlDocMenuApp $windowMenuApp

#ajout des events, cases a cocher, etc.. pour appMenuChoice:
#Logiciels à cocher automatiquement
$manufacturerBrand = Get-Manufacturer
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
$videoController = Get-WmiObject win32_videoController | Select-Object -Property name
if($videoController -match 'NVIDIA')
{
    $formControlsMenuApp.chkboxGeForce.IsChecked = $true
}
#Boutons
$formControlsMenuApp.btnGo.Add_Click({
$windowMenuApp.Close()
})
$formControlsMenuApp.btnReturn.Add_Click({
    start-process "$env:SystemDrive\_Tech\Menu.bat" -verb Runas
    $windowMenuApp.Close()
    Exit
})
$formControlsMenuApp.btnclose.Add_Click({
    $windowMenuApp.Close()
    Exit
})
$formControlsMenuApp.btnQuit.Add_Click({
    Invoke-Task -TaskName 'delete _tech' -ExecutedScript 'C:\Temp\Stoolbox\Remove.bat'
    $windowMenuApp.Close()
    Exit
})
$formControlsMenuApp.GridToolbar.Add_MouseDown({
    $windowMenuApp.DragMove()
})

$windowMenuApp.add_Closed({
    Remove-Item -Path $installationLockFile -Force -ErrorAction SilentlyContinue
})

#WPF - Main GUI
$xamlFileMain = "$pathInstallationSource\MainWindow1.xaml"
$xamlContentMain = Read-XamlFileContent $xamlFileMain
$formatedXamlFileMain = Format-XamlFile $xamlContentMain
$xamlDocMain = Convert-ToXmlDocument $formatedXamlFileMain
$XamlReaderMain = New-XamlReader $xamlDocMain
$windowMain = New-WPFWindowFromXaml $XamlReaderMain
$formControlsMain = Get-WPFControlsFromXaml $xamlDocMain $windowMain $sync

# Function to get a Brush by name
function Get-BrushByName 
{
    param 
    (
        [string]$brushName
    )

    switch ($brushName) 
    {
        "Red" { return [System.Windows.Media.Brushes]::Red }
        "Green" { return [System.Windows.Media.Brushes]::MediumSeaGreen }
        "Blue" { return [System.Windows.Media.Brushes]::DodgerBlue }
        default { return [System.Windows.Media.Brushes]::white }
    }
}

function Add-Text 
{
    param
    (
        [string]$text,
        [string]$colorName,
        [switch]$SameLine = $false
    )
    # Create a Run element with the specified text and color
    $run = New-Object System.Windows.Documents.Run
    $run.Text = $text
    $run.Foreground = Get-BrushByName -brushName $colorName
    
    # Get the document and last paragraph
    $document = $global:sync["richTxtBxOutput"].Document
    $lastParagraph = $document.Blocks.LastBlock
    
    if ($lastParagraph -eq $null) {
        # If no paragraph exists, create one
        $lastParagraph = New-Object System.Windows.Documents.Paragraph
        $document.Blocks.Add($lastParagraph)
    }
    
    # If not using SameLine, add a line break
    if (-not $SameLine) {
        $lineBreak = New-Object System.Windows.Documents.LineBreak
        $lastParagraph.Inlines.Add($lineBreak)
    }
    
    # Add the colored run to the paragraph
    $lastParagraph.Inlines.Add($run)
}

$formControlsMain.richTxtBxOutput.add_textchanged({
    $WindowMain.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action]{}) #Refresh le text
    $formControlsMain.richTxtBxOutput.ScrollToEnd() #scroll en bas
})

$cbBoxSizeDefaultValue = "250"
$cbBoxRestartTimereDefaultValue = "300"

if (-not $formControlsMenuApp.CbBoxSize.SelectedItem) 
{
    $formControlsMenuApp.CbBoxSize.SelectedItem = $formControlsMenuApp.CbBoxSize.Items | Where-Object { $_.Content -eq $cbBoxSizeDefaultValue }
}

if (-not $formControlsMenuApp.CbBoxRestartTimer.SelectedItem) 
{
    $formControlsMenuApp.CbBoxRestartTimer.SelectedItem = $formControlsMenuApp.CbBoxRestartTimer.Items | Where-Object { $_.Content -eq $cbBoxRestartTimereDefaultValue }
}

$windowMain.add_Closed({
    Remove-Item -Path $installationLockFile -Force -ErrorAction SilentlyContinue
    exit
})

$formControlsMain.lblWinget.foreground = "white"
$formControlsMain.lblChoco.foreground = "white"
$formControlsMain.lblNuget.foreground = "white"
$formControlsMain.lblSoftware.foreground = "white"
$formControlsMain.lblActivation.foreground = "white"
$formControlsMain.lblManualComplete.foreground = "white"
if($formControlsMenuApp.chkboxMSStore.IsChecked -eq $true)
{ 
    $formControlsMain.lblStore.foreground = "white"
}
if($formControlsMenuApp.chkboxDisque.IsChecked -eq $true)
{ 
    $formControlsMain.lblDisk.foreground = "white"
}
if($formControlsMenuApp.chkboxExplorer.IsChecked -eq $true)
{ 
    $formControlsMain.lblExplorer.foreground = "white"
}
if($formControlsMenuApp.chkboxBitlocker.IsChecked -eq $true)
{ 
    $formControlsMain.lblBitlocker.foreground = "white"
}
if($formControlsMenuApp.chkboxStartup.IsChecked -eq $true)
{ 
    $formControlsMain.lblStartup.foreground = "white"
}
if($formControlsMenuApp.chkboxClavier.IsChecked -eq $true)
{ 
    $formControlsMain.lblkeyboard.foreground = "white"
}
if($formControlsMenuApp.chkboxConfi.IsChecked -eq $true)
{ 
    $formControlsMain.lblPrivacy.foreground = "white"
}
if($formControlsMenuApp.chkboxIcone.IsChecked -eq $true)
{
    $formControlsMain.lblDesktopIcon.foreground = "white"  
}
if($formControlsMenuApp.chkboxMSStore.IsChecked -eq $true)
{ 
    $formControlsMain.lblStore2.foreground = "white"
}
if($formControlsMenuApp.chkboxWindowsUpdate.IsChecked -eq $true)
{ 
    $formControlsMain.lblUpdate.foreground = "white"
}

$formControlsMain.btnclose.Add_Click({
    $windowMain.Close()
    Exit
})
$formControlsMain.btnmin.Add_Click({
    $windowMain.WindowState = [System.Windows.WindowState]::Minimized
})
$formControlsMain.Titlebar.Add_MouseDown({
    $windowMain.DragMove()
})

function Install-SoftwaresManager
{
    Add-Log $logFileName "Installation de $windowsVersion le $actualDate"
    $formControlsMain.lblProgress.content = "Préparation"

    $formControlsMain.lblWinget.foreground = "DodgerBlue"
    $wingetStatus = Get-WingetStatus
    Add-Text -text "Installation de Winget"
    if($wingetStatus -le '1.8')
    {
        Install-Winget
        $wingetStatus = Get-WingetStatus
        if($wingetStatus -ge '1.8')
        {
            Add-Text -text " - Winget a été installé" -SameLine
            $formControlsMain.lblWinget.foreground = "MediumSeaGreen"
        }
        else 
        {
            Add-Text -text " - Winget a échoué" -colorName "red" -SameLine
            $formControlsMain.lblWinget.foreground = "red"
        }
    }
    else 
    {
        Add-Text -text " - Winget est déja installé" -SameLine
        $formControlsMain.lblWinget.foreground = "MediumSeaGreen"
    }

    $formControlsMain.lblChoco.foreground = "DodgerBlue"
    $chocostatus = Get-ChocoStatus
    Add-Text -text "Installation de Chocolatey"
    if($chocostatus -eq $false)
    {
        Install-Choco
        $chocostatus = Get-ChocoStatus
        if($chocostatus -eq $true)
        {
            Add-Text -text " - Chocolatey a été installé" -SameLine
            $formControlsMain.lblChoco.foreground = "MediumSeaGreen"
        }
        else 
        {
            Add-Text -text " - Chocolatey a échoué" -colorName "red" -SameLine
            $formControlsMain.lblChoco.foreground = "red"
        }
    }
    else 
    {
        Add-Text -text " - Chocolatey est déja installé" -SameLine 
        $formControlsMain.lblChoco.foreground = "MediumSeaGreen"
    }

    $formControlsMain.lblNuget.foreground = "DodgerBlue"
    $nugetExist = Get-NugetStatus
    Add-Text -text "Installation de NuGet"
    if($nugetExist -eq $false)
    {   
        Install-Nuget
        $nugetExist = Get-NugetStatus
        if($nugetExist -eq $true)
        {
            Add-Text -text " - Nuget a été installé" -SameLine
            Add-Text -text "`n"
            $formControlsMain.lblNuget.foreground = "MediumSeaGreen"
        }
        else 
        {
            Add-Text -text " - Nuget a échoué" -colorName = "red" -SameLine
            Add-Text -text "`n"
            $formControlsMain.lblNuget.foreground = "red"
        }
    }
    else 
    {    
        Add-Text -text " - Nuget est déja installé" -SameLine
        Add-Text -text "`n"
        $formControlsMain.lblNuget.foreground = "MediumSeaGreen"
    }
}

function Update-MsStore 
{
    $formControlsMain.lblStore.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Mises à jour du Microsoft Store"
    #pour gérer les vieilles versions qui ne vont pas s'updaté
    $storeVersion = (Get-AppxPackage Microsoft.WindowsStore).version
    if ($storeVersion -le 22110)
    {
        Add-Text -text "Mettre le Store à jour manuellement"
        Start-Process "ms-windows-store:"
        return
    }
    Add-Text -text "Lancement des updates du Microsoft Store"
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
    $result = Get-CimInstance -Namespace $namespaceName -ClassName $className | Invoke-CimMethod -MethodName UpdateScanMethod
    if ($result.ReturnValue -eq 0) 
    {
        Add-Text -text " - Mises à jour du Microsoft Store lancées" -SameLine
        $formControlsMain.lblStore.foreground = "MediumSeaGreen"
        Add-Log $logFileName "Mises à jour de Microsoft Store" 
    } 
    else 
    {
        Add-Text -text " - Échec des mises à jour du Microsoft Store" -colorName "red" -SameLine
        $formControlsMain.lblStore.foreground = "red"
    }
}

Function Rename-SystemDrive
{
    <#
    .SYNOPSIS
        Renomme le lecteur C:
    .DESCRIPTION
        Renomme par OS par défaut au lieu du nom actuel (souvent disque local)
        Vérifie si ca a fonctionné
    .PARAMETER NewDiskName
        Le nouveau nom du disque
    .EXAMPLE
        Rename-SystemDrive -NewDiskName "OS"
        Renomme le disque OS
    #>
    
    
    [CmdletBinding()]
    param
    (
        [string]$NewDiskName = "OS"
    )
    $formControlsMain.lblDisk.foreground = "DodgerBlue"
    $systemDriverLetter = $env:SystemDrive.TrimEnd(':') #Retourne la lettre seulement sans le :
    $formControlsMain.lblProgress.Content = "Renommage du disque"
    $diskName = (Get-Volume -DriveLetter $systemDriverLetter).FileSystemLabel
    
    if($diskName -match $NewDiskName)
    {
        $formControlsMain.lblDisk.foreground = "MediumSeaGreen"
        Add-Text -text "Le disque est déja nommé $NewDiskName"
    }
    else
    {
        Set-Volume -DriveLetter $systemDriverLetter -NewFileSystemLabel $NewDiskName
        $diskName = (Get-Volume -DriveLetter $systemDriverLetter).FileSystemLabel

        if($diskName -match $NewDiskName)
        {
            $formControlsMain.lblDisk.foreground = "MediumSeaGreen"
            Add-Text -text "Le disque $env:SystemDrive a été renommé $NewDiskName" 
            Add-Log $logFileName "Le disque $env:SystemDrive a été renommé $NewDiskName"
        }
        else
        {
            Add-Text -text "Échec du renommage de disque" -colorName "red"    
            $formControlsMain.lblDisk.foreground = "red"
        }
    } 
}

Function Set-ExplorerDisplay
{
    $formControlsMain.lblExplorer.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Configuration des paramètres de l'explorateur de fichiers"

    $explorerLaunchWindow = (get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo').LaunchTo
    if($explorerLaunchWindow -eq '1')
    {
        Add-Text -text "Ce PC remplace déja l'accès rapide"
    }
    else 
    {
        set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo' -Type 'DWord' -Value '1'     
    }

    $providerNotifications = (get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications').ShowSyncProviderNotifications
    if($providerNotifications -eq '0')
    {
        Add-Text -text "Le fournisseur de synchronisation est déjà décoché"
    }
    else 
    {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications' -Type 'DWord' -Value '0'
    }
    $explorerLaunchWindow = (get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo').LaunchTo
    $providerNotifications = (get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications').ShowSyncProviderNotifications
    if(($explorerLaunchWindow -eq '1') -and ($providerNotifications -eq '0'))
    {
        $formControlsMain.lblExplorer.foreground = "MediumSeaGreen"
        Add-Text -text "L'accès rapide a été remplacé par Ce PC"
        Add-Text -text "Le fournisseur de synchronisation a été decoché" 
        Add-Log $logFileName "Explorateur de fichiers configuré" 
    }
    else 
    {
        $formControlsMain.lblExplorer.foreground = "red"
        if($explorerLaunchWindow -ne '1')
        {
            Add-Text -text "L'accès rapide n'a pas été remplacé par Ce PC" -colorName "red"
        }
        if($providerNotifications -ne '0')
        {
            Add-Text -text "Le fournisseur de synchronisation n'a pas été decoché" -colorName "red"
        }       
    }
}

Function Disable-Bitlocker
{
    $formControlsMain.lblBitlocker.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Désactivation du bitlocker"
    $bitlockerStatus = Get-BitLockerVolume -MountPoint $env:SystemDrive | Select-Object -expand VolumeStatus
    if($bitlockerStatus -eq 'FullyEncrypted')
    {
        manage-bde $env:systemdrive -off
        $formControlsMain.lblBitlocker.foreground = "MediumSeaGreen"
        Add-Text -text "Bitlocker a été désactivé"
        Add-Log $logFileName "Bitlocker a été désactivé"
    }
    elseif ($bitlockerStatus -eq 'EncryptionInProgress')
    {
        manage-bde $env:systemdrive -off
        $formControlsMain.lblBitlocker.foreground = "MediumSeaGreen"
        Add-Text -text "Bitlocker a été désactivé"
        Add-Log $logFileName "Bitlocker a été désactivé"
    }
    elseif ($bitlockerStatus -eq 'FullyDecrypted')
    {
        $formControlsMain.lblBitlocker.foreground = "MediumSeaGreen"
        Add-Text -text "Bitlocker est déja désactivé"
        Add-Log $logFileName "Bitlocker est déja désactivé"
    }
    elseif ($bitlockerStatus -eq 'DecryptionInProgress')
    {
        $formControlsMain.lblBitlocker.foreground = "MediumSeaGreen"
        Add-Text -text "Bitlocker est déja en cours de déchiffrement" 
        Add-Log $logFileName "Bitlocker est déja en cours de déchiffrement"
    }
    else 
    {
        $formControlsMain.lblBitlocker.foreground = "red"
        Add-Text -text "Bitlocker a échoué" -colorName "red"
        Add-Log $logFileName "Bitlocker a échoué"
    }
}

Function Disable-FastBoot
{
    $formControlsMain.lblStartup.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Desactivation du demarrage rapide"    
    $power = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name 'HiberbootEnabled').HiberbootEnabled
    if($power -eq '0')
    {  
        Add-Text -text "Le démarrage rapide est déjà désactivé"
        $formControlsMain.lblStartup.foreground = "MediumSeaGreen"
    }
    elseif($power -eq '1')
    {
        set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name 'HiberbootEnabled' -Type 'DWord' -Value '0'  
        Add-Text -text "Le démarrage rapide a été désactivé"
        Add-Log $logFileName "Le démarrage rapide a été désactivé"
        $formControlsMain.lblStartup.foreground = "MediumSeaGreen"
    }
    else  
    {
        Add-Text -text "Le démarrage rapide n'a pas été désactivé" -colorName "red"
        $formControlsMain.lblStartup.foreground = "red"
    }
}

Function Remove-EngKeyboard
{
    $formControlsMain.lblkeyboard.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Suppression du clavier Anglais"   
    $langList = Get-WinUserLanguageList #Gets the language list for the current user account
    $anglaisCanada = $langList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
    if(($anglaisCanada).LanguageTag -eq 'en-CA')
    {
        $langList.Remove($anglaisCanada) | Out-Null #supprimer la clavier sélectionner
        Set-WinUserLanguageList $langList -Force -WarningAction SilentlyContinue | Out-Null #applique le changement
        $anglaisCanada = $langList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
        if(($anglaisCanada).LanguageTag -eq 'en-CA')
        {
            Add-Text -text "Le clavier Anglais n'a pas été supprimé" -colorName "red"
            $formControlsMain.lblkeyboard.foreground = "red"
        }
        else
        {
            Add-Text -text "Le clavier Anglais a été supprimé"
            $formControlsMain.lblkeyboard.foreground = "MediumSeaGreen"
            Add-Log $logFileName "Le clavier Anglais a été supprimé"
        }
    }
    else 
    {
        Add-Text -text "Le clavier Anglais est déja supprimé"
        $formControlsMain.lblkeyboard.foreground = "MediumSeaGreen"
    }   
}

Function Set-Privacy
{
    $formControlsMain.lblPrivacy.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Paramètres de confidentialité"

    $338393 = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled")."SubscribedContent-338393Enabled"
    $353694 = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled")."SubscribedContent-353694Enabled"
    $353696 = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled")."SubscribedContent-353696Enabled"
    $Start_TrackProgs = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs")."Start_TrackProgs"
    if (($338393 -eq 0) -and ($353694 -eq 0) -and ($353696 -eq 0) -and ($Start_TrackProgs -eq 0))
    {
        Add-Text -text "Les options de confidentialité sont déjà configurées"
        $formControlsMain.lblPrivacy.foreground = "MediumSeaGreen"
    }
    else 
    {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type 'DWord' -Value 0 
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type 'DWord' -Value 0 
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type 'DWord' -Value 0 
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type 'DWord' -Value 0 
        $338393 = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled")."SubscribedContent-338393Enabled"
        $353694 = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled")."SubscribedContent-353694Enabled"
        $353696 = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled")."SubscribedContent-353696Enabled"
        $Start_TrackProgs = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs")."Start_TrackProgs"
        
        if (($338393 -eq 0) -and ($353694 -eq 0) -and ($353696 -eq 0) -and ($Start_TrackProgs -eq 0))
        { 
            Add-Text -text "Les options de confidentialité ont été configurées"
            Add-Log $logFileName "Les options de confidentialité ont été configurées"
            $formControlsMain.lblPrivacy.foreground = "MediumSeaGreen" 
        }
        else 
        {
            $formControlsMain.lblPrivacy.foreground = "red" 
            Add-Text -text "Les options de confidentialité n'ont pas été configurées" -colorName "red"
        } 
    }    
}

Function Enable-DesktopIcon
{
    $formControlsMain.lblDesktopIcon.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Installation des icones systèmes sur le bureau"   
    if (!(Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"))
		{
			New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force
		}

    $configPanel = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}")."{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
    $myPC = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}")."{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
    $userFolder = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}")."{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
    
    if (($configPanel -eq 0) -and ($myPC -eq 0) -and ($userFolder -eq 0))
    {
        Add-Text -text "Les icones systèmes sont déjà installés sur le bureau"
        Add-Text -text "`n"
        $formControlsMain.lblDesktopIcon.foreground = "MediumSeaGreen"
    }
    else 
    {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type 'DWord' -Value 0 
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type 'DWord' -Value 0 
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type 'DWord' -Value 0
        $configPanel = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}")."{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
        $myPC = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}")."{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        $userFolder = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}")."{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
        
        if (($configPanel -eq 0) -and ($myPC -eq 0) -and ($userFolder -eq 0))
        {
            Add-Text -text "Les icones systèmes ont été installés sur le bureau"
            Add-Text -text "`n" #Permet de créé un espace avant les logiciels
            Add-Log $logFileName "Les icones systèmes ont été installés sur le bureau"
            $formControlsMain.lblDesktopIcon.foreground = "MediumSeaGreen"  
        }
        else 
        {
            Add-Text -text "Les icones systèmes n'ont pas été installés sur le bureau" -colorName "red"
            Add-Text -text "`n" #Permet de créé un espace avant les logiciels
            $formControlsMain.lblDesktopIcon.foreground = "red"
        }
    }  
}

$jsonFilePath = "$pathInstallationSource\InstallationApps.JSON"
$jsonString = Get-Content -Raw $jsonFilePath
$appsInfo = ConvertFrom-Json $jsonString
$appNames = $appsInfo.psobject.Properties.Name
$appNames | ForEach-Object {
    $appName = $_
    $appsInfo.$appName.path64 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path64)
    $appsInfo.$appName.path32 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path32)
    $appsInfo.$appName.pathAppData = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.pathAppData)
    $appsInfo.$appName.NiniteName = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.NiniteName)
    }

#Install les logiciels cochés
function Get-CheckBoxStatus 
{
    $formControlsMain.lblSoftware.foreground = "DodgerBlue"
    $checkboxes = $formControlsMenuApp.GridInstallationMenuAppChoice.Children | Where-Object {$_ -is [System.Windows.Controls.CheckBox] -and $_.Name -like "chkbox*" -and $_.IsChecked -eq $true}
    foreach ($chkbox in $checkboxes) 
    {
        $appName = "$($chkbox.Content)"
        Install-Software $appsInfo.$appName
    }
    $formControlsMain.lblSoftware.foreground = "MediumSeaGreen"
}

function Test-SoftwarePresence($appInfo)
{
   $softwareInstallationStatus= $false
   if (($appInfo.path64 -AND (Test-Path $appInfo.path64)) -OR 
   ($appInfo.path32 -AND (Test-Path $appInfo.path32)) -OR 
   ($appInfo.pathAppData -AND (Test-Path $appInfo.pathAppData)))
   {
     $softwareInstallationStatus = $true
   }
   return $softwareInstallationStatus
}

function Install-Software($appInfo)
{
    $formControlsMain.lblProgress.Content = "Installation de $appName"
    Add-Text -text "Installation de $appName en cours"
    $softwareInstallationStatus = Test-SoftwarePresence $appInfo
        if($softwareInstallationStatus)
        {
            Add-Text -text "- $appName est déja installé" -SameLine
        }
        elseif($softwareInstallationStatus -eq $false)
        {  
            Install-SoftwareWithWinget $appInfo
        }
    Add-Log $logFileName "Installation de $appName" 
}

function Install-SoftwareWithWinget($appInfo)
{
    if($appInfo.WingetName)
    {
        winget install -e --id $appInfo.wingetname --accept-package-agreements --accept-source-agreements --silent | out-null
    } 
    $softwareInstallationStatus = Test-SoftwarePresence $appInfo
        if($softwareInstallationStatus)
        {
            Add-Text -text " - $appName installé avec succès" -SameLine
        } 
        else
        {
            Install-SoftwareWithChoco $appInfo
        }     
}

function Install-SoftwareWithChoco($apsInfo)
{
    if($appInfo.ChocoName)
    {
        choco install $appInfo.ChocoName -y | out-null
    }
    $softwareInstallationStatus = Test-SoftwarePresence $apsInfo
    if($softwareInstallationStatus)
    {     
        Add-Text -text " - $appName installé avec succès" -SameLine
    }
    else
    {
        Add-Text -text " - $appName a échoué" -colorName "red" -SameLine
        Install-SoftwareWithNinite $appInfo
    } 
}

function Install-SoftwareWithNinite($appInfo)
{
    if($appInfo.NiniteName)
    {
        Invoke-WebRequest $appInfo.NiniteGithubLink -OutFile $appInfo.NiniteName | Out-Null
        Start-Process $appInfo.NiniteName -Verb runAs
    }
}

function Get-ActivationStatus
{
    $formControlsMain.lblActivation.foreground = "DodgerBlue"
    $activated = Get-CIMInstance -query "select LicenseStatus from SoftwareLicensingProduct where LicenseStatus=1" | Select-Object -ExpandProperty LicenseStatus 
    if($activated -eq "1")
    {
        Add-Text -text "`n"
        Add-Text -text "$windowsVersion est activé sur cet ordinateur"
        $formControlsMain.lblActivation.foreground = "MediumSeaGreen"      
    }
    else 
    {
        Add-Text -text "`n"
        Add-Text -text "Windows n'est pas activé" -colorName "red"
        [System.Windows.MessageBox]::Show("Windows n'est pas activé","Installation Windows",0,64) | Out-Null   
        $formControlsMain.lblActivation.foreground = "red"
    }  
}

function Initialize-WindowsUpdate
{
    Install-Module PSWindowsUpdate -Force | Out-Null #install le module pour les Update de Windows
    $pathPSWindowsUpdateExist = test-path "$env:SystemDrive\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate" 
    if($pathPSWindowsUpdateExist -eq $false) #si le module n'est pas là (Plan B)
    {
        choco install pswindowsupdate -y | out-null
    }
    Import-Module PSWindowsUpdate | out-null 
}

function Get-WindowsUpdateReboot
{
    $restartComputer = $false
    $rebootStatus = get-wurebootstatus -Silent #vérifie si ordi doit reboot à cause de windows update (PSwindowsupdate)
    if($rebootStatus)
    {
        Add-Text -text "`n"
        Add-Text -text "L'ordinateur devra redémarrer pour finaliser l'installation des mises à jour"
        [System.Windows.MessageBox]::Show("L'ordinateur devra redémarrer pour finaliser l'installation des mises à jour","Installation Windows",0,64) | Out-Null    
        $restartComputer = $true
    } 
    return $restartComputer
} 

function Install-WindowsUpdate
{
    <#
    .SYNOPSIS
        Installer les mises a jour de Windows
    .DESCRIPTION
        Liste les updates de Windows qui sont disponibles
        Si il ya 0 update dispo, va afficher que c'est deja bon
        si il y a des updates de trouvé, il va les faire une par une et afficher ce qu'il fait en temps reel
    .PARAMETER UpdateSize
        La Taille maximum des mises a jour de Windows
    .EXAMPLE
        Install-WindowsUpdate -UpdateSize "250" 
        Install chaque update qui est de moins de 250mb
    #>
    
    
    [CmdletBinding()]
    param
    (
        [int]$UpdateSize = 250
    )


    $formControlsMain.lblUpdate.foreground = "DodgerBlue"
    $formControlsMain.lblProgress.Content = "Mises à jour de Windows"
    Add-Text -text "Vérification des mises à jour de Windows"
    Initialize-WindowsUpdate 
    $maxSizeBytes = $UpdateSize * 1MB #sans ca ca marchera pas
    $updates = Get-WUList -MaxSize $maxSizeBytes
    $totalUpdates = $updates.Count
        if($totalUpdates -eq 0)
        {
            Add-Text -text " - Toutes les mises à jour sont deja installées" -SameLine 
            $formControlsMain.lblUpdate.foreground = "MediumSeaGreen"   
        }
        elseif($totalUpdates -gt 0)
        {
            Add-Text -text " - $totalUpdates mises à jour de disponibles" -SameLine 
            $currentUpdate = 0
                foreach($update in $updates)
                { 
                    $currentUpdate++ 
                    $kb = $update.KB
                    Add-Text -text "Mise à jour $($currentUpdate) sur $($totalUpdates): $($update.Title)"
                    Get-WindowsUpdate -KBArticleID $kb -MaxSize $maxSizeBytes -Install -AcceptAll -IgnoreReboot     
                }
                $formControlsMain.lblUpdate.foreground = "MediumSeaGreen"
        }  
        else
        {
            Add-Text -text " - Échec de la vérification des mise a jours de Windows" -colorName "red" -SameLine
            $formControlsMain.lblUpdate.foreground = "red"
        } 
   Add-Log $logFileName "Mises à jour de Windows effectuées"
}

function Set-DefaultBrowser
{
    $currentHttpAssocation = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\http\UserChoice | Select-Object -ExpandProperty ProgId
    $currentHttpsAssocation = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Associations\URLAssociations\https\UserChoice | Select-Object -ExpandProperty ProgId
    if(($currentHttpAssocation -notlike "ChromeHTML*") -and ($currentHttpsAssocation -notlike "ChromeHTML*"))
    {
        Start-Process ms-settings:defaultapps
        [System.Windows.MessageBox]::Show("Mettre Google Chrome par défaut","Installation Windows",0,64) | Out-Null   
    }
}
   
function Set-DefaultPDFViewer
{
    $currentDefaultPdfViewer = Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice | Select-Object -ExpandProperty ProgId
    if($currentDefaultPdfViewer -notlike "*.Document.DC")
    {
        [System.Windows.MessageBox]::Show("Mettre Adobe Reader par défaut","Installation Windows",0,64) | Out-Null   
    }
}
    
function Set-GooglePinnedTaskbar
{
    $taskbardir = "$env:SystemDrive\Users\$env:username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
    $chromeTaskbarStatus= Test-Path "$taskbardir\*Google*Chrome*"
    if($chromeTaskbarStatus-eq $false)
    {
        [System.Windows.MessageBox]::Show("Épingler Google Chrome dans la barre des tâches","Installation Windows",0,64) | Out-Null   
    } 
}

function Complete-Installation
{
    $formControlsMain.lblManualComplete.foreground = "DodgerBlue"
    Add-Log $logFileName "Installation de Windows effectué avec Succès"
    Send-FTPLogs $pathInstallationSource\$logFileName
    [Audio]::Volume = 0.25
    [console]::beep(1000,666)
    Start-Sleep -s 1
    [Audio]::Volume = 0.75
    Get-voice -Verb runAs
    Send-VoiceMessage "Vous avez terminer la configuration du Windows."
    Add-Text -text "`n"
    Add-Text -text "Vous avez terminer la configuration du Windows."
    Stop-Process -Name "ninite" -Force -erroraction ignore
    if($formControlsMenuApp.chkboxGoogleChrome.IsChecked -eq $true)
    {
        Set-DefaultBrowser
        Set-GooglePinnedTaskbar
    }
    if($formControlsMenuApp.chkboxAdobe.IsChecked -eq $true)
    {
        Set-DefaultPDFViewer
    }
    $formControlsMain.lblManualComplete.foreground = "MediumSeaGreen"
    if($formControlsMenuApp.chkboxWindowsUpdate.IsChecked -eq $true)
    {
        $wuRestart = Get-WindowsUpdateReboot
        if($wuRestart -eq $true)
        {
            $restartTime = $formControlsMenuApp.CbBoxRestartTimer.SelectedItem.Content
            shutdown /r /t $restartTime
        }  
    }
    Invoke-Task -TaskName 'delete _tech' -ExecutedScript 'C:\Temp\Stoolbox\Remove.bat'
    $window.Close()
}

function Main
{
    Install-SoftwaresManager
    if($formControlsMenuApp.chkboxMSStore.IsChecked -eq $true)
    { 
        Update-MsStore
    }
    if($formControlsMenuApp.chkboxDisque.IsChecked -eq $true)
    { 
        Rename-SystemDrive -NewDiskName $formControlsMenuApp.TxtBkDiskName.text
    }
    if($formControlsMenuApp.chkboxExplorer.IsChecked -eq $true)
    { 
        Set-ExplorerDisplay
    }
    if($formControlsMenuApp.chkboxBitlocker.IsChecked -eq $true)
    { 
        Disable-Bitlocker
    }
    if($formControlsMenuApp.chkboxStartup.IsChecked -eq $true)
    { 
        Disable-FastBoot
    }
    if($formControlsMenuApp.chkboxClavier.IsChecked -eq $true)
    { 
        Remove-EngKeyboard
    }
    if($formControlsMenuApp.chkboxConfi.IsChecked -eq $true)
    { 
        Set-Privacy
    }
    if($formControlsMenuApp.chkboxIcone.IsChecked -eq $true)
    {
        Enable-DesktopIcon  
    }
    Get-CheckBoxStatus
    Get-ActivationStatus
    if($formControlsMenuApp.chkboxMSStore.IsChecked -eq $true)
    { 
        $formControlsMain.lblStore2.foreground = "DodgerBlue"
        Update-MsStore
        $formControlsMain.lblStore2.foreground = "MediumSeaGreen"
    }
    if($formControlsMenuApp.chkboxWindowsUpdate.IsChecked -eq $true)
    { 
        Install-WindowsUpdate -UpdateSize $formControlsMenuApp.CbBoxSize.SelectedItem.Content
    }
    Complete-Installation
}
Start-WPFAppDialog $windowMenuApp
Start-WPFApp $windowMain
New-Item -Path $installationLockFile -ItemType 'File' -Force
Main