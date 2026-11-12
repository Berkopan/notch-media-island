#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/check-requirements.sh
PREVIEW_BUILD="$PWD/.build/readme-preview"
mkdir -p "$PREVIEW_BUILD" docs/images
export CLANG_MODULE_CACHE_PATH="$PREVIEW_BUILD/clang-cache"
xcrun swiftc -emit-library -emit-module -module-name IslandCore \
  -module-cache-path "$PREVIEW_BUILD/module-cache" \
  Sources/IslandCore/*.swift -o "$PREVIEW_BUILD/libIslandCore.dylib" \
  -emit-module-path "$PREVIEW_BUILD/IslandCore.swiftmodule"
xcrun swiftc -parse-as-library -D README_PREVIEW \
  -module-cache-path "$PREVIEW_BUILD/module-cache" \
  -I "$PREVIEW_BUILD" -L "$PREVIEW_BUILD" -lIslandCore \
  -Xlinker -rpath -Xlinker "$PREVIEW_BUILD" \
  Sources/NotchMediaIsland/IslandView.swift Sources/NotchMediaIsland/MediaService.swift \
  scripts/ReadmePreview.swift -o "$PREVIEW_BUILD/render-preview"
"$PREVIEW_BUILD/render-preview" "$PWD/docs/images/preview.png"
