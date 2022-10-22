$driveletter = $pwd.drive.name #retourne la lettre du disque actuel
$root = "$driveletter" + ":" #rajoute  : pour que sa fit dans le path

New-Item -ItemType Directory "C:\_Tech" -Force
Copy-Item "$root\_TECH\*" "C:\_TECH" -Recurse -Force

Start-Process "C:\_Tech"