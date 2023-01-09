#Vérifier si Choco est déja installé
function Preverifchoco 
{
    $chocoexist = $false
    $chocopath = Test-Path "$env:SystemDrive\ProgramData\chocolatey"
    if ($chocopath -eq $true)
    {
       $chocoexist = $true 
    } 
    return $chocoexist
}

#Vérifier si choco s'est bien installé
function Postverifchoco 
{
    $chocopath = Test-Path "$env:SystemDrive\ProgramData\chocolatey"
    if ($chocopath -eq $false)
    {
        $ErrorMessage = $_.Exception.Message
        Write-Warning "Choco n'a pas pu s'installer !!!! $ErrorMessage"
    }
}

#Install le package manager Choco
function Chocoinstall
{
    $progressPreference = 'SilentlyContinue' #cache la barre de progres
    $chocoexist = Preverifchoco
    if($chocoexist -eq $false)
    {
        Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression | Out-Null #install le module choco
        $env:Path += ";$env:SystemDrive\ProgramData\chocolatey" #permet de pouvoir installer les logiciels sans reload powershell
    }
    Postverifchoco
}