# einwilligungserklaerung-e-mail-versand-jobcenter-enzkreis
Einwilligungserklärung E-Mail-Versand

## Projektüberblick
Dieses Projekt enthält eine LaTeX-Vorlage für eine Einwilligungserklärung zum E-Mail-Versand für das Jobcenter Enzkreis.

## Hauptdateien
- `main.tex`: Die zentrale LaTeX-Datei für das Formular.
- `build.sh`: Skript zum Bauen des PDFs aus der LaTeX-Datei.
- `flake.nix`: Nix-Flake für reproduzierbare Entwicklungsumgebung (TexLive, Texlab).

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
