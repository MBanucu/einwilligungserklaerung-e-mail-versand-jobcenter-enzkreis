#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: recreate_tag.sh [--push] [--dry-run]

Find the latest git tag (most recent annotated/ lightweight tag),
recreate that tag locally to point to HEAD, and optionally push the
updated tag to origin (force-update).

Options:
  --push      Push the recreated tag to origin with --force (destructive)
  --dry-run   Print the commands that would be run and exit (default)
  --yes       Don't prompt for confirmation when pushing
  -h,--help   Show this help

Notes:
  - Recreating a tag updates the tag reference to point at the current
    HEAD. Pushing the tag with --force will overwrite the remote tag.
    This can be destructive for collaborators. Use --push only when
    you're sure.
EOF
}

PUSH=false
DRY_RUN=true
FORCE_CONFIRM=false

while [[ ${1:-} != "" ]]; do
  case "$1" in
    --push) PUSH=true; DRY_RUN=false; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --yes) FORCE_CONFIRM=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

# Find latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
if [[ -z "$latest_tag" ]]; then
  echo "No tags found in repository." >&2
  exit 1
fi

echo "Latest tag: $latest_tag"
echo "Current HEAD: $(git rev-parse --short HEAD)"

cmds=(
  "git tag -f $latest_tag HEAD"
)

if [ "$PUSH" = true ]; then
  cmds+=("git push --force origin $latest_tag")
fi

echo ""
echo "Planned actions:"
for c in "${cmds[@]}"; do
  echo "  $c"
done

if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "Dry run: no changes made. Re-run with --push to apply (or --dry-run to see only)."
  exit 0
fi

if [ "$PUSH" = true ] && [ "$FORCE_CONFIRM" = false ]; then
  read -p "About to force-update remote tag '$latest_tag'. Continue? (y/N): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted by user."; exit 0
  fi
fi

echo "Executing..."
for c in "${cmds[@]}"; do
  echo "+ $c"
  eval "$c"
done

echo "Done. Latest tag '$latest_tag' now points to HEAD: $(git rev-parse --short HEAD)"
if [ "$PUSH" = true ]; then
  echo "Remote tag '$latest_tag' was force-updated on origin. Run 'git fetch --tags' for others."
fi
