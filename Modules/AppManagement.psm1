function DownloadExeFile($exe,$downloadLink,$current)
{
    $appExist = test-Path "$env:SystemDrive\_Tech\Applications\$current\Source\$exe"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile "$env:SystemDrive\_Tech\Applications\$current\Source\$exe"
    }
}

function StartExeFile($exe,$current)
{
    Start-Process "$env:SystemDrive\_Tech\Applications\$current\Source\$exe" -verb runas
}

function StartApp($appExe,$current)
{
    Start-Process "$env:SystemDrive\_Tech\Applications\$current\Source\$app\$appExe" -verb runas
}

function UnzipApp($appfolder,$downloadLink,$current)
{
    $appExist = test-Path "$env:SystemDrive\_Tech\Applications\$current\Source\$appfolder"
    $zipFile = "$env:SystemDrive\_Tech\Applications\$current\Source\$appfolder.zip"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile $zipFile
        Expand-Archive $zipFile "$env:SystemDrive\_Tech\Applications\$current\Source"
        Remove-Item $zipFile
    }
}

#Legacy support
function DownloadLaunchApp($exe,$downloadLink,$current)
{
    $appExist = test-Path "$env:SystemDrive\_Tech\Applications\$current\Source\$exe"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile "$env:SystemDrive\_Tech\Applications\$current\Source\$exe"
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\$current\Source\$exe" -verb runas
}

function UnzipAppLaunch($appfolder,$downloadLink,$appExe,$current)
{
    UnzipApp $appfolder $downloadLink $current
    Start-Process "$env:SystemDrive\_Tech\Applications\$current\Source\$appfolder\$appExe"
} 