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

#WPF - appMenuChoice
$xamlFile = "$pathInstallationSource\MainWindow.xaml"
$xamlContent = Read-XamlFileContent $xamlFile
$formatedXamlFile = Format-XamlFile $xamlContent
$xamlDoc = Convert-ToXmlDocument $formatedXamlFile
$XamlReader = New-XamlReader $xamlDoc
$window = New-WPFWindowFromXaml $XamlReader
$formControlsMenuApp = Get-WPFControlsFromXaml $xamlDoc $window


#ajout des events, cases a cocher, etc.. pour le WPF:

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
$window.Close()
})
$formControlsMenuApp.btnReturn.Add_Click({
    start-process "$env:SystemDrive\_Tech\Menu.bat" -verb Runas
    $window.Close()
    Exit
})
$formControlsMenuApp.btnclose.Add_Click({
    $window.Close()
    Exit
})
$formControlsMenuApp.btnQuit.Add_Click({
    Invoke-Task -TaskName 'delete _tech' -ExecutedScript 'C:\Temp\Stoolbox\Remove.bat'
    $window.Close()
    Exit
})
$formControlsMenuApp.GridToolbar.Add_MouseDown({
    $window.DragMove()
})

$window.add_Closed({
    Remove-Item -Path $installationLockFile -Force -ErrorAction SilentlyContinue
})

Start-WPFAppDialog $window

#WPF - Main GUI
$xamlFile = "$pathInstallationSource\MainWindow1.xaml"
$xamlContent = Read-XamlFileContent $xamlFile
$formatedXamlFile = Format-XamlFile $xamlContent
$xamlDoc = Convert-ToXmlDocument $formatedXamlFile
$XamlReader = New-XamlReader $xamlDoc
$window = New-WPFWindowFromXaml $XamlReader
$formControlsMain = Get-WPFControlsFromXaml $xamlDoc $window $sync

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
        "Green" { return [System.Windows.Media.Brushes]::Green }
        "Blue" { return [System.Windows.Media.Brushes]::Blue }
        default { return [System.Windows.Media.Brushes]::Black }
    }
}

# Function to add a colored line to the RichTextBox
function Add-ColoredLine {
    param (
        [string]$text,
        [string]$colorName
    )

    # Create a new Paragraph
    $paragraph = New-Object System.Windows.Documents.Paragraph

    # Create a Run element with the specified text and color
    $run = New-Object System.Windows.Documents.Run
    $run.Text = $text
    $run.Foreground = Get-BrushByName -brushName $colorName

    # Add the Run to the Paragraph
    $paragraph.Inlines.Add($run)

    # Add the Paragraph to the RichTextBox
    $global:sync["richTxtBxTaskList"].Document.Blocks.Add($paragraph)

    # Reset the color for the next line
    $defaultRun = New-Object System.Windows.Documents.Run
    $defaultRun.Text = "`n" # Add a new line character
    $defaultRun.Foreground = [System.Windows.Media.Brushes]::Black # Default color

    # Create a new Paragraph for the default color
    $defaultParagraph = New-Object System.Windows.Documents.Paragraph
    $defaultParagraph.Inlines.Add($defaultRun)

    # Add the default Paragraph to the RichTextBox
    $global:sync["richTxtBxTaskList"].Document.Blocks.Add($defaultParagraph)
}

$formControlsMain.richTxtBxTaskList.add_textchanged({
    $Window.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action]{}) #Refresh le text
    $formControlsMain.richTxtBxTaskList.ScrollToEnd() #scroll en bas
})

$formControlsMain.richTxtBxOutput.add_textchanged({
    $Window.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action]{}) #Refresh le text
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

$window.add_Closed({
    Remove-Item -Path $installationLockFile -Force -ErrorAction SilentlyContinue
    exit
})

Start-WPFApp $window
New-Item -Path $installationLockFile -ItemType 'File' -Force


#Add-ColoredLine -text "allo" -colorName "red"
#read-host "allo"
#par défaut on peut mettre en genre de gris claire toutes les task. et lors du script ca change en de couleur .
#si c'est le cas je pense que ca ca sera plus simple que chaque tache soit un label independant qui change de couleur.
<# Liste de tâches


#>

