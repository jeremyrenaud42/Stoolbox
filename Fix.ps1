Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.speech
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

function admin
{
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
     {
        Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit #permet de fermer la session non-admin
    }
}
admin

$driveletter = $pwd.drive.name
$root = "$driveletter" + ":"

set-location "$root\_Tech\Applications\fix" #met la location au repertoir actuel
Import-Module "$root\_Tech\Applications\Source\modules\update.psm1" | Out-Null
Import-Module "$root\_Tech\Applications\Source\modules\task.psm1" | Out-Null #Module pour supprimer C:\_Tech
Import-Module "$root\_Tech\Applications\Source\modules\Logs.psm1" | Out-Null #Module pour les logs
Import-Module "$root\_Tech\Applications\Source\modules\source.psm1" | Out-Null #Module pour créer source

$scriptDir = 
    if (-not $PSScriptRoot) 
    {
        Split-Path -Parent (Convert-Path ([environment]::GetCommandLineArgs()[0]))
    } 

    else 
    {
        $PSScriptRoot
    }
$lettre = [System.IO.path]::GetPathRoot($scriptDir)

Sourceexist

function zipComIntRep
{
    $ComIntReppath = test-Path "$root\\_Tech\\Applications\\fix\Source\ComIntRep\ComIntRep_X64.exe"
    if($ComIntReppath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/ComIntRep.zip' -OutFile "$root\\_Tech\\Applications\\fix\Source\ComIntRep.zip"
    Expand-Archive "$root\\_Tech\\Applications\\fix\Source\ComIntRep.zip" "$root\\_Tech\\Applications\\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\\fix\Source\ComIntRep.zip"
    }
    Start-Process "$root\\_Tech\\Applications\\fix\Source\ComIntRep\ComIntRep_X64.exe"
    Addlog "Fixlog.txt" "Réparer Internet"
}

function zipsecudossier
{
    $SecuriteDossierpath = test-Path "$root\\_Tech\\Applications\\fix\Source\Securite_Dossier"
    if($SecuriteDossierpath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Securite_Dossier.zip' -OutFile "$root\\_Tech\\Applications\fix\Source\Securite_Dossier.zip"
    Expand-Archive "$root\\_Tech\\Applications\fix\Source\Securite_Dossier.zip" "$root\\_Tech\\Applications\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\fix\Source\Securite_Dossier.zip"
    }
    Start-Process "$PSScriptRoot\Source\Securite_Dossier\Wise Force Deleter\WiseDeleter.exe"
}

function zipsterjo
{
    $Sterjopath = test-Path "$root\\_Tech\\Applications\\fix\Source\Sterjo"
    if($Sterjopath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Sterjo.zip' -OutFile "$root\\_Tech\\Applications\\fix\Source\Sterjo.zip"
    Expand-Archive "$root\\_Tech\\Applications\\fix\Source\Sterjo.zip" "$root\\_Tech\\Applications\\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\\fix\Source\Sterjo.zip"
    }
}

function zipWinDirStat
{
    $WinDirStatpath = test-Path "$root\\_Tech\\Applications\\fix\Source\WinDirStat\WinDirStatPortable.exe"
    if($WinDirStatpath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/WinDirStat.zip' -OutFile "$root\\_Tech\\Applications\\fix\Source\WinDirStat.zip"
    Expand-Archive "$root\\_Tech\\Applications\\fix\Source\WinDirStat.zip" "$root\\_Tech\\Applications\\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\\fix\Source\WinDirStat.zip"
    }
    Start-Process "$root\\_Tech\\Applications\\fix\Source\WinDirStat\WinDirStatPortable.exe"
}

function zipscripts
{
    $scriptspath = test-Path "$root\\_Tech\\Applications\\fix\Source\scripts"
    if($scriptspath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/scripts.zip' -OutFile "$root\_Tech\Applications\fix\Source\scripts.zip"
    Expand-Archive "$root\\_Tech\\Applications\\fix\Source\scripts.zip" "$root\\_Tech\\Applications\\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\\fix\Source\scripts.zip"
    }
}

function zipDDU
{
    $DDUpath = test-Path "$root\\_Tech\\Applications\\fix\Source\DDU\Display Driver Uninstaller.exe"
    if($DDUpath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/DDU.zip' -OutFile "$root\\_Tech\\Applications\\fix\Source\DDU.zip"
    Expand-Archive "$root\\_Tech\\Applications\\fix\Source\DDU.zip" "$root\\_Tech\\Applications\\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\\fix\Source\DDU.zip"
    }
    Start-Process "$root\\_Tech\\Applications\\fix\Source\DDU\Display Driver Uninstaller.exe"
    Addlog "Fixlog.txt" "Désinstallation du pilote graphique avec DDU"
}

