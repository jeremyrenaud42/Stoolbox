$formControls.btnMenu_Fix.Add_Click({
    Open-Menu
})

$formControls.btnQuit_Fix.Add_Click({
    Remove-StoolboxApp
})

$formControls.btnScript_Fix.Add_Click({
    $formControls.btnSFC_Fix.Visibility="Visible"
    $formControls.btnDISM_Fix.Visibility="Visible"
    $formControls.btnCHKDSK_Fix.Visibility="Visible"
    $formControls.btnSession_Fix.Visibility="Visible"
    $formControls.btnScript_Fix.Visibility="Collapsed"
})
$formControls.btnTweak_Fix.Add_Click({
    $formControls.btnFW10_Fix.Visibility="Visible"
    $formControls.btnFW11_Fix.Visibility="Visible"
    $formControls.btnUWT10_Fix.Visibility="Visible"
    $formControls.btnUWT11_Fix.Visibility="Visible"
    $formControls.btnTweaking_Fix.Visibility="Visible"
    $formControls.btnTweak_Fix.Visibility="Collapsed"
    Get-RemoteFile "Tweak.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Tweak.zip" $global:appPathSource
})
$formControls.btnSterjo_Fix.Add_Click({
    $formControls.btnSterjoBrowser_Fix.Visibility="Visible"
    $formControls.btnSterjoChrome_Fix.Visibility="Visible"
    $formControls.btnSterjoFirefox_Fix.Visibility="Visible"
    $formControls.btnSterjoKeys_Fix.Visibility="Visible"
    $formControls.btnSterjoMail_Fix.Visibility="Visible"
    $formControls.btnSterjoWireless_Fix.Visibility="Visible"
    $formControls.btnSterjo_Fix.Visibility="Collapsed"
    Get-RemoteFile "Sterjo.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Sterjo.zip" $global:appPathSource
})

$formControls.btnDDU_Fix.Add_Click({
    Invoke-App "Display Driver Uninstaller.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Display Driver Uninstaller.zip" $global:appPathSource
})
$formControls.btnWFD_Fix.Add_Click({
    Invoke-App "WiseForceDeleterPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/WiseForceDeleterPortable.zip" $global:appPathSource
})
$formControls.btnWinDirStat_Fix.Add_Click({
    Invoke-App "WinDirStatPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/WinDirStatPortable.zip" $global:appPathSource
})
$formControls.btnPW_Fix.Add_Click({
    Invoke-App "PartitionWizard.zip" "https://ftp.alexchato9.com/public/file/eortitew8kkil6hdeh2lgw/PartitionWizard.zip" $global:appPathSource
})
$formControls.btnInternet_Fix.Add_Click({
    Invoke-App "ComIntRep_X64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/ComIntRep_X64.zip"  $global:appPathSource
})

