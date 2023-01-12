Add-Type -AssemblyName PresentationFramework,System.Windows.Forms,System.speech,System.Drawing,presentationCore
[System.Windows.Forms.Application]::EnableVisualStyles()

set-location "$env:SystemDrive\_Tech\Applications\Diagnostique" #met la location au repertoir actuel

Import-Module "$env:SystemDrive\_Tech\Applications\Source\modules\update.psm1" | Out-Null
Import-Module "$env:SystemDrive\_Tech\Applications\Source\modules\task.psm1" | Out-Null #Module pour supprimer C:\_Tech
Import-Module "$env:SystemDrive\_Tech\Applications\Source\modules\Logs.psm1" | Out-Null #Module pour les logs
Import-Module "$env:SystemDrive\_Tech\Applications\Source\modules\source.psm1" | Out-Null #Module pour créer source

function zipsourcediag
{
    Sourceexist
    $fondpath = test-Path "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\fondDiag.jpg" #Vérifie si le fond écran est présent
    $iconepath = test-path "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Icone.ico" #vérifie si l'icone existe
    if($fondpath -eq $false) #si fond pas présent
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/fondDiag.jpg' -OutFile "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\fondDiag.jpg" | Out-Null #Download le fond
    }
    if($iconepath -eq $false) #si icone pas présent
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Icone.ico' -OutFile "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Icone.ico" | Out-Null #Download l'icone
    } 
}
zipsourcediag

function Unzip($app, $lien)
{
    $path = test-Path "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\$app"
    $zip = "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\$app.zip"
    if($path -eq $false)
    {
        Invoke-WebRequest $lien -OutFile $zip
        Expand-Archive $zip "$env:SystemDrive\_Tech\Applications\Diagnostique\Source"
        Remove-Item $zip
    }
}

function UnzipLaunch($app, $lien, $exe)
{
    $path = test-Path "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\$app"
    $zip = "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\$app.zip"
    if($path -eq $false)
    {
        Invoke-WebRequest $lien -OutFile $zip
        Expand-Archive $zip "$env:SystemDrive\_Tech\Applications\Diagnostique\Source"
        Remove-Item $zip
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\$app\$exe"
} 

$image = [system.drawing.image]::FromFile("$env:SystemDrive\_Tech\Applications\Diagnostique\Source\fondDiag.jpg")
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Diagnostiques"
$Form.BackgroundImage = $image
$Form.Width = $image.Width
$Form.height = $image.height
$Form.MaximizeBox = $false
$Form.icon = New-Object system.drawing.icon ("$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Icone.ico") 

#Boutonbat
$Boutonbat = New-Object System.Windows.Forms.Button
$Boutonbat.Location = New-Object System.Drawing.Point(445,100)
$Boutonbat.Width = '120'
$Boutonbat.Height = '55'
$Boutonbat.ForeColor='black'
$Boutonbat.BackColor = 'white'
$Boutonbat.Text = "Batterie"
$Boutonbat.Font= 'Microsoft Sans Serif,12'
$Boutonbat.FlatStyle = 'Flat'
$Boutonbat.FlatAppearance.BorderSize = 2
$Boutonbat.FlatAppearance.BorderColor = 'black'
$Boutonbat.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Boutonbat.FlatAppearance.MouseOverBackColor = 'gray'
$Boutonbat.Add_MouseEnter({$Boutonbat.ForeColor = 'White'})
$Boutonbat.Add_MouseLeave({$Boutonbat.ForeColor = 'black'})
$Boutonbat.Add_Click({Unzip "Batterie" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Batterie.zip"})
$Boutonbat.Add_Click({$Battinfo.visible = $true})
$Boutonbat.Add_Click({$Dontsleep.visible = $true})
$Boutonbat.Add_Click({$Boutonbat.visible = $false})
$Boutonbat.Add_Click({$docbattinfo.visible = $true})
$Boutonbat.Add_Click({$Dontsleepinfo.visible = $true})

#Battinfo
$Battinfo = New-Object System.Windows.Forms.Button
$Battinfo.Location = New-Object System.Drawing.Point(445,100)
$Battinfo.Width = '120'
$Battinfo.Height = '55'
$Battinfo.ForeColor='black'
$Battinfo.BackColor = 'magenta'
$Battinfo.Text = "BattInfoview"
$Battinfo.Font= 'Microsoft Sans Serif,12'
$Battinfo.FlatStyle = 'Flat'
$Battinfo.FlatAppearance.BorderSize = 2
$Battinfo.FlatAppearance.BorderColor = 'black'
$Battinfo.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Battinfo.FlatAppearance.MouseOverBackColor = 'gray'
$Battinfo.Add_MouseEnter({$Battinfo.ForeColor = 'White'})
$Battinfo.Add_MouseLeave({$Battinfo.ForeColor = 'black'})
$Battinfo.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\battinfoview\batteryinfoview.exe"
Addlog "diagnostiquelog.txt" "Usure de la batterie vérifié"
})
#Tooltip
$tooltipBattinfo = New-Object System.Windows.Forms.ToolTip
$tooltipBattinfo.IsBalloon =$true
$tooltipBattinfoText = "Vérifier l'usure de la batterie"
$tooltipBattinfo.SetToolTip($Battinfo, $tooltipBattinfoText)
$Battinfo.Add_MouseEnter({$tooltipBattinfo})
$Battinfo.visible = $false
#info
$docbattinfo = New-Object System.Windows.Forms.Button
$docbattinfo.Location = New-Object System.Drawing.Point(445,140)
$docbattinfo.size = '33,18'
$docbattinfo.Text = "Doc"
$docbattinfo.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\battinfoview\docs.txt"})
$docbattinfo.visible = $false
#$Form.Controls.Add($docbattinfo)

#Dontsleep
$Dontsleep = New-Object System.Windows.Forms.Button
$Dontsleep.Location = New-Object System.Drawing.Point(445,175)
$Dontsleep.Width = '120'
$Dontsleep.Height = '55'
$Dontsleep.ForeColor='black'
#$Dontsleep.BackColor = 'magenta'
$Dontsleep.Text = "DontSleep"
$Dontsleep.Font= 'Microsoft Sans Serif,12'
$Dontsleep.FlatStyle = 'Flat'
$Dontsleep.FlatAppearance.BorderSize = 2
$Dontsleep.FlatAppearance.BorderColor = 'black'
$Dontsleep.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Dontsleep.FlatAppearance.MouseOverBackColor = 'gray'
$Dontsleep.Add_MouseEnter({$Dontsleep.ForeColor = 'White'})
$Dontsleep.Add_MouseLeave({$Dontsleep.ForeColor = 'black'})
$Dontsleep.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\DontSleep\DontSleep_x64_p.exe"
Addlog "diagnostiquelog.txt" "Dontsleep a été utilisé pour tester la batterie"
})
#Tooltip
$tooltipDontsleep = New-Object System.Windows.Forms.ToolTip
$tooltipDontsleep.IsBalloon =$true
$tooltipDontSleepText = "Empêche l'ordinateur de tomber en veille"
$tooltipDontsleep.SetToolTip($Dontsleep, $tooltipDontSleepText)
$Dontsleep.Add_MouseEnter({$tooltipDontsleep})
$Dontsleep.visible = $false
$Dontsleepinfo = New-Object System.Windows.Forms.Button
$Dontsleepinfo.Location = New-Object System.Drawing.Point(445,215)
$Dontsleepinfo.size = '33,18'
$Dontsleepinfo.Text = "Doc"
$Dontsleepinfo.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Batterie\DontSleep\docs.txt"})
$Dontsleepinfo.visible = $false
#$Form.Controls.Add($Dontsleepinfo)

