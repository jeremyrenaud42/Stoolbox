$applications = "$env:SystemDrive\_Tech\applications" #chemin du dossier applications

function Update($categorie,$nomApplicationAMettreAJour,$liengithub,$lienappligithub)
{
    $dossierTemp = "$env:SystemDrive\_Tech\applications\$categorie\source\$nomApplicationAMettreAJour\Temp" #path du dossier Temp
    try 
    {
        New-Item -Path $dossierTemp -ItemType 'Directory' -Force | Out-Null #créer dossier temp
    }   
    catch 
    {
        Write-Error "Erreur! Le dossier temporaire n'a pas pu être créé!"
        return
    }

    #Download le fichier version depuis github
    Invoke-WebRequest $liengithub -OutFile "$applications\$categorie\source\$nomApplicationAMettreAJour\Temp\$nomApplicationAMettreAJour.version.txt" | Out-Null

    #cherche le chiffre dans les 2 fichiers
    $valuedownloadfile = Get-Content -Path "$dossierTemp\$nomApplicationAMettreAJour.version.txt" #fichier version nouveau
    $valueactualfile = Get-Content -Path "$applications\$categorie\source\$nomApplicationAMettreAJour\*.version.txt" #fichier version actuel
    
    #compare les 2 valeurs
    if ($valuedownloadfile -gt $valueactualfile) 
    { 
        try 
        {
            Write-Host "Mise à jour en cours..."
            Invoke-WebRequest $lienappligithub -OutFile "$applications\$categorie\source\$nomApplicationAMettreAJour.zip" | Out-Null
            Expand-Archive "$applications\$categorie\source\$nomApplicationAMettreAJour.zip" "$applications\$categorie\source" -Force | Out-Null
            Remove-Item "$applications\$categorie\source\$nomApplicationAMettreAJour.zip" -Force | Out-Null
            Copy-Item "$applications\$categorie\source\$nomApplicationAMettreAJour\Temp\$nomApplicationAMettreAJour.version.txt" -Destination "$applications\$categorie\source\$nomApplicationAMettreAJour\$nomApplicationAMettreAJour.version.txt" -Force | Out-Null #Met le fichier version a jour.
        }
        catch 
        {
            Write-Error "Erreur!"
            return
        }
    } 
    Remove-Item $dossierTemp -Recurse -Force #Supprime le dossier temp
    return  
}

#exemple de call
#Import-Module "$env:SystemDrive\_Tech\Applications\Source\update.psm1"
#Update "Diagnostique" "Speccy" 'https://raw.githubusercontent.com/jeremyrenaud42/versions/main/Diagnostique/speccy.version.txt' 'https://raw.githubusercontent.com/jeremyrenaud42/Diagnostique/main/Speccy.zip'