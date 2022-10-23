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
        Start-Process powershell.exe -ArgumentList ("-NoProfile -windowstyle hidden -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit #permet de fermer la session non-admin
    }
}
admin

function Testconnexion
{
    $internet = $false
    $ping = test-connection 8.8.8.8 -Count 1 -quiet -ErrorAction Ignore
    if ($ping -eq $true)
    {
       $internet = $true 
    } 
    else 
    {
        write-warning "Vous n'êtes pas connecté à Internet, certaines fonctionnalités ne pourraient pas fonctionner"
    }
    return $internet
}

function zipsource #Download et création des fondamentaux
{
$fondpath = test-Path "$root\_Tech\applications\source\Images\fondpluiesize.gif" #Vérifie si le fond écran est présent
$iconepath = test-path "$root\_Tech\applications\source\Images\Icone.ico" #vérifie si l'icone existe
    if($fondpath -eq $false) #si fond pas présent
    {
        New-Item "$root\_Tech\Applications\Source\Images" -ItemType Directory -Force | Out-Null #créé les dossiers source\images
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' -OutFile "$root\_Tech\applications\source\Images\fondpluiesize.gif" | Out-Null #Download le fond
    }
    if($iconepath -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' -OutFile "$root\_Tech\applications\source\Images\Icone.ico" | Out-Null #Download l'icone
    }    
}

function testpath #vérification que le dossier a bien été créé par zipsource
{
$keypath = Test-Path "c:\_Tech\applications" #Test si dossier applications existe
    if (!($keypath)) #S'il n'existe pas
    {
        [System.Windows.MessageBox]::Show("Votre clé n'est pas configuré de la bonne facon","Chemin obligatoire",0) | Out-Null #Affiche ce message
        [System.Windows.MessageBox]::Show("Elle doit respectée le chemin C:\_Tech\Applications\...","Chemin obligatoire",0) | Out-Null #Affiche ce message
        exit
    }
}

function Update
{
    New-Item "$root\_Tech\Temp" -ItemType Directory -Force | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/versions/main/menu.version.txt' -OutFile "$root\_Tech\Temp\menu.version.txt" | Out-Null
    $valuedownloadfile = Get-Content -Path "$root\_Tech\Temp\menu.version.txt" | Out-Null #fichier version nouveau
    $valueactualfile = Get-Content -Path "$root\_Tech\menu.version.txt" | Out-Null #fichier version actuel

    if ($valuedownloadfile -gt $valueactualfile) 
    { 
        try 
        {
            Write-Host "Lancer mise à jour de Menu.exe"
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.ps1' -OutFile "$root\_Tech\Menu.ps1" | Out-Null
            Copy-Item "$root\_Tech\Temp\menu.version.txt" -Destination "$root\_Tech\menu.version.txt" -Force | Out-Null #Met le fichier version a jour.
        }
        catch 
        {
            Write-Error "Erreur lors de la mise à jour de Menu.ps1!"
            return
        }
    } 
    Remove-Item "$root\_Tech\Temp" -Recurse -Force #Supprime le dossier temp
    return  
}

Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force #met la policy a unrestricted a cause de intermediate .ps1
$driveletter = $pwd.drive.name #retourne la lettre du disque actuel
$root = "$driveletter" + ":" #rajoute  : pour que sa fit dans le path
set-location "C:\_Tech" #met la location au repertoir actuel
zipsource #install les fichiers sources (deja installé par foldermenu normalement)
testpath #vérifie si la clé est bien faite (deja vérifier par foldemrenu normalement)
$internetenabled = Testconnexion
if($internetenabled -eq $true)
{
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/update.psm1' -OutFile "$root\_Tech\applications\source\update.psm1" | Out-Null #Download le module des update
    Update #Vérifie si menu.exe a des mise a jours
}

