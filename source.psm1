function Sourceexist
{
$sourcefolder = Test-path ".\Source" #chemin du dossier source
    if(!($sourcefolder))
    {
        New-Item ".\Source" -ItemType 'Directory' -Force | Out-Null #Créer le dossier source si il n'est pas là
    }
}