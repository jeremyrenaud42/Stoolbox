@echo off
rem Ce script a pour but de downloader la boite à outils. Il permet de faire une recherche Internet et de télécharger l'app
rem verifier si internet est connecté
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

rem créer un dossier nommé "_tech" dans le lecteur C: afin de pouvoir y downloader le script Powershell de preinstall
if not exist %SystemDrive%\_Tech mkdir %SystemDrive%\_Tech 2>nul
powershell -Command "if (!(Test-Path -Path '%SystemDrive%\_Tech')) { New-Item -ItemType Directory -Path '%SystemDrive%\_Tech' -Force -ErrorAction SilentlyContinue }"

rem Download le script Menu.ps1 dans le dossier C:\_TECH
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& { (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.ps1', '%SystemDrive%\_tech\Menu.ps1')}"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& { (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Menu.bat', '%SystemDrive%\_tech\Menu.bat')}"
rem Lance le script Menu.bat qui appel Menu.ps1
START /min /wait powershell.exe -executionpolicy unrestricted -command "%SystemDrive%\_TECH\Menu.bat" -Verb runAs