Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore,Microsoft.VisualBasic

function CheckInternetStatus
{
    while (!(test-connection 8.8.8.8 -Count 1 -quiet)) #Ping Google et recommence jusqu'a ce qu'il y est internet
    {
    [Microsoft.VisualBasic.Interaction]::MsgBox("Veuillez vous connecter à Internet et cliquer sur OK",'OKOnly,SystemModal,Information', "Menu - Boite à outils du technicien") | Out-Null
    start-sleep 5
    }
}

function ReloadAsAdmin
{
    Start-Process powershell.exe -ArgumentList ("-NoProfile -windowstyle hidden -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit #permet de fermer la session non-Admin
}

function DownloadModules
{
    $modulepath = test-path "$applicationPath\source\Modules"
    if($modulepath -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip' -OutFile "$applicationPath\source\Modules.zip" | Out-Null
        Expand-Archive "$applicationPath\source\Modules.zip" "$applicationPath\source" -Force
        Remove-Item "$applicationPath\source\Modules.zip"
    }
}

function ImportModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

function DownloadAndImportModules
{
    DownloadModules
    ImportModules
}

function DownloadBackgroundAndIcone
{
    CreateFolder "_Tech\Applications\Source\images"
    DownloadFile "fondpluiesize.gif" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' "$applicationPath\Source\Images"
    DownloadFile "Icone.ico" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' "$applicationPath\source\Images"
}

function DownloadRemoveScripts
{
    DownloadFile "Remove.ps1" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1' "$env:SystemDrive\Temp"
    DownloadFile "Remove.bat" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/Remove.bat' "$env:SystemDrive\Temp"
}

function DeployApp($appName,$githubPs1Link,$githubBatLink)
{
    CreateFolder "_Tech\Applications\$appName"
    set-location "$applicationPath\$appName" 
    DownloadFile "$appName\$appName.ps1" $githubPs1Link $applicationPath
    DownloadFile "$appName\RunAs$appName.bat" $githubBatLink $applicationPath
    Start-Process "$applicationPath\$appName\RunAs$appName.bat" | Out-Null
}

CheckInternetStatus
$applicationPath = "$env:SystemDrive\_Tech\Applications"
set-location "$env:SystemDrive\_Tech" 
New-Item "$applicationPath\Source" -ItemType 'Directory' -Force | Out-Null   
DownloadAndImportModules
DownloadBackgroundAndIcone
$desktop= [Environment]::GetFolderPath("Desktop")
CreateDesktopShortcut "$desktop\Menu.lnk" "$env:SystemDrive\_Tech\Menu.bat" "$applicationPath\Source\Images\Icone.ico"
CreateFolder "Temp"
DownloadRemoveScripts
$adminStatus = CheckAdminStatus
if($adminStatus -eq $false)
{
    ReloadAsAdmin
}

###GUI###
DownloadFile "MainWindow.xaml" 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/MainWindow.xaml' "$applicationPath\Source"
$inputXML = importXamlFromFile "$applicationPath\Source\MainWindow.xaml"
$formatedXaml = FormatXamlFile $inputXML
$ObjectXaml = CreateXamlObject $formatedXaml
$window = LoadWPFWindowFromXaml $ObjectXaml
$formControls = GetWPFObjects $formatedXaml $window

$formControls.btnInstall.Add_Click({
    DeployApp "Installation" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsInstallation.bat'
    $window.Close()
})
$formControls.btnOptiNett.Add_Click({
    DeployApp "Optimisation_Nettoyage" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsOptimisation_Nettoyage.bat'
    $window.Close()
})
$formControls.btnDiagnostic.Add_Click({
    DeployApp "Diagnostique" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDiagnostique.bat'
    $window.Close()    
})
$formControls.btnDesinfection.Add_Click({
    DeployApp "Desinfection" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDesinfection.bat'
    $window.Close() 
})
$formControls.btnFix.Add_Click({
    DeployApp "Fix" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsFix.bat'
    $window.Close()   
})
$formControls.btnChangeLog.Add_Click({
    DownloadFile "changelog.txt" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/changelog.txt'"$env:SystemDrive\_Tech"
    Start-Process "$env:SystemDrive\_Tech\changelog.txt"
})
$formControls.btnQuit.Add_Click({
    Task
    $window.Close() 
})

function MenuWinget
{
    $formControls.txtBlkWingetVersion.text = CheckWingetStatus
    if($formControls.txtBlkWingetVersion.text -ge 1.8)
    {
        $formControls.txtBlkWingetVersion.Foreground = "green"  
        $formControls.btnWinget.Visibility = "Collapsed"
    }
    elseif($formControls.txtBlkWingetVersion.text -lt 1.8)
    {
        $formControls.btnWinget.content = "Mettre à jour"
    }
    else
    {
        $formControls.txtBlkWingetVersion.text = "Non installé"
        $formControls.btnWinget.content = "Installer"
    }
}

function MenuChoco
{
    $formControls.txtBlkChocoVersion.text = CheckChocoStatus
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

function MenuGit
{
    $formControls.txtBlkGitVersion.text = CheckGitStatus
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

function MenuFTP
{
    $formControls.txtBlkFTPVersion.text = CheckFtpStatus
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
    Wingetinstall
    MenuWinget
})

$formControls.btnChoco.Add_Click({
    Chocoinstall
    MenuChoco
})

MenuWinget
MenuChoco
MenuGit
MenuFTP

LaunchWPFAppDialog $window