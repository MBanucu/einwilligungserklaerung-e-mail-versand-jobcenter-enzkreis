# einwilligungserklaerung-e-mail-versand-jobcenter-enzkreis
Einwilligungserklärung E-Mail-Versand

## Projektüberblick
Dieses Projekt enthält eine LaTeX-Vorlage für eine Einwilligungserklärung zum E-Mail-Versand für das Jobcenter Enzkreis.

## Hauptdateien
- `main.tex`: Die zentrale LaTeX-Datei für das Formular.
- `build.sh`: Skript zum Bauen des PDFs aus der LaTeX-Datei.
 - `flake.nix`: Nix-Flake für reproduzierbare Entwicklungsumgebung (TexLive, Texlab).
 - `original/flake.nix`: zusätzliche Nix-Flake, die ein kleines Hilfsskript
   `compress-jpgs` bereitstellt (siehe unten).

## Bauen des Dokuments
1. Stelle sicher, dass Nix installiert ist.
2. Starte die Entwicklungsumgebung:
	```
	nix develop
	```
3. Baue das PDF:
	```
	./build.sh
	```
	Das PDF wird als `main.pdf` im Projektverzeichnis abgelegt.

## Abhängigkeiten
Die Umgebung wird über Nix bereitgestellt und enthält:
- TexLive (LaTeX-Pakete: fontspec, tabularray, microtype, hyperref, babel-german, etc.)
- Texlab (LSP für LaTeX)
- Zathura (PDF-Viewer)
- entr (Dateiüberwachung)

## Lizenz
Dieses Projekt steht unter der [GNU GPLv3](LICENSE).

## Bildkompression / Hilfsskript
Die Flake unter `original/` stellt ein kleines Hilfsskript `compress-jpgs`
zur Verfügung, das JPG-Dateien skaliert und/oder in unterschiedlichen
Qualitätsstufen neu schreibt. Kurzinfo:

- Ausführen (lokal, Nix nötig):
  - `nix run ./original#compress-jpgs -- --quality --dir original`
  - `nix run ./original#compress-jpgs -- --scale --dir original`
  - beide Flags kombinierbar: `--scale --quality`
- Verhalten: das Skript erzeugt Ausgabeverzeichnisse unterhalb des
  angegebenen `--dir` (z.B. `original/scale/10/quality/`) — Originalbilder
  werden nicht überschrieben.
- Hinweise: `original/**/*.jpg` ist in `.gitignore` eingetragen, damit
  generierte Bilder nicht versehentlich in Git landen.

Wenn du möchtest, kann ich eine kurze Beispielausgabe oder einen kleinen
Testlauf ins Repo legen (derzeit führe ich Tests lokal ohne Commit aus).
