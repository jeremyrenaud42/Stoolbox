function DownloadRemoveScript
{
    CreateFolder "Temp"
    $removePs1Exist = test-path "$env:SystemDrive\Temp\remove.ps1"
    $removeBatExist = test-path "$env:SystemDrive\Temp\Remove.bat"
    if($removePs1Exist -eq $false -and $removeBatExist -eq $false)
    {
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Remove.ps1' -OutFile "$env:SystemDrive\Temp\Remove.ps1" | Out-Null
        Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/bat/Remove.bat' -OutFile "$env:SystemDrive\Temp\Remove.bat" | Out-Null
    }
}