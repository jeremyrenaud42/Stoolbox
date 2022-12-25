@echo off
rem verifier internet
:loop
ping -n 1 8.8.8.8 >nul
if %errorlevel% equ 0 (
  goto end
) else (
  echo Veuillez vous connecter à Internet
  ping -n 5 8.8.8.8 >nul
  goto loop
)
:end

rem créer un dossier nommé "_tech" dans le lecteur C:
mkdir c:\_Tech 2> nul

rem Download le script preinstall.ps1 dans le dossier C:\_TECH
powershell -WindowStyle Hidden -Command "& { (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Preinstall.ps1', 'C:\_tech\Preinstall.ps1')}"
rem Lance le script Preinstall
START /min /wait powershell.exe -executionpolicy unrestricted -command "C:\_TECH\preinstall.ps1" -Verb runAs