$formControls.btnSFC_Fix.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k sfc /scannow"
})
$formControls.btnDISM_Fix.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k DISM /online /cleanup-image /restorehealth";Add-Log $global:logFileName "Reparation du Windows"
})
$formControls.btnCHKDSK_Fix.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k chkdsk /f /r"
})
$formControls.btnSession_Fix.Add_Click({
    Get-RemoteFile "creer_session.txt" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/creer_session.txt" $global:appPathSource
    Start-Process "$global:appPathSource\creer_session.txt"
})
$formControls.btnFW10_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\FixWin10\FixWin 10.2.2.exe"
})
$formControls.btnFW11_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\FixWin11\FixWin 11.1.exe"
})
$formControls.btnUWT10_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\Ultimate Windows Tweaker w10\Ultimate Windows Tweaker 4.8.exe"
})
$formControls.btnUWT11_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\Ultimate Windows Tweaker w11\Ultimate Windows Tweaker 5.1.exe"
})
$formControls.btnTweaking_Fix.Add_Click({
    Invoke-App "Repair_Windows.zip" "https://ftp.alexchato9.com/public/file/7mop4guroekrtvbrhb_0wq/Repair_Windows.zip" "$global:appPathSource\Tweak"
})
$formControls.btnSterjoBrowser_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\SterJo_Browser_Passwords_sps\BrowserPasswords.exe"
})
$formControls.btnSterjoChrome_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\SterJo_Chrome_Passwords_sps\ChromePasswords.exe"
})
$formControls.btnSterjoFirefox_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\Sterjo_Firefox\FirefoxPasswords.exe"
})
$formControls.btnSterjoKeys_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\Sterjo_Key\KeyFinder.exe"
})
$formControls.btnSterjoMail_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\SterJo_Mail_Passwords_sps\MailPasswords.exe"
})
$formControls.btnSterjoWireless_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\Sterjo_Wireless\WiFiPasswords.exe"
})
<#
Function menu
{
    Clear-Host
    write-host "============================================================================================"
    write-host "  + [#] +           Programme                 +              Description               +  "-ForegroundColor $coloraccent
    write-host "  + --- + ----------------------------------- + -------------------------------------- +  " 
    write-host "  + [1] + SFC/DISM/CHKDSK        [sous-menu]  + Fichiers corrompus                     +  " -ForegroundColor $colorfolder
    write-host "  + [2] + Windows tweak          [sous-menu]  + Windows Tweak et Fix                   +  " -ForegroundColor $colorfolder
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
    2{Get-RemoteFile "Tweak.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Tweak.zip" $global:appPathSource; submenuTweak;Break}
    3{Get-RemoteFile "Sterjo.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Sterjo.zip" $global:appPathSource; submenuMDP;Break}
    4{Invoke-App "Display Driver Uninstaller.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Display Driver Uninstaller.zip" $global:appPathSource;Add-Log $global:logFileName "Désinstallation du pilote graphique avec DDU";Break}
    5{Invoke-App "WiseForceDeleterPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/WiseForceDeleterPortable.zip" $global:appPathSource;Break}
    6{Invoke-App "WinDirStatPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/WinDirStatPortable.zip" $global:appPathSource;Break}
    7{Get-PW;Break} 
    8{Invoke-App "ComIntRep_X64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/ComIntRep_X64.zip" $global:appPathSource;Add-Log $global:logFileName "Réparer Internet";Break}
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
        Invoke-Task -TaskName "delete _tech" -ExecutedScript "C:\Temp\Stoolbox\Remove.ps1"
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
1{Start-Process cmd.exe -ArgumentList "/k sfc /scannow";Add-Log $global:logFileName "Reparation des fichiers corrompus";Break}
2{Start-Process cmd.exe -ArgumentList "/k DISM /online /cleanup-image /restorehealth";Add-Log $global:logFileName "Reparation du Windows";Break}
3{Start-Process cmd.exe -ArgumentList "/k chkdsk /f /r";Add-Log $global:logFileName "Reparation du HDD";Break}
4{Get-RemoteFile "creer_session.txt" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/creer_session.txt" $global:appPathSource;Start-Process "$global:appPathSource\creer_session.txt";Add-Log $global:logFileName "Nouvelle session créé";Break}
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
1{Start-Process "$global:appPathSource\Sterjo\SterJo_Browser_Passwords_sps\BrowserPasswords.exe";Break}
2{Start-Process "$global:appPathSource\Sterjo\SterJo_Chrome_Passwords_sps\ChromePasswords.exe";Break}
3{Start-Process "$global:appPathSource\Sterjo\Sterjo_Firefox\FirefoxPasswords.exe";Break}
4{Start-Process "$global:appPathSource\Sterjo\Sterjo_Key\KeyFinder.exe";Break}
5{Start-Process "$global:appPathSource\Sterjo\SterJo_Mail_Passwords_sps\MailPasswords.exe";Break}
6{Start-Process "$global:appPathSource\Sterjo\Sterjo_Wireless\WiFiPasswords.exe";Break}
}
Start-Sleep 1
submenuMDP
}

function submenuTweak
{
Clear-Host
write-host "================================================="
write-host "  + [#] +           Windows Tweak et Fix      +  "-ForegroundColor $coloraccent
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
1{Start-Process "$global:appPathSource\Tweak\FixWin10\FixWin 10.2.2.exe";Break}
2{Start-Process "$global:appPathSource\Tweak\FixWin11\FixWin 11.1.exe";break}
3{Start-Process "$global:appPathSource\Tweak\Ultimate Windows Tweaker w10\Ultimate Windows Tweaker 4.8.exe";Break}
4{Start-Process "$global:appPathSource\Tweak\Ultimate Windows Tweaker w11\Ultimate Windows Tweaker 5.1.exe";break}
5{Get-Tweaking;Break} 
}
Start-Sleep 1
submenuTweak
}
menu
#>