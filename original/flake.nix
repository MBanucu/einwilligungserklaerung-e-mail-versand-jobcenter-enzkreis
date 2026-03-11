{
  description = "Nix flake providing compress-jpgs script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.compress-jpgs = pkgs.writeShellScriptBin "compress-jpgs" ''
          #!/usr/bin/env bash
          set -euo pipefail

          SCALE=""
          while [ "$#" -gt 0 ]; do
              case "$1" in
                  --scale)
                      SCALE=true
                      shift
                      ;;
                  *)
                      echo "Unknown option: $1" >&2
                      echo "Usage: $0 [--scale]" >&2
                      exit 2
                      ;;
              esac
          done

          if [ "$SCALE" = true ]; then
              for factor in $(seq 1 9); do
                  percent=$((factor * 10))
                  folder=$(awk "BEGIN {printf \"%.1f\", $percent/100}")
                  echo "Scaling JPGs to $percent%..."
                  mkdir -p "$folder" && \
                  for file in *.jpg; do \
                      magick "$file" -resize "$percent%" "$folder/$file"; \
                  done
              done
          else
              for quality in $(seq 10 10 90); do
                  echo "Compressing JPGs to $quality% quality..."
                  mkdir -p "$quality" && \
                  for file in *.jpg; do \
                      magick "$file" -quality "$quality" "$quality/$file"; \
                  done
              done
          fi
        '';
      }
    );
}