#BoutonCPU
$BoutonCPU = New-Object System.Windows.Forms.Button
$BoutonCPU.Location = New-Object System.Drawing.Point(120,100)
$BoutonCPU.Width = '120'
$BoutonCPU.Height = '55'
$BoutonCPU.ForeColor='black'
$BoutonCPU.BackColor = 'red'
$BoutonCPU.Text = "CPU"
$BoutonCPU.Font= 'Microsoft Sans Serif,12'
$BoutonCPU.FlatStyle = 'Flat'
$BoutonCPU.FlatAppearance.BorderSize = 2
$BoutonCPU.FlatAppearance.BorderColor = 'black'
$BoutonCPU.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$BoutonCPU.FlatAppearance.MouseOverBackColor = 'gray'
$BoutonCPU.Add_MouseEnter({$BoutonCPU.ForeColor = 'White'})
$BoutonCPU.Add_MouseLeave({$BoutonCPU.ForeColor = 'black'})
$BoutonCPU.Add_Click({Unzip "CPU" 'https://ftp.alexchato9.com/public/file/BB4NxwBawUmDufbDNKEJAA/CPU.zip'})
$BoutonCPU.Add_Click({$BoutonCPU.visible = $false})
$BoutonCPU.Add_Click({$Aida.visible = $true})
$BoutonCPU.Add_Click({$Prime95.visible = $true})
$BoutonCPU.Add_Click({$coretemp.visible = $true})
$BoutonCPU.Add_Click({$HeavyLoad.visible = $true})
$BoutonCPU.Add_Click({$cpuz.visible = $true})
$BoutonCPU.Add_Click({$docAida.visible = $true})
$BoutonCPU.Add_Click({$docCoretemp.visible = $true})
$BoutonCPU.Add_Click({$docPrime95.visible = $true})
$BoutonCPU.Add_Click({$docCPUZ.visible = $true})
$BoutonCPU.Add_Click({$docHeavyLoad.visible = $true})

#Aida
$Aida = New-Object System.Windows.Forms.Button
$Aida.Location = New-Object System.Drawing.Point(105,100)
$Aida.Width = '120'
$Aida.Height = '55'
$Aida.ForeColor='black'
$Aida.BackColor = 'darkmagenta'
$Aida.Text = "Aida64"
$Aida.Font= 'Microsoft Sans Serif,12'
$Aida.FlatStyle = 'Flat'
$Aida.FlatAppearance.BorderSize = 2
$Aida.FlatAppearance.BorderColor = 'black'
$Aida.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Aida.FlatAppearance.MouseOverBackColor = 'gray'
$Aida.Add_MouseEnter({$Aida.ForeColor = 'White'})
$Aida.Add_MouseLeave({$Aida.ForeColor = 'black'})
$Aida.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\Aida64\aida64.exe"
Addlog "diagnostiquelog.txt" "Test de stabilité du système effectué"oh i sd
})
#tooltip
$tooltipAida = New-Object System.Windows.Forms.ToolTip
$tooltipAida.IsBalloon =$true
$tooltipAidaText = "Testé la stabilité système"
$tooltipAida.SetToolTip($Aida, $tooltipAidaText)
$Aida.Add_MouseEnter({$tooltipAida})
$Aida.visible = $false
#info
$docAida = New-Object System.Windows.Forms.Button
$docAida.Location = New-Object System.Drawing.Point(105,145)
$docAida.size = '33,18'
$docAida.Text = "Doc"
$docAida.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\Aida64\docs.txt"})
$docAida.visible = $false
#$Form.Controls.Add($docAida)