function zipMinitool
{
    $sminitoolpath = test-Path "$root\\_Tech\\Applications\\fix\Source\Partition_Wizard"
    if($sminitoolpath -eq $false)
    {
    Invoke-WebRequest 'https://ftp.alexchato9.com/public/file/hUDD8v1EW0awbjwCip3xkg/Partition_Wizard.zip' -OutFile "$root\\_Tech\\Applications\\fix\Source\Partition_Wizard.zip"
    Expand-Archive "$root\\_Tech\\Applications\\fix\Source\Partition_Wizard.zip" "$root\\_Tech\\Applications\\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\\fix\Source\Partition_Wizard.zip"
    }
    Start-Process "$root\\_Tech\\Applications\\fix\Source\Partition_Wizard\partitionwizard.exe"
}
function zipTweak
{
    $tweakpath = test-Path "$root\_Tech\\Applications\fix\Source\Tweak"
    if($tweakpath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Tweak.zip' -OutFile "$root\_Tech\Applications\fix\Source\Tweak.zip"
    Expand-Archive "$root\_Tech\Applications\fix\Source\Tweak.zip" "$root\_Tech\Applications\fix\Source"
    Remove-Item "$root\_Tech\Applications\fix\Source\Tweak.zip"
    }
}

function Tweaking
{
    $path = Test-Path "$root\_Tech\Applications\fix\Source\Tweak\Tweaking.com - Windows Repair\Repair_Windows.exe"
    if($path -eq $false)
    {
        Invoke-WebRequest 'https://ftp.alexchato9.com/public/file/xOQ0JbscWkmQZ-5Zfwzpnw/tweaking.com%20-%20Windows%20Repair.zip' -OutFile "$root\_Tech\Applications\fix\Source\Tweak\tweaking.com - Windows Repair.zip"
        Expand-Archive "$root\_Tech\Applications\fix\Source\Tweak\tweaking.com - Windows Repair.zip" "$root\_Tech\Applications\fix\Source\Tweak"
        Remove-Item "$root\_Tech\Applications\fix\Source\Tweak\tweaking.com - Windows Repair.zip"
        Copy-Item "$root\_Tech\Applications\fix\Source\Tweak\Tweaking.com - Windows Repair" -Recurse -Destination "$env:SystemDrive\Users\$env:UserName\Desktop\Tweaking.com - Windows Repair"
        Start-Process "$env:SystemDrive\Users\$env:UserName\Desktop\Tweaking.com - Windows Repair\Repair_Windows.exe"
    }    
    elseif($path)
    {
        Start-Process "$env:SystemDrive\Users\$env:UserName\Desktop\Tweaking.com - Windows Repair\Repair_Windows.exe"
    }
}

function zipRecup
{
    $recuppath = test-Path "$root\\_Tech\\Applications\\fix\Source\Recup_donnees"
    if($recuppath -eq $false)
    {
    Invoke-WebRequest 'https://ftp.alexchato9.com/public/file/x_25M6QRJUSCC3KDhnBGxg/Recup_donnees.zip' -OutFile "$root\\_Tech\\Applications\\fix\Source\Recup_donnees.zip"
    Expand-Archive "$root\\_Tech\\Applications\\fix\Source\Recup_donnees.zip" "$root\\_Tech\\Applications\\fix\Source"
    Remove-Item "$root\\_Tech\\Applications\\fix\Source\Recup_donnees.zip"
    }
    Start-Process "$root\\_Tech\\Applications\\fix\Source\Recup_donnees\EaseUS Data Recovery Wizard\DRW.exe"
}

Function menu
{
Clear-Host
write-host "[1] Fichiers corrompues" -ForegroundColor 'Cyan'
write-host "[2] Windows Tweak et Fix" -ForegroundColor 'Green'
write-host "[3] Obtenir MDP et licenses" -ForegroundColor 'darkcyan'
write-host "[4] Desinstaller les pilotes graphiques (DDU)" -ForegroundColor 'DarkGreen'
write-host "[5] Supprimer un dossier" -ForegroundColor 'magenta'
write-host "[6] Verifier taille des dossiers" -ForegroundColor 'red'
write-host "[7] Gerer les partitions" -ForegroundColor 'green'
write-host "[8] Reparer Internet" -ForegroundColor 'DarkRed'
write-host "[9] Recuperer des donnees" -ForegroundColor 'Yellow'
write-host ""
write-host "[0] Quitter" -ForegroundColor 'red'
$choix = read-host "Choisissez une option" 

switch ($choix)
{
0{sortie;break}
1{zipscripts; submenuHDD;Break}
2{zipTweak; submenuTweak;Break}
3{zipsterjo; submenuMDP;Break}
4{zipDDU;Break}
5{zipsecudossier;Break}
6{zipWinDirStat;Break}
7{zipMinitool;Break} 
8{zipComIntRep;Break}
9{zipRecup;Break}
}
start-sleep 1
menu
}

