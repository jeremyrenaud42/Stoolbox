$formControls.btnMenu_Desinfection.Add_Click({
    Open-Menu
})

$formControls.btnQuit_Desinfection.Add_Click({
    Remove-StoolboxApp
})

$formControls.btnProcess_Explorer_Desinfection.Add_Click({
    Invoke-App "procexp64.exe" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/procexp64.exe" $global:appPathSource
    Add-Log $global:logFileName "Vérifier les process"
})

$formControls.btnRKill_Desinfection.Add_Click({
    Invoke-App "rkill64.exe" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/rkill64.exe" $global:appPathSource
    Add-Log $global:logFileName "Désactiver les process"
})

$formControls.btnAutoruns_Desinfection.Add_Click({
    Invoke-App "autoruns.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/autoruns.exe" $global:appPathSource
    start-sleep 5
    taskmgr
    Add-Log $global:logFileName "Vérifier les logiciels au démarrage"
})

$formControls.btnHDD_Desinfection.Add_Click({
    Start-Process "$env:SystemDrive\Windows\SYSTEM32\cleanmgr.exe"
    Add-Log $global:logFileName "Nettoyage du disque effectué"
})

$formControls.btnCcleaner_Desinfection.Add_Click({
    Invoke-App "CCleaner64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/CCleaner64.zip" $global:appPathSource
    Add-Log $global:logFileName "Nettoyage CCleaner effectué"
 })

$formControls.btnRevo_Desinfection.Add_Click({
    Invoke-App "RevoUPort.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/RevoUPort.zip" $global:appPathSource
    Add-Log $global:logFileName "Vérifier les programmes nuisibles"
 })


$formControls.btnADWcleaner_Desinfection.Add_Click({
    Invoke-App "adwcleaner.exe" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/adwcleaner.exe" $global:appPathSource
    Add-Log $global:logFileName "Analyse ADW effectué"
 })

$formControls.btnMalwareByte_Desinfection.Add_Click({
    $path = Test-Path "$env:SystemDrive\Program Files\Malwarebytes\Anti-Malware\mbam.exe" 
    if($path -eq $false)
    {
        Install-Choco
        choco install malwarebytes -y | Out-Null
        if($path -eq $false)
        {
            Invoke-WebRequest "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/Ninite Malwarebytes Installer.exe" -OutFile "$root\_Tech\Applications\$appName\Source\Ninite Malwarebytes Installer.exe"
            Start-Process "$root\_Tech\\Applications\$appName\Source\Ninite Malwarebytes Installer.exe"
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
    Add-Log $global:logFileName "Analyse Malwarebyte effectué"
 })

$formControls.btnSuperAntiSpyware_Desinfection.Add_Click({
    $path = Test-Path "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe"
    if($path -eq $false)
    {
        Install-Choco
        choco install superantispyware -y | out-null
        Start-Process "$env:SystemDrive\Program Files\SUPERAntiSpyware\SUPERAntiSpyware.exe" 
        if($path -eq $false)
        {
            Invoke-WebRequest "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/Ninite SUPERAntiSpyware Installer.exe" -OutFile "$root\_Tech\Applications\$appName\Source\Ninite SUPERAntiSpyware Installer.exe"
            Start-Process "$root\_Tech\\Applications\$appName\Source\Ninite SUPERAntiSpyware Installer.exe"
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
    Add-Log $global:logFileName "Analyse SuperAntiSpyware effectué"
 })

$formControls.btnHitmanPro_Desinfection.Add_Click({
    Invoke-App "HitmanPro.exe" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/HitmanPro.exe" $global:appPathSource
    Add-Log $global:logFileName "Vérifier les virus avec HitmanPro"
})

$formControls.btnRogueKiller_Desinfection.Add_Click({
    Invoke-App "RogueKiller_portable64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/RogueKiller_portable64.zip" $global:appPathSource
    Add-Log $global:logFileName "Analyse RogueKiller effectué"
    #via le cmd, aller a l"emplacement RogueKillerCMD.exe -scan -no-interact -deleteall #-debuglog {path}
 })