$applicationPath = "$env:SystemDrive\_Tech\Applications"
function DownloadImages
{
    CreateFolder "_Tech\Applications\Source\images"
    $fondpath = test-Path "$applicationPath\source\Images\fondpluiesize.gif"
    $iconepath = test-path "$applicationPath\source\Images\Icone.ico"
        if($fondpath -eq $false) 
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/fondpluiesize.gif' -OutFile "$applicationPath\source\Images\fondpluiesize.gif" | Out-Null
        }
        if($iconepath -eq $false) 
        {
            Invoke-WebRequest 'https://raw.githubusercontent.com/jeremyrenaud42/Menu/main/Icone.ico' -OutFile "$applicationPath\source\Images\Icone.ico" | Out-Null
        } 
}

function DownloadBackground($app, $lienGithub, $fond)
{
    $fondpath = test-Path "$applicationPath\$app\source\$fond"
        if($fondpath -eq $false) 
        {
            Invoke-WebRequest $lienGithub -OutFile "$applicationPath\$app\source\$fond" | Out-Null
        }
}