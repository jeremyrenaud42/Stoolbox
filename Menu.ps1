<#
.SYNOPSIS
    Affiche un menu qui permet de sélectionner les actions à faire
.DESCRIPTION
    Directement téléchargé par le .exe il va permettre de poser les bases pour que tout fonctionne.
    vérifie donc qu'Internet soit présent, que le script soit en admin
    Créer les dossiers nécéssaires
    télécharge les modules et les importes (executionpolicy doit etre a unrestricted pour que ca importe)
    télécharge le script qui permet d'effacer/desisntaller le tout
    affiche un menu généré en WPF par un fichier XAML
    Permet d'installer winget et choco tout de suite au besoin
    Affiche les boutons qui ouvre les autres scripts
.NOTES
    est initialement downloadé par Stoolbox.exe depuis github
    Par la suite il ya un raccourci sur le bureau pour l'appeler
    Ou directement via le menu.bat dans c:\_tech
#>

#Load les assemblies nécéssaire au fonctionnement
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore
########################Fonctions nécéssaire au déroulement########################
function Test-InternetConnection
{
    <#
    .SYNOPSIS
        Vérifie si il y a Internet de connecté
    .DESCRIPTION
        Envoi une seule requête PING vers 8.8.8.8 (google.com)
        Tant que la requête échoue ca affiche un message aux 5 secondes qui mentionne qu'il n'y a pas Internet
        Le message disparait après avoir cliquer OK si Internet est connecté.
    .PARAMETER PingAddress
        Adresse IP utilisé pour le ping. Defaut = 8.8.8.8 (Google.com)
    .PARAMETER CheckInterval
        Le nombre de délai avant de recommencer la reqête ping. Defaut = 5 secondes
    .EXAMPLE
        Test-InternetConnection
        Tests the internet connection using default parameters (pinging 8.8.8.8 every 5 seconds).
    .EXAMPLE
        Test-InternetConnection -PingAddress "1.1.1.1" -CheckInterval 10
        Tests the internet connection by pinging 1.1.1.1 and checking every 10 seconds.
    .Notes
        Ne prend pas la fonction deja inclus dans le module Verifiation car a ce moment la on a pas les modules de downloadé
    #>


    [CmdletBinding()]
    param
    (
        [string]$PingAddress = "8.8.8.8",

        [int]$CheckInterval = 5
    )


    while (!(test-connection $PingAddress -Count 1 -quiet))
    {
        $messageBoxText = "Veuillez vous connecter à Internet et cliquer sur OK"
        $messageBoxTitle = "Menu - Boite à outils du technicien"
        $failMessageBox = [System.Windows.MessageBox]::Show($messageBoxText,$messageBoxTitle,1,48)
        if($failMessageBox -eq 'Cancel')
        {
            exit
        }
        start-sleep $CheckInterval
    }
}

function Get-RequiredModules
{
    <#
    .SYNOPSIS
        Download les modules nécéssaires pour tous les scripts
    .DESCRIPTION
        Download depuis github vers c:\_tech\applications\source
        C'est un zip qui les contient tous qui va être dezippé sous le dossier module
    #>
    $modulesFolderPath = "$sourceFolderPath\Modules"
    $modulesFolderPathExist = test-path -Path $modulesFolderPath
    if($modulesFolderPathExist -eq $false)
    {
        $zipFileDownloadLink = 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip'
        $zipFile = "Modules.zip"
        Invoke-WebRequest -Uri $zipFileDownloadLink -OutFile $sourceFolderPath\$zipFile
        Expand-Archive -Path $sourceFolderPath\$zipFile -DestinationPath $sourceFolderPath -Force
        Remove-Item -Path $sourceFolderPath\$zipFile
    }
}

function Import-RequiredModules
{
    <#
    .SYNOPSIS
        Importe les modules nécéssaires pour tous les scripts
    .DESCRIPTION
       Importe tous les modules du dossier "$env:SystemDrive\_Tech\Applications\Source\modules"
    .NOTES
        nécéssite executionpolicy unrestricted ou bypass
    #>  
    $modulesFolderPath = "$sourceFolderPath\Modules"
    foreach ($module in Get-Childitem $modulesFolderPath -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolderPath\$module
    }
}

