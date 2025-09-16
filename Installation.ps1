#cases qui se coche automatiquement selon des critères à l'ouverture de la grid
$manufacturerBrand = Get-Manufacturer
if($manufacturerBrand -match 'LENOVO')
{
    $formControls.chkboxLenovoVantage.IsChecked = $true
    $formControls.chkboxLenovoSystemUpdate.IsChecked = $true
}
elseif($manufacturerBrand -match 'HP')
{        
    $formControls.chkboxHPSA.IsChecked = $true
}
elseif($manufacturerBrand -match 'DELL')
{
    $formControls.chkboxDellsa.IsChecked = $true
}
elseif($manufacturerBrand -like '*Micro-Star*')
{
    $formControls.chkboxMSICenter.IsChecked = $true
}
$videoController = Get-WmiObject win32_videoController | Select-Object -Property name
if($videoController -match 'NVIDIA')
{
    $formControls.chkboxNVIDIA.IsChecked = $true
}

#Actions lorsque boutons sont cliqués 
$formControls.btnAdobe.Add_Click({
    Install-SoftwareMenuApp "Adobe Reader"
})
$formControls.btnGoogleChrome.Add_Click({
    Install-SoftwareMenuApp "Google Chrome"
})
$formControls.btnTeamviewer.Add_Click({
    Install-SoftwareMenuApp "TeamViewer"
})
$formControls.btnVLC.Add_Click({
    Install-SoftwareMenuApp "VLC"
})
$formControls.btn7zip.Add_Click({
    Install-SoftwareMenuApp "7Zip"
})
$formControls.btnMacrium.Add_Click({
    Install-SoftwareMenuApp "Macrium"
})
$formControls.btnNVIDIA.Add_Click({
    Install-SoftwareMenuApp "NVIDIA App"
})
$formControls.btnLenovoVantage.Add_Click({
    Install-SoftwareMenuApp "Lenovo Vantage"
})
$formControls.btnLenovoSystemUpdate.Add_Click({
    Install-SoftwareMenuApp "Lenovo System Update"
})
$formControls.btnHPSA.Add_Click({
    Install-SoftwareMenuApp "HP Support Assistant"
})
$formControls.btnMSICenter.Add_Click({
    Install-SoftwareMenuApp "MSI Center"
})
$formControls.btnMyAsus.Add_Click({
    Install-SoftwareMenuApp "MyAsus"
})
$formControls.btnDellsa.Add_Click({
    Install-SoftwareMenuApp "Dell Command Update"
})
$formControls.btnIntel.Add_Click({
    Install-SoftwareMenuApp "Intel Drivers Support"
})
$formControls.btnSteam.Add_Click({
    Install-SoftwareMenuApp "Steam"
})
$formControls.btnZoom.Add_Click({
    Install-SoftwareMenuApp "Zoom"
})
$formControls.btnDiscord.Add_Click({
    Install-SoftwareMenuApp "Discord"
})
$formControls.btnFirefox.Add_Click({
    Install-SoftwareMenuApp "Firefox"
})
$formControls.btnLibreOffice.Add_Click({
    Install-SoftwareMenuApp "Libre Office"
})
$formControls.btnWindowsUpdate.Add_Click({
    start-Process "ms-settings:windowsupdate"
    $formControls.rtbOutput_InstallationConfig.AppendText("Vérification des mises à jour de Windows`r")
})
$formControls.btnDisque.Add_Click({
    script:Update-CheckboxStatus
    Rename-SystemDrive -NewDiskName $global:jsonChkboxContent.TxtBxDiskName.status
})
$formControls.btnMSStore.Add_Click({
    Update-MsStore
})
$formControls.btnBitlocker.Add_Click({
    Disable-BitLocker
})
$formControls.btnStartup.Add_Click({
    Disable-FastBoot
})
$formControls.btnClavier.Add_Click({
    Remove-EngKeyboard 'en-CA'
})
$formControls.btnExplorer.Add_Click({
    Set-ExplorerDisplay
})
$formControls.btnIcone.Add_Click({
    Enable-DesktopIcon 
})
$formControls.btnConfi.Add_Click({
    Set-Privacy
})
$formControls.btnReturn_InstallationConfig.Add_Click({
    Open-Menu
})
$formControls.btnQuit_InstallationConfig.Add_Click({
    Remove-StoolboxApp
})
$formControls.btnGo_InstallationConfig.Add_Click({
    script:Update-CheckboxStatus

    if($formControls.chkboxDeleteFolder.IsChecked)
    {
        Update-JsonFile "$sourceFolderPath\Settings.JSON" "RemoveDownloadFolder" "Status" "1"
    }
    elseif($formControls.chkboxDeleteFolder.IsChecked -eq $false)
    { 
        Update-JsonFile "$sourceFolderPath\Settings.JSON" "RemoveDownloadFolder" "Status" "0"
    }

    if($formControls.chkboxDeleteBin.IsChecked)
    {
        Update-JsonFile "$sourceFolderPath\Settings.JSON" "EmptyRecycleBin" "Status" "1"
    }
    elseif($formControls.chkboxDeleteBin.IsChecked -eq $false)
    { 
        Update-JsonFile "$sourceFolderPath\Settings.JSON" "EmptyRecycleBin" "Status" "0"
    }
    Remove-Item -Path "$env:SystemDrive\_Tech\Applications\source\Menu.lock" -Force 
    $lockFile = "$sourceFolderPath\Installation.lock"
    $Global:appIdentifier = "Installation.ps1"
    Test-ScriptInstance $lockFile $Global:appIdentifier
    $processCaff = get-process -name caffeine64 -ErrorAction SilentlyContinue
    if($processCaff -eq $null)
    {
        start-Process "$global:appPathSource\caffeine64.exe"
    }
    $window.Close()
    Start-WPFApp $global:windowMain
    Main
})
#Actions lorsque des checkbox sont cochées 
$formControls.chkboxRemove.Add_Checked({
    $formControls.chkboxDeleteFolder.IsChecked = $true
    $formControls.chkboxDeleteBin.IsChecked = $true
})
$formControls.chkboxRemove.Add_Unchecked({
    $formControls.chkboxDeleteFolder.IsChecked = $false
    $formControls.chkboxDeleteBin.IsChecked = $false
})