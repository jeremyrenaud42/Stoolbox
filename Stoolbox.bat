@echo off
rem créer un dossier nommé "_tech" dans le lecteur C:
mkdir c:\_Tech 2> nul

powershell -Command "& { (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/jeremyrenaud42/Bat/main/Preinstall.ps1', 'C:\_tech\Preinstall.ps1')}"
START powershell.exe -executionpolicy unrestricted -command C:\_TECH\preinstall.ps1 -Verb runAs