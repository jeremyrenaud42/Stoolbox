function VerifPresenceApp($appPath)
{
    $appExistStatus = $false
    $appExist = Test-Path $appPath
    if($appExist)
    {
       $appExistStatus = $true 
    } 
    return $appExistStatus
}

function CreateFolder($folder) 
{
    $folderPath = "$env:SystemDrive\$folder"
    $folderExist = VerifPresenceApp $folderPath 
    if($folderExist -eq $false)
    {
        New-Item $folderPath -ItemType 'Directory' -Force | Out-Null
    }
}

function DownloadFile($file,$downloadLink,$path)
{
    $appExist = VerifPresenceApp "$path\$file"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile "$path\$file"
    }
}

function StartExeFile($exe,$path)
{
    Start-Process "$path\$exe" -verb runas
}

function DownloadLaunchApp($exe,$downloadLink,$path)
{
    DownloadFile $exe $downloadLink $path
    StartExeFile $exe $path
}

function UnzipApp($appFolder,$downloadLink,$path)
{
    $appExist = VerifPresenceApp "$path\$appFolder"
    $zipFile = "$path\$appFolder.zip"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile $zipFile
        Expand-Archive $zipFile $path
        Remove-Item $zipFile
    }
}

function StartApp($appExe,$appFolder,$path)
{
    Start-Process "$path\$appFolder\$appExe" -verb runas
}

function UnzipAppLaunch($appFolder,$downloadLink,$appExe,$path)
{
    UnzipApp $appFolder $downloadLink $path
    StartApp $appExe $appFolder $path
} 

function RemoveApp($path)
{
    Remove-Item $path -Force | out-null
}