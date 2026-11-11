#!/usr/bin/env bash
# Updates UniXNU-sheng and uefi-sheng to their latest commits and pins UniXNU to the
# revision that UniXNU-sheng's own packaging workflow uses, so the three stay compatible.
set -euo pipefail
cd "$(dirname "$0")/.."
git submodule update --init --remote UniXNU-sheng uefi-sheng
rev=$(sed -n 's/^ *ref: \([0-9a-f]\{40\}\).*/\1/p' UniXNU-sheng/.github/workflows/package.yml | head -1)
[[ -n $rev ]] || { echo "UniXNU revision not found in UniXNU-sheng/.github/workflows/package.yml" >&2; exit 1; }
git -C UniXNU fetch origin "$rev"
git -C UniXNU checkout --quiet "$rev"
git submodule update --init --recursive
echo "UniXNU pinned to $rev"
git status --short
