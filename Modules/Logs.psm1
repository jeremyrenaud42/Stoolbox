function Add-Log ($filename,$message)
{
    $logFilePath = ".\Source\$filename" #chemin du fichier texte
    (Get-Date).ToString() + " - " + $message + "`r`n" | Out-file -filepath $logFilePath -append -force
}

function Remove-Log($filename)
{
    $logFilePath = ".\Source\$filename" #chemin du fichier texte 
    Remove-Item $logFilePath -Force | out-null
}

function Copy-Log($filename,$destination)
{
    Copy-Item ".\Source\$filename" -destination $destination -Force | out-null 
}


#a verifier et tester
function Copy-AllLog
{
$pathDesinfection = "$env:SystemDrive\_Tech\Applications\Desinfection\Source\*log.txt"
$pathFix = "$env:SystemDrive\_Tech\Applications\Fix\Source\*Log.txt"
$pathDiag = "$env:SystemDrive\_Tech\Applications\Diagnostique\Source\*log.txt"
$pathInstall = "$env:SystemDrive\_Tech\Applications\Installation\Source\*log.txt"
$pathOpti = "$env:SystemDrive\_Tech\Applications\Optimisation_Nettoyage\Source\*log.txt"

#Specifier le chemin du log dans lequel on combine tous les logs de chaque script
$finalLogFilePath = "$env:SystemDrive\Temp\FinalLog.txt"

#effacer le contenu du log final avant d'ecrire dedans
if (Test-Path $finalLogFilePath)
{
    Clear-Content $finalLogFilePath 
}
#mettre le contenue dans le log final
$contentDesinfection = Get-Content -Path $pathDesinfection | Out-File $finalLogFilePath -Append -Force
$contentFix = Get-Content -Path $pathFix | Out-File $finalLogFilePath -Append -Force
$contentDiag = Get-Content -Path $pathDiag | Out-File $finalLogFilePath -Append -Force
$contenInstall = Get-Content -Path $pathInstall | Out-File $finalLogFilePath -Append -Force
$contentOpti = Get-Content -Path $pathOpti | Out-File $finalLogFilePath -Append -Force

#effacer le contenu des logs qu'on a combines
Clear-Content -Path $pathDesinfection
Clear-Content -Path $pathFix
Clear-Content -Path $pathDiag
Clear-Content -Path $pathInstall
Clear-Content -Path $pathOpti

[System.Windows.MessageBox]::Show("Log disponible C:\Temp\FinalLog.txt","Rapport Final",0) | Out-Null
}