Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

function Get-RequiredModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

$pathDesinfection = "$env:SystemDrive\_Tech\Applications\Desinfection"
$pathDesinfectionSource = "$env:SystemDrive\_Tech\Applications\Desinfection\source"
set-location $pathDesinfection
Get-RequiredModules
$applicationPath = "$env:SystemDrive\_Tech\Applications"
$sourceFolderPath = "$applicationPath\source"
$logFileName = Initialize-LogFile $pathDesinfectionSource
$desinfectionLockFile = "$sourceFolderPath\Desinfection.lock"
Get-RemoteFile "Background_desinfection.jpeg" "https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/assets/$Global:seasonFolderName/$Global:NumberRDM.jpeg" "$pathDesinfectionSource"
Get-RemoteFile "MainWindow.xaml" 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/MainWindow.xaml' "$pathDesinfectionSource"
$adminStatus = Get-AdminStatus
if($adminStatus -eq $false)
{
    Restart-Elevated -Path $pathDesinfection\Desinfection.ps1
}
$Global:desinfectionIdentifier = "Desinfection.ps1"
Test-ScriptInstance $desinfectionLockFile $Global:desinfectionIdentifier

$xamlFile = "$pathDesinfectionSource\MainWindow.xaml"
$xamlContent = Read-XamlFileContent $xamlFile
$formatedXamlFile = Format-XamlFile $xamlContent
$xamlDoc = Convert-ToXmlDocument $formatedXamlFile
$XamlReader = New-XamlReader $xamlDoc
$window = New-WPFWindowFromXaml $XamlReader
$formControls = Get-WPFControlsFromXaml $xamlDoc $window

$formControls.btnMenu.Add_Click({
    $window.Close()
    start-process "$env:SystemDrive\\_Tech\\Menu.bat" -verb Runas
    Exit
})

$formControls.btnQuit.Add_Click({
    $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
    $jsonFilePath = "$sourceFolderPath\Settings.JSON"
    $jsonContent = Get-Content $jsonFilePath -Raw | ConvertFrom-Json
    $messageBox = [System.Windows.MessageBox]::Show("Voulez-vous vider la corbeille et effacer les derniers téléchargements ?","Quitter et Supprimer",4,64)
    if($messageBox -eq '6')
    {
        $jsonContent.RemoveDownloadFolder.Status = "1"
        $jsonContent.EmptyRecycleBin.Status = "1"
    }
    else
    {
        $jsonContent.RemoveDownloadFolder.Status = "0"
        $jsonContent.EmptyRecycleBin.Status = "0"  
    }   
    $jsonContent | ConvertTo-Json | Set-Content $jsonFilePath -Encoding UTF8
    Invoke-Task -TaskName 'delete _tech' -ExecutedScript 'C:\Temp\Stoolbox\Remove.bat'
    $window.Close()
})

$formControls.btnProcess_Explorer.Add_Click({
    Invoke-App "procexp64.exe" 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/procexp64.exe' "$pathDesinfectionSource"
    Add-Log $logFileName "Vérifier les process"
})

$formControls.btnRKill.Add_Click({
    Invoke-App "rkill64.exe" 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/rkill64.exe' "$pathDesinfectionSource"
    Add-Log $logFileName "Désactiver les process"
})

$formControls.btnAutoruns.Add_Click({
    Invoke-App "autoruns.exe" 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/autoruns.exe' "$pathDesinfectionSource"
    start-sleep 5
    taskmgr
    Add-Log $logFileName "Vérifier les logiciels au démarrage"
})

$formControls.btnHDD.Add_Click({
    Start-Process "$env:SystemDrive\Windows\SYSTEM32\cleanmgr.exe"
    Add-Log $logFileName "Nettoyage du disque effectué"
})

$formControls.btnCcleaner.Add_Click({
    Invoke-App "CCleaner64.zip" 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/CCleaner64.zip' $pathDesinfectionSource
    Add-Log $logFileName "Nettoyage CCleaner effectué"
 })

$formControls.btnRevo.Add_Click({
    Invoke-App "RevoUPort.zip" 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/RevoUPort.zip' "$pathDesinfectionSource"
    Add-Log $logFileName "Vérifier les programmes nuisibles"
 })


$formControls.btnADWcleaner.Add_Click({
    Invoke-App "adwcleaner.exe" 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/adwcleaner.exe' "$pathDesinfectionSource"
    Add-Log $logFileName "Analyse ADW effectué"
 })

$formControls.btnMalwareByte.Add_Click({
    $path = Test-Path "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe" 
    if($path -eq $false)
    {
        Install-Choco
        choco install malwarebytes -y | Out-Null
        if($path -eq $false)
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/Ninite Malwarebytes Installer.exe' -OutFile "$root\_Tech\Applications\Desinfection\Source\Ninite Malwarebytes Installer.exe"
            Start-Process "$root\_Tech\\Applications\Desinfection\Source\Ninite Malwarebytes Installer.exe"
            $path = Test-Path "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe"
            if($path -eq $false)
            {
                Install-Winget
                winget install -e --id  Malwarebytes.Malwarebytes --accept-package-agreements --accept-source-agreements --silent
                Start-Process "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe"
            }  
        }
        else
        {
            Start-Process "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe"
        } 
    }
    else 
    {
        Start-Process "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe"
    }
    Add-Log $logFileName "Analyse Malwarebyte effectué"
 })

$formControls.btnSuperAntiSpyware.Add_Click({
    $path = Test-Path "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe"
    if($path -eq $false)
    {
        Install-Choco
        choco install superantispyware -y | out-null
        Start-Process "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe" 
        if($path -eq $false)
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/Ninite SUPERAntiSpyware Installer.exe' -OutFile "$root\_Tech\Applications\Desinfection\Source\Ninite SUPERAntiSpyware Installer.exe"
            Start-Process "$root\_Tech\\Applications\Desinfection\Source\Ninite SUPERAntiSpyware Installer.exe"
            $path = Test-Path "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe"
            if($path -eq $false)
            {
                Install-Winget
                winget install -e --id  SUPERAntiSpyware.SUPERAntiSpyware --accept-package-agreements --accept-source-agreements --silent
            } 
        }
        else 
        {
            Start-Process "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe" 
        }  
    }
    else 
    {
        Start-Process "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe"
    }
    Add-Log $logFileName "Analyse SuperAntiSpyware effectué"
 })

$formControls.btnHitmanPro.Add_Click({
    Invoke-App "HitmanPro.exe" 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/HitmanPro.exe' "$pathDesinfectionSource"
    Add-Log $logFileName "Vérifier les virus avec HitmanPro"
})

$formControls.btnRogueKiller.Add_Click({
    Invoke-App "RogueKiller_portable64.zip" 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/RogueKiller_portable64.zip' "$pathDesinfectionSource"
    Add-Log $logFileName "Analyse RogueKiller effectué"
    #via le cmd, aller a l'emplacement RogueKillerCMD.exe -scan -no-interact -deleteall #-debuglog {path}
 })

$window.add_Closed({
    Remove-Item -Path $desinfectionLockFile -Force -ErrorAction SilentlyContinue
})

Start-WPFAppDialog $window