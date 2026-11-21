@echo off
rem Ouvre ArmoireDesigner.html en fenetre dediee (Edge, sinon Chrome, sinon navigateur par defaut)
set "F=%~dp0ArmoireDesigner.html"
if not exist "%F%" (
  echo ArmoireDesigner.html est introuvable : placez-le dans le meme dossier que ce fichier.
  pause
  exit /b 1
)
set "E=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if exist "%E%" goto run
set "E=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if exist "%E%" goto run
set "E=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if exist "%E%" goto run
set "E=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if exist "%E%" goto run
start "" "%F%"
exit /b 0
:run
start "" "%E%" --start-maximized --app="file:///%F%"
exit /b 0