#Coretemp
$Coretemp = New-Object System.Windows.Forms.Button
$Coretemp.Location = New-Object System.Drawing.Point(105,175)
$Coretemp.Width = '120'
$Coretemp.Height = '55'
$Coretemp.ForeColor='black'
$Coretemp.BackColor = 'red'
$Coretemp.Text = "Core Temp"
$Coretemp.Font= 'Microsoft Sans Serif,12'
$Coretemp.FlatStyle = 'Flat'
$Coretemp.FlatAppearance.BorderSize = 2
$Coretemp.FlatAppearance.BorderColor = 'black'
$Coretemp.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Coretemp.FlatAppearance.MouseOverBackColor = 'gray'
$Coretemp.Add_MouseEnter({$Coretemp.ForeColor = 'White'})
$Coretemp.Add_MouseLeave({$Coretemp.ForeColor = 'black'})
$Coretemp.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\Core_Temp\Core Temp.exe"
Addlog "diagnostiquelog.txt" "Température du CPU vérifié"
})
#Tooltip
$tooltipCoretemp = New-Object System.Windows.Forms.ToolTip
$tooltipCoretemp.IsBalloon =$true
$tooltipCoretempText = "Vérifier Température CPU"
$tooltipCoretemp.SetToolTip($Coretemp, $tooltipCoretempText)
$Coretemp.Add_MouseEnter({$tooltipCoretemp})
$Coretemp.visible = $false
#info
$docCoretemp = New-Object System.Windows.Forms.Button
$docCoretemp.Location = New-Object System.Drawing.Point(105,215)
$docCoretemp.size = '33,18'
$docCoretemp.Text = "Doc"
$docCoretemp.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\Core_Temp\docs.txt"})
$docCoretemp.visible = $false
#$Form.Controls.Add($docCoretemp)

#Prime95
$Prime95 = New-Object System.Windows.Forms.Button
$Prime95.Location = New-Object System.Drawing.Point(105,400)
$Prime95.Width = '120'
$Prime95.Height = '55'
$Prime95.ForeColor='black'
$Prime95.BackColor = 'cyan'
$Prime95.Text = "Prime95"
$Prime95.Font= 'Microsoft Sans Serif,12'
$Prime95.FlatStyle = 'Flat'
$Prime95.FlatAppearance.BorderSize = 2
$Prime95.FlatAppearance.BorderColor = 'black'
$Prime95.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Prime95.FlatAppearance.MouseOverBackColor = 'gray'
$Prime95.Add_MouseEnter({$Prime95.ForeColor = 'White'})
$Prime95.Add_MouseLeave({$Prime95.ForeColor = 'black'})
$Prime95.Add_Click(
{Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\Prime95\prime95.exe"
Addlog "diagnostiquelog.txt" "Stress test du CPU effectué"
})
#Tooltip
$tooltipPrime95 = New-Object System.Windows.Forms.ToolTip
$tooltipPrime95.IsBalloon =$true
$tooltipPrime95Text = "stress test du CPU"
$tooltipPrime95.SetToolTip($Prime95, $tooltipPrime95Text)
$Prime95.Add_MouseEnter({$tooltipPrime95})
$Prime95.visible = $false
#info
$docPrime95 = New-Object System.Windows.Forms.Button
$docPrime95.Location = New-Object System.Drawing.Point(105,440)
$docPrime95.size = '33,18'
$docPrime95.Text = "Doc"
$docPrime95.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\Prime95\docs.txt"})
$docPrime95.visible = $false
#$Form.Controls.Add($docPrime95)

#CPUZ
$CPUZ = New-Object System.Windows.Forms.Button
$CPUZ.Location = New-Object System.Drawing.Point(105,250)
$CPUZ.Width = '120'
$CPUZ.Height = '55'
$CPUZ.ForeColor='black'
$CPUZ.BackColor = 'cyan'
$CPUZ.Text = "CPUZ"
$CPUZ.Font= 'Microsoft Sans Serif,12'
$CPUZ.FlatStyle = 'Flat'
$CPUZ.FlatAppearance.BorderSize = 2
$CPUZ.FlatAppearance.BorderColor = 'black'
$CPUZ.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$CPUZ.FlatAppearance.MouseOverBackColor = 'gray'
$CPUZ.Add_MouseEnter({$CPUZ.ForeColor = 'White'})
$CPUZ.Add_MouseLeave({$CPUZ.ForeColor = 'black'})
$CPUZ.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\CPUZ\cpuz.exe"
})
#Tooltip
$tooltipCPUZ = New-Object System.Windows.Forms.ToolTip
$tooltipCPUZ.IsBalloon =$true
$tooltipCPUZText = "Information sur le CPU,la carte mère et la mémoire"
$tooltipCPUZ.SetToolTip($CPUZ, $tooltipCPUZText)
$CPUZ.Add_MouseEnter({$tooltipCPUZ})
$CPUZ.visible = $false
#info
$docCPUZ = New-Object System.Windows.Forms.Button
$docCPUZ.Location = New-Object System.Drawing.Point(105,290)
$docCPUZ.size = '33,18'
$docCPUZ.Text = "Doc"
$docCPUZ.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\CPUZ\docs.txt"})
$docCPUZ.visible = $false
#$Form.Controls.Add($docCPUZ)

