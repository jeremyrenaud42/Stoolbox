#Les assembly sont nécéssaire pour le fonctionnement du script. Ne pas effacer
Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

#Cette fonction permet de relancer le script en mode Admin si besoin
function Admin
{
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
     {
        Start-Process powershell.exe -ArgumentList ("-NoProfile -windowstyle hidden -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit #permet de fermer la session non-Admin
    }
}

function FolderCreation($folder) #Création des dossiers
{
    $path = "$env:SystemDrive\$folder"
    $folderexist = test-path $path 
    if($folderexist -eq $false)
    {
        New-Item $path -ItemType 'Directory' -Force | Out-Null
    }
}

#Download des files pour Remove  et delete
function Remove
{
    FolderCreation "Temp"
    $delete = test-path "$env:SystemDrive\Temp\delete.ps1"
    if($delete -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/delete.ps1' -OutFile "$env:SystemDrive\Temp\delete.ps1" | Out-Null
    }
    $remove = test-path "$env:SystemDrive\Temp\Remove.bat"
    if($remove -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/Remove.bat' -OutFile "$env:SystemDrive\Temp\Remove.bat" | Out-Null
    } 
}

function Modules #Dowload les modules
{
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Modules.zip' -OutFile "$env:SystemDrive\_Tech\applications\source\Modules.zip" | Out-Null
    Expand-Archive "$env:SystemDrive\_Tech\applications\source\Modules.zip" "$env:SystemDrive\_Tech\applications\source" -Force
    Remove-Item "$env:SystemDrive\_Tech\applications\source\Modules.zip"
}
    
function Zipsource #Download et création des fondamentaux
{
    #Preinstall #Va créer les dossiers
    FolderCreation "_Tech\Applications"
    FolderCreation "_Tech\Applications\Source"
    FolderCreation "_Tech\Applications\Source\images"
    $fondpath = test-Path "$env:SystemDrive\_Tech\applications\source\Images\fondpluiesize.gif" #Vérifie si le fond écran est présent
    $iconepath = test-path "$env:SystemDrive\_Tech\applications\source\Images\Icone.ico" #vérifie si l'icone existe
        if($fondpath -eq $false) #si fond pas présent
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' -OutFile "$env:SystemDrive\_Tech\applications\source\Images\fondpluiesize.gif" | Out-Null #Download le fond
        }
        if($iconepath -eq $false) #si icone pas présent
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' -OutFile "$env:SystemDrive\_Tech\applications\source\Images\Icone.ico" | Out-Null #Download l'icone
        } 
    Remove #Va download remove
    Modules #Va download les modules
}

Admin #emet en admin si pas executer en admin
Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force #met la policy a unrestricted a cause de intermediate .ps1
set-location "$env:SystemDrive\_Tech" #met la location au repertoir actuel
Zipsource #install les fichiers sources
Import-Module "$env:SystemDrive\_Tech\Applications\Source\modules\task.psm1" | Out-Null #Module pour supprimer C:\_Tech

$img = [system.drawing.image]::FromFile("$env:SystemDrive\_Tech\Applications\Source\Images\fondpluiesize.gif") #Il faut mettre le chemin complet pour éviter des erreurs.
$pictureBoxBackGround = new-object Windows.Forms.PictureBox #permet d'afficher un gif
$pictureBoxBackGround.width = $img.width 
$pictureBoxBackGround.height = $img.height
$pictureBoxBackGround.Image = $img #contient l'image gif de background
$pictureBoxBackGround.AutoSize = $true 

$form = New-Object System.Windows.Forms.Form
$form.Text = "Menu - Boite à outils du technicien"
$form.Width = $img.Width
$form.height = $img.height
$form.MaximizeBox = $false
$form.icon = New-Object system.drawing.icon ("$env:SystemDrive\_Tech\Applications\Source\Images\Icone.ico") #Il faut mettre le chemin complet pour éviter des erreurs.
$form.KeyPreview = $True
$form.Add_KeyDown({if ($_.KeyCode -eq "Escape") {Task;$form.Close()}}) #si on fait échape sa ferme la fenetre
#$form.add_FormClosed({Task;$form.Close()})
$form.TopMost = $true
$form.StartPosition = "CenterScreen"
$form.BackgroundImageLayout = "Stretch"

function FolderDownload($folder,$ps1download,$batdownload)
{
    FolderCreation "_Tech\Applications\$folder" #Créer le dossier vide s'il n'existe pas
    Invoke-WebRequest $ps1download -OutFile "$env:SystemDrive\_Tech\Applications\$folder\$folder.ps1" | Out-Null #download le .exe
    Invoke-WebRequest $batdownload -OutFile "$env:SystemDrive\_Tech\Applications\$folder\RunAs$folder.bat" | Out-Null #download le .exe
    set-location "$env:SystemDrive\_Tech\Applications\$folder" #met le path dans le dossier 
    Start-Process "$env:SystemDrive\_Tech\Applications\$folder\RunAs$folder.bat" | Out-Null #Lance le script
}

