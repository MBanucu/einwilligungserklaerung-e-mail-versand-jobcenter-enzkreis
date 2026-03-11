{
  description = "LaTeX-Entwicklungsumgebung mit Tectonic (modernes TeX)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "latex-tectonic-shell";

          packages = with pkgs; [
            tectonic # der Star: selbstständiges LaTeX → tectonic main.tex
            texlab # LSP-Server → gut für neovim, helix, vscode + latex-workshop

            # Hilfreiche Tools
            zathura # leichter PDF-Viewer mit SyncTeX-Unterstützung
            # okular               # alternativer Viewer mit mehr Features
            graphviz # falls du dot-Grafiken in LaTeX einbindest

            # file watcher
            entr

            bashInteractive
          ];

          shellHook = ''
            echo "Tectonic-LaTeX-Umgebung geladen"
            echo "  → tectonic main.tex          (einmalig kompilieren + Abhängigkeiten holen)"
            echo "  → tectonic --watch main.tex   (live watch + rebuild)"
            echo "  → ./build.sh                  (PDF + JPGs bauen)"
            echo "  → echo main.tex | entr -s './build.sh'  (auto-rebuild bei Änderungen)"
            echo ""
            echo "Tipp für VSCode / Neovim:"
            echo "  Stelle latex-workshop oder texlab auf tectonic ein"
          '';
        };
      }
    );
}