#HeavyLoad
$HeavyLoad = New-Object System.Windows.Forms.Button
$HeavyLoad.Location = New-Object System.Drawing.Point(105,325)
$HeavyLoad.Width = '120'
$HeavyLoad.Height = '55'
$HeavyLoad.ForeColor='black'
$HeavyLoad.BackColor = 'yellow'
$HeavyLoad.Text = "HeavyLoad"
$HeavyLoad.Font= 'Microsoft Sans Serif,12'
$HeavyLoad.FlatStyle = 'Flat'
$HeavyLoad.FlatAppearance.BorderSize = 2
$HeavyLoad.FlatAppearance.BorderColor = 'black'
$HeavyLoad.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$HeavyLoad.FlatAppearance.MouseOverBackColor = 'gray'
$HeavyLoad.Add_MouseEnter({$HeavyLoad.ForeColor = 'White'})
$HeavyLoad.Add_MouseLeave({$HeavyLoad.ForeColor = 'black'})
$HeavyLoad.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\HeavyLoad\HeavyLoad.exe" -ArgumentList "/start /cpu"
Addlog "diagnostiquelog.txt" "Test de stabilité du système effectué"
})
#Tooltip
$tooltipHeavyLoad = New-Object System.Windows.Forms.ToolTip
$tooltipHeavyLoad.IsBalloon =$true
$tooltipHeavyLoadText = "Testé la stabilité système"
$tooltipHeavyLoad.SetToolTip($HeavyLoad, $tooltipHeavyLoadText)
$HeavyLoad.Add_MouseEnter({$tooltipHeavyLoad})
$HeavyLoad.visible = $false
#info
$docHeavyLoad = New-Object System.Windows.Forms.Button
$docHeavyLoad.Location = New-Object System.Drawing.Point(105,365)
$docHeavyLoad.size = '33,18'
$docHeavyLoad.Text = "Doc"
$docHeavyLoad.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\CPU\HeavyLoad\docs.txt"})
$docHeavyLoad.visible = $false
#$Form.Controls.Add($docHeavyLoad)

#BoutonHDD
$BoutonHDD = New-Object System.Windows.Forms.Button
$BoutonHDD.Location = New-Object System.Drawing.Point(280,100)
$BoutonHDD.Width = '120'
$BoutonHDD.Height = '55'
$BoutonHDD.ForeColor='black'
$BoutonHDD.BackColor = 'darkcyan'
$BoutonHDD.Text = "HDD"
$BoutonHDD.Font= 'Microsoft Sans Serif,12'
$BoutonHDD.FlatStyle = 'Flat'
$BoutonHDD.FlatAppearance.BorderSize = 2
$BoutonHDD.FlatAppearance.BorderColor = 'black'
$BoutonHDD.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$BoutonHDD.FlatAppearance.MouseOverBackColor = 'gray'
$BoutonHDD.Add_MouseEnter({$BoutonHDD.ForeColor = 'White'})
$BoutonHDD.Add_MouseLeave({$BoutonHDD.ForeColor = 'black'})
$BoutonHDD.Add_Click({Unzip "HDD" 'https://ftp.alexchato9.com/public/file/t6QQNrPcLk6gruXnTEr1fA/HDD.zip'})
$BoutonHDD.Add_Click({$BoutonHDD.visible = $false})
$BoutonHDD.Add_Click({$HDTune.visible = $true})
$BoutonHDD.Add_Click({$HDSentinnel.visible = $true})
$BoutonHDD.Add_Click({$ASSD.visible = $true})
$BoutonHDD.Add_Click({$diskmark.visible = $true})
$BoutonHDD.Add_Click({$docdiskmark.visible = $true})
$BoutonHDD.Add_Click({$docHDSentinnel.visible = $true})
$BoutonHDD.Add_Click({$docHDTune.visible = $true})
$BoutonHDD.Add_Click({$docASSD.visible = $true})

function HDSentinel
{
start-process -wait "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\HD_Sentinnel\_HDSentinel.exe" -ArgumentList "/report"
Addlog "diagnostiquelog.txt" "Vérifier la santé du disque dur"
#hdsslog | Out-File $logfilepath -Append
}

function hdsslog
{
$PathHDSentinelData = Get-Content "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\HD_Sentinnel\HDSData\HDSentinel_5.70 PRO_report.txt"
$lignedisk = "" #initialise la variable vide

foreach ($ligne in $PathHDSentinelData) #pour chaque ligne dans le fichier, car chaque ligne est un objet
{
    if($ligne -match "Drive \d+") #si une ligne match drive + un chiffre
    {
        $lignedisk = $ligne  #$lignedisk contient la ligne drive x
    }
   
    elseif($lignedisk -and $ligne -match "size") #si ma ligne drive x est $TRUe et ma ligne qui match size
    {
        $lignedisk,$ligne #afficher drive x et la size
    }

    elseif($lignedisk -and $ligne -match "Temperature" -and $ligne -notmatch "Max. Temperature"  -and $ligne -notmatch "Airflow Temperature" -and $ligne -notmatch "disk Temperature") #si ma ligne drive x est $TRUe et ma ligne qui match temprature
    {
        $ligne,$lignesize #la temperature et la taille
    }

    elseif($lignedisk -and $ligne -match "Power on time" -and $ligne -notmatch "Power on time measure" -and $ligne -notmatch "Power On Time Count") 
    {
        $ligne,$lignesize,$lignetemp
    }

    elseif($lignedisk -and $ligne -match "Remaining lifetime") 
    {
        $ligne,$lignesize,$lignetemp,$lignePoweronTime
    }

    elseif($lignedisk -and $ligne -match "Disk Performance") 
    {
        $ligne,$lignesize,$lignetemp,$lignePoweronTime,$ligneremaininglifetime
    }

    elseif($lignedisk -and $ligne -match "Interface used") 
    {
        $ligne,$lignesize,$lignetemp,$lignePoweronTime,$ligneremaininglifetime,$ligneperfo
    }

    elseif($lignedisk -and $ligne -match "Disk Fitness") 
    {
        $ligne,$lignesize,$lignetemp,$lignePoweronTime,$ligneremaininglifetime,$ligneperfo,$ligneInterfaceused
        [System.Windows.MessageBox]::Show("$lignedisk,$ligne","Santé",0)
        $lignedisk = "" #flusher une fois la variable a la fin
    }
}
}

