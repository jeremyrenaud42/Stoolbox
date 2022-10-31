Add-Type -AssemblyName Microsoft.VisualBasic

write-host "Suppression du dossier c:\_Tech"
Remove-Item  "C:\_Tech" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
start-sleep -s 2
Write-Host "Vidage de la corbeille"
Clear-RecycleBin -DriveLetter 'C' -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host "La corbeille a été vidé"
start-sleep -s 2

$path = Test-Path "C:\_Tech"
if($path)
{
    [Microsoft.VisualBasic.Interaction]::MsgBox("La suppression du dossier C:\_Tech a échoué",'OKOnly,SystemModal,Information', "Suppression") | Out-Null
}