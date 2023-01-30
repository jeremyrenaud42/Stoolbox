#Les assembly sont nécéssaire pour le fonctionnement du script. Ne pas effacer
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

$driveletter = $pwd.drive.name
$root = "$driveletter" + ":"

set-location "$env:SystemDrive\_Tech\Applications\Desinfection" #met la location au repertoir actuel
#Importer tout mes modules
$modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
{
    Import-Module $modulesFolder\$module
}

function zipsourcevirus #Ce qui va toujours être redownloader à neuf à chaque lancement. Le pack obligatoire pour le fonctionnement + le reset des logs
{
    Sourceexist
    $fondpath = test-Path "$env:SystemDrive\_Tech\Applications\Desinfection\Source\fondopti.jpg" #Vérifie si le fond écran est présent
    $iconepath = test-path "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Icone.ico" #vérifie si l'icone existe
    if($fondpath -eq $false) #si fond pas présent
    {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/fondvirus.png' -OutFile "$env:SystemDrive\_Tech\Applications\Desinfection\Source\fondvirus.png" | Out-Null
    }
    if($iconepath -eq $false) #si icone pas présent
    {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/Icone.ico' -OutFile "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Icone.ico" | Out-Null
    }
}

function zipHitmanPro
{
    $PathHitmanPro = test-Path "$env:SystemDrive\_Tech\Applications\Desinfection\Source\HitmanPro.exe"
    if($PathHitmanPro -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/HitmanPro.exe' -OutFile "$env:SystemDrive\_Tech\Applications\Desinfection\Source\HitmanPro.exe"
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\Desinfection\Source\HitmanPro.exe"
    Addlog "desinfectionlog.txt" "Vérifier les virus avec HitmanPro"
}

function zipautoruns
{
    $pathautoruns = test-Path "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\autoruns.exe"
    if($pathautoruns -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/autoruns.exe' -OutFile "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\autoruns.exe"
    }
    Start-Process "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\autoruns.exe"
    start-sleep 5
    taskmgr
    Addlog "desinfectionlog.txt" "Vérifier les logiciels au démarrage"
}

function zipprocessexplorer
{
    $pathprocexp = test-Path "$env:SystemDrive\_Tech\Applications\Desinfection\Source\procexp64.exe"
    if($pathprocexp -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/procexp64.exe' -OutFile "$env:SystemDrive\_Tech\Applications\Desinfection\Source\procexp64.exe"
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\Desinfection\Source\procexp64.exe"
    Addlog "desinfectionlog.txt" "Vérifier les process"
}

function ziprkill
{
    $pathrkill= test-Path "$env:SystemDrive\_Tech\Applications\Desinfection\Source\rkill64.exe"
    if($pathrkill -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/rkill64.exe' -OutFile "$env:SystemDrive\_Tech\Applications\Desinfection\Source\rkill64.exe"
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\Desinfection\Source\rkill64.exe"
    Addlog "desinfectionlog.txt" "Désactiver les process"
}

function zipadw
{
    $pathadw = test-Path "$env:SystemDrive\_Tech\Applications\Desinfection\Source\adwcleaner.exe"
    if($pathadw -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/adwcleaner.exe' -OutFile "$env:SystemDrive\_Tech\Applications\Desinfection\Source\adwcleaner.exe"
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\Desinfection\Source\adwcleaner.exe"
    Addlog "desinfectionlog.txt" "Analyse ADW effectué"
}

function ziproguekiller
{
    $pathroguekiller= test-Path "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Roguekiller\RogueKiller_Portable64.exe"
    if($pathroguekiller -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/Roguekiller.zip' -OutFile "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Roguekiller.zip"
    Expand-Archive "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Roguekiller.zip" "$env:SystemDrive\_Tech\Applications\Desinfection\Source"
    Remove-Item "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Roguekiller.zip"
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Roguekiller\RogueKiller_portable64.exe"
    Addlog "desinfectionlog.txt" "Analyse RogueKiller effectué"
}

function ziprevo
{
    $revopath = test-Path "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\RevoUninstaller_Portable\RevoUPort.exe"
    if($revopath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/RevoUninstaller_Portable.zip' -OutFile "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\RevoUninstaller_Portable.zip"
    Expand-Archive "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\RevoUninstaller_Portable.zip" "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source"
    Remove-Item "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\RevoUninstaller_Portable.zip"
    }
    Start-Process "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\RevoUninstaller_Portable\RevoUPort.exe"
    Addlog "desinfectionlog.txt" "Vérifier les programmes nuisibles"
}

function zipccleaner
{
    $ccleanerpath = test-Path "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\CCleaner64.exe"
    if($ccleanerpath -eq $false)
    {
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/Ccleaner.zip' -OutFile "$root\\_Tech\Applications\Optimisation_Nettoyage\Source\Ccleaner.zip"
    Expand-Archive "$root\\_Tech\Applications\Optimisation_Nettoyage\Source\Ccleaner.zip" "$root\\_Tech\\Applications\Optimisation_Nettoyage\Source" -Force
    Remove-Item "$root\\_Tech\Applications\Optimisation_Nettoyage\Source\Ccleaner.zip"
    }
    $ccleanerpostpath = test-Path "$env:SystemDrive\Temp\CCleaner\CCleaner64.exe"
    if(!($ccleanerpostpath))
    {
        New-Item "$env:SystemDrive\Temp\CCleaner" -ItemType Directory
        Copy-Item "$root\\_Tech\Applications\Optimisation_Nettoyage\Source\Ccleaner\*" -Destination "$env:SystemDrive\Temp\CCleaner" -Force | Out-Null #copy sur le dossier user pour pas bloquer la clé
    }
    Start-Process "$env:SystemDrive\Temp\CCleaner\CCleaner64.exe"
    Addlog "desinfectionlog.txt" "Nettoyage CCleaner effectué"
}

zipsourcevirus

$image = [system.drawing.image]::FromFile("$env:SystemDrive\_Tech\Applications\Desinfection\Source\fondvirus.png") 
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Desinfection"
$Form.BackgroundImage = $image
$Form.Width = $image.Width
$Form.height = $image.height
$Form.MaximizeBox = $false
$Form.icon = New-Object system.drawing.icon ("$env:SystemDrive\_Tech\Applications\Desinfection\Source\Icone.ico") 
#$Form.add_FormClosed({Task;$Form.Close()}) #Supprimer le dossier _Tech lorsque la form se ferme

#Process_Explorer
$Process_Explorer = New-Object System.Windows.Forms.Button
$Process_Explorer.Location = New-Object System.Drawing.Point(670,300)
$Process_Explorer.Width = '120'
$Process_Explorer.Height = '55'
$Process_Explorer.ForeColor='black'
$Process_Explorer.Text = "Process Explorer"
$Process_Explorer.Font= 'Microsoft Sans Serif,13'
$Process_Explorer.FlatStyle = 'Flat'
$Process_Explorer.FlatAppearance.BorderSize = 2
$Process_Explorer.FlatAppearance.BorderColor = 'darkred'
$Process_Explorer.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Process_Explorer.FlatAppearance.MouseOverBackColor = 'gray'
$Process_Explorer.Add_Click({
zipprocessexplorer
})

#RKill
$RKill = New-Object System.Windows.Forms.Button
$RKill.Location = New-Object System.Drawing.Point(670,200)
$RKill.Width = '120'
$RKill.Height = '55'
$RKill.ForeColor='black'
$RKill.BackColor = 'red'
$RKill.Text = "RKill"
$RKill.Font= 'Microsoft Sans Serif,13'
$RKill.FlatStyle = 'Flat'
$RKill.FlatAppearance.BorderSize = 2
$RKill.FlatAppearance.BorderColor = 'darkred'
$RKill.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$RKill.FlatAppearance.MouseOverBackColor = 'gray'
$RKill.Add_Click({
ziprkill
})

#Autoruns
$Autoruns = New-Object System.Windows.Forms.Button
$Autoruns.Location = New-Object System.Drawing.Point(200,200)
$Autoruns.Width = '120'
$Autoruns.Height = '55'
$Autoruns.ForeColor='black'
$Autoruns.Text = "Autoruns"
$Autoruns.Font= 'Microsoft Sans Serif,13'
$Autoruns.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Autoruns.FlatAppearance.BorderSize = 2
$Autoruns.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Autoruns.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Autoruns.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Autoruns.Add_Click({
zipautoruns
})

#Nettoyage
$HDD = New-Object System.Windows.Forms.Button
$HDD.Location = New-Object System.Drawing.Point(200,400)
$HDD.Width = '120'
$HDD.Height = '55'
$HDD.ForeColor='black'
$HDD.BackColor = 'darkcyan'
$HDD.Text = "Nettoyage HDD"
$HDD.Font= 'Microsoft Sans Serif,13'
$HDD.FlatStyle = 'Flat'
$HDD.FlatAppearance.BorderSize = 2
$HDD.FlatAppearance.BorderColor = 'darkred'
$HDD.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$HDD.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$HDD.Add_Click({
Start-Process "$env:SystemDrive\Windows\SYSTEM32\cleanmgr.exe"
Addlog "desinfectionlog.txt" "Nettoyage du disque effectué"
})

#Ccleaner
$Ccleaner = New-Object System.Windows.Forms.Button
$Ccleaner.Location = New-Object System.Drawing.Point(200,300)
$Ccleaner.Width = '120'
$Ccleaner.Height = '55'
$Ccleaner.ForeColor='black'
$Ccleaner.BackColor = 'darkgreen'
$Ccleaner.Text = "Ccleaner"
$Ccleaner.Font= 'Microsoft Sans Serif,13'
$Ccleaner.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Ccleaner.FlatAppearance.BorderSize = 2
$Ccleaner.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Ccleaner.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Ccleaner.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Ccleaner.Add_Click({
zipccleaner
})

#Restauration
$Restauration = New-Object System.Windows.Forms.Button
$Restauration.Location = New-Object System.Drawing.Point(30,50)
$Restauration.Width = '120'
$Restauration.Height = '55'
$Restauration.ForeColor='black'
$Restauration.BackColor = 'cyan'
$Restauration.Text = "Point de restauration"
$Restauration.Font= 'Microsoft Sans Serif,13'
$Restauration.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Restauration.FlatAppearance.BorderSize = 2
$Restauration.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Restauration.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Restauration.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Restauration.Add_Click({
CreateRestorePoint #| Out-Null
Addlog "desinfectionlog.txt" "Point de restauration effectué"
})

Function Revo
{
$PathRevo= "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\RevoUninstaller_Portable\\RevoUPort.exe"
Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName  | Sort-Object -Property DisplayName | Format-Table �AutoSize > "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\RevoBefore.txt"
Start-Process -wait "$PathRevo"
AddLog "desinfectionlog.txt" "Vérifier les programmes nuisibles"
Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName  | Sort-Object -Property DisplayName | Format-Table �AutoSize > "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\RevoAfter.txt"
Compare-Object -ReferenceObject (Get-Content -path "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\RevoBefore.txt") -DifferenceObject (Get-Content -path "$root\\_Tech\\Applications\\Optimisation_Nettoyage\\Source\\RevoAfter.txt") | Out-File "$env:SystemDrive\_Tech\Applications\Desinfection\Source\Logs\Log.txt" -Append
}

#Revo
$Revo = New-Object System.Windows.Forms.Button
$Revo.Location = New-Object System.Drawing.Point(670,400)
$Revo.Width = '120'
$Revo.Height = '55'
$Revo.ForeColor='black'
$Revo.BackColor = 'cyan'
$Revo.Text = "Revo"
$Revo.Font= 'Microsoft Sans Serif,13'
$Revo.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Revo.FlatAppearance.BorderSize = 2
$Revo.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Revo.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Revo.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Revo.Add_Click({
ziprevo
})


#ADWcleaner
$ADWcleaner = New-Object System.Windows.Forms.Button
$ADWcleaner.Location = New-Object System.Drawing.Point(460,100)
$ADWcleaner.Width = '120'
$ADWcleaner.Height = '55'
$ADWcleaner.ForeColor='black'
$ADWcleaner.BackColor = 'Yellow'
$ADWcleaner.Text = "ADW"
$ADWcleaner.Font= 'Microsoft Sans Serif,13'
$ADWcleaner.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$ADWcleaner.FlatAppearance.BorderSize = 2
$ADWcleaner.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$ADWcleaner.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$ADWcleaner.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$ADWcleaner.Add_Click({
zipadw
})

#MalwareByte
$MalwareByte = New-Object System.Windows.Forms.Button
$MalwareByte.Location = New-Object System.Drawing.Point(460,200)
$MalwareByte.Width = '120'
$MalwareByte.Height = '55'
$MalwareByte.ForeColor='black'
$MalwareByte.BackColor = 'magenta'
$MalwareByte.Text = "MalwareByte"
$MalwareByte.Font= 'Microsoft Sans Serif,12.5'
$MalwareByte.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$MalwareByte.FlatAppearance.BorderSize = 2
$MalwareByte.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$MalwareByte.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$MalwareByte.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$MalwareByte.Add_Click({
$path = Test-Path "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe"
if($path -eq $false)
{
    Chocoinstall
    choco install malwarebytes -y | Out-Null
    if($path -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/Ninite Malwarebytes Installer.exe' -OutFile "$root\_Tech\Applications\Desinfection\Source\Ninite Malwarebytes Installer.exe"
        Start-Process "$root\_Tech\\Applications\Desinfection\Source\Ninite Malwarebytes Installer.exe"
        $path = Test-Path "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe"
        if($path -eq $false)
        {
            Wingetinstall
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
Addlog "desinfectionlog.txt" "Analyse Malwarebyte effectué"
})

#SuperAntiSpyware
$SuperAntiSpyware = New-Object System.Windows.Forms.Button
$SuperAntiSpyware.Location = New-Object System.Drawing.Point(460,300)
$SuperAntiSpyware.Width = '120'
$SuperAntiSpyware.Height = '55'
$SuperAntiSpyware.ForeColor='black'
$SuperAntiSpyware.BackColor = 'cyan'
$SuperAntiSpyware.Text = "Super Anti Spyware"
$SuperAntiSpyware.Font= 'Microsoft Sans Serif,13'
$SuperAntiSpyware.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$SuperAntiSpyware.FlatAppearance.BorderSize = 2
$SuperAntiSpyware.FlatAppearance.BorderColor = 'darkred'
$SuperAntiSpyware.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$SuperAntiSpyware.FlatAppearance.MouseOverBackColor = 'gray'
$SuperAntiSpyware.Add_Click({
$path = Test-Path "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe"
if($path -eq $false)
{
    Chocoinstall
    choco install superantispyware -y | out-null
    Start-Process "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe" 
    if($path -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/Ninite SUPERAntiSpyware Installer.exe' -OutFile "$root\_Tech\Applications\Desinfection\Source\Ninite SUPERAntiSpyware Installer.exe"
        Start-Process "$root\_Tech\\Applications\Desinfection\Source\Ninite SUPERAntiSpyware Installer.exe"
        $path = Test-Path "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe"
        if($path -eq $false)
        {
            Wingetinstall
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
Addlog "desinfectionlog.txt" "Analyse SuperAntiSpyware effectué"
})

#HitmanPro
$HitmanPro = New-Object System.Windows.Forms.Button
$HitmanPro.Location = New-Object System.Drawing.Point(460,400)
$HitmanPro.Width = '120'
$HitmanPro.Height = '55'
$HitmanPro.ForeColor='black'
$HitmanPro.BackColor = 'darkcyan'
$HitmanPro.Text = "HitmanPro"
$HitmanPro.Font= 'Microsoft Sans Serif,13'
$HitmanPro.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$HitmanPro.FlatAppearance.BorderSize = 2
$HitmanPro.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$HitmanPro.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$HitmanPro.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$HitmanPro.Add_Click({
zipHitmanPro
})

#RogueKiller
$RogueKiller = New-Object System.Windows.Forms.Button
$RogueKiller.Location = New-Object System.Drawing.Point(460,500)
$RogueKiller.Width = '120'
$RogueKiller.Height = '55'
$RogueKiller.ForeColor='black'
$RogueKiller.BackColor = 'darkgreen'
$RogueKiller.Text = "RogueKiller"
$RogueKiller.Font= 'Microsoft Sans Serif,13'
$RogueKiller.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$RogueKiller.FlatAppearance.BorderSize = 2
$RogueKiller.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$RogueKiller.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$RogueKiller.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$RogueKiller.Add_Click({
ziproguekiller
})
#via le cmd, aller a l'emplacement RogueKillerCMD.exe -scan -no-interact -deleteall #-debuglog {path}

#Quitter
$quit = New-Object System.Windows.Forms.Button
$quit.Location = New-Object System.Drawing.Point(460,575)
$quit.Width = '120'
$quit.Height = '55'
$quit.ForeColor='darkblue'
$quit.BackColor = 'darkred'
$quit.Text = "Quitter"
$quit.Font= 'Microsoft Sans Serif,13'
$quit.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$quit.FlatAppearance.BorderSize = 2
$quit.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$quit.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$quit.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$quit.Add_Click({
Task
$Form.Close()
})

#Menu principal
$Menuprincipal = New-Object System.Windows.Forms.Button
$Menuprincipal.Location = New-Object System.Drawing.Point(105,575)
$Menuprincipal.Width = '120'
$Menuprincipal.Height = '55'
$Menuprincipal.ForeColor='darkblue'
$Menuprincipal.BackColor = 'darkred'
$Menuprincipal.Text = "Menu principal"
$Menuprincipal.Font= 'Microsoft Sans Serif,13'
$Menuprincipal.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$Menuprincipal.FlatAppearance.BorderSize = 2
$Menuprincipal.FlatAppearance.BorderColor = [System.Drawing.Color]::darkred
$Menuprincipal.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Darkmagenta
$Menuprincipal.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::gray
$Menuprincipal.Add_Click({
$Form.Close()
start-process "$root\_Tech\Menu.bat" -verb Runas
})

#Label
$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Point(358,35)
$label.AutoSize = $false
$label.width = 325
$label.height = 55
$label.Font= 'Microsoft Sans Serif,16'
$label.ForeColor='white'
$label.BackColor = 'darkred'
$label.Text = "Choisissez une option"
$label.TextAlign = 'MiddleCenter'

#afficher la form
$Form.controls.AddRange(@($Menuprincipal,$Ccleaner,$HDD,$Rkill,$Autoruns,$Process_Explorer,$Restauration,$Revo,$ADWcleaner,$MalwareByte,$SuperAntiSpyware,$HitmanPro,$RogueKiller,$Quit,$label))
$Form.ShowDialog() | out-null