# Armoire Designer — contexte pour Claude Code

Logiciel de conception d'armoires électriques, en français, pour Windows.

## Fichiers
- `ArmoireDesigner.html` : TOUTE l'application (≈285 Ko, HTML/CSS/JS dans un seul fichier, aucune dépendance externe).
- `Lancer_ArmoireDesigner.bat` : ouvre l'app dans Edge/Chrome en mode `--app --start-maximized`.
- `Installer_le_raccourci.vbs`, `ArmoireDesigner.ico`, `Armoire Designer.lnk` : raccourci bureau.
- `icone\` : sources de l'icône « plan technique » (SVG + scripts de rendu Edge headless → .ico, voir LISEZMOI.txt).
  DA « noir et bleu » : accent d'interface `#4d9fff`, bouton principal `#1f6feb`, gris bleutés (fond `#121a25`, en-tête `#0a0f17`).
  Le vert `#3dcd58`/`#2ecc71` est réservé aux états (OK, en marche, voyants, bornes raccordées) et aux dessins d'appareils.
  L'écran de démarrage (`#splash`) reprend ce style : armoire dessinée, portes qui s'ouvrent, équipements posés (~7,6 s).
- `rust\` : coquille Rust (tao + wry/WebView2) + Velopack. `build.ps1 -Version x.y.z [-UpdateUrl …]`
  copie `..\ArmoireDesigner.html` dans `rust\assets\`, compile et produit `Releases\ArmoireDesigner-win-Setup.exe`.
  Données utilisateur dans `%APPDATA%\Armoire Designer` (hors dossier d'installation Velopack).
  Version portable : même code compilé avec `ARMOIRE_PORTABLE=1` (`--target-dir target\portable`) →
  `Releases\ArmoireDesigner-Portable.exe`, données dans `.\ArmoireDesigner-donnees`, pas de mises à jour.
  `vpk pack` refuse une version déjà présente dans `Releases\` : augmenter `-Version`.
  CI : `.github\workflows\release.yml` (tag `v*.*.*` → Release GitHub via `vpk upload github`).
  `build.ps1` doit rester en UTF-8 **avec BOM** (Windows PowerShell 5.1).
  Compilé et empaqueté le 2026-11-21 : Rust 1.100 (rustup, MSVC), wry 0.47.2, tao 0.30.8, rfd 0.15.4, velopack 1.2.161
  (= version de l'outil `vpk`, à garder alignées ; `UpdateCheck::UpdateAvailable` contient un `Box<UpdateInfo>`).
  Sur ce PC, nuget.org n'est pas une source configurée : `dotnet tool … --add-source https://api.nuget.org/v3/index.json`.

## Architecture de ArmoireDesigner.html
- État global `S` = {enc, devs, wires, uid, opts, ducts, door, proj, cabs, cur, custom, prices, margin, links, note, sim},
  sauvegardé dans localStorage (`armoire`, `armoireLib`, `armoirePrices`, `armoireBak`, `armoireHelpSeen`, `armoireTab`).
- Catalogue `CAT`/`ALL` construit par `add(groupe,item)` ; kinds : gv2, gv2p, ic60, lc1d (P7 = 230 VAC, BD = 24 VDC),
  psu, cpu, io, ba, tb (borniers), custom, vfd (ATV320/630/650), dr (éléments de porte).
- Bornes : `terms(dev)` → {id,x,y,label} ; t# en haut, b# en bas, c# voies d'E/S/commande, p# réseau.
- Vues `viewMode` : '3d' (implantation), 'sch' (schéma multi-folios), 'door' (porte fermée), 'open' (porte ouverte).
- Fonctions utiles : `place(ref,{x,y})`, `rails()`, `nextTag`, `render()`, `fit()`, `setView()`, `modal(titre,html,boutons)`,
  `toast()`, `dl(nom,données,type)`, `esc`, `fN`, `runChecks`, `wireCalc`, `bomRows`.
- Modules : note de calcul (`noteModal`, `noteCalc`, `noteLoad`), câbles/thermique/prix, DXF, rapport HTML, révisions,
  aide (`HELP`, `showHelp`, `loadExample`).
- Simulation (onglet Simulation, dock `#simdock`) : `SIM` (état d'exécution), `simD()` = S.sim {tags, prog (blocs ladder),
  gr (GRAFCET steps/trs, transition `any:true` = depuis n'importe quelle étape), inst (objets process), strict}.
  `stations()` regroupe CPU + modules Siemens collés et attribue %I/%Q ; `bindings()` déduit du câblage quelles sorties
  pilotent quelles bobines/voyants ; `simStep()` = entrées → GRAFCET → ladder → sorties → physique (`instPhys`).
  Pupitre (`pupHtml`, `doorPress`) dans l'onglet Installation.
- Exemples : `simExample()` (cuve), `polyExample()` (préparation de polymère, projet type de l'aide).

## Méthode de travail
- Modifier par remplacements de chaînes exactes ; vérifier la syntaxe :
  extraire le plus long `<script>` et `node -e "new Function(src)"`.
- Tester dans un navigateur (l'écran de démarrage dure ~9 s) : aucune erreur console, captures d'écran.
- Garder une copie de sauvegarde avant chaque grosse modification.
- Répondre en français.
