$driveletter = $pwd.drive.name #retourne la lettre du disque actuel
$root = "$driveletter" + ":" #rajoute  : pour que sa fit dans le path
Set-Location "$root\_Tech\"
Start-Process "$root\_Tech\menu.exe"