Add-Type -AssemblyName PresentationFramework #Pour supporter le WPF

function importXamlFromFile($xamlFile)
{
    $inputXML = Get-Content $xamlFile -Raw
    return $inputXML
}

function FormatXamlFile($inputXML)
{
    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
    [XML]$formatedXaml = $inputXML
    return $formatedXaml
}

function CreateXamlObject($formatedXaml)
{
    $ObjectXaml = (New-Object System.Xml.XmlNodeReader $formatedXaml)
    return $ObjectXaml
}

function LoadWPFWindowFromXaml($ObjectXaml)
{
    try 
    {
        $window = [Windows.Markup.XamlReader]::Load($ObjectXaml)
        return $window
    } 
    catch 
    {
        Write-Warning $_.Exception
        throw
    }
}

function GetWPFObjects($formatedXaml, $window)
{
    $formControls = [PSCustomObject]@{}
    $formatedXaml.SelectNodes("//*[@Name]") | ForEach-Object {
        try 
        {
            $formControls | Add-Member -MemberType 'NoteProperty' -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
        } 
        catch 
        {
            throw
        }
    }
    return $formControls
}

function LaunchWPFApp($window)
{
    $Null = $window.ShowDialog() 
}


<#
$inputXML = importXamlFromFile "C:\Users\Proprio\Desktop\MainWindow.xaml"
$formatedXaml = FormatXamlFile $inputXML
$ObjectXaml = CreateXamlObject $formatedXaml
$window = LoadWPFWindowFromXaml $ObjectXaml
$formControls = GetWPFObjects $formatedXaml $window
LaunchWPFApp $window
#>






#$formControls | get-member
#$formControls.var_chkboxVLC.IsChecked

<#
$xamlFile = "C:\Users\Famille Renaud\source\repos\InstallationMenuAppChoice\InstallationMenuAppChoice\MainWindow.xaml"
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML
#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
    $window = [Windows.Markup.XamlReader]::Load( $reader ) #loadxaml
    } catch {
        Write-Warning $_.Exception
        throw
    }
#Creer des variables basé sur le nom des controls de la form
#Les variables seront nommé comme suit 'var_<control name>' ex: $lblBonjour
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}
#Get-Variable var_* 

$Null = $window.ShowDialog() 
$var_chkboxVLC.IsChecked 
#>
