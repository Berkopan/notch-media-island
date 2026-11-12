#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Never replace a running app or silently overwrite a different application.
if pgrep -x MacBookIsland >/dev/null; then
  echo "Önce menü çubuğundaki MacBook Island > Çıkış seçeneğini kullanın, sonra yeniden deneyin." >&2
  echo "Quit MacBook Island from its menu bar icon, then try again." >&2
  exit 1
fi
APPLICATIONS_DIR="${ISLAND_APPLICATIONS_DIR:-$HOME/Applications}"
DESTINATION="$APPLICATIONS_DIR/MacBook Island.app"
if [[ -e "$DESTINATION" ]]; then
  EXISTING_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DESTINATION/Contents/Info.plist" 2>/dev/null || true)"
  if [[ "$EXISTING_ID" != local.macbook-island.app ]]; then
    echo "Aynı isimde başka bir uygulama var; üzerine yazılmadı / A different app already exists at: $DESTINATION" >&2
    exit 1
  fi
fi
bash scripts/build.sh
mkdir -p "$APPLICATIONS_DIR"
STAGING="$(mktemp -d "$APPLICATIONS_DIR/.macbook-island.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
ditto "build/MacBook Island.app" "$STAGING/MacBook Island.app"
codesign --verify --deep --strict "$STAGING/MacBook Island.app"
if [[ -e "$DESTINATION" ]]; then mv "$DESTINATION" "$STAGING/Previous.app"; fi
if ! mv "$STAGING/MacBook Island.app" "$DESTINATION"; then
  if [[ -e "$STAGING/Previous.app" ]]; then mv "$STAGING/Previous.app" "$DESTINATION"; fi
  exit 1
fi
if [[ "${ISLAND_SKIP_OPEN:-0}" != 1 ]]; then open "$DESTINATION"; fi
echo "Kuruldu / Installed: $DESTINATION"
