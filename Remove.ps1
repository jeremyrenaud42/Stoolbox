Add-Type -AssemblyName PresentationCore,PresentationFramework

$desktop = [Environment]::GetFolderPath("Desktop")
$techFolder = "$env:SystemDrive\_Tech"
$tempFolder = "$env:SystemDrive\Temp\Stoolbox"
$lockfile = "$env:SystemDrive\_Tech\Applications\source\*.lock"
$maxAttempts = 5
$attempt = 0
$dateFile = "C:\_tech\Applications\Source\installedDate.txt"

if (test-path "C:\_Tech\Applications\source\Settings.JSON")
{
    Copy-Item "C:\_Tech\Applications\source\Settings.JSON" -Destination "C:\Temp\Stoolbox" -Force
}
$jsonFilePath = "C:\Temp\Stoolbox\Settings.JSON"
$jsonContent = Get-Content $jsonFilePath | ConvertFrom-Json

$download = $jsonContent.RemoveDownloadFolder.Status
$bin = $jsonContent.EmptyRecycleBin.Status

function Remove-Installer
{
    if (Test-Path "$env:USERPROFILE\Downloads\stoolbox.exe")
    {
        Remove-Item -Path "$env:USERPROFILE\Downloads\stoolbox.exe" -Force
    }
}
function Remove-DownloadFolder
{
    Write-Host "Nettoyage du dossier téléchargements" -ForegroundColor DarkCyan
    if (-not (test-path $dateFile) -or (Get-Content -Path $dateFile -ErrorAction SilentlyContinue).Trim().Length -eq 0) 
    {
        Write-Host "Échec de la suppression des téléchargements - Aucune date d'installation trouvée"
    }
    else 
    {
        $logContent = Get-Content -Path $dateFile
        $dateString = $logContent.Trim()  # Trim whitespace and newlines
        $targetDateTime = [DateTime]::ParseExact($dateString, "yyyy-MM-dd HH:mm:ss", $null) # Convert the date string to a DateTime object
        # Get the list of files with a LastWriteTime on or before the target date and time
        $files = Get-ChildItem -Path "$env:USERPROFILE\Downloads" | Where-Object { $_.LastWriteTime -ge $targetDateTime }
        if ($files.Count -eq 0) 
        {
            Write-Host "Aucun fichiers récents trouvé dans le dossier des téléchargements."
            Start-Sleep -s 1
            return
        }
        foreach ($file in $files) 
        {
            Remove-Item -Path $file.FullName -Recurse -Force
            Write-Output "$($file.FullName) a été supprimé"
        }
        Start-Sleep -s 1
    }
}   
function Remove-Task
{
    Write-Host "Suppresion de la tâche planifiée" -ForegroundColor DarkCyan
    $TaskName = 'delete _tech'
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -ne $task) 
    {
        if ($task.State -eq 'Ready') 
        {
            try 
            {
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop | Out-Null
                Write-Host "La tâche planifiée a été supprimée"
            } 
            catch 
            {
                Write-Host "Erreur lors de la suppression de la tâche: $($_.Exception.Message)"
            }
        } 
        else 
        {
            Write-Host "La tâche n'est pas en état 'Ready'. État actuel: $($task.State)"
        }
    } 
    else 
    {
        Write-Host "La tâche planifiée '$TaskName' n'existe pas."
    }
    Start-Sleep -Seconds 2
}
function Get-LockFile
{
    while(Test-Path $lockfile)
    {
        $attempt++
        Write-Host "En attente de la fermeture des scripts [$attempt/$maxAttempts]"
        Start-Sleep -s 2
        if ($attempt -ge $maxAttempts) 
        {
            Write-Host "La suppression de $techFolder va se poursuivre, mais pourrait contenir des erreurs."
            break
        }
    }
}
function Remove-techFolder
{
    Write-Host "Suppression du dossier $techFolder" -ForegroundColor DarkCyan
    Remove-Item "$techFolder\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item $techFolder -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    if (Test-Path $techFolder)
    {
        [System.Windows.MessageBox]::Show("La suppression du dossier C:\_Tech a échoué","Suppression",0,48) | Out-Null
    }
    else 
    {
        Write-Host "Le dossier C:\_Tech a été supprimé"
    }
    Start-Sleep -Seconds 1
}
function Remove-Shortcut
{
    Write-Host "Suppression du raccourci" -ForegroundColor DarkCyan
    Remove-Item "$desktop\Menu.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
    Start-Sleep -Seconds 1
}
function Remove-RecycleBin
{
    Write-Host "Vidage de la corbeille" -ForegroundColor DarkCyan
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "La corbeille a été vidé"
    Start-Sleep -Seconds 1
}
function Remove-TempFolder
{
    Write-Host "Suppresion du dossier $tempFolder " -ForegroundColor DarkCyan
    Remove-Item -Path "$tempFolder\*" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path $tempFolder -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Le dossier $tempFolder a été supprimé"
}
function Move-RemoveFile
{
    if (Test-Path "C:\Temp\Stoolbox\remove.ps1" -ErrorAction SilentlyContinue)
    {
        Move-Item "C:\Temp\Stoolbox\remove.ps1" -Destination "$env:APPDATA\remove.ps1" -Force -ErrorAction SilentlyContinue | Out-Null
        $scriptPath = "$env:APPDATA\remove.ps1"
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
        exit
    }
}
function Remove-RemoveFile
{
    Remove-Item "$env:APPDATA\remove.ps1" -Force -ErrorAction SilentlyContinue | Out-Null
}

#Main
if (Test-Path $techFolder)
{
    Get-LockFile
    Remove-Installer
    if($download -eq '1')
    {
        Remove-DownloadFolder
    }
    Remove-techFolder
    Remove-Shortcut
    if($bin -eq '1')
    {
        Remove-RecycleBin 
    } 
}
else #si C:\_Tech n'existe pas
{
    if (-not (Test-Path "$env:APPDATA\remove.ps1"))
    {
        Write-Host "Le dossier C:\_Tech n'existe pas."
        Start-Sleep -Seconds 2
    }
}

#Que techFolder existe ou pas ca va faire la suite:
Move-RemoveFile
Remove-TempFolder
Remove-RemoveFile
Remove-Task