function Install-RequiredModules
{
    <#
    .SYNOPSIS
        Combiner les 2 fonctions ensemble en une seule fonction
    #>
    Get-RequiredModules
    Import-RequiredModules
}

function Get-GuiFiles
{
    <#
    .SYNOPSIS
       Download le fond d'écran, l'icone et le xaml
    .NOTES
        Premiere fonction qui utilise les modules
    #>
    Get-RemoteFile "fondpluiesize.gif" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' "$applicationPath\Source\Images"
    Get-RemoteFile "Icone.ico" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' "$applicationPath\source\Images"
    Get-RemoteFile "MainWindow.xaml" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/MainWindow.xaml' "$applicationPath\Source"
}

function Get-RemoveScriptFiles
{
    <#
    .SYNOPSIS
        Download les scripts permettant de tout supprimer les traces
    .DESCRIPTION
        Créer un dossier c:\Temp
        Download Remove.bat et Remove.ps1
    .NOTES
        Ne peut pas être downloadé dans c:\_Tech pour ne pas bloquer la suppression
    #>
    Get-RemoteFile "Remove.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1' "$env:SystemDrive\Temp"
    Get-RemoteFile "Remove.bat" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/Remove.bat' "$env:SystemDrive\Temp"
}

function Initialize-Application($appName,$githubPs1Link,$githubBatLink)
{
    <#
    .SYNOPSIS
        Configure et lance les scripts
    .DESCRIPTION
        Est utilisé lorsque qu'un bouton est cliqué
        Créer un dossier au nom de l'application
        Download le .ps1 et le .bat
        Execute le script
    .NOTES
        N'est pas dans un module, car c'est spécific au menu seulement
    #>
    Get-RemoteFile "$appName.ps1" $githubPs1Link $applicationPath\$appName
    Invoke-App "RunAs$appName.bat" $githubBatLink $applicationPath\$appName
}

########################Déroulement########################
Test-InternetConnection
$applicationPath = "$env:SystemDrive\_Tech\Applications"
$sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
New-Item "$applicationPath\Source" -ItemType 'Directory' -Force | Out-Null   
Install-RequiredModules
Get-GuiFiles
$desktop = [Environment]::GetFolderPath("Desktop")
Add-DesktopShortcut "$desktop\Menu.lnk" "$env:SystemDrive\_Tech\Menu.bat" "$applicationPath\Source\Images\Icone.ico"
Get-RemoveScriptFiles
$adminStatus = Get-AdminStatus
if($adminStatus -eq $false)
{
    Restart-Elevated -Path "$env:SystemDrive\_Tech\Menu.ps1"
}

########################GUI########################
$inputXML = import-XamlFromFile "$applicationPath\Source\MainWindow.xaml"
$formatedXaml = Format-XamlFile $inputXML
$objectXaml = New-XamlObject $formatedXaml
$window = Add-WPFWindowFromXaml $objectXaml
$formControls = Get-WPFObjects $formatedXaml $window

