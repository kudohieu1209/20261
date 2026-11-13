#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
for src in GK[0-6]_*.typ CK[1-5]_*.typ; do
  typst compile "$src" "${src%.typ}.pdf"
done
