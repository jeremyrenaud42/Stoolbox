write-host "Suppression du dossier c:\_Tech"
Remove-Item  "C:\_Tech" -Recurse -Force
Write-Host "Vidage de la corbeille"
Clear-RecycleBin -DriveLetter 'C' -Force -ErrorAction SilentlyContinue
Write-Host "La corbeille a été vidé"
start-sleep -s 2

$path = Test-Path "C:\_Tech"
if($path)
{
    write-host  "La suppression du dossier C:\_Tech a échoué"
}