#Installation
$boutonInstall = New-Object System.Windows.Forms.Button
$boutonInstall.Location = New-Object System.Drawing.Point(446,100)
$boutonInstall.AutoSize = $false
$boutonInstall.Width = '150'
$boutonInstall.Height = '65'
$boutonInstall.ForeColor='black'
$boutonInstall.BackColor = 'darkred'
$boutonInstall.Text = "Installation Windows"
$boutonInstall.Font= 'Microsoft Sans Serif,16'
$boutonInstall.FlatStyle = 'Flat'
$boutonInstall.FlatAppearance.BorderSize = 2
$boutonInstall.FlatAppearance.BorderColor = 'black'
$boutonInstall.FlatAppearance.MouseDownBackColor = 'darkcyan'
$boutonInstall.FlatAppearance.MouseOverBackColor = 'gray'
$boutonInstall.Add_MouseEnter({$boutonInstall.ForeColor = 'White'})
$boutonInstall.Add_MouseLeave({$boutonInstall.ForeColor = 'Black'})
$boutonInstall.Add_Click({
FolderDownload "Installation" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsInstallation.bat'
$form.Close()
})

#Optimisation et nettoyage
$boutonOptiNett = New-Object System.Windows.Forms.Button
$boutonOptiNett.Location = New-Object System.Drawing.Point(446,175)
$boutonOptiNett.AutoSize = $false
$boutonOptiNett.Width = '150'
$boutonOptiNett.Height = '65'
$boutonOptiNett.ForeColor='black'
$boutonOptiNett.BackColor = 'darkred'
$boutonOptiNett.Text = "Optimisation et Nettoyage"
$boutonOptiNett.Font= 'Microsoft Sans Serif,16'
$boutonOptiNett.FlatStyle = 'Flat'
$boutonOptiNett.FlatAppearance.BorderSize = 3
$boutonOptiNett.FlatAppearance.BorderColor = 'black'
$boutonOptiNett.FlatAppearance.MouseDownBackColor = 'darkcyan'
$boutonOptiNett.FlatAppearance.MouseOverBackColor = 'gray'
$boutonOptiNett.Add_MouseEnter({$boutonOptiNett.ForeColor = 'White'})
$boutonOptiNett.Add_MouseLeave({$boutonOptiNett.ForeColor = 'Black'})
$boutonOptiNett.Add_Click({
FolderDownload "Optimisation_Nettoyage" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsOptimisation_Nettoyage.bat'
$form.Close()
})

#Diagnostic
$diagnostic = New-Object System.Windows.Forms.Button
$diagnostic.Location = New-Object System.Drawing.Point(446,250)
$diagnostic.Width = '150'
$diagnostic.Height = '65'
$diagnostic.ForeColor='black'
$diagnostic.BackColor = 'darkred'
$diagnostic.Text = "Diagnostique"
$diagnostic.Font= 'Microsoft Sans Serif,16'
$diagnostic.FlatStyle = 'Flat'
$diagnostic.FlatAppearance.BorderSize = 3
$diagnostic.FlatAppearance.BorderColor = 'black'
$diagnostic.FlatAppearance.MouseDownBackColor = 'darkcyan'
$diagnostic.FlatAppearance.MouseOverBackColor = 'gray'
$diagnostic.Add_MouseEnter({$diagnostic.ForeColor = 'White'})
$diagnostic.Add_MouseLeave({$diagnostic.ForeColor = 'Black'})
$diagnostic.Add_Click({
FolderDownload "Diagnostique" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDiagnostique.bat'
$form.Close()
})

function Zipdesinfection 
{
    FolderCreation "_Tech\Applications\Securite" #Créer le dossier vide Securite s'il n'existe pas
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' -OutFile "$env:SystemDrive\_Tech\Applications\Securite\Desinfection.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDesinfection.bat' -OutFile "$env:SystemDrive\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #download le .exe
    set-location "$env:SystemDrive\_Tech\Applications\Securite" #met le path dans le dossier Securite
    Start-Process "$env:SystemDrive\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #Lance le script de désinfcetion
}

#Desinfection
$desinfection = New-Object System.Windows.Forms.Button
$desinfection.Location = New-Object System.Drawing.Point(446,325)
$desinfection.Width = '150'
$desinfection.Height = '65'
$desinfection.ForeColor='black'
$desinfection.BackColor = 'darkred'
$desinfection.Text = "Désinfection"
$desinfection.Font= 'Microsoft Sans Serif,16'
$desinfection.FlatStyle = 'Flat'
$desinfection.FlatAppearance.BorderSize = 3
$desinfection.FlatAppearance.BorderColor = 'black'
$desinfection.FlatAppearance.MouseDownBackColor = 'darkcyan'
$desinfection.FlatAppearance.MouseOverBackColor = 'gray'
$desinfection.Add_MouseEnter({$desinfection.ForeColor = 'White'})
$desinfection.Add_MouseLeave({$desinfection.ForeColor = 'Black'})
$desinfection.Add_Click({
Zipdesinfection
#FolderDownload "Securite" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsDesinfection.bat'
$form.Close()
})

