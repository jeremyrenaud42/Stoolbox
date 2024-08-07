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



#$desktop = [Environment]::GetFolderPath("Desktop")
$pathDiagnostique = "$env:SystemDrive\_Tech\Applications\Diagnostique"
$pathDiagnostiqueSource = "$env:SystemDrive\_Tech\Applications\Diagnostique\source"
set-location $pathDiagnostique
Get-RequiredModules
Get-RemoteFile "fondDiag.jpg" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/fondDiag.jpg' "$pathDiagnostiqueSource" 
Get-RemoteFile "MainWindow.xaml" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/MainWindow.xaml' "$pathDiagnostiqueSource"
Get-RemoteFile "DiagApps.JSON" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/DiagApps.JSON' "$pathDiagnostiqueSource"  
$adminStatus = Get-AdminStatus
if($adminStatus -eq $false)
{
    Restart-Elevated -Path $pathDiagnostique\Diagnostique.ps1
}
if ($PSVersionTable.PSVersion.Major -lt 7 -and -not (Get-Command -Type Cmdlet Start-ThreadJob -ErrorAction SilentlyContinue)) 
{
    Install-Nuget
    Install-Module -Scope CurrentUser ThreadJob -Force #ca prend nuget
}
Import-Module -Name ThreadJob

$inputXML = import-XamlFromFile "$pathDiagnostiqueSource\MainWindow.xaml"
$formatedXaml = Format-XamlFile $inputXML
$objectXaml = New-XamlObject $formatedXaml
$window = Add-WPFWindowFromXaml $objectXaml
$formControls = Get-WPFObjects $formatedXaml $window


$formControls.BoutonMenu.Add_Click({
    start-process "$env:SystemDrive\\_Tech\\Menu.bat" -verb Runas
    $window.Close()
    Exit
})

$formControls.BoutonQuit.Add_Click({
    winget uninstall -e --id XPDNXG5333CSVK
    Invoke-Task -TaskName 'delete _tech' -ExecutedScript 'C:\Temp\Remove.bat'
    $window.Close()
})

$formControls.Boutonbat.Add_Click({
    $formControls.BoutonBattinfo.Visibility="Visible"
    $formControls.BoutonDontsleep.Visibility="Visible"
    $formControls.Boutonbat.Visibility="Collapsed"
    Get-RemoteZipFile "Batterie" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Batterie.zip" "$pathDiagnostiqueSource"
})
$formControls.BoutonCPU.Add_Click({
    $formControls.BoutonAida.Visibility="Visible"
    $formControls.BoutonCoretemp.Visibility="Visible"
    $formControls.BoutonPrime95.Visibility="Visible"
    $formControls.BoutonHeavyLoad.Visibility="Visible"
    $formControls.BoutonThrottleStop.Visibility="Visible"
    $formControls.BoutonCPU.Visibility="Collapsed"
    new-item -ItemType Directory -path "$pathDiagnostiqueSource\CPU" | Out-Null
})
$formControls.BoutonHDD.Add_Click({
    $formControls.BoutonHDSentinnel.Visibility="Visible"
    $formControls.BoutonHDTune.Visibility="Visible"
    $formControls.BoutonASSD.Visibility="Visible"
    $formControls.BoutonDiskmark.Visibility="Visible"
    $formControls.BoutonHDD.Visibility="Collapsed"
    Get-RemoteZipFile "HDD" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HDD.zip' "$pathDiagnostiqueSource"
})
$formControls.BoutonGPU.Add_Click({
    $formControls.BoutonFurmark.Visibility="Visible"
    $formControls.BoutonUnigine.Visibility="Visible"
    $formControls.BoutonGPU.Visibility="Collapsed"
    Get-RemoteZipFile "GPU" 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/GPU.zip' "$pathDiagnostiqueSource"
})
$formControls.BoutonRAM.Add_Click({
    mdsched.exe
    Add-Log "diagnostiquelog.txt" "Memtest effectué"
})

$formControls.BoutonBattinfo.Add_Click({
    Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\battinfoview\batteryinfoview.exe"
    Add-Log "diagnostiquelog.txt" "Usure de la batterie vérifié"
})
    
$formControls.BoutonDontsleep.Add_Click({
    Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\Batterie\DontSleep\DontSleep_x64_p.exe"
    Add-Log "diagnostiquelog.txt" "Dontsleep a été utilisé pour tester la batterie"
})
    
$formControls.BoutonAida.Add_Click({
   $scriptBlock = {
        $pathDiagnostiqueSource = "$env:SystemDrive\_Tech\Applications\Diagnostique\source"
        $modulesFolder = "$env:SystemDrive\_Tech\Applications\Source\modules"
        foreach ($module in Get-Childitem $modulesFolder -Name -Filter "*.psm1")
        {
            Import-Module $modulesFolder\$module
        }
    Invoke-RemoteZipFile "Aida64" "https://ftp.alexchato9.com/public/file/WPdP-yDdBE2pOpHVFKNC6g/Aida64.zip" "aida64.exe" "$pathDiagnostiqueSource\cpu"
    Add-Log "diagnostiquelog.txt" "Test de stabilité du système effectué"
    }      
    Start-ThreadJob -ScriptBlock $scriptBlock | Wait-Job | Remove-Job
})
    