$img = [system.drawing.image]::FromFile("$root\_Tech\Applications\Source\Images\fondpluiesize.gif") #Il faut mettre le chemin complet pour éviter des erreurs.
$pictureBoxBackGround = new-object Windows.Forms.PictureBox #permet d'afficher un gif
$pictureBoxBackGround.width = $img.width 
$pictureBoxBackGround.height = $img.height
$pictureBoxBackGround.Image = $img #contient l'image gif de background
$pictureBoxBackGround.AutoSize = $true 

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Menu - Boite à outils du technicien"
$Form.Width = $img.Width
$Form.height = $img.height
$Form.MaximizeBox = $false
$Form.icon = New-Object system.drawing.icon ("$root\_Tech\Applications\Source\Images\Icone.ico") #Il faut mettre le chemin complet pour éviter des erreurs.
$Form.KeyPreview = $True
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$Form.Close()}}) #si on fait échape sa ferme la fenetre
$Form.TopMost = $true
$Form.StartPosition = "CenterScreen"
$Form.BackgroundImageLayout = "Stretch"



function zipinstallation
{
    $installationexepath = Test-Path "$root\_Tech\Applications\Installation\installation.ps1" #vérifie si le exe existe
    if($installationexepath) #S'Il existe
    {
        Remove-Item -Path "$root\_Tech\Applications\Installation\installation.ps1" -Recurse | Out-Null #supprime le .exe
    }
    #Créer le dossier vide Installation s'il n'existe pas
    $instapath = Test-Path "$root\_Tech\Applications\Installation" #vérifie si le dossier existe 
    if($instapath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Installation" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Installation.ps1' -OutFile "$root\_Tech\Applications\Installation\Installation.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsInstallation.bat' -OutFile "$root\_Tech\Applications\Installation\RunAsInstallation.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Installation" #met le path dans le dossier Installation
    Start-Process "$root\_Tech\Applications\Installation\RunAsInstallation.bat" | Out-Null #Lance le script d'installation

}

#Installation
$BoutonInstall = New-Object System.Windows.Forms.Button
$BoutonInstall.Location = New-Object System.Drawing.Point(446,100)
$BoutonInstall.AutoSize = $false
$BoutonInstall.Width = '150'
$BoutonInstall.Height = '65'
$BoutonInstall.ForeColor='black'
$BoutonInstall.BackColor = 'darkred'
$BoutonInstall.Text = "Installation Windows"
$BoutonInstall.Font= 'Microsoft Sans Serif,16'
$BoutonInstall.FlatStyle = 'Flat'
$BoutonInstall.FlatAppearance.BorderSize = 2
$BoutonInstall.FlatAppearance.BorderColor = 'black'
$BoutonInstall.FlatAppearance.MouseDownBackColor = 'darkcyan'
$BoutonInstall.FlatAppearance.MouseOverBackColor = 'gray'
$BoutonInstall.Add_MouseEnter({$BoutonInstall.ForeColor = 'White'})
$BoutonInstall.Add_MouseLeave({$BoutonInstall.ForeColor = 'Black'})
$BoutonInstall.Add_Click({
zipinstallation
$Form.Close()
})

function zipOpti 
{
    #Mettre à jour le .exe s'il existe.
    $optiexepath = Test-Path "$root\_Tech\Applications\Optimisation_Nettoyage\Optimisation_Nettoyage.ps1" | Out-Null #vérifie si le .exe existe
    if($optiexepath) #si le .exe existe
    {
        Remove-Item -Path "$root\_Tech\Applications\Optimisation_Nettoyage\Optimisation_Nettoyage.ps1" -Recurse | Out-Null #supprime le .exe
    }
     #Créer le dossier vide Optimisation_Nettoyage s'il n'existe pas
    $optipath = Test-Path "$root\_Tech\Applications\Optimisation_Nettoyage" #vérifie si le dossier existe 
    if($optipath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Optimisation_Nettoyage" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Optimisation_Nettoyage.ps1' -OutFile "$root\_Tech\Applications\Optimisation_Nettoyage\Optimisation_Nettoyage.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsOptimisation_Nettoyage.bat' -OutFile "$root\_Tech\Applications\Optimisation_Nettoyage\RunAsOptimisation_Nettoyage.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Optimisation_Nettoyage" #met le path dans le dossier Optimisation
    Start-Process "$root\_Tech\Applications\Optimisation_Nettoyage\RunAsOptimisation_Nettoyage.bat" | Out-Null #Lance le script d'optimisation
}

#Optimisation et nettoyage
$BoutonOptiNett = New-Object System.Windows.Forms.Button
$BoutonOptiNett.Location = New-Object System.Drawing.Point(446,175)
$BoutonOptiNett.AutoSize = $false
$BoutonOptiNett.Width = '150'
$BoutonOptiNett.Height = '65'
$BoutonOptiNett.ForeColor='black'
$BoutonOptiNett.BackColor = 'darkred'
$BoutonOptiNett.Text = "Optimisation et Nettoyage"
$BoutonOptiNett.Font= 'Microsoft Sans Serif,16'
$BoutonOptiNett.FlatStyle = 'Flat'
$BoutonOptiNett.FlatAppearance.BorderSize = 3
$BoutonOptiNett.FlatAppearance.BorderColor = 'black'
$BoutonOptiNett.FlatAppearance.MouseDownBackColor = 'darkcyan'
$BoutonOptiNett.FlatAppearance.MouseOverBackColor = 'gray'
$BoutonOptiNett.Add_MouseEnter({$BoutonOptiNett.ForeColor = 'White'})
$BoutonOptiNett.Add_MouseLeave({$BoutonOptiNett.ForeColor = 'Black'})
$BoutonOptiNett.Add_Click({
zipOpti
$Form.Close()
})

function zipdiag
{
    #Mettre à jour le .exe s'il existe.
    $diagexepath = Test-Path "$root\_Tech\Applications\Diagnostique\Diagnostique.ps1"  #vérifie si le .exe existe
    if($diagexepath) #s'il existe supprime le .exe
    {
        Remove-Item -Path "$root\_Tech\Applications\Diagnostique\Diagnostique.ps1" -Recurse | Out-Null #si le exe existe il supprime tout le dossier
    }
    #Créer le dossier vide Diagnostique s'il n'existe pas
    $diagpath = Test-Path "$root\_Tech\Applications\Diagnostique"  #vérifie si le dossier existe 
    if($diagpath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Diagnostique" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Diagnostique.ps1' -OutFile "$root\_Tech\Applications\Diagnostique\Diagnostique.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsDiagnostique.bat' -OutFile "$root\_Tech\Applications\Diagnostique\RunAsDiagnostique.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Diagnostique" #met le path dans le dossier Diagnostique
    Start-Process "$root\_Tech\Applications\Diagnostique\RunAsDiagnostique.bat" | Out-Null #Lance le script de Diagnostique
}

#Diagnostic
$Diagnostic = New-Object System.Windows.Forms.Button
$Diagnostic.Location = New-Object System.Drawing.Point(446,250)
$Diagnostic.Width = '150'
$Diagnostic.Height = '65'
$Diagnostic.ForeColor='black'
$Diagnostic.BackColor = 'darkred'
$Diagnostic.Text = "Diagnostique"
$Diagnostic.Font= 'Microsoft Sans Serif,16'
$Diagnostic.FlatStyle = 'Flat'
$Diagnostic.FlatAppearance.BorderSize = 3
$Diagnostic.FlatAppearance.BorderColor = 'black'
$Diagnostic.FlatAppearance.MouseDownBackColor = 'darkcyan'
$Diagnostic.FlatAppearance.MouseOverBackColor = 'gray'
$Diagnostic.Add_MouseEnter({$Diagnostic.ForeColor = 'White'})
$Diagnostic.Add_MouseLeave({$Diagnostic.ForeColor = 'Black'})
$Diagnostic.Add_Click({
zipdiag
$Form.Close()
})

function zipdesinfection 
{
    #Mettre à jour le .exe s'il existe.
    $desinfectionexepath = Test-Path "$root\_Tech\Applications\Securite\Desinfection.ps1"  #vérifie si le .exe existe
    if($desinfectionexepath) #s'il existe supprime le .exe
    {
        Remove-Item -Path "$root\_Tech\Applications\Securite\Desinfection.ps1" -Recurse | Out-Null #si le exe existe il supprime tout le dossier
    }
    #Créer le dossier vide Securite s'il n'existe pas
    $desinfectionpath = Test-Path "$root\_Tech\Applications\Securite"  #vérifie si le dossier existe 
    if($desinfectionpath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Securite" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Desinfection.ps1' -OutFile "$root\_Tech\Applications\Securite\Desinfection.ps1" | Out-Null #download le .exe
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsDesinfection.bat' -OutFile "$root\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #download le .exe
    set-location "$root\_Tech\Applications\Securite" #met le path dans le dossier Securite
    Start-Process "$root\_Tech\Applications\Securite\RunAsDesinfection.bat" | Out-Null #Lance le script de désinfcetion
}

#Desinfection
$Desinfection = New-Object System.Windows.Forms.Button
$Desinfection.Location = New-Object System.Drawing.Point(446,325)
$Desinfection.Width = '150'
$Desinfection.Height = '65'
$Desinfection.ForeColor='black'
$Desinfection.BackColor = 'darkred'
$Desinfection.Text = "Désinfection"
$Desinfection.Font= 'Microsoft Sans Serif,16'
$Desinfection.FlatStyle = 'Flat'
$Desinfection.FlatAppearance.BorderSize = 3
$Desinfection.FlatAppearance.BorderColor = 'black'
$Desinfection.FlatAppearance.MouseDownBackColor = 'darkcyan'
$Desinfection.FlatAppearance.MouseOverBackColor = 'gray'
$Desinfection.Add_MouseEnter({$Desinfection.ForeColor = 'White'})
$Desinfection.Add_MouseLeave({$Desinfection.ForeColor = 'Black'})
$Desinfection.Add_Click({
zipdesinfection
$Form.Close()
})

function zipfix
{
    #Mettre à jour le .exe s'il existe.
    $fixexepath = Test-Path "$root\_Tech\Applications\Fix\Fix.ps1" #vérifie si le .exe existe
    if($fixexepath) #s'il existe supprime le fichier ps1
    {
        Remove-Item -Path "$root\_Tech\Applications\Fix\Fix.ps1" -Recurse | Out-Null #si le exe existe il supprime tout le dossier
    }
     #Créer le dossier vide Fix s'il n'existe pas
    $fixpath = Test-Path "$root\_Tech\Applications\Fix" #vérifie si le dossier existe 
    if($fixpath -eq $false)
    {
        New-Item -Path "$root\_Tech\Applications\Fix" -ItemType directory | Out-Null #s'il n'existe pas le créé
    }
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Fix.ps1' -OutFile "$root\_Tech\Applications\Fix\Fix.ps1" | Out-Null #download le .ps1
    Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/RunAsFix.bat' -OutFile "$root\_Tech\Applications\Fix\RunAsFix.bat" | Out-Null #download le .ps1
    set-location "$root\_Tech\\Applications\Fix" #met le path dans le dossier Fix
    Start-Process "$root\_Tech\Applications\Fix\RunAsFix.bat" | Out-Null #Lance le script de Fix
}

#Fix
$Fix = New-Object System.Windows.Forms.Button
$Fix.Location = New-Object System.Drawing.Point(446,400)
$Fix.Width = '150'
$Fix.Height = '65'
$Fix.ForeColor='black'
$Fix.BackColor = 'darkred'
$Fix.Text = "Fix"
$Fix.Font= 'Microsoft Sans Serif,16'
$Fix.FlatStyle = 'Flat'
$Fix.FlatAppearance.BorderSize = 3
$Fix.FlatAppearance.BorderColor = 'black'
$Fix.FlatAppearance.MouseDownBackColor = 'darkcyan'
$Fix.FlatAppearance.MouseOverBackColor = 'gray'
$Fix.Add_MouseEnter({$Fix.ForeColor = 'White'})
$Fix.Add_MouseLeave({$Fix.ForeColor = 'Black'})
$Fix.Add_Click({
zipfix
$Form.Close()
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
$Form.Close()
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
$Form.controls.AddRange(@($signatureSTO,$labelchoisiroption,$BoutonInstall,$BoutonOptiNett,$Diagnostic,$Desinfection,$Fix,$quit,$pictureBoxBackGround))
$Form.ShowDialog() | out-null