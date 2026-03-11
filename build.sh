#!/usr/bin/env bash

set -euo pipefail

# Simple CLI: support a single flag --wait which runs the build in the
# foreground and waits for it to finish. Default behaviour remains background.
WAIT=false
while [[ ${1:-} != "" ]]; do
    case "$1" in
        --wait)
            WAIT=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--wait]" >&2
            exit 2
            ;;
    esac
done

now=$(date +%Y%m%dT-%H%M%S%z)
build_dir=build/$now
mkdir -p "$build_dir"
cp main.tex "$build_dir/main.tex"

run_build() {
    tectonic "$build_dir/main.tex" --outdir="$build_dir" --keep-intermediates -Z search-path=./fonts
    cp "$build_dir/main.pdf" build/main.pdf
}

if [ "$WAIT" = true ]; then
    # Run in foreground, stream log to file AND stdout
    # Preserve the exit code of run_build when piping to tee
    run_build 2>&1 | tee "$build_dir/build.log"
    status=${PIPESTATUS[0]}
    echo "Build finished with exit code: $status"
    exit $status
else
    # Run in background and detach, print pid for convenience
    (
        run_build
    ) > "$build_dir/build.log" 2>&1 &
    pid=$!
    echo "Build started in background (pid: $pid). Log: $build_dir/build.log"
fi
