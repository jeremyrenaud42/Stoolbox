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

$formControls.btnUpdate.Add_Click({
    start-Process "ms-settings:windowsupdate"
    Add-Log $logFileName "Mises à jours de Windows effectuées"
})

$formControls.btnAutoruns.Add_Click({
    Invoke-App "autoruns.exe" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/autoruns.exe" "$appPathSource"
    start-sleep 5
    taskmgr
    Add-Log $logFileName "Vérifier les logiciels au démarrage"
})

$formControls.btnRevo.Add_Click({
    Invoke-App "RevoUPort.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/RevoUPort.zip" "$appPathSource"
    Add-Log $logFileName "Vérifier les programmes nuisibles"
})

$formControls.btnHDD.Add_Click({
    Start-Process "$env:SystemDrive\Windows\SYSTEM32\cleanmgr.exe"
    Add-Log $logFileName "Nettoyage du disque effectué"
})

$formControls.btnCcleaner.Add_Click({
    Invoke-App "CCleaner64.zip" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/CCleaner64.zip" $appPathSource
    Add-Log $logFileName "Nettoyage CCleaner effectué"
})

$formControls.btnsfc.Add_Click({
    Invoke-App "sfcScannow.bat" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/sfcScannow.bat" "$appPathSource"
    Add-Log $logFileName "Vérifier les fichiers corrompus"
})

$formControls.btnHitmanPro.Add_Click({
    Invoke-App "HitmanPro.exe" "https://raw.githubusercontent.com/jeremyrenaud42/Desinfection/main/HitmanPro.exe" "$appPathSource"
    Add-Log $logFileName "Vérifier les virus avec HitmanPro"
})

$formControls.btnSysEvent.Add_Click({
    Invoke-App "sysevent.exe" "https://raw.githubusercontent.com/jeremyrenaud42/$appName/main/sysevent/sysevent.exe" "$appPathSource"
    Add-Log $logFileName "Vérifier les evenements"
})

$formControls.btnCrystalDiskInfo.Add_Click({
    Invoke-App "CrystalDiskInfoPortable.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/CrystalDiskInfoPortable.zip" "$appPathSource"
    Add-Log $logFileName "Vérifier la santé du HDD"
})

$formControls.btnHDTune.Add_Click({
    Invoke-App "_HDTune.zip" "https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/_HDTune.zip" "$appPathSource"
    Add-Log $logFileName "Vérifier la Vitesse du disque dur"
})

$formControls.btnSysinfoz.Add_Click({
    msinfo32.exe
})

$formControls.btnQuit.Add_Click({
    Remove-StoolboxApp
})

$formControls.btnMenu.Add_Click({
    Open-Menu
})

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

$window.add_Closed({
    Remove-Item -Path $lockFile -Force -ErrorAction SilentlyContinue
})

Start-WPFAppDialog $window