function diskmarkinfoLog
{
$logfile = "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\CrystalDiskInfoPortable\App\CrystalDiskInfo\diskinfo.txt"
$contentlogfile = Get-Content $logfile
$lignedisk = "" #initialise la variable vide


foreach ($ligne in $contentlogfile) #pour chaque ligne dans le fichier, car chaque ligne est un objet
{
    if($ligne -match "Model") #si une ligne match drive + un chiffre
    {
        $lignedisk = $ligne
    }

    elseif($lignedisk -and $ligne -match "Interface") 
    {       
        "$lignedisk `r`n $ligne`r`n"    

    }

    elseif($lignedisk -and $ligne -match " Health Status") 
    {
        "$ligne $ligneInterfaceused`r`n"
        $lignedisk = "" #flusher une fois la variable a la fin
    }
}
}

function HDTune
{
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\HD_Tune\_HDTune.exe"
Addlog "diagnostiquelog.txt" "Vérifier la Vitesse du disque dur"
}

#HDSentinnel
$HDSentinnel = New-Object System.Windows.Forms.Button
$HDSentinnel.Location = New-Object System.Drawing.Point(280,100)
$HDSentinnel.Width = '120'
$HDSentinnel.Height = '55'
$HDSentinnel.ForeColor='black'
$HDSentinnel.BackColor = 'darkcyan'
$HDSentinnel.Text = "Santé HDD (HDSentinel)"
$HDSentinnel.Font= 'Microsoft Sans Serif,12'
$HDSentinnel.FlatStyle = 'Flat'
$HDSentinnel.FlatAppearance.BorderSize = 2
$HDSentinnel.FlatAppearance.BorderColor = 'black'
$HDSentinnel.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$HDSentinnel.FlatAppearance.MouseOverBackColor = 'gray'
$HDSentinnel.Add_MouseEnter({$HDSentinnel.ForeColor = 'White'})
$HDSentinnel.Add_MouseLeave({$HDSentinnel.ForeColor = 'black'})
$HDSentinnel.Add_Click({
HDSentinel
})
#Tooltip
$tooltipHDSentinnel = New-Object System.Windows.Forms.ToolTip
$tooltipHDSentinnel.IsBalloon =$true
$tooltipHDSentinnelText = "Vérifier Santé HDD"
$tooltipHDSentinnel.SetToolTip($HDSentinnel, $tooltipHDSentinnelText)
$HDSentinnel.Add_MouseEnter({$tooltipHDSentinnel})
$HDSentinnel.visible = $false
#info
$docHDSentinnel = New-Object System.Windows.Forms.Button
$docHDSentinnel.Location = New-Object System.Drawing.Point(280,140)
$docHDSentinnel.size = '33,18'
$docHDSentinnel.Text = "Doc"
$docHDSentinnel.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\HD_Sentinnel\docs.txt"})
$docHDSentinnel.visible = $false
#$Form.Controls.Add($docHDSentinnel)

#HDTune
$HDTune = New-Object System.Windows.Forms.Button
$HDTune.Location = New-Object System.Drawing.Point(280,325)
$HDTune.Width = '120'
$HDTune.Height = '55'
$HDTune.ForeColor='black'
$HDTune.BackColor = 'gray'
$HDTune.Text = "Vitesse HDD (HDTune)"
$HDTune.Font= 'Microsoft Sans Serif,12'
$HDTune.FlatStyle = 'Flat'
$HDTune.FlatAppearance.BorderSize = 2
$HDTune.FlatAppearance.BorderColor = 'black'
$HDTune.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$HDTune.FlatAppearance.MouseOverBackColor = 'gray'
$HDTune.Add_MouseEnter({$HDTune.ForeColor = 'White'})
$HDTune.Add_MouseLeave({$HDTune.ForeColor = 'black'})
$HDTune.Add_Click({
HDTune
})
#Tooltip
$tooltipHDTune = New-Object System.Windows.Forms.ToolTip
$tooltipHDTune.IsBalloon =$true
$tooltipHDTuneText = "Vérifier vitesse HDD"
$tooltipHDTune.SetToolTip($HDTune, $tooltipHDTuneText)
$HDTune.Add_MouseEnter({$tooltipHDTune})
$HDTune.visible = $false
#info
$docHDTune = New-Object System.Windows.Forms.Button
$docHDTune.Location = New-Object System.Drawing.Point(280,365)
$docHDTune.size = '33,18'
$docHDTune.Text = "Doc"
$docHDTune.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Diagnostique\\Source\HDD\HD_Tune\hdtune.html"})
$docHDTune.visible = $false
#$Form.Controls.Add($docHDTune)

#AS_SSD
$ASSD = New-Object System.Windows.Forms.Button
$ASSD.Location = New-Object System.Drawing.Point(280,250)
$ASSD.Width = '120'
$ASSD.Height = '55'
$ASSD.ForeColor='black'
$ASSD.BackColor = 'cyan'
$ASSD.Text = "Vitesse HDD (AS_SSD)"
$ASSD.Font= 'Microsoft Sans Serif,12'
$ASSD.FlatStyle = 'Flat'
$ASSD.FlatAppearance.BorderSize = 2
$ASSD.FlatAppearance.BorderColor = 'black'
$ASSD.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$ASSD.FlatAppearance.MouseOverBackColor = 'gray'
$ASSD.Add_MouseEnter({$ASSD.ForeColor = 'White'})
$ASSD.Add_MouseLeave({$ASSD.ForeColor = 'black'})
$ASSD.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\As_SSD\AS SSD Benchmark.exe"
})
#Tooltip
$tooltipASSD = New-Object System.Windows.Forms.ToolTip
$tooltipASSD.IsBalloon =$true
$tooltipASSDText = "Vérifier vitesse HDD"
$tooltipASSD.SetToolTip($ASSD, $tooltipASSDText)
$ASSD.Add_MouseEnter({$tooltipASSD})
$ASSD.visible = $false
#info
$docASSD = New-Object System.Windows.Forms.Button
$docASSD.Location = New-Object System.Drawing.Point(280,290)
$docASSD.size = '33,18'
$docASSD.Text = "Doc"
$docASSD.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\As_SSD\docs.txt"})
$docASSD.visible = $false
#$Form.Controls.Add($docASSD)

