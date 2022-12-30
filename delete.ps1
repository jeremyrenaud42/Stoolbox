Add-Type -AssemblyName Microsoft.VisualBasic

$preverif = Test-Path "$env:SystemDrive\_Tech"
if($preverif)
{
    write-host "Suppression du dossier $env:SystemDrive\_Tech"
    Remove-Item  "$env:SystemDrive\_Tech\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null #Ca prend cette ligne si executer depuis C:\_tech. Ca va laisser le odssier _tech vide, mais au moins ca marchera.
    Remove-Item  "$env:SystemDrive\_Tech" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    start-sleep -s 2
    Write-Host "Vidage de la corbeille"
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "La corbeille a été vidé"
    start-sleep -s 2
    
    $path = Test-Path "$env:SystemDrive\_Tech\preinstall.ps1"
    if($path)
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("La suppression du dossier C:\_Tech a échoué",'OKOnly,SystemModal,Information', "Suppression") | Out-Null
    }
}