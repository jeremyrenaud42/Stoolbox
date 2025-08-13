$formControls.btnUpdate_Optimisation_Nettoyage.Add_Click({
    start-Process "ms-settings:windowsupdate"
    Add-Log $global:logFileName "Mises à jours de Windows effectuées"
})

$formControls.btnAutoruns_Optimisation_Nettoyage.Add_Click({
    Invoke-App "autoruns.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/autoruns.exe" $global:appPathSource
    start-sleep 3
    taskmgr
    Add-Log $global:logFileName "Vérifier les logiciels au démarrage"
})

$formControls.btnRevo_Optimisation_Nettoyage.Add_Click({
    Invoke-App "RevoUPort.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/RevoUPort.zip" $global:appPathSource
    Add-Log $global:logFileName "Vérifier les programmes nuisibles"
})

$formControls.btnHDD_Optimisation_Nettoyage.Add_Click({
    Start-Process "$env:SystemDrive\Windows\SYSTEM32\cleanmgr.exe"
    Add-Log $global:logFileName "Nettoyage du disque effectué"
})

$formControls.btnCcleaner_Optimisation_Nettoyage.Add_Click({
    Invoke-App "CCleaner64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/CCleaner64.zip" $global:appPathSource
    Add-Log $global:logFileName "Nettoyage du disque avec CCleaner effectué"
})

$formControls.btnSfc_Optimisation_Nettoyage.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k sfc /scannow"
    Add-Log $global:logFileName "Vérifier les fichiers corrompus"
})

$formControls.btnHitmanPro_Optimisation_Nettoyage.Add_Click({
    Invoke-App "HitmanPro.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/HitmanPro.exe" $global:appPathSource
    Add-Log $global:logFileName "Vérifier les virus avec HitmanPro"
})

$formControls.btnSysEvent_Optimisation_Nettoyage.Add_Click({
    Get-RemoteFile "sysevent.ps1" "https://raw.githubusercontent.com/jeremyrenaud42/Optimisation_Nettoyage/main/sysevent.ps1" $global:appPathSource
    powershell -ExecutionPolicy Bypass -File "$global:appPathSource/sysevent.ps1"
    Add-Log $global:logFileName "Vérifier les evenements"
})

$formControls.btnCrystalDiskInfo_Optimisation_Nettoyage.Add_Click({
    Invoke-App "CrystalDiskInfoPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/HDD/CrystalDiskInfoPortable.zip" $global:appPathSource
    Add-Log $global:logFileName "Vérifier la santé du HDD"
})

$formControls.btnHDTune_Optimisation_Nettoyage.Add_Click({
    Invoke-App "_HDTune.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/_HDTune.zip" $global:appPathSource
    Add-Log $global:logFileName "Vérifier la Vitesse du disque dur"
})

$formControls.btnSysinfoz_Optimisation_Nettoyage.Add_Click({
    msinfo32.exe
})

$formControls.btnQuit_Optimisation_Nettoyage.Add_Click({
    Remove-StoolboxApp
})

$formControls.btnMenu_Optimisation_Nettoyage.Add_Click({
    Open-Menu
})

#choco install hdtune
#choco install hdsentinel
#choco install revo-uninstaller
#choco install ccleaner.portable
#choco install ccenhancer
#choco install autoruns
#choco install hitmanpro

#RevoUninstaller.RevoUninstaller
#Piriform.CCleaner
#SingularLabs.CCEnhancer

<#
Import-Module -Name "$env:SystemDrive\\_TECH\\Applications\\Source\\Excel\\ImportExcel" #import le module Excel situ� dans la cl�
$excel = Open-ExcelPackage -Path "$env:SystemDrive\\_TECH\\Applications\\Source\\Excel\\Rapport.xlsm" #ouvre la grille Excel
$worksheet = $excel.Workbook.Worksheets["Gabarit"] #pr�cise quelle grille Excel sera utilis�

$worksheet.Cells["A1"].Value #get une valeur
$worksheet.Cells["B2"].Value = "4" #set une valeur

B2 = num_tel
4 � 13 = OS
16 � 20 = Composantes
A25 � A41 = Notes
Cases � cocher: B = Bon.  C = Jaune.  D= Rouge. E = Notes.
#>