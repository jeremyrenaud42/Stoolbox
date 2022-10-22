Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.speech
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

<#
$image = [system.drawing.image]::FromFile("$root\\_Tech\\Applications\\Diagnostique\\Source\\Images\\alley-89197_1920_1041x688.jpg")
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Diagnostiques"
#$Form.BackgroundImage = $image
$Form.Width = $image.Width
$Form.height = $image.height
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.icon = New-Object system.drawing.icon ("$root\\_Tech\\Applications\\Source\\Images\\Icone.ico") 

#Quitter
$quit = New-Object System.Windows.Forms.Button
$quit.Location = New-Object System.Drawing.Point(469,575)
$quit.Width = '120'
$quit.Height = '55'
$quit.ForeColor='black'
$quit.BackColor = 'darkred'
$quit.Text = "Quitter"
$quit.Font= 'Microsoft Sans Serif,12'
$quit.FlatStyle = 'Flat'
$quit.FlatAppearance.BorderSize = 2
$quit.FlatAppearance.BorderColor = 'black'
$quit.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$quit.FlatAppearance.MouseOverBackColor = 'gray'
$quit.Add_MouseEnter({$quit.ForeColor = 'White'})
$quit.Add_MouseLeave({$quit.ForeColor = 'black'})
$quit.Add_Click({
$Form.Close()
})

#Menu principal
$Menuprincipal = New-Object System.Windows.Forms.Button
$Menuprincipal.Location = New-Object System.Drawing.Point(25,25)
$Menuprincipal.Width = '120'
$Menuprincipal.Height = '55'
$Menuprincipal.ForeColor='black'
$Menuprincipal.BackColor = 'darkred'
$Menuprincipal.Text = "Menu principal"
$Menuprincipal.Font= 'Microsoft Sans Serif,12'
$Menuprincipal.FlatStyle = 'Flat'
$Menuprincipal.FlatAppearance.BorderSize = 2
$Menuprincipal.FlatAppearance.BorderColor = 'black'
$Menuprincipal.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Menuprincipal.FlatAppearance.MouseOverBackColor = 'gray'
$Menuprincipal.Add_MouseEnter({$Menuprincipal.ForeColor = 'White'})
$Menuprincipal.Add_MouseLeave({$Menuprincipal.ForeColor = 'black'})
$Menuprincipal.Add_Click({
start-process "$root\\_Tech\\Menu.exe" -verb Runas
$Form.Close()
})


$Form.controls.AddRange(@($Menuprincipal,$Quit))
$Form.ShowDialog() | out-null
#>

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

set-location "$root\\_Tech\\Applications\\fix" #met la location au repertoir actuel
$loc = Get-Location #assgine la location du repertoir actuel

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

$logfilepath="$PSScriptRoot\Source\Logs\Log.txt"
function AddLog ($message)
{
(Get-Date).ToString() + " - " + $message + "`r`n">> $logfilepath
}


Function menu
{
cls
write-host "[1] Fichiers corrompues" -ForegroundColor Cyan
write-host "[2] Windows Tweak et Fix" -ForegroundColor Green
write-host "[3] Obtenir MDP et licenses" -ForegroundColor darkcyan
write-host "[4] Desinstaller les pilotes graphiques (DDU)" -ForegroundColor DarkGreen
write-host "[5] Supprimer un dossier" -ForegroundColor magenta
write-host "[6] Windirstat" -ForegroundColor red
write-host "[7] Partition Wizard" -ForegroundColor green
write-host "[8] Reparer Internet" -ForegroundColor DarkRed
write-host "[9] Recuperer des donnees" -ForegroundColor Yellow
#write-host "[10] Driver Internet" -ForegroundColor white
write-host ""
write-host "[0] Quitter" -ForegroundColor red
$choix = read-host "Choisissez une option" 

switch ($choix)
{
0{sortie;break}
1{submenu-HDD;Break}
2{submenu-Tweak;Break}
3{submenu-MDP;Break}
4{Start "$PSScriptRoot\Source\DDU\Display Driver Uninstaller.exe" | addlog "Désinstallation du pilote graphique avec DDU";Break}
5{submenu-Dossier;Break}
6{start "$PSScriptRoot\Source\WinDirStat\WinDirStatPortable.exe";Break}
7{start "$PSScriptRoot\Source\MiniTool Partition Wizard 11\partitionwizard.exe";Break}
8{start "$PSScriptRoot\Source\ComIntRep\ComIntRep_X64.exe";Break}
9{start "$PSScriptRoot\Source\Recup_donnees\EaseUS Data Recovery Wizard\DRW.EXE";Break}
10{Start "$PSScriptRoot\Source\Drivers\pilote_carte_asus\setup.exe"| addlog "installation du pilote wifi asus";Break}
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
        start-process "$lettre\\_Tech\\RunAsMenu.bat" -verb Runas
        exit
    }
    else
    {
        exit
    }
}

