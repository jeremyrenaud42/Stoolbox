function CreateFolder($folder) 
{
    $folderPath = "$env:SystemDrive\$folder"
    $folderExist = test-path $folderPath 
    if($folderExist -eq $false)
    {
        New-Item $folderPath -ItemType 'Directory' -Force | Out-Null
    }
}