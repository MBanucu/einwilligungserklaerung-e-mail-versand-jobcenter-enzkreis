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
              run_quality="$2"
              scale_root="$search_dir/scale"
              mkdir -p "$scale_root"
              for percent in $(seq 10 10 100); do
                  folder="$scale_root/$(awk 'BEGIN {printf "%.1f", '"$percent"'/100}')"
                  echo "Scaling JPGs to $percent% in $scale_root..."
                  mkdir -p "$folder" && \
                  for file in "$search_dir"/*.jpg; do \
                      [ -e "$file" ] || continue
                      magick "$file" -resize "$percent%" "$folder/$(basename "$file")"; \
                  done
                  if [ "$run_quality" = true ]; then
                      quality_images "$folder"
                  fi
              done
          }

          quality_images() {
              search_dir="$1"
              quality_root="$search_dir/quality"
              mkdir -p "$quality_root"
              for percent in $(seq 10 10 100); do
                  folder="$quality_root/$percent"
                  echo "Compressing JPGs to $percent% quality in $quality_root..."
                  mkdir -p "$folder" && \
                  for file in "$search_dir"/*.jpg; do \
                      [ -e "$file" ] || continue
                      magick "$file" -quality "$percent" "$folder/$(basename "$file")"; \
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

          if [ "$SCALE" = true ] && [ "$QUALITY" = true ]; then
              scale_images "$DIR" true
          elif [ "$SCALE" = true ]; then
              scale_images "$DIR" false
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
