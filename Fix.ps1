$formControls.btnMenu_Fix.Add_Click({
    Open-Menu
})

$formControls.btnQuit_Fix.Add_Click({
    Remove-StoolboxApp
})

$formControls.btnScript_Fix.Add_Click({
    $formControls.btnSFC_Fix.Visibility="Visible"
    $formControls.btnDISM_Fix.Visibility="Visible"
    $formControls.btnCHKDSK_Fix.Visibility="Visible"
    $formControls.btnSession_Fix.Visibility="Visible"
    $formControls.btnScript_Fix.Visibility="Collapsed"
})
$formControls.btnTweak_Fix.Add_Click({
    $formControls.btnFW10_Fix.Visibility="Visible"
    $formControls.btnFW11_Fix.Visibility="Visible"
    $formControls.btnUWT10_Fix.Visibility="Visible"
    $formControls.btnUWT11_Fix.Visibility="Visible"
    $formControls.btnTweaking_Fix.Visibility="Visible"
    $formControls.btnTweak_Fix.Visibility="Collapsed"
    Get-RemoteFile "Tweak.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Tweak.zip" $global:appPathSource
})
$formControls.btnSterjo_Fix.Add_Click({
    $formControls.btnSterjoBrowser_Fix.Visibility="Visible"
    $formControls.btnSterjoKeys_Fix.Visibility="Visible"
    $formControls.btnSterjoMail_Fix.Visibility="Visible"
    $formControls.btnSterjoWireless_Fix.Visibility="Visible"
    $formControls.btnSterjo_Fix.Visibility="Collapsed"
    Get-RemoteFile "Sterjo.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Sterjo.zip" $global:appPathSource
})

$formControls.btnDDU_Fix.Add_Click({
    Invoke-App "Display Driver Uninstaller.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/Display Driver Uninstaller.zip" $global:appPathSource
})
$formControls.btnWFD_Fix.Add_Click({
    Invoke-App "WiseForceDeleterPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/WiseForceDeleterPortable.zip" $global:appPathSource
})
$formControls.btnWinDirStat_Fix.Add_Click({
    Invoke-App "WinDirStatPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/WinDirStatPortable.zip" $global:appPathSource
})
$formControls.btnPW_Fix.Add_Click({
    Invoke-App "PartitionWizard.zip" "https://ftp.alexchato9.com/public/file/lmyigeszp0mea-kh9cbe0g/PartitionWizard.zip" $global:appPathSource
})
$formControls.btnInternet_Fix.Add_Click({
    Invoke-App "ComIntRep_X64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/ComIntRep_X64.zip"  $global:appPathSource
})

$formControls.btnSFC_Fix.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k sfc /scannow"
})
$formControls.btnDISM_Fix.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k DISM /online /cleanup-image /restorehealth";Add-Log $global:logFileName "Reparation du Windows"
})
$formControls.btnCHKDSK_Fix.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k chkdsk /f /r"
})
$formControls.btnSession_Fix.Add_Click({
    Get-RemoteFile "creer_session.txt" "https://raw.githubusercontent.com/jeremyrenaud42/Fix/main/creer_session.txt" $global:appPathSource
    Start-Process "$global:appPathSource\creer_session.txt"
})
$formControls.btnFW10_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\FixWin10\FixWin 10.2.2.exe"
})
$formControls.btnFW11_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\FixWin11\FixWin 11.1.exe"
})
$formControls.btnUWT10_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\Ultimate Windows Tweaker w10\Ultimate Windows Tweaker 4.8.exe"
})
$formControls.btnUWT11_Fix.Add_Click({
    Start-Process "$global:appPathSource\Tweak\Ultimate Windows Tweaker w11\Ultimate Windows Tweaker 5.1.exe"
})
$formControls.btnTweaking_Fix.Add_Click({
    Invoke-App "Repair_Windows.zip" "https://ftp.alexchato9.com/public/file/8xogge6k4uugcx2y9dp8vw/Repair_Windows.zip" "$global:appPathSource\Tweak"
})
$formControls.btnSterjoBrowser_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\SterJo_Browser\BrowserPasswords.exe"
})
$formControls.btnSterjoKeys_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\Sterjo_Key\KeyFinder.exe"
})
$formControls.btnSterjoMail_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\SterJo_Mail\MailPasswords.exe"
})
$formControls.btnSterjoWireless_Fix.Add_Click({
    Start-Process "$global:appPathSource\Sterjo\Sterjo_Wireless\WiFiPasswords.exe"
})