$formControls.BoutonCoretemp.Add_Click({
Invoke-RemoteZipFile "Core_Temp" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Core_Temp.zip" "Core Temp.exe" "$pathDiagnostiqueSource\cpu"
Add-Log "diagnostiquelog.txt" "Température du CPU vérifié"
})

$formControls.BoutonPrime95.Add_Click({
Invoke-RemoteZipFile "Prime95" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Prime95.zip" "Prime95.exe" "$pathDiagnostiqueSource\cpu"
Add-Log "diagnostiquelog.txt" "Stress test du CPU effectué"
})

$formControls.BoutonHeavyLoad.Add_Click({
Invoke-RemoteZipFile "HeavyLoad" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HeavyLoad.zip" "HeavyLoad.exe" "$pathDiagnostiqueSource\cpu"
Add-Log "diagnostiquelog.txt" "Test de stabilité du système effectué"
})
$formControls.BoutonThrottleStop.Add_Click({
    Invoke-RemoteZipFile "ThrottleStop" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/ThrottleStop.zip" "ThrottleStop.exe" "$pathDiagnostiqueSource\cpu"
    Add-Log "diagnostiquelog.txt" "Stress test du CPU effectué"
    })

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

$formControls.BoutonHDSentinnel.Add_Click({
function HDSentinnel
{
    $pathHDS = "C:\Program Files (x86)\Hard Disk Sentinel"
    Add-Log "diagnostiquelog.txt" "Vérifier la santé du disque dur"
    $apppath = Test-AppPresence $pathHDS
    if($apppath)
    {
        Start-App "HDSentinel.exe" $pathHDS
    }
    elseif($apppath -eq $false)
    {
    Install-Winget  
    winget install -e --id XPDNXG5333CSVK --accept-package-agreements --accept-source-agreements --silent | Out-Null
    $apppath = Test-AppPresence $pathHDS
        if($apppath -eq $false)
        {
            Chocoinstall
            choco install hdsentinel -y | Out-Null
        }
        Start-App "HDSentinel.exe" $pathHDS
    }
}
HDSentinnel
})

$formControls.BoutonHDTune.Add_Click({
    Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\HD_Tune\_HDTune.exe"
    Add-Log "diagnostiquelog.txt" "Vérifier la Vitesse du disque dur"
})

$formControls.BoutonASSD.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\As_SSD\AS SSD Benchmark.exe"
})

$formControls.BoutonDiskmark.Add_Click({
Start-Process -wait  "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\HDD\CrystalDiskInfoPortable\CrystalDiskInfoPortable.exe"  -ArgumentList "/copy"
Add-Log "diagnostiquelog.txt" "Vérifier la santé du disque dur"
#diskmarkinfolog | Out-File $logfilepath -Append
})

$formControls.BoutonFurmark.Add_Click({
Start-Process "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\GPU\FurMark\FurMark.exe"
Add-Log "diagnostiquelog.txt" "Stress test du GPU"
})


$formControls.BoutonUnigine.Add_Click({
Start-Process "https://benchmark.unigine.com/"
Add-Log "diagnostiquelog.txt" "Vérifier les performances du GPU"
})

$formControls.BoutonSpeccy.Add_Click({
Invoke-RemoteZipFile "Speccy" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Speccy.zip" "Speccy.exe" "$pathDiagnostiqueSource"
})

$formControls.BoutonHWMonitor.Add_Click({
Invoke-RemoteZipFile "HWmonitor" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HWMonitor.zip" "HWMonitor_x64.exe" "$pathDiagnostiqueSource"
})

$formControls.BoutonWhocrashed.Add_Click({
Invoke-RemoteZipFile "WhoCrashed" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/WhoCrashed.zip" "WhoCrashedEx.exe" "$pathDiagnostiqueSource"
})

$formControls.BoutonSysinfo.Add_Click({
msinfo32
})

Start-WPFAppDialog $window


$JSONFilePath = "$env:SystemDrive\_Tech\Applications\Diagnostique\source\DiagApps.JSON"
$jsonString = Get-Content -Raw $JSONFilePath
$appsInfo = ConvertFrom-Json $jsonString
$appNames = $appsInfo.psobject.Properties.Name
#Iterate over the applications in the JSON and interpolate the variables
$appNames | ForEach-Object {
    $appName = $_
    $appsInfo.$appName.path64 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path64)
    $appsInfo.$appName.path32 = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.path32)
    $appsInfo.$appName.pathAppData = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.pathAppData)
    $appsInfo.$appName.NiniteName = $ExecutionContext.InvokeCommand.ExpandString($appsInfo.$appName.NiniteName)
    }