function sortie
{
$sortie = read-host "Voulez-vous retourner au menu Principal? o/n"

    if($sortie -eq "o")
    {   
        Set-Location "$lettre\\_Tech"
        start-process "$lettre\\_Tech\Menu.bat" -verb Runas
        exit
    }
    else
    {
        Get-Process -Name AliyunWrapExe | Out-Null   
        stop-process -Name AliyunWrapExe -ErrorAction SilentlyContinue | Out-Null #gérer easeUS removal
        Task
        exit
    }
}

function submenuHDD
{
Clear-Host
set-location "$env:SystemDrive\"
write-host "[1] Sfc /scannow"
write-host "[2] DISM"
write-host "[3] CHKDSK"
write-host "[4] Creer session admin"
write-host ""
Write-host "[0] Retour au menu precedent" -ForegroundColor 'red'
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{set-location "$lettre\\_Tech\\applications\\fix";menu;break}
1{Start-Process "$PSScriptRoot\Source\Scripts\sfcScannow.bat" | Addlog "Fixlog.txt" "Réparation des fichiers corrompus";Break}
2{Start-Process "$PSScriptRoot\Source\Scripts\DISM.bat" | Addlog "Fixlog.txt" "Réparation du Windows";Break}
3{Start-Process "$PSScriptRoot\Source\Scripts\CHKDSK.BAT" | Addlog "Fixlog.txt" "Réparation du HDD";Break}
4{Start-Process "$PSScriptRoot\Source\Scripts\creer_session.txt" | Addlog "Fixlog.txt" "Nouvelle session créé";Break}
}
start-sleep 1
submenuHDD
}

function submenuMDP
{
Clear-Host
write-host "[1] Browser"
write-host "[2] Chrome"
write-host "[3] Firefox"
write-host "[4] Keys"
write-host "[5] Mail"
write-host "[6] Wireless"
write-host ""
Write-host "[0] Retour au menu precedent" -ForegroundColor 'red'
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start-Process "$PSScriptRoot\Source\Sterjo\SterJo_Browser_Passwords_sps\BrowserPasswords.exe";Break}
2{Start-Process "$PSScriptRoot\Source\Sterjo\SterJo_Chrome_Passwords_sps\ChromePasswords.exe";Break}
3{Start-Process "$PSScriptRoot\Source\Sterjo\Sterjo_Firefox\FirefoxPasswords.exe";Break}
4{Start-Process "$PSScriptRoot\Source\Sterjo\Sterjo_Key\KeyFinder.exe";Break}
5{Start-Process "$PSScriptRoot\Source\Sterjo\SterJo_Mail_Passwords_sps\MailPasswords.exe";Break}
6{Start-Process "$PSScriptRoot\Source\Sterjo\Sterjo_Wireless\WiFiPasswords.exe";Break}
}
Start-Sleep 1
submenuMDP
}

function submenuTweak
{
Clear-Host
write-host "[1] Fix w10"
write-host "[2] Fix w8"
write-host "[3] Ultimate Windows Tweaker W10"
write-host "[4] Ultimate Windows Tweaker W11"
write-host "[5] Tweaking Windows Repair"
write-host ""
Write-host "[0] Retour au menu precedent" -ForegroundColor 'red'
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start-Process "$PSScriptRoot\Source\Tweak\FixWin10\FixWin 10.2.2.exe";Break}
2{Start-Process "$PSScriptRoot\Source\Tweak\FixWin8\FixWin 2.2.exe";break}
3{Start-Process "$PSScriptRoot\Source\Tweak\Ultimate Windows Tweaker w10\Ultimate Windows Tweaker 4.8.exe";Break}
4{Start-Process "$PSScriptRoot\Source\Tweak\Ultimate Windows Tweaker w11\Ultimate Windows Tweaker 5.0.exe";break}
5{Tweaking;Break} 
}
Start-Sleep 1
submenuTweak
}
menu