function submenu-HDD
{
cls
set-location "c:\"
write-host "[1] Sfc /scannow"
write-host "[2] DISM"
write-host "[3] CHKDSK"
write-host "[4] Creer session admin"
write-host ""
Write-host "[0] Retour au menu précédent" -ForegroundColor red
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{set-location "$lettre\\_Tech\\applications\\fix"; menu; break}
1{start "$PSScriptRoot\Source\Scripts\sfcScannow.bat" | addlog "Réparation des fichiers corrompus" ;Break}
2{start "$PSScriptRoot\Source\Scripts\DISM.bat" | addlog "Réparation du Windows" ;Break}
3{start "$PSScriptRoot\Source\Scripts\CHKDSK.BAT" | addlog "Réparation du HDD";Break}
4{start "$PSScriptRoot\Source\Scripts\creer_session.txt" | addlog "Nouvelle session créé" ;Break}
}
start-sleep 1
submenu-HDD
}

function submenu-Dossier
{
cls
write-host "[1] Unlocker"
write-host "[2] WinOwnership"
write-host "[3] TakeOwnershipPro"
write-host "[4] FileAssassin"
write-host "[5] Wise Force Deleter"
write-host ""
Write-host "[0] Retour au menu précédent" -ForegroundColor red
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start "$PSScriptRoot\Source\Securite_Dossier\Unlocker\UnlockerPortable.exe";Break}
2{Start "$PSScriptRoot\Source\Securite_Dossier\WinOwnership\WinOwnership v1.1.exe";Break}
3{Start "$PSScriptRoot\Source\Securite_Dossier\TakeOwnershipPro\TakeOwnershipPro.exe";Break}
4{Start "$PSScriptRoot\Source\Securite_Dossier\FileAssassin\FileASSASSIN.exe";Break}
5{Start "$PSScriptRoot\Source\Securite_Dossier\Wise Force Deleter\WiseDeleter.exe";Break}
}
Start-Sleep 1
submenu-Dossier
}

function submenu-MDP
{
cls
write-host "[1] Browser"
write-host "[2] Chrome"
write-host "[3] Firefox"
write-host "[4] Keys"
write-host "[5] Mail"
write-host "[6] Wireless"
write-host "[7] NetStalker"
write-host ""
Write-host "[0] Retour au menu précédent" -ForegroundColor red
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start "$PSScriptRoot\Source\Sterjo\SterJo_Browser_Passwords_sps\BrowserPasswords.exe";Break}
2{Start "$PSScriptRoot\Source\Sterjo\SterJo_Chrome_Passwords_sps\ChromePasswords.exe";Break}
3{Start "$PSScriptRoot\Source\Sterjo\Sterjo_Firefox\FirefoxPasswords.exe";Break}
4{Start "$PSScriptRoot\Source\Sterjo\Sterjo_Key\KeyFinder.exe";Break}
5{Start "$PSScriptRoot\Source\Sterjo\SterJo_Mail_Passwords_sps\MailPasswords.exe";Break}
6{Start "$PSScriptRoot\Source\Sterjo\Sterjo_Wireless\WiFiPasswords.exe";Break}
7{Start "$PSScriptRoot\Source\Sterjo\SterJo_NetStalker_sps\NetStalker.exe";Break}
}

Start-Sleep 1
submenu-MDP
}

function submenu-Tweak
{
cls
write-host "[1] Fix w10"
write-host "[2] Fix w8"
write-host "[3] Fix w7"
write-host "[4] Tweaking - Windows Repair"
write-host "[5] Ultimate Windows Tweaker W10"
write-host "[6] Ultimate Windows Tweaker W11"
write-host ""
Write-host "[0] Retour au menu précédent" -ForegroundColor red
$choix = read-host "Choisissez une option"

switch ($choix)
{
0{menu}
1{Start "$PSScriptRoot\Source\Tweak\FixWin10\FixWin 10.2.2.exe";Break}
2{Start "$PSScriptRoot\Source\Tweak\FixWin8\FixWin 2.2.exe";break}
3{Start "$PSScriptRoot\Source\Tweak\FixWin7\FixWin v 1.2.exe";Break}
4{Start "$PSScriptRoot\Source\Tweak\Tweaking.com - Windows Repair\Repair_Windows.exe";Break}
5{Start "$PSScriptRoot\Source\Tweak\Ultimate Windows Tweaker w10\Ultimate Windows Tweaker 4.8.exe";Break}
6{Start "$PSScriptRoot\Source\Tweak\Ultimate Windows Tweaker w11\Ultimate Windows Tweaker 5.0.exe";break}
}
Start-Sleep 1
submenu-Tweak
}

menu