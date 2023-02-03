function DownloadLaunchApp($app, $liengithub,$current)
{
    $apppath = test-Path "$env:SystemDrive\_Tech\Applications\$current\Source\$app"
    if($apppath -eq $false)
    {
    Invoke-WebRequest $liengithub -OutFile "$env:SystemDrive\_Tech\Applications\$current\Source\$app"
    }
    Start-Process "$env:SystemDrive\_Tech\Applications\$current\Source\$app" -verb runas
  
}

function UnzipApp($app, $lienGithub, $current)
{
    $appPath = test-Path "$env:SystemDrive\_Tech\Applications\$current\Source\$app"
    $zipFile = "$env:SystemDrive\_Tech\Applications\$current\Source\$app.zip"
    if($appPath -eq $false)
    {
        Invoke-WebRequest $lienGithub -OutFile $zipFile
        Expand-Archive $zipFile "$env:SystemDrive\_Tech\Applications\$current\Source"
        Remove-Item $zipFile
    }
}

function UnzipAppLaunch($app, $lienGithub, $appExe, $current)
{
    UnzipApp $app $lienGithub $current
    Start-Process "$env:SystemDrive\_Tech\Applications\$current\Source\$app\$appExe"
} 