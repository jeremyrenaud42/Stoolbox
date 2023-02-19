<#
function DownloadFile($file,$downloadLink,$category)
{
    $appExist = test-Path "$env:SystemDrive\_Tech\Applications\$category\Source\$file"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile "$env:SystemDrive\_Tech\Applications\$category\Source\$file"
    }
}
#>

function DownloadFile($file,$downloadLink,$path)
{
    $appExist = test-Path "$path\$file"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile "$path\$file"
    }
}

function StartExeFile($exe,$path)
{
    Start-Process "$path\$exe" -verb runas
}

function StartApp($appExe,$appFolder,$category)
{
    Start-Process "$env:SystemDrive\_Tech\Applications\$category\Source\$appFolder\$appExe" -verb runas
}

function UnzipApp($appfolder,$downloadLink,$category)
{
    $appExist = test-Path "$env:SystemDrive\_Tech\Applications\$category\Source\$appfolder"
    $zipFile = "$env:SystemDrive\_Tech\Applications\$category\Source\$appfolder.zip"
    if($appExist -eq $false)
    {
        Invoke-WebRequest $downloadLink -OutFile $zipFile
        Expand-Archive $zipFile "$env:SystemDrive\_Tech\Applications\$category\Source"
        Remove-Item $zipFile
    }
}

function DownloadLaunchApp($exe,$downloadLink,$path)
{
    DownloadFile $exe $downloadLink $path
    StartExeFile $exe $path
}

function UnzipAppLaunch($appfolder,$downloadLink,$appExe,$category)
{
    UnzipApp $appfolder $downloadLink $category
    StartApp $appExe $appFolder $category
} 