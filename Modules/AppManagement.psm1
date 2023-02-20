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

function Chocoinstall
{
    $progressPreference = 'SilentlyContinue' #cache la barre de progres
    $chocoExist = VerifPresenceApp "$env:SystemDrive\ProgramData\chocolatey"
    if($chocoExist -eq $false)
    {
        Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression | Out-Null #install le module choco
        $env:Path += ";$env:SystemDrive\ProgramData\chocolatey" #permet de pouvoir installer les logiciels sans reload powershell
    }
}

function Wingetinstall
{
    $progressPreference = 'SilentlyContinue' #cache la barre de progres
    $wingetPath = VerifPresenceApp "$env:SystemDrive\Users\$env:username\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe"
    if($wingetPath -eq $false)
    {
        UnzipApp "winget" 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Winget.zip' "$env:SystemDrive\_Tech\Applications\Source"
        Add-AppxPackage -path "$env:SystemDrive\_Tech\Applications\Source\winget\Microsoft.VCLibs.x64.14.00.Desktop.appx"  | out-null #prérequis pour winget
        Add-AppxPackage -path "$env:SystemDrive\_Tech\Applications\Source\winget\Microsoft.UI.Xaml.2.7.appx" | out-null #prérequis pour winget
        Add-AppPackage -path "$env:SystemDrive\_Tech\Applications\Source\winget\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" | out-null #installeur de winget
    }
    Postverifwinget
}