#Fix
$fix = New-Object System.Windows.Forms.Button
$fix.Location = New-Object System.Drawing.Point(446,400)
$fix.Width = '150'
$fix.Height = '65'
$fix.ForeColor='black'
$fix.BackColor = 'darkred'
$fix.Text = "Fix"
$fix.Font= 'Microsoft Sans Serif,16'
$fix.FlatStyle = 'Flat'
$fix.FlatAppearance.BorderSize = 3
$fix.FlatAppearance.BorderColor = 'black'
$fix.FlatAppearance.MouseDownBackColor = 'darkcyan'
$fix.FlatAppearance.MouseOverBackColor = 'gray'
$fix.Add_MouseEnter({$fix.ForeColor = 'White'})
$fix.Add_MouseLeave({$fix.ForeColor = 'Black'})
$fix.Add_Click({
FolderDownload "Fix" 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1' 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/RunAsFix.bat'
$form.Close()
})

#changelog
$changelog = New-Object System.Windows.Forms.Button
$changelog.Location = New-Object System.Drawing.Point(026,600)
$changelog.Width = '115'
$changelog.Height = '40'
$changelog.ForeColor= 'white'
$changelog.BackColor = 'black'
$changelog.Text = "Changelog"
$changelog.Font= 'Microsoft Sans Serif,10'
$changelog.FlatStyle = 'Flat'
$changelog.FlatAppearance.BorderSize = 3
$changelog.FlatAppearance.BorderColor = 'black'
$changelog.FlatAppearance.MouseDownBackColor = 'Darkcyan'
$quit.FlatAppearance.MouseOverBackColor = 'darkred'
$changelog.Add_MouseEnter({$changelog.ForeColor = 'black'})
$changelog.Add_MouseLeave({$changelog.ForeColor = 'darkred'})
$changelog.Add_Click({
    $form.TopMost = $false
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/changelog.txt' -OutFile "$env:SystemDrive\_Tech\changelog.txt" | Out-Null #download le .ps1
    Start-Process "$env:SystemDrive\_Tech\changelog.txt"
    Start-Sleep -s 5
    $form.TopMost = $true
})

#quitter
$quit = New-Object System.Windows.Forms.Button
$quit.Location = New-Object System.Drawing.Point(446,575)
$quit.Width = '150'
$quit.Height = '65'
$quit.ForeColor= 'darkred'
$quit.BackColor = 'black'
$quit.Text = "Quitter"
$quit.Font= 'Microsoft Sans Serif,16'
$quit.FlatStyle = 'Flat'
$quit.FlatAppearance.BorderSize = 3
$quit.FlatAppearance.BorderColor = 'black'
$quit.FlatAppearance.MouseDownBackColor = 'Darkcyan'
$quit.FlatAppearance.MouseOverBackColor = 'darkred'
$quit.Add_MouseEnter({$quit.ForeColor = 'black'})
$quit.Add_MouseLeave({$quit.ForeColor = 'darkred'})
$quit.Add_Click({
Task
$form.Close()
})
 
#Choisissez une option
$labelchoisiroption = New-Object System.Windows.Forms.label
$labelchoisiroption.Location = New-Object System.Drawing.Point(359,35)
$labelchoisiroption.AutoSize = $true
$labelchoisiroption.width = 325
$labelchoisiroption.height = 55
$labelchoisiroption.TextAlign = 'MiddleCenter'
$labelchoisiroption.Font= 'Microsoft Sans Serif,22'
$labelchoisiroption.ForeColor='white'
$labelchoisiroption.BackColor = 'darkred'
$labelchoisiroption.Text = "Choisissez une option"
$labelchoisiroption.BorderStyle = 'fixed3D'

#signatureSTO
$signatureSTO = New-Object System.Windows.Forms.label
$signatureSTO.Location = New-Object System.Drawing.Point(861,633)
$signatureSTO.AutoSize = $true
$signatureSTO.width = 180
$signatureSTO.height = 20
$signatureSTO.Font= 'Centau,10'
$signatureSTO.ForeColor='gray'
$signatureSTO.BackColor = 'black'
$signatureSTO.Text = "Propriété de Jérémy Renaud"
$signatureSTO.TextAlign = 'Middleleft'

#afficher la form
$form.controls.AddRange(@($signatureSTO,$labelchoisiroption,$boutonInstall,$boutonOptiNett,$diagnostic,$desinfection,$fix,$quit,$changelog,$pictureBoxBackGround))
$form.ShowDialog() | out-null