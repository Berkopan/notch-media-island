#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/build.sh
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
ARCH="$(uname -m)"
NAME="MacBook-Island-${VERSION}-${ARCH}"
mkdir -p dist
STAGING="$(mktemp -d "$PWD/build/package.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
mkdir -p "$STAGING/$NAME"
ditto "build/MacBook Island.app" "$STAGING/$NAME/MacBook Island.app"
cp LICENSE THIRD_PARTY_NOTICES.md docs/INSTALL_RELEASE.txt "$STAGING/$NAME/"
cp Vendor/MediaRemoteAdapter/LICENSE "$STAGING/$NAME/MediaRemoteAdapter-LICENSE.txt"
ditto -c -k --sequesterRsrc --keepParent "$STAGING/$NAME" "dist/$NAME.zip"
(cd dist && shasum -a 256 "$NAME.zip" > "$NAME.zip.sha256")
echo "Release package: dist/$NAME.zip (local ad-hoc signature; not notarized)"