########################GUI Events########################
$formControls.btnInstall.Add_Click({
    Initialize-Application "Installation" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsInstallation.bat'
    $window.Close()
})
$formControls.btnOptiNett.Add_Click({
    Initialize-Application "Optimisation_Nettoyage" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsOptimisation_Nettoyage.bat'
    $window.Close()
})
$formControls.btnDiagnostic.Add_Click({
    Initialize-Application "Diagnostique" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDiagnostique.bat'
    $window.Close()    
})
$formControls.btnDesinfection.Add_Click({
    Initialize-Application "Desinfection" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDesinfection.bat'
    $window.Close() 
})
$formControls.btnFix.Add_Click({
    Initialize-Application "Fix" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsFix.bat'
    $window.Close()   
})
$formControls.btnChangeLog.Add_Click({
    Get-RemoteFile "changelog.txt" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/changelog.txt' "$env:SystemDrive\_Tech\Applications\source"
    Start-Process "$env:SystemDrive\_Tech\Applications\source\changelog.txt"
})
$formControls.btnForceUpdate.Add_Click({
    Get-RemoteFileForce  "Installation.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1' "$env:SystemDrive\_Tech\Applications\Installation"
    Get-RemoteFileForce  "Optimisation_Nettoyage.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1' "$env:SystemDrive\_Tech\Applications\Optimisation_Nettoyage"
    Get-RemoteFileForce  "Diagnostique.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1' "$env:SystemDrive\_Tech\Applications\Diagnostique"
    Get-RemoteFileForce  "Desinfection.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' "$env:SystemDrive\_Tech\Applications\Desinfection"
    Get-RemoteFileForce  "Fix.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1' "$env:SystemDrive\_Tech\Applications\Fix"
    Get-RemoteFileForce "Remove.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1' "$env:SystemDrive\Temp"
    Get-RemoteFileForce  "Menu.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.ps1' "$env:SystemDrive\_Tech"
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip' -OutFile "$applicationPath\source\Modules.zip" | Out-Null
    Expand-Archive "$applicationPath\source\Modules.zip" "$applicationPath\source" -Force
    Remove-Item "$applicationPath\source\Modules.zip"
    Restart-Elevated -Path "$env:SystemDrive\_Tech\Menu.ps1"
})
$formControls.btnQuit.Add_Click({
    Invoke-Task -TaskName 'delete _tech' -ExecutedScript 'C:\Temp\Remove.bat'
    $window.Close() 
})

function Set-MenuWinget
{
    $version = Get-WingetStatus
	if($version -eq $null)
	{
		$formControls.txtBlkWingetVersion.text = "Non installé"
	}
    
    elseif($version -ge 1.8)
    {
        $formControls.txtBlkWingetVersion.Foreground = "green"  
        $formControls.btnWinget.Visibility = "Collapsed"
        $formControls.txtBlkWingetVersion.text = $version
    }
    elseif($version -lt 1.8)
    {
        $formControls.btnWinget.content = "Mettre à jour"
        $formControls.txtBlkWingetVersion.text = $version
    }
    else
    {
        $formControls.txtBlkWingetVersion.text = "Erreur"
        $formControls.btnWinget.content = "Installer"
    }
}

function Set-MenuChoco
{
    $formControls.txtBlkChocoVersion.text = Get-ChocoStatus
    if($formControls.txtBlkChocoVersion.text -eq $true)
    {
        $formControls.txtBlkChocoVersion.Foreground = "green"  
        $formControls.txtBlkChocoVersion.text = "Installé"
        $formControls.btnChoco.Visibility = "Collapsed" 
    }
    elseif($formControls.txtBlkChocoVersion.text -eq $false)
    {
        $formControls.txtBlkChocoVersion.text = "Non installé"
        $formControls.btnChoco.content = "Installer"
    }
    else 
    {
        $formControls.txtBlkChocoVersion.text = "Erreur"
    }
}

function Set-MenuGit
{
    $formControls.txtBlkGitVersion.text = Get-GitStatus
    if($formControls.txtBlkGitVersion.text -eq $true)
    {
        $formControls.txtBlkGitVersion.Foreground = "green"  
        $formControls.txtBlkGitVersion.text = "Valide"
    }
    else
    {
        $formControls.txtBlkGitVersion.text = "Injoignable"
    }
}

function Set-MenuFTP
{
    $formControls.txtBlkFTPVersion.text = Get-FtpStatus
    if($formControls.txtBlkFTPVersion.text -eq $true)
    {
        $formControls.txtBlkFTPVersion.Foreground = "green"
        $formControls.txtBlkFTPVersion.text = "Valide"  
    }
    else
    {
        $formControls.txtBlkFTPVersion.text = "Injoignable"
    }
}

$formControls.btnWinget.Add_Click({
    Install-Winget
    Set-MenuWinget
})

$formControls.btnChoco.Add_Click({
    Install-Choco
    Set-MenuChoco
})

Set-MenuWinget
Set-MenuChoco
Set-MenuGit
Set-MenuFTP

Start-WPFAppDialog $window