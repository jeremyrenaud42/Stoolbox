#Download fichiers winget depuis github
function zipwinget
{
$wingetpath = test-Path "$env:SystemDrive\_Tech\Applications\Source\winget"
    if($wingetpath -eq $false) #Si dossier Winget n'existe pas, va le download
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Installation/main/Winget.zip' -OutFile "$env:SystemDrive\_Tech\Applications\Source\Winget.zip"
        Expand-Archive "$env:SystemDrive\_Tech\Applications\Source\Winget.zip" "$env:SystemDrive\_Tech\Applications\Source"
        Remove-Item "$env:SystemDrive\_Tech\Applications\Source\Winget.zip" 
    }
}

#Vérifier si winget est déja installé
function Preverifwinget
{
   $wingetpath = $false
   $wingetpath = test-path "$env:SystemDrive\Users\$env:username\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe"
   if($wingetpath)
   {
     $wingetpath = $true
   }
   return $wingetpath
}

#Install le package manager Winget
function Wingetinstall
{
    $progressPreference = 'SilentlyContinue' #cache la barre de progres
    $wingetpath = Preverifwinget
    if($wingetpath -eq $false)
    {
        zipwinget
        Add-AppxPackage -path "$env:SystemDrive\_Tech\Applications\Source\winget\Microsoft.VCLibs.x64.14.00.Desktop.appx"  | out-null #prérequis pour winget
        Add-AppxPackage -path "$env:SystemDrive\_Tech\Applications\Source\winget\Microsoft.UI.Xaml.2.7.appx" | out-null #prérequis pour winget
        Add-AppPackage -path "$env:SystemDrive\_Tech\Applications\Source\winget\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" | out-null #installeur de winget
    }
    Postverifwinget
}

#Vérifier si winget s'est bien installé
function Postverifwinget
{
   $wingetpath = test-path "$env:SystemDrive\Users\$env:username\AppData\Local\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe"
   if($wingetpath -eq $false)
   {
       $ErrorMessage = $_.Exception.Message
       Write-Warning "Winget n'a pas pu s'installer !!!! $ErrorMessage"
   }
}