function Install-SoftwaresManager
{
    Add-Log $logFileName "Installation de $windowsVersion le $actualDate"
    $formControlsMain.lblProgress.content = "Préparation"   
    $formControlsMain.richTxtBxOutput.AppendText("Lancement de la configuration du Windows`r`n")  

    $wingetStatus = Get-WingetStatus
    if($wingetStatus -le '1.8')
    {
        $formControlsMain.richTxtBxOutput.AppendText("Installation de Winget`r`n")   
        Install-Winget
        $wingetStatus = Get-WingetStatus
        if($wingetStatus -ge '1.8')
        {
            $formControlsMain.richTxtBxOutput.AppendText("Winget a été installé`r`n")
        }
        else 
        {
            $formControlsMain.richTxtBxOutput.AppendText("Winget a échoué`r`n")
        }
    }
    else 
    {
        $formControlsMain.richTxtBxOutput.AppendText("Winget est déja installé`r`n")
    }

    $chocostatus = Get-ChocoStatus
    if($chocostatus -eq $false)
    {
        $formControlsMain.richTxtBxOutput.AppendText("Installation de Chocolatey`r`n")
        Install-Choco
        $chocostatus = Get-ChocoStatus
        if($chocostatus -eq $true)
        {
            $formControlsMain.richTxtBxOutput.AppendText("Chocolatey a été installé`r`n")
        }
        else 
        {
            $formControlsMain.richTxtBxOutput.AppendText("Chocolatey a échoué`r`n")
        }
    }
    else 
    {
        $formControlsMain.richTxtBxOutput.AppendText("Chocolatey est déja installé`r`n")
    }

    $nugetExist = Get-NugetStatus
    if($nugetExist -eq $false)
    {
        $formControlsMain.richTxtBxOutput.AppendText("Installation de NuGet`r`n")
        Install-Nuget
        $nugetExist = Get-NugetStatus
        if($nugetExist -eq $true)
        {
            $formControlsMain.richTxtBxOutput.AppendText("Nuget a été installé`r`n`r`n")
        }
        else 
        {
            $formControlsMain.richTxtBxOutput.AppendText("Nuget a échoué`r`n`r`n")
        }
    }
    else 
    {    
        $formControlsMain.richTxtBxOutput.AppendText("Nuget est déja installé`r`n`r`n")
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
        $formControlsMain.richTxtBxOutput.AppendText("`r`nL'ordinateur devra redémarrer pour finaliser l'installation des mises à jour")
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


    $formControlsMain.lblProgress.Content = "Mises à jour de Windows"
    $formControlsMain.richTxtBxOutput.AppendText("Vérification des mises à jour de Windows") 
    Initialize-WindowsUpdate 
    $maxSizeBytes = $UpdateSize * 1MB #sans ca ca marchera pas
    $updates = Get-WUList -MaxSize $maxSizeBytes
    $totalUpdates = $updates.Count
        if($totalUpdates -eq 0)
        {
            $formControlsMain.richTxtBxOutput.AppendText(" -Toutes les mises à jour sont deja installées`r`n")     
        }
        elseif($totalUpdates -gt 0)
        {
            $formControlsMain.richTxtBxOutput.AppendText(" -$totalUpdates mises à jour de disponibles`r`n") 
            $currentUpdate = 0
                foreach($update in $updates)
                { 
                    $currentUpdate++ 
                    $kb = $update.KB
                    $formControlsMain.richTxtBxOutput.AppendText("Mise à jour $($currentUpdate) sur $($totalUpdates): $($update.Title)`r`n")                    
                    Get-WindowsUpdate -KBArticleID $kb -MaxSize $maxSizeBytes -Install -AcceptAll -IgnoreReboot     
                }
        }  
        else
        {
            $formControlsMain.richTxtBxOutput.AppendText(" -Échec de la vérification des mise a jours de Windows`r`n") 
        } 
   Add-Log $logFileName "Mises à jour de Windows effectuées"
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

    $systemDriverLetter = $env:SystemDrive.TrimEnd(':') #Retounre la lettre seulement sans le :
    $formControlsMain.lblProgress.Content = "Renommage du disque"    
    Set-Volume -DriveLetter $systemDriverLetter -NewFileSystemLabel $NewDiskName
    $diskName = (Get-Volume -DriveLetter $systemDriverLetter).FileSystemLabel
    if($diskName -match $NewDiskName)
    {
        $formControlsMain.richTxtBxOutput.AppendText("Le disque $env:SystemDrive a été renommé $NewDiskName`r`n")    
        Add-Log $logFileName "Le disque $env:SystemDrive a été renommé $NewDiskName"
    }
    else
    {
        $formControlsMain.richTxtBxOutput.AppendText("`r`nÉchec du renommage de disque`r`n")    
    }
}

Function Set-ExplorerDisplay
{
    $formControlsMain.lblProgress.Content = "Configuration des paramètres de l'explorateur de fichiers"
    set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo' -Type 'DWord' -Value '1'
    $formControlsMain.richTxtBxOutput.AppendText("L'accès rapide a été remplacé par Ce PC`r`n")   
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSyncProviderNotifications' -Type 'DWord' -Value '0'
    $formControlsMain.richTxtBxOutput.AppendText("Le fournisseur de synchronisation a été decoché`r`n")   
    Add-Log $logFileName "Explorateur de fichiers configuré" 
}

Function Disable-Bitlocker
{
    $formControlsMain.lblProgress.Content = "Désactivation du bitlocker"
    $bitlockerStatus = Get-BitLockerVolume -MountPoint $env:SystemDrive | Select-Object -expand VolumeStatus
    if($bitlockerStatus -eq 'FullyEncrypted')
    {
        manage-bde $env:systemdrive -off
        $formControlsMain.richTxtBxOutput.AppendText("Bitlocker a été désactivé`r`n")
        Add-Log $logFileName "Bitlocker a été désactivé"
    }
    elseif ($bitlockerStatus -eq 'EncryptionInProgress')
    {
        manage-bde $env:systemdrive -off
        $formControlsMain.richTxtBxOutput.AppendText("Bitlocker a été désactivé`r`n")
        Add-Log $logFileName "Bitlocker a été désactivé"
    }
    elseif ($bitlockerStatus -eq 'FullyDecrypted')
    {
        $formControlsMain.richTxtBxOutput.AppendText("Bitlocker est déja désactivé`r`n") 
        Add-Log $logFileName "Bitlocker est déja désactivé"
    }
    elseif ($bitlockerStatus -eq 'DecryptionInProgress')
    {
        $formControlsMain.richTxtBxOutput.AppendText("Bitlocker est déja en cours de déchiffrement`r`n") 
        Add-Log $logFileName "Bitlocker est déja en cours de déchiffrement"
    }
}

Function Disable-FastBoot
{
    $formControlsMain.lblProgress.Content = "Desactivation du demarrage rapide"    
    set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name 'HiberbootEnabled' -Type 'DWord' -Value '0'
    #powercfg /h off
    $formControlsMain.richTxtBxOutput.AppendText("Le démarrage rapide a été désactivé`r`n")   
    Add-Log $logFileName "Le démarrage rapide a été désactivé"
}

Function Remove-EngKeyboard
{
    $formControlsMain.lblProgress.Content = "Suppression du clavier Anglais"   
    $langList = Get-WinUserLanguageList #Gets the language list for the current user account
    $anglaisCanada = $langList | Where-Object LanguageTag -eq "en-CA" #sélectionne le clavier anglais canada de la liste
    $langList.Remove($anglaisCanada) | Out-Null #supprimer la clavier sélectionner
    Set-WinUserLanguageList $langList -Force -WarningAction SilentlyContinue | Out-Null #applique le changement
    $formControlsMain.richTxtBxOutput.AppendText("Le clavier Anglais a été supprimé`r`n")
    Add-Log $logFileName "Le clavier Anglais a été supprimé"
}

Function Set-Privacy
{
    $formControlsMain.lblProgress.Content = "Paramètres de confidentialité"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type 'DWord' -Value 0 
    $formControlsMain.richTxtBxOutput.AppendText("Les options de confidentialité ont été configuré`r`n") 
    Add-Log $logFileName "Les options de confidentialité ont été configuré"
      
}

Function Enable-DesktopIcon
{
    $formControlsMain.lblProgress.Content = "Installation des icones systèmes sur le bureau"   
    if (!(Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"))
		{
			New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force
		}
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type 'DWord' -Value 0 
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type 'DWord' -Value 0
    $formControlsMain.richTxtBxOutput.AppendText("Les icones systèmes ont été installés sur le bureau`r`n")
    $formControlsMain.richTxtBxOutput.AppendText(" `r`n") #Permet de créé un espace avant les logiciels
    Add-Log $logFileName "Les icones systèmes ont été installés sur le bureau"  
}

function Update-MsStore 
{
    $formControlsMain.lblProgress.Content = "Mises à jour du Microsoft Store"
    #pour gérer les vieilles versions qui ne vont pas s'updaté
    $storeVersion = (Get-AppxPackage Microsoft.WindowsStore).version
    if ($storeVersion -le 22110)
    {
        $formControlsMain.richTxtBxOutput.AppendText("Mettre le Store à jour manuellement`r`n")
        Start-Process "ms-windows-store:"
        return
    }

    $formControlsMain.richTxtBxOutput.AppendText("`r`nLancement des updates du Microsoft Store")
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
    $result = Get-CimInstance -Namespace $namespaceName -ClassName $className | Invoke-CimMethod -MethodName UpdateScanMethod
    if ($result.ReturnValue -eq 0) 
    {
        $formControlsMain.richTxtBxOutput.AppendText(" - Mises à jour du Microsoft Store lancées`r`n")
        Add-Log $logFileName "Mises à jour de Microsoft Store" 
    } 
    else 
    {
        $formControlsMain.richTxtBxOutput.AppendText(" - Échec des mises à jour du Microsoft Store `r`n")
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
    $checkboxes = $formControlsMenuApp.GridInstallationMenuAppChoice.Children | Where-Object {$_ -is [System.Windows.Controls.CheckBox] -and $_.Name -like "chkbox*" -and $_.IsChecked -eq $true}
    foreach ($chkbox in $checkboxes) 
    {
        $appName = "$($chkbox.Content)"
        Install-Software $appsInfo.$appName
    }
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
    $formControlsMain.richTxtBxOutput.AppendText("Installation de $appName en cours")
    $softwareInstallationStatus = Test-SoftwarePresence $appInfo
        if($softwareInstallationStatus)
        {
            $formControlsMain.richTxtBxOutput.AppendText(" -$appName est déja installé`r`n")
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
            $formControlsMain.richTxtBxOutput.AppendText(" -$appName installé avec succès`r`n") 
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
        $formControlsMain.richTxtBxOutput.AppendText(" -$appName installé avec succès`r`n")  
    }
    else
    {
        $formControlsMain.richTxtBxOutput.AppendText(" -$appName a échoué`r`n")
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
    $activated = Get-CIMInstance -query "select LicenseStatus from SoftwareLicensingProduct where LicenseStatus=1" | Select-Object -ExpandProperty LicenseStatus 
    if($activated -eq "1")
    {
        $formControlsMain.richTxtBxOutput.AppendText("`r`n$windowsVersion est activé sur cet ordinateur`r`n")       
    }
    else 
    {
        $formControlsMain.richTxtBxOutput.AppendText("`r`nWindows n'est pas activé`r`n")  
        [System.Windows.MessageBox]::Show("Windows n'est pas activé","Installation Windows",0,64) | Out-Null   
    }  
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
    Add-Log $logFileName "Installation de Windows effectué avec Succès"
    Send-FTPLogs $pathInstallationSource\$logFileName
    [Audio]::Volume = 0.25
    [console]::beep(1000,666)
    Start-Sleep -s 1
    [Audio]::Volume = 0.75
    Get-voice -Verb runAs
    Send-VoiceMessage "Vous avez terminer la configuration du Windows."
    $formControlsMain.richTxtBxOutput.AppendText("`r`nVous avez terminer la configuration du Windows.")
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
        Update-MsStore
    }
    if($formControlsMenuApp.chkboxWindowsUpdate.IsChecked -eq $true)
    { 
        Install-WindowsUpdate -UpdateSize $formControlsMenuApp.CbBoxSize.SelectedItem.Content
    }
    Complete-Installation
}
Main