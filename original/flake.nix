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

          scale_images() {
              search_dir="$1"
              for factor in $(seq 1 9); do
                  percent=$((factor * 10))
                  folder=$(awk "BEGIN {printf \"%.1f\", $percent/100}")
                  echo "Scaling JPGs to $percent% in $search_dir..."
                  mkdir -p "$folder" && \
                  for file in "$search_dir"/*.jpg; do \
                      [ -e "$file" ] || continue
                      magick "$file" -resize "$percent%" "$folder/$(basename "$file")"; \
                  done
              done
          }

          quality_images() {
              search_dir="$1"
              for quality in $(seq 10 10 90); do
                  echo "Compressing JPGs to $quality% quality in $search_dir..."
                  mkdir -p "$quality" && \
                  for file in "$search_dir"/*.jpg; do \
                      [ -e "$file" ] || continue
                      magick "$file" -quality "$quality" "$quality/$(basename "$file")"; \
                  done
              done
          }

          SCALE=""
          QUALITY=""
          DIR="."
          while [ "$#" -gt 0 ]; do
              case "$1" in
                  --scale)
                      SCALE=true
                      shift
                      ;;
                  --quality)
                      QUALITY=true
                      shift
                      ;;
                  --dir)
                      DIR="$2"
                      shift 2
                      ;;
                  *)
                      echo "Unknown option: $1" >&2
                      echo "Usage: $0 [--scale] [--quality] [--dir DIR]" >&2
                      exit 2
                      ;;
              esac
          done

          if [ "$SCALE" = true ]; then
              scale_images "$DIR"
          elif [ "$QUALITY" = true ]; then
              quality_images "$DIR"
          else
              echo "No option given. Nothing to do."
              exit 0
          fi
        '';
      }
    );
}
