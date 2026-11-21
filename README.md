# Armoire Designer

Logiciel de conception d'armoires électriques, en français, pour Windows.

Implantation 3D des appareils sur rails DIN, schéma électrique multi-folios, porte (fermée / ouverte),
câblage, note de calcul, thermique, nomenclature et prix, exports DXF / CSV / rapport HTML,
et simulation (GRAFCET, ladder, pupitre, procédé).

## Utiliser

- **Installateur** : `ArmoireDesigner-win-Setup.exe` (onglet *Releases*) — installe l'application, crée les raccourcis.
- **Portable** : `ArmoireDesigner-Portable.exe` — un seul fichier, sans installation ; données dans `ArmoireDesigner-donnees\` à côté de l'exe.
- **Sans compilation** : ouvrir `ArmoireDesigner.html` dans Edge ou Chrome (ou `Lancer_ArmoireDesigner.bat`).

## Organisation

| Chemin | Contenu |
| --- | --- |
| `ArmoireDesigner.html` | Toute l'application (HTML/CSS/JS, sans dépendance externe) |
| `rust/` | Coquille Windows (tao + wry/WebView2) et empaquetage Velopack — voir `rust/LISEZMOI.md` |
| `icone/` | Sources de l'icône et scripts de génération du `.ico` |
| `.github/workflows/release.yml` | Compilation et publication d'une Release à chaque tag `v*.*.*` |

## Construire

Prérequis : Rust (MSVC), SDK .NET 8, outil `vpk` (Velopack).

```powershell
cd rust
.\build.ps1 -Version 1.0.3
```

Produit `rust\Releases\ArmoireDesigner-win-Setup.exe` et `rust\Releases\ArmoireDesigner-Portable.exe`.
