{
  description = "Nix flake providing compress-jpgs script";

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
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.compress-jpgs = pkgs.writeShellApplication {
          name = "compress-jpgs";
          runtimeInputs = [ pkgs.bc pkgs.imagemagick pkgs.coreutils ];
          text = ''
            #!/usr/bin/env bash
            set -euo pipefail

            scale_images() {
                local search_dir="$1"
                local run_quality="$2"
                local scale_root="$search_dir/scale"
                mkdir -p "$scale_root"
                for percent in $(seq 10 10 100); do
                    local folder="$scale_root/$percent"
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
                local search_dir="$1"
                local quality_root="$search_dir/quality"
                mkdir -p "$quality_root"
                for percent in $(seq 10 10 100); do
                    local folder="$quality_root/$percent"
                    echo "Compressing JPGs to $percent% quality in $quality_root..."
                    mkdir -p "$folder" && \
                    for file in "$search_dir"/*.jpg; do \
                        [ -e "$file" ] || continue
                        magick "$file" -quality "$percent" "$folder/$(basename "$file")"; \
                    done
                done
            }

            size_images() {
                local search_dir="$1"
                local target_size="$2"
                local size_root="$search_dir/size"
                local log_file="$size_root/size_images.log"
                mkdir -p "$size_root"
                echo "filename,resize,quality,size,entropy" > "$log_file"
                for file in "$search_dir"/*.jpg; do
                    local best_entropy=0
                    local best_resize=100
                    local best_quality=100
                    local best_file=""
                    for resize in $(seq 100 -20 20); do
                        for quality in $(seq 100 -20 20); do
                            local out
                            local actual_size
                            out="''${size_root}/$(basename "$file")_''${resize}_''${quality}.jpg"
                            magick "$file" -resize "''${resize}%" -quality "$quality" "$out"
                            actual_size=$(stat -c%s "$out")
                            local entropy=""
                            if [ "$actual_size" -le "$target_size" ]; then
                                entropy=$(magick "$out" -format "%[entropy]" info:)
                            else
                                entropy=""
                            fi
                            echo "$(basename "$file"),$resize,$quality,$actual_size,$entropy" >> "$log_file"
                            echo "size of $out: $actual_size bytes (target: $target_size bytes)"
                            if [ "$actual_size" -le "$target_size" ] && [ -n "$entropy" ]; then
                                if (( $(echo "$entropy > $best_entropy" | bc -l) )); then
                                    best_entropy=$entropy
                                    best_resize=$resize
                                    best_quality=$quality
                                    best_file="$out"
                                fi
                            fi
                            rm -f "$out"
                        done
                    done
                    if [ -n "$best_file" ]; then
                        magick "$file" -resize "''${best_resize}%" -quality "''${best_quality}" "$size_root/$(basename "$file")"
                        echo "Best for $(basename "$file"): resize=$best_resize quality=$best_quality entropy=$best_entropy"
                    else
                        echo "No suitable version found for $(basename "$file")"
                    fi
                done
            }

            SCALE=""
            QUALITY=""
            SIZE=""
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
                    --size)
                        SIZE="$2"
                        shift 2
                        ;;
                    --dir)
                        DIR="$2"
                        shift 2
                        ;;
                    *)
                        echo "Unknown option: $1" >&2
                        echo "Usage: $0 [--scale] [--quality] [--size BYTES] [--dir DIR]" >&2
                        exit 2
                        ;;
                esac
            done

            if [ -n "$SIZE" ]; then
                size_images "$DIR" "$SIZE"
            elif [ "$SCALE" = true ] && [ "$QUALITY" = true ]; then
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
        };
      }
    );
}
