function Get-RequiredModules
{
    $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
    foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
    {
        Import-Module $modulesFolder\$module
    }
}

Function menu
{
    Clear-Host
    write-host "============================================================================================"
    write-host "  + [#] +           Programme                 +              Description               +  "-ForegroundColor $coloraccent
    write-host "  + --- + ----------------------------------- + -------------------------------------- +  " 
    write-host "  + [1] + SFC/DISM/CHKDSK        [sous-menu]  + Fichiers corrompus                     +  " -ForegroundColor $colorfolder
    write-host "  + [2] + Windows tweak          [sous-menu]  + Windows Tweak et $appName                   +  " -ForegroundColor $colorfolder
    write-host "  + [3] + Sterjo MDP recovery    [sous-menu]  + Obtenir MDP et licences                +  " -ForegroundColor $colorfolder
    write-host "  + [4] + DDU                                 + Desinstaller les pilotes graphiques    +  " 
    write-host "  + [5] + WiseForceDeleter                    + Supprimer un dossier/fichier           +  " -ForegroundColor $coloraccent
    write-host "  + [6] + WinDirStat                          + Verifier taille des dossiers           +  " 
    write-host "  + [7] + Partition Wizard                    + Gerer les partitions                   +  " -ForegroundColor $coloraccent
    write-host "  + [8] + Internet repair                     + Reparer Internet                       +  " 
    write-host "  + --- + ----------------------------------- + -------------------------------------- +  " -ForegroundColor $coloraccent
    write-host "  + [0] + Quitter                             + Fermer ou revenir au menu              +  " -ForegroundColor $colorquit
    write-host "============================================================================================="
    $choix = read-host "Choisissez une option" 

    switch ($choix)
    {
    0{sortie;break}
    1{submenuScripts;Break}
    2{Get-RemoteFile "Tweak.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/Tweak.zip" "$appPathSource"; submenuTweak;Break}
    3{Get-RemoteFile "Sterjo.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/Sterjo.zip" "$appPathSource"; submenuMDP;Break}
    4{Invoke-App "Display Driver Uninstaller.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/Display Driver Uninstaller.zip" "$appPathSource";Add-Log $logFileName "Désinstallation du pilote graphique avec DDU";Break}
    5{Invoke-App "WiseForceDeleterPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/WiseForceDeleterPortable.zip" "$appPathSource";Break}
    6{Invoke-App "WinDirStatPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/WinDirStatPortable.zip" "$appPathSource";Break}
    7{Get-PW;Break} 
    8{Invoke-App "ComIntRep_X64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/ComIntRep_X64.zip" "$appPathSource";Add-Log $logFileName "Réparer Internet";Break}
    T{$number = SubmenuTheme;Set-Theme -theme $number;Break}
    }
    start-sleep 1
    menu
}

function Set-Theme 
{
    param 
    (
        [int]$theme = 1
    )
    
    switch ($theme) 
    {
        0 { # STO:
            $script:backgroundColor = "Black"
            $script:colordefault = "DarkRed"
            $script:coloraccent = "White"
            $script:colorfolder = "yellow"
            $script:colorquit = "red"
        }
        1 { # Classic:
            $script:backgroundColor = "Black"
            $script:colordefault = "Cyan"
            $script:coloraccent = "magenta"
            $script:colorfolder = "green"
            $script:colorquit = "Darkred"
        }
        2 { # Halloween:
            $script:backgroundColor = "Black"
            $script:colordefault = "yellow"
            $script:coloraccent = "red"
            $script:colorfolder = "DarkGreen"
            $script:colorquit = "Darkred"
        }
        3 { # Christmas:
            $script:backgroundColor = "Black"
            $script:colordefault = "Darkred"
            $script:coloraccent = "White"
            $script:colorfolder = "Darkgreen"
            $script:colorquit = "Cyan"
        }
        4 { # Ocean:
            $script:backgroundColor = "DarkMagenta"
            $script:colordefault = "Gray"
            $script:coloraccent = "Cyan"
            $script:colorfolder = "Blue"
            $script:colorquit = "DarkCyan"
        }
        default { # Default:
            $script:backgroundColor = "Black"
            $script:colordefault = "white"
            $script:coloraccent = "white"
            $script:colorfolder = "white"
            $script:colorquit = "Darkred"
        }
    }

    $Host.UI.RawUI.BackgroundColor = $script:backgroundColor
    $Host.UI.RawUI.ForegroundColor = $script:colordefault
}


