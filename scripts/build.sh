#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
APP="$ROOT/build/MacBook Island.app"
FRAMEWORK="$APP/Contents/Frameworks/MediaRemoteAdapter.framework"
export CLANG_MODULE_CACHE_PATH="$ROOT/.build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$ROOT/.build/module-cache"
swift build -c release --disable-sandbox
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$FRAMEWORK/Versions/A/Resources"
cp .build/release/MacBookIsland "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Vendor/MediaRemoteAdapter/bin/mediaremote-adapter.pl "$APP/Contents/Resources/"
cp Vendor/MediaRemoteAdapter/LICENSE "$APP/Contents/Resources/MediaRemoteAdapter-LICENSE"
SOURCES=()
while IFS= read -r file; do SOURCES+=("$file"); done < <(find Vendor/MediaRemoteAdapter/src -name '*.m' ! -path '*/test/*' | sort)
xcrun clang -dynamiclib -fobjc-arc -fvisibility=default -mmacosx-version-min=14.0 \
  -I Vendor/MediaRemoteAdapter/include -I Vendor/MediaRemoteAdapter/src \
  -framework Foundation -framework AppKit -framework UniformTypeIdentifiers \
  -install_name '@rpath/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter' \
  "${SOURCES[@]}" -o "$FRAMEWORK/Versions/A/MediaRemoteAdapter"
cat > "$FRAMEWORK/Versions/A/Resources/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.vandenbe.MediaRemoteAdapter</string>
<key>CFBundleExecutable</key><string>MediaRemoteAdapter</string>
<key>CFBundlePackageType</key><string>FMWK</string>
<key>CFBundleVersion</key><string>0.1.0</string>
</dict></plist>
PLIST
ln -sfn A "$FRAMEWORK/Versions/Current"
ln -sfn Versions/Current/MediaRemoteAdapter "$FRAMEWORK/MediaRemoteAdapter"
ln -sfn Versions/Current/Resources "$FRAMEWORK/Resources"
codesign --force --sign - "$FRAMEWORK"
codesign --force --sign - "$APP"
echo "Built: $APP"
