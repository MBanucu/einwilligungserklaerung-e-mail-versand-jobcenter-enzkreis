{
  description = "basic texlive dev shell with tectonic and texlab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
        myTex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-basic
            latex-lab
            l3backend
            pdfmanagement-testphase
            tagpdf
            fontspec
            xetex
            tabularray
            microtype
            babel-german
            hyphen-german
            hyperref
            ;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "texlive-shell";

          packages = with pkgs; [
            myTex
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
            echo "  → ./build.sh                  (PDF + JPGs bauen)"
            echo "  → echo main.tex | entr -s './build.sh'  (auto-rebuild bei Änderungen)"
          '';
        };
      }
    );
}
