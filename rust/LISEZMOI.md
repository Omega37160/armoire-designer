# Armoire Designer — version Rust + Velopack

L'application devient un vrai programme Windows (`ArmoireDesigner.exe`) :
- fenêtre native maximisée, icône, entrée dans le menu Démarrer ;
- l'interface (tout ArmoireDesigner.html) est intégrée dans l'exécutable et affichée par WebView2 ;
- les exports (DXF, CSV, rapport, projet) ouvrent la boîte « Enregistrer sous » de Windows ;
- installation et **mises à jour automatiques** avec Velopack.

## Prérequis (une seule fois)
1. Rust : https://rustup.rs (choisir les outils de compilation MSVC proposés par l'installateur).
2. SDK .NET 8 : https://dotnet.microsoft.com/download (pour l'outil `vpk` de Velopack).
3. WebView2 : déjà présent sur Windows 10 et 11.

## Créer l'installateur
Dans PowerShell, dans ce dossier :
```powershell
.\build.ps1 -Version 1.0.0
```
Résultat : `Releases\ArmoireDesigner-win-Setup.exe` (à distribuer).
Le script reprend automatiquement `..\ArmoireDesigner.html`, donc toute modification de l'application est intégrée.

`build.ps1` produit aussi `Releases\ArmoireDesigner-Portable.exe` : **version portable**, un seul fichier,
sans installation (clé USB, poste sans droits). Ses données sont rangées dans un dossier `ArmoireDesigner-donnees`
créé à côté de l'exe (ou dans `%APPDATA%\Armoire Designer` si ce dossier est en lecture seule). Pas de mises à jour automatiques.

## Mises à jour automatiques
1. Choisir un dossier web (serveur, partage HTTP, GitHub Releases…) et compiler avec son adresse :
   `.\build.ps1 -Version 1.0.0 -UpdateUrl https://mon-serveur/armoire`
2. Pour chaque nouvelle version : `.\build.ps1 -Version 1.0.1 -UpdateUrl …`, puis copier le contenu de `Releases\` dans ce dossier web
   (garder les anciens fichiers `.nupkg` permet des mises à jour différentielles plus légères).
3. Au lancement, l'application propose d'installer la nouvelle version et redémarre.

## Compilation sur GitHub
Le fichier `.github/workflows/release.yml` (à la racine du dépôt, ce dossier `rust\` étant un sous-dossier)
compile, empaquette et publie une Release GitHub à chaque tag `v1.0.1` (ou à la main via « Run workflow »).
L'adresse de mise à jour se règle dans la variable de dépôt `ARMOIRE_UPDATE_URL`, par exemple
`https://github.com/<compte>/<dépôt>/releases/latest/download` (dépôt public).

## Remarques
- Les projets enregistrés automatiquement dans l'ancienne version (navigateur Edge) ne sont pas repris :
  exportez-les en fichier depuis l'ancienne version, puis rouvrez-les dans la nouvelle.
- Programme installé par Velopack : `%LOCALAPPDATA%\ArmoireDesigner` (supprimé à la désinstallation).
- Données de l'application (projets enregistrés automatiquement, bibliothèque, prix) : `%APPDATA%\Armoire Designer`,
  conservées lors des mises à jour et de la désinstallation.
- Garder l'outil `vpk` à la même version que la crate `velopack` (actuellement 1.2.161, voir `Cargo.lock`).