function SubmenuTheme 
{
    Write-Host "Select Theme:"
    Write-Host "1: STO"
    Write-Host "2: Classic"
    Write-Host "3: Halloween"
    Write-Host "4: Christmas"
    Write-Host "5: Ocean"
    Write-Host "0: Exit"

    $choix = Read-Host "Choisissez une option (0-5)"

    switch ($choix) {
        0 { return }
        1 { return "0"}
        2 { return "1"}
        3 { return "2"}
        4 { return "3"}
        5 { return "4"}
        Default {Write-Host "Invalide. Choisir un chiffre de 0 à 5."}
    }

    Start-Sleep 1
    SubmenuTheme
}
Set-Theme -theme 1


Get-RequiredModules
$appName = "Fix"
$applicationPath = "$env:SystemDrive\_Tech\Applications"
$appPath = "$applicationPath\$appName"
$appPathSource = "$appPath\source"
set-location $appPath
$logFileName = Initialize-LogFile $appPathSource
$lockFile = "$applicationPath\source\$appName.lock"

function Get-Minitool
{
    $minitoolpath = test-Path "$env:SystemDrive\Program Files\MiniTool Partition*\partitionwizard.exe"
    if($minitoolpath)
    {
        Start-Process "$env:SystemDrive\Program Files\MiniTool Partition*\partitionwizard.exe"
    }
    elseif($minitoolpath -eq $false)
    {
    Install-Winget  
    winget install -e --id MiniTool.PartitionWizard.Free --accept-package-agreements --accept-source-agreements --silent | Out-Null
    $minitoolpath = test-Path "$env:SystemDrive\Program Files\MiniTool Partition*\partitionwizard.exe"
        if($minitoolpath -eq $false)
        {
            Install-Choco
            choco install partitionwizard -y | Out-Null
        }
    }
}

function Get-Tweaking
{
    $path = Test-Path "$appPathSource\Tweak\Tweaking.com - Windows Repair\Repair_Windows.exe"
    if($path -eq $false)
    {
        #choco install windowsrepair , il faudra revoir le start process aussi
        Invoke-WebRequest "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/tweaking.com - Windows Repair.zip" -OutFile "$appPathSource\Tweak\tweaking.com - Windows Repair.zip"
        Expand-Archive "$appPathSource\Tweak\tweaking.com - Windows Repair.zip" "$appPathSource\Tweak"
        Remove-Item "$appPathSource\Tweak\tweaking.com - Windows Repair.zip"
        Copy-Item "$appPathSource\Tweak\Tweaking.com - Windows Repair" -Recurse -Destination "$desktop\Tweaking.com - Windows Repair"
        Start-Process "$desktop\Tweaking.com - Windows Repair\Repair_Windows.exe"
    }    
    elseif($path)
    {
        Start-Process "$desktop\Tweaking.com - Windows Repair\Repair_Windows.exe"
    }
}

function Get-PW
{
    $path = Test-Path "$appPathSource\Partition_Wizard\partitionwizard.exe"
    if($path -eq $false)
    {
        Invoke-WebRequest "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/Partition_Wizard.zip" -OutFile "$appPathSource\Partition_Wizard.zip"
        Expand-Archive "$appPathSource\Partition_Wizard.zip" "$appPathSource"
        Remove-Item "$appPathSource\Partition_Wizard.zip"
        Copy-Item "$appPathSource\Partition_Wizard" -Recurse -Destination "$desktop\Partition_Wizard"
        Start-Process "$desktop\Partition_Wizard\partitionwizard.exe"
    }    
    elseif($path)
    {
        Start-Process "$desktop\Partition_Wizard\partitionwizard.exe"
    }
}

function sortie
{
$sortie = read-host "Voulez-vous retourner au menu Principal? o/n/q [q = Suppression]"

    if($sortie -eq "o")
    {   
        Set-Location "$env:SystemDrive\_Tech"
        start-process "$env:SystemDrive\_Tech\Menu.bat" -verb Runas
        Remove-Item -Path $lockFile -Force -ErrorAction SilentlyContinue
        exit
    }
    elseif($sortie -eq "n")
    {
        Remove-Item -Path $lockFile -Force -ErrorAction SilentlyContinue
        exit
    }
    elseif($sortie -eq "q")
    {
        $sourceFolderPath = "$env:SystemDrive\_Tech\Applications\source"
        $jsonFilePath = "$sourceFolderPath\Settings.JSON"
        $jsonContent = Get-Content $jsonFilePath -Raw | ConvertFrom-Json
        $messageBox = [System.Windows.MessageBox]::Show("Voulez-vous vider la corbeille et effacer les derniers téléchargements ?","Quitter et Supprimer",4,64)
        if($messageBox -eq "6")
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
        Remove-Item -Path $lockFile -Force -ErrorAction SilentlyContinue
        Invoke-Task -TaskName "delete _tech" -ExecutedScript "C:\Temp\Stoolbox\Remove.bat"
        exit
    }
    else 
    {
        sortie
    }
}

