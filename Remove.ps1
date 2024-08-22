Add-Type -AssemblyName PresentationCore,PresentationFramework

$desktop = [Environment]::GetFolderPath("Desktop")
$folderPath = "$env:SystemDrive\_Tech"
$lockfile = "$env:SystemDrive\_Tech\Applications\source\*lockfile.lock"
$maxAttempts = 5
$attempt = 0

if (Test-Path $folderPath)
{
    while(Test-Path $lockfile)
    {
        Write-Host "En attente de la fermeture des scripts [$attempt/$maxAttempts]"
        Start-Sleep -s 2
        $attempt++

        if ($attempt -ge $maxAttempts) 
        {
            Write-Host "La suppression de $folderPath va se poursuivre, mais pourrait contenir des erreurs."
            break
        }
    }
    Write-Host "Suppression du dossier $folderPath"
    Remove-Item "$folderPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "$desktop\Menu.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "$env:SystemDrive\Temp\Remove.bat" -Force -ErrorAction SilentlyContinue | Out-Null
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
