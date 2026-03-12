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
- `docs/`: Dokumentation und PDF-Viewer (für GitHub Pages)

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

## PDF-Viewer (GitHub Pages)
Dieses Repository enthält einen PDF-Viewer basierend auf Mozilla's PDF.js, der über GitHub Pages verfügbar gemacht wird.

Um den Viewer zu nutzen:
1. Stelle sicher, dass `main.pdf` im `docs/` Verzeichnis vorhanden ist
2. Aktiviere GitHub Pages in den Repository-Einstellungen:
   - Branch: `main`
   - Folder: `/docs (root)`
3. Der Viewer ist dann verfügbar unter: `https://<username>.github.io/<repository>/`

Der Viewer wird automatisch über GitHub Actions gebaut und deployed (siehe unten).

## Abhängigkeiten
Die Umgebung wird über Nix bereitgestellt und enthält:
- TexLive (LaTeX-Pakete: fontspec, tabularray, microtype, hyperref, babel-german, etc.)
- Texlab (LSP für LaTeX)
- Zathura (PDF-Viewer)
- entr (Dateiüberwachung)

## GitHub Actions Workflow
Das Repository verwendet GitHub Actions für automatisierte Builds und Releases:

- **Build & Release Workflow** (`.github/workflows/release.yml`):
  - Wird bei Tag-Pushes (v*) oder manueller Ausführung getriggert
  - Verwendet Nix für reproduzierbare Builds (basierend auf `flake.nix`)
  - Baut das PDF mit `./build.sh --wait`
  - Kopiert das PDF nach `docs/main.pdf` für den Viewer
  - Erstellt GitHub-Releases mit dem PDF als Asset (bei Tag-Pushes)

### Lokaler Build mit Nix
```bash
# Entwicklungsumgebung starten
nix develop

# PDF bauen
./build.sh --wait

# Für automatischen Wiederbau bei Änderungen:
echo main.tex | entr -s './build.sh'
```

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

## PDF aktualisieren
Um das PDF zu aktualisieren und eine neue Version zu veröffentlichen:

1. Lokal bauen: `./build.sh --wait`
2. Das release.sh Skript ausführen:
   ```bash
   ./release.sh
   ```
   Dies führt dich durch:
   - Wahl der Versionerhöhung (patch/minor/major)
   - Bestätigung der neuen Version
   - Automatisches Kopieren des PDFs nach `docs/`
   - Commit mit Nachricht "docs: update PDF to X.Y.Z"
   - Erstellung eines Git-Tags

3. Änderungen pushen:
   ```bash
   git push && git push --tags
   ```
   Dies triggert den GitHub Actions Workflow, der:
   - Das PDF neu baut (für Konsistenz)
   - Es in den Release-Assets hochlädt

Wenn du möchtest, kann ich eine kurze Beispielausgabe oder einen kleinen
Testlauf ins Repo legen (derzeit führe ich Tests lokal ohne Commit aus).