function submenuScripts
{
Clear-Host
write-host "================================================="
write-host "  + [#] +           SFC/DISM/CHKDSK           +  "-ForegroundColor $coloraccent
write-host "  + --- + ----------------------------------- +  " 
write-host "  + [1] + Sfc /scannow                        +  " -ForegroundColor $coloraccent
write-host "  + [2] + DISM                                +  " 
write-host "  + [3] + CHKDSK                              +  " -ForegroundColor $coloraccent
write-host "  + [4] + Creer session admin                 +  " 
write-host "  + --- + ----------------------------------- +  " -ForegroundColor $coloraccent
write-host "  + [0] + Retour au menu precedent            +  " -ForegroundColor $colorquit
write-host "================================================="
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start-Process cmd.exe -ArgumentList "/k sfc /scannow";Add-Log $logFileName "Reparation des fichiers corrompus";Break}
2{Start-Process cmd.exe -ArgumentList "/k DISM /online /cleanup-image /restorehealth";Add-Log $logFileName "Reparation du Windows";Break}
3{Start-Process cmd.exe -ArgumentList "/k chkdsk /f /r";Add-Log $logFileName "Reparation du HDD";Break}
4{Get-RemoteFile "creer_session.txt" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/creer_session.txt" "$appPathSource";Start-Process "$appPathSource\creer_session.txt";Add-Log $logFileName "Nouvelle session créé";Break}
}
start-sleep 1
submenuScripts
}

function submenuMDP
{

Clear-Host
write-host "================================================="
write-host "  + [#] +           Sterjo MDP recovery       +  "-ForegroundColor $coloraccent
write-host "  + --- + ----------------------------------- +  " 
write-host "  + [1] + Browser                             +  " -ForegroundColor $coloraccent
write-host "  + [2] + Chrome                              +  " 
write-host "  + [3] + Firefox                             +  " -ForegroundColor $coloraccent
write-host "  + [4] + Keys                                +  " 
write-host "  + [5] + Mail                                +  " -ForegroundColor $coloraccent
write-host "  + [6] + Wireless                            +  " 
write-host "  + --- + ----------------------------------- +  " -ForegroundColor $coloraccent
write-host "  + [0] + Retour au menu precedent            +  " -ForegroundColor $colorquit
write-host "================================================="
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start-Process "$appPathSource\Sterjo\SterJo_Browser_Passwords_sps\BrowserPasswords.exe";Break}
2{Start-Process "$appPathSource\Sterjo\SterJo_Chrome_Passwords_sps\ChromePasswords.exe";Break}
3{Start-Process "$appPathSource\Sterjo\Sterjo_Firefox\FirefoxPasswords.exe";Break}
4{Start-Process "$appPathSource\Sterjo\Sterjo_Key\KeyFinder.exe";Break}
5{Start-Process "$appPathSource\Sterjo\SterJo_Mail_Passwords_sps\MailPasswords.exe";Break}
6{Start-Process "$appPathSource\Sterjo\Sterjo_Wireless\WiFiPasswords.exe";Break}
}
Start-Sleep 1
submenuMDP
}

function submenuTweak
{
Clear-Host
write-host "================================================="
write-host "  + [#] +           Windows Tweak et $appName      +  "-ForegroundColor $coloraccent
write-host "  + --- + ----------------------------------- +  " 
write-host "  + [1] + Fix w10                             +  " -ForegroundColor $coloraccent
write-host "  + [2] + Fix w11                             +  " 
write-host "  + [3] + Ultimate Windows Tweaker W10        +  " -ForegroundColor $coloraccent
write-host "  + [4] + Ultimate Windows Tweaker W11        +  " 
write-host "  + [5] + Tweaking Windows Repair             +  " -ForegroundColor $coloraccent
write-host "  + --- + ----------------------------------- +  " 
write-host "  + [0] + Retour au menu precedent            +  " -ForegroundColor $colorquit
write-host "================================================="
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start-Process "$appPathSource\Tweak\FixWin10\FixWin 10.2.2.exe";Break}
2{Start-Process "$appPathSource\Tweak\FixWin11\FixWin 11.1.exe";break}
3{Start-Process "$appPathSource\Tweak\Ultimate Windows Tweaker w10\Ultimate Windows Tweaker 4.8.exe";Break}
4{Start-Process "$appPathSource\Tweak\Ultimate Windows Tweaker w11\Ultimate Windows Tweaker 5.1.exe";break}
5{Get-Tweaking;Break} 
}
Start-Sleep 1
submenuTweak
}
menu