#Diskmark
$Diskmark = New-Object System.Windows.Forms.Button
$Diskmark.Location = New-Object System.Drawing.Point(280,175)
$Diskmark.Width = '120'
$Diskmark.Height = '55'
$Diskmark.ForeColor='black'
$Diskmark.BackColor = 'darkgreen'
$Diskmark.Text = "Santé HDD (CrystalDisk)"
$Diskmark.Font= 'Microsoft Sans Serif,12'
$Diskmark.FlatStyle = 'Flat'
$Diskmark.FlatAppearance.BorderSize = 2
$Diskmark.FlatAppearance.BorderColor = 'black'
$Diskmark.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Diskmark.FlatAppearance.MouseOverBackColor = 'gray'
$Diskmark.Add_MouseEnter({$Diskmark.ForeColor = 'White'})
$Diskmark.Add_MouseLeave({$Diskmark.ForeColor = 'black'})
$Diskmark.Add_Click({
Start-Process -wait  "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\CrystalDiskInfoPortable\CrystalDiskInfoPortable.exe"  -ArgumentList "/copy"
Addlog "diagnostiquelog.txt" "Vérifier la santé du disque dur"
#diskmarkinfolog | Out-File $logfilepath -Append
})
#Tooltip
$tooltipDiskmark = New-Object System.Windows.Forms.ToolTip
$tooltipDiskmark.IsBalloon =$true
$tooltipDiskmarkText = "Vérifier Santé HDD"
$tooltipDiskmark.SetToolTip($Diskmark, $tooltipDiskmarkText)
$Diskmark.Add_MouseEnter({$tooltipDiskmark})
$Diskmark.visible = $false
#info
$docDiskmark = New-Object System.Windows.Forms.Button
$docDiskmark.Location = New-Object System.Drawing.Point(280,215)
$docDiskmark.size = '33,18'
$docDiskmark.Text = "Doc"
$docDiskmark.Add_Click({Start-Process-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\CrystalDiskInfoPortable\docs.txt"})
$docDiskmark.visible = $false
#$Form.Controls.Add($docDiskmark)

#BoutonGPU
$BoutonGPU = New-Object System.Windows.Forms.Button
$BoutonGPU.Location = New-Object System.Drawing.Point(760,100)
$BoutonGPU.Width = '120'
$BoutonGPU.Height = '55'
$BoutonGPU.ForeColor='black'
$BoutonGPU.BackColor = 'yellow'
$BoutonGPU.Text = "GPU"
$BoutonGPU.Font= 'Microsoft Sans Serif,12'
$BoutonGPU.FlatStyle = 'Flat'
$BoutonGPU.FlatAppearance.BorderSize = 2
$BoutonGPU.FlatAppearance.BorderColor = 'black'
$BoutonGPU.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$BoutonGPU.FlatAppearance.MouseOverBackColor = 'gray'
$BoutonGPU.Add_MouseEnter({$BoutonGPU.ForeColor = 'White'})
$BoutonGPU.Add_MouseLeave({$BoutonGPU.ForeColor = 'black'})
$BoutonGPU.Add_Click({Unzip "GPU" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/GPU.zip'})
$BoutonGPU.Add_Click({$Unigine.visible = $true})
$BoutonGPU.Add_Click({$Furmark.visible = $true})
#$BoutonGPU.Add_Click({$gpuz.visible = $true})
$BoutonGPU.Add_Click({$BoutonGPU.visible = $false})
$BoutonGPU.Add_Click({$DocUnigine.visible = $true})
$BoutonGPU.Add_Click({$DocFurmark.visible = $true})
#$BoutonGPU.Add_Click({$Docgpuz.visible = $true})

#Furmark
$Furmark = New-Object System.Windows.Forms.Button
$Furmark.Location = New-Object System.Drawing.Point(760,100)
$Furmark.Width = '120'
$Furmark.Height = '55'
$Furmark.ForeColor='black'
$Furmark.BackColor = 'darkgray'
$Furmark.Text = "Furmark"
$Furmark.Font= 'Microsoft Sans Serif,12'
$Furmark.FlatStyle = 'Flat'
$Furmark.FlatAppearance.BorderSize = 2
$Furmark.FlatAppearance.BorderColor = 'black'
$Furmark.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Furmark.FlatAppearance.MouseOverBackColor = 'gray'
$Furmark.Add_MouseEnter({$Furmark.ForeColor = 'White'})
$Furmark.Add_MouseLeave({$Furmark.ForeColor = 'black'})
$Furmark.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\GPU\FurMark\FurMark.exe"
#Log
#$env:SystemDrive\_Tech\Applications\Diagnostique\GPU\FurMark\FurMark_0001.txt
Addlog "diagnostiquelog.txt" "Stress test du GPU"
})
#Tooltip
$tooltipFurmark = New-Object System.Windows.Forms.ToolTip
$tooltipFurmark.IsBalloon =$true
$tooltipFurmarkText = "Stress test du GPU"
$tooltipFurmark.SetToolTip($Furmark, $tooltipFurmarkText)
$Furmark.Add_MouseEnter({$tooltipFurmark})
$Furmark.visible = $false
#info
$docFurmark = New-Object System.Windows.Forms.Button
$docFurmark.Location = New-Object System.Drawing.Point(760,140)
$docFurmark.size = '33,18'
$docFurmark.Text = "Doc"
$docFurmark.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\GPU\FurMark\docs.txt"})
$docFurmark.visible = $false
#$Form.Controls.Add($docFurmark)

#Unigine
$Unigine = New-Object System.Windows.Forms.Button
$Unigine.Location = New-Object System.Drawing.Point(760,175)
$Unigine.Width = '120'
$Unigine.Height = '55'
$Unigine.ForeColor='black'
$Unigine.BackColor = 'Magenta'
$Unigine.Text = "Unigine"
$Unigine.Font= 'Microsoft Sans Serif,12'
$Unigine.FlatStyle = 'Flat'
$Unigine.FlatAppearance.BorderSize = 2
$Unigine.FlatAppearance.BorderColor = 'black'
$Unigine.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Unigine.FlatAppearance.MouseOverBackColor = 'gray'
$Unigine.Add_MouseEnter({$Unigine.ForeColor = 'White'})
$Unigine.Add_MouseLeave({$Unigine.ForeColor = 'black'})
$Unigine.Add_Click({
Start-Process "https://benchmark.unigine.com/"
Addlog "diagnostiquelog.txt" "Vérifier les performances du GPU"
})
#Tooltip
$tooltipUnigine = New-Object System.Windows.Forms.ToolTip
$tooltipUnigine.IsBalloon =$true
$tooltipUnigineText = "Vérifier qualité des graphiques"
$tooltipUnigine.SetToolTip($Unigine, $tooltipUnigineText)
$Unigine.Add_MouseEnter({$tooltipUnigine})
$Unigine.visible = $false
#info
$docUnigine = New-Object System.Windows.Forms.Button
$docUnigine.Location = New-Object System.Drawing.Point(760,215)
$docUnigine.size = '33,18'
$docUnigine.Text = "Doc"
$docUnigine.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\GPU\Unigine\docs.txt"})
$docUnigine.visible = $false
#$Form.Controls.Add($docUnigine)

#Speccy
$Speccy = New-Object System.Windows.Forms.Button
$Speccy.Location = New-Object System.Drawing.Point(105,525)
$Speccy.Width = '120'
$Speccy.Height = '55'
$Speccy.ForeColor='black'
$Speccy.BackColor = 'green'
$Speccy.Text = "Speccy"
$Speccy.Font= 'Microsoft Sans Serif,12'
$Speccy.FlatStyle = 'Flat'
$Speccy.FlatAppearance.BorderSize = 2
$Speccy.FlatAppearance.BorderColor = 'black'
$Speccy.FlatAppearance.MouseDownBackColor = 'gray'
$Speccy.Add_MouseEnter({$Speccy.ForeColor = 'White'})
$Speccy.Add_MouseLeave({$Speccy.ForeColor = 'black'})
$Speccy.Add_Click({
UnzipLaunch "Speccy" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Speccy.zip" "Speccy.exe"
})
#Tooltip
$tooltipSpeccy = New-Object System.Windows.Forms.ToolTip
$tooltipSpeccy.IsBalloon =$true
$tooltipSpeccyText = "Information système(Composantes,OS,Température"
$tooltipSpeccy.SetToolTip($Speccy, $tooltipSpeccyText)
$Speccy.Add_MouseEnter({$tooltipSpeccy})
#info
$docSpeccy = New-Object System.Windows.Forms.Button
$docSpeccy.Location = New-Object System.Drawing.Point(105,565)
$docSpeccy.size = '33,18'
$docSpeccy.Text = "Doc"
$docSpeccy.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Speccy\docs.txt"})
#$docSpeccy.visible = $false
#$Form.Controls.Add($docSpeccy)

#HWMonitor
$HWMonitor = New-Object System.Windows.Forms.Button
$HWMonitor.Location = New-Object System.Drawing.Point(325,525)
$HWMonitor.Width = '120'
$HWMonitor.Height = '55'
$HWMonitor.ForeColor='black'
$HWMonitor.BackColor = 'magenta'
$HWMonitor.Text = "HWMonitor"
$HWMonitor.Font= 'Microsoft Sans Serif,12'
$HWMonitor.FlatStyle = 'Flat'
$HWMonitor.FlatAppearance.BorderSize = 2
$HWMonitor.FlatAppearance.BorderColor = 'black'
$HWMonitor.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$HWMonitor.FlatAppearance.MouseOverBackColor = 'gray'
$HWMonitor.Add_MouseEnter({$HWMonitor.ForeColor = 'White'})
$HWMonitor.Add_MouseLeave({$HWMonitor.ForeColor = 'black'})
$HWMonitor.Add_Click({
UnzipLaunch "HWmonitor" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HWMonitor.zip" "HWMonitor_x64.exe"
})
#Tooltip
$tooltipHWMonitor = New-Object System.Windows.Forms.ToolTip
$tooltipHWMonitor.IsBalloon =$true
$tooltipHWMonitorText = "Vérifier voltages, temperatures, fans speed."
$tooltipHWMonitor.SetToolTip($HWMonitor, $tooltipHWMonitorText)
$HWMonitor.Add_MouseEnter({$tooltipHWMonitor})
#info
$docHWMonitor = New-Object System.Windows.Forms.Button
$docHWMonitor.Location = New-Object System.Drawing.Point(325,565)
$docHWMonitor.size = '33,18'
$docHWMonitor.Text = "Doc"
$docHWMonitor.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HWMonitor\docs.txt"})
#$docHWMonitor.visible = $false
#$Form.Controls.Add($docHWMonitor)

#Whocrashed
$Whocrashed = New-Object System.Windows.Forms.Button
$Whocrashed.Location = New-Object System.Drawing.Point(625,525)
$Whocrashed.Width = '120'
$Whocrashed.Height = '55'
$Whocrashed.ForeColor='black'
$Whocrashed.BackColor = 'darkgreen'
$Whocrashed.Text = "Whocrashed"
$Whocrashed.Font= 'Microsoft Sans Serif,12'
$Whocrashed.FlatStyle = 'Flat'
$Whocrashed.FlatAppearance.BorderSize = 2
$Whocrashed.FlatAppearance.BorderColor = 'black'
$Whocrashed.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$Whocrashed.FlatAppearance.MouseOverBackColor = 'gray'
$Whocrashed.Add_MouseEnter({$Whocrashed.ForeColor = 'White'})
$Whocrashed.Add_MouseLeave({$Whocrashed.ForeColor = 'black'})
$Whocrashed.Add_Click({
UnzipLaunch "WhoCrashed" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/WhoCrashed.zip" "WhoCrashedEx.exe"
})
#Tooltip
$tooltipWhocrashed = New-Object System.Windows.Forms.ToolTip
$tooltipWhocrashed.IsBalloon =$true
$tooltipWhocrashedText = "Trouver la cause des BSOD (Blue screen)"
$tooltipWhocrashed.SetToolTip($Whocrashed, $tooltipWhocrashedText)
$Whocrashed.Add_MouseEnter({$tooltipWhocrashed})
#info
$docWhocrashed = New-Object System.Windows.Forms.Button
$docWhocrashed.Location = New-Object System.Drawing.Point(625,565)
$docWhocrashed.size = '33,18'
$docWhocrashed.Text = "Doc"
$docWhocrashed.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Whocrashed\docs.txt"})
#$Form.Controls.Add($docWhocrashed)

#sysinfo
$sysinfo = New-Object System.Windows.Forms.Button
$sysinfo.Location = New-Object System.Drawing.Point(825,525)
$sysinfo.Width = '120'
$sysinfo.Height = '55'
$sysinfo.ForeColor='black'
$sysinfo.BackColor = 'red'
$sysinfo.Text = "Sysinfo"
$sysinfo.Font= 'Microsoft Sans Serif,12'
$sysinfo.FlatStyle = 'Flat'
$sysinfo.FlatAppearance.BorderSize = 2
$sysinfo.FlatAppearance.BorderColor = 'black'
$sysinfo.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$sysinfo.FlatAppearance.MouseOverBackColor = 'gray'
$sysinfo.Add_MouseEnter({$sysinfo.ForeColor = 'White'})
$sysinfo.Add_MouseLeave({$sysinfo.ForeColor = 'black'})
$sysinfo.Add_Click({
msinfo32
})
#Tooltip
$tooltipsysinfo = New-Object System.Windows.Forms.ToolTip
$tooltipsysinfo.IsBalloon =$true
$tooltipsysinfotext = "Informations générales des composantes de l'ordinateur"
$tooltipsysinfo.SetToolTip($sysinfo, $tooltipsysinfotext)
$sysinfo.Add_MouseEnter({$tooltipsysinfo})
#info
$docsysinfo = New-Object System.Windows.Forms.Button
$docsysinfo.Location = New-Object System.Drawing.Point(825,565)
$docsysinfo.size = '33,18'
$docsysinfo.Text = "Doc"
$docsysinfo.Add_Click({Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\sysinfo\docs.txt"})
#$Form.Controls.Add($docsysinfo)

#RAM
$RAM = New-Object System.Windows.Forms.Button
$RAM.Location = New-Object System.Drawing.Point(600,100)
$RAM.Width = '120'
$RAM.Height = '55'
$RAM.ForeColor='black'
#$RAM.BackColor = 'darkgray'
$RAM.Text = "RAM"
$RAM.Font= 'Microsoft Sans Serif,12'
$RAM.FlatStyle = 'Flat'
$RAM.FlatAppearance.BorderSize = 2
$RAM.FlatAppearance.BorderColor = 'black'
$RAM.FlatAppearance.MouseDownBackColor = 'Darkmagenta'
$RAM.FlatAppearance.MouseOverBackColor = 'gray'
$RAM.Add_MouseEnter({$RAM.ForeColor = 'White'})
$RAM.Add_MouseLeave({$RAM.ForeColor = 'black'})
$RAM.Add_Click({
mdsched.exe
Addlog "diagnostiquelog.txt" "Memtest effectué"
})
#Tooltip
$tooltipRAM = New-Object System.Windows.Forms.ToolTip
$tooltipRAM.IsBalloon =$true
$tooltipHDRAMText = "Diagnostiquede mémoire de Windows 10, nécéssite un redémarrage"
$tooltipRAM.SetToolTip($RAM, $tooltipHDRAMText)
$RAM.Add_MouseEnter({$tooltipRAM})

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
Task
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
start-process "$env:SystemDrive\_Tech\Menu.bat" -verb Runas
$Form.Close()
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
$Form.controls.AddRange(@($Menuprincipal,$Prime95,$Boutonbat,$BoutonGPU,$Whocrashed,$Unigine,$cpuz,$HeavyLoad,$Dontsleep,$HWMonitor,$BoutonCPU,$BoutonHDD,$Aida,$Battinfo,$Coretemp,$HDSentinnel,$HDTune,$RAM,$Furmark,$Speccy,$Quit,$label,$sysinfo,$ASSD,$Diskmark))
$Form.ShowDialog() | out-null