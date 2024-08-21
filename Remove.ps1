Add-Type -AssemblyName PresentationCore,PresentationFramework

$desktop = [Environment]::GetFolderPath("Desktop")
$folderPath = "$env:SystemDrive\_Tech"

if (Test-Path $folderPath)
{
    Write-Host "Suppression du dossier $folderPath"
    Remove-Item "$folderPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "$desktop\Menu.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
    Start-Sleep -Seconds 2
    Write-Host "Vidage de la corbeille"
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "La corbeille a été vidé"
    Start-Sleep -Seconds 2

    if (Test-Path $folderPath)
    {
        [System.Windows.MessageBox]::Show("La suppression du dossier C:\_Tech a échoué","Suppression",0,48) | Out-Null
    }
}
else
{
    Write-Host "Le dossier C:\_Tech n'existe pas."
    Start-Sleep -Seconds 2
}
