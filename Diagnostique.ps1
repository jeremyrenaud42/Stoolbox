$formControls.btnMenu_Diagnostique.Add_Click({
    Open-Menu
})

$formControls.btnQuit_Diagnostique.Add_Click({
    Remove-StoolboxApp
})

$formControls.btnbat_Diagnostique.Add_Click({
    $formControls.btnBattinfo_Diagnostique.Visibility="Visible"
    $formControls.btnDontsleep_Diagnostique.Visibility="Visible"
    $formControls.btnBattMonitor_Diagnostique.Visibility="Visible"
    $formControls.btnCaffeine_Diagnostique.Visibility="Visible"
    $formControls.btnbat_Diagnostique.Visibility="Collapsed"
    New-Folder "$global:appPathSource\Batterie"
})
$formControls.btnCPU_Diagnostique.Add_Click({
    $formControls.btnAida_Diagnostique.Visibility="Visible"
    $formControls.btnCoretemp_Diagnostique.Visibility="Visible"
    $formControls.btnPrime95_Diagnostique.Visibility="Visible"
    $formControls.btnHeavyLoad_Diagnostique.Visibility="Visible"
    $formControls.btnThrottleStop_Diagnostique.Visibility="Visible"
    $formControls.btnCPU_Diagnostique.Visibility="Collapsed"
    New-Folder "$global:appPathSource\CPU"
})
$formControls.btnHDD_Diagnostique.Add_Click({
    $formControls.btnHDSentinnel_Diagnostique.Visibility="Visible"
    $formControls.btnHDTune_Diagnostique.Visibility="Visible"
    $formControls.btnASSD_Diagnostique.Visibility="Visible"
    $formControls.btnCrystalDiskInfo_Diagnostique.Visibility="Visible"
    $formControls.btnHDD_Diagnostique.Visibility="Collapsed"
    New-Folder "$global:appPathSource\GPU"
})
$formControls.btnGPU_Diagnostique.Add_Click({
    $formControls.btnFurmark_Diagnostique.Visibility="Visible"
    $formControls.btnFurmarkV2_Diagnostique.Visibility="Visible"
    $formControls.btnUnigine_Diagnostique.Visibility="Visible"
    $formControls.btnGPU_Diagnostique.Visibility="Collapsed"
    New-Folder "$global:appPathSource\GPU"
})
$formControls.btnRAM_Diagnostique.Add_Click({
    mdsched.exe
    Add-Log $global:logFileName "Memtest effectué"
})

$formControls.btnBattinfo_Diagnostique.Add_Click({
    Invoke-App "batteryinfoview.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/Batterie/batteryinfoview.exe" "$global:appPathSource/Batterie"
    Add-Log $global:logFileName "Usure de la batterie vérifié"
})
$formControls.btnBattMonitor_Diagnostique.Add_Click({
    Invoke-App "BatteryMonx64.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/Batterie/BatteryMonx64.exe" "$global:appPathSource/Batterie"
    Add-Log $global:logFileName "Usure de la batterie vérifié"
})
    
$formControls.btnDontsleep_Diagnostique.Add_Click({
    Invoke-App "DontSleep_x64_p.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/Batterie/DontSleep_x64_p.exe" "$global:appPathSource/Batterie"
})

$formControls.btnCaffeine_Diagnostique.Add_Click({
    Invoke-App "caffeine64.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/caffeine64.exe" "$global:appPathSource/Batterie"
})
    
$formControls.btnAida_Diagnostique.Add_Click({
    Invoke-App "Aida64.zip" "https://ftp.alexchato9.com/public/file/usqmwleqye2mhazxdvahvw/Aida64.zip" "$global:appPathSource\cpu" 
    Add-Log $global:logFileName "Test de stabilité du système effectué"
})
    
$formControls.btnCoretemp_Diagnostique.Add_Click({
    Invoke-App "Core Temp.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/CPU/Core Temp.zip" "$global:appPathSource\cpu"
    Add-Log $global:logFileName "Température du CPU vérifié"
})

$formControls.btnPrime95_Diagnostique.Add_Click({
    Invoke-App "Prime95.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/CPU/Prime95.zip" "$global:appPathSource\cpu"
    Add-Log $global:logFileName "Stress test du CPU effectué"
})

$formControls.btnHeavyLoad_Diagnostique.Add_Click({
    Invoke-App "HeavyLoad.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/CPU/HeavyLoad.zip" "$global:appPathSource\cpu"
    Add-Log $global:logFileName "Test de stabilité du système effectué"
})
$formControls.btnThrottleStop_Diagnostique.Add_Click({
    Invoke-App "ThrottleStop.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/CPU/ThrottleStop.zip" "$global:appPathSource\cpu"
    Add-Log $global:logFileName "Stress test du CPU effectué"
})

$formControls.btnHDSentinnel_Diagnostique.Add_Click({
    function HDSentinnel
    {
        $pathHDS = "C:\Program Files (x86)\Hard Disk Sentinel"
        Add-Log $global:logFileName "Vérifier la santé du disque dur"
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

$formControls.btnHDTune_Diagnostique.Add_Click({
    Invoke-App "_HDTune.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/HDD/_HDTune.exe" "$global:appPathSource/HDD"
    Add-Log $global:logFileName "Vérifier la Vitesse du disque dur"
})

$formControls.btnASSD_Diagnostique.Add_Click({
    Invoke-App "As_SSD.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/HDD/As_SSD.zip" "$global:appPathSource/HDD"
    Add-Log $global:logFileName "Vérifier la Vitesse du disque dur"
})

$formControls.btnCrystalDiskInfo_Diagnostique.Add_Click({
    Invoke-App "CrystalDiskInfoPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/HDD/CrystalDiskInfoPortable.zip" "$global:appPathSource/HDD"
    Add-Log $global:logFileName "Vérifier la santé du disque dur"
})

$formControls.btnFurmark_Diagnostique.Add_Click({
    Invoke-App "FurMark.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/GPU/FurMark.zip" "$global:appPathSource/GPU"
    Add-Log $global:logFileName "Stress test du GPU"
})

$formControls.btnFurmarkV2_Diagnostique.Add_Click({
    Invoke-App "FurMark_GUI.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/GPU/FurMark_GUI.zip" "$global:appPathSource/GPU"
    Add-Log $global:logFileName "Stress test du GPU"
})
    
$formControls.btnUnigine_Diagnostique.Add_Click({
    Start-Process "https://benchmark.unigine.com/"
    Add-Log $global:logFileName "Vérifier les performances du GPU"
})

$formControls.btnSpeccy_Diagnostique.Add_Click({
    Invoke-App "Speccy.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/Speccy.zip" $global:appPathSource
})

$formControls.btnHWMonitor_Diagnostique.Add_Click({
    Invoke-App "HWMonitor_x64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/HWMonitor_x64.zip" $global:appPathSource
})

$formControls.btnWhocrashed_Diagnostique.Add_Click({
    Invoke-App "WhoCrashedEx.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Software/main/Diagnostique/WhoCrashedEx.zip" $global:appPathSource
})

$formControls.btnSysinfo_Diagnostique.Add_Click({
    msinfo32
})