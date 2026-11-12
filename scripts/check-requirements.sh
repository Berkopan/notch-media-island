#!/bin/bash
set -euo pipefail
if [[ "$(uname -s)" != Darwin ]]; then
  echo "MacBook Island yalnızca macOS'ta çalışır / requires macOS." >&2
  exit 1
fi
MAJOR_OS="$(sw_vers -productVersion | cut -d. -f1)"
if (( MAJOR_OS < 14 )); then
  echo "macOS 14 Sonoma veya daha yenisi gerekli / macOS 14 or newer required." >&2
  exit 1
fi
if ! xcode-select -p >/dev/null 2>&1 || ! xcrun --find swift >/dev/null 2>&1; then
  echo "Apple Command Line Tools eksik / Apple Command Line Tools are missing."
  echo "Kurulum için / To install: xcode-select --install"
  echo "Kurulum tamamlanınca Start.command dosyasını yeniden açın / Reopen Start.command after installation."
  exit 2
fi
if ! SWIFT_VERSION="$(xcrun swift --version 2>&1)"; then
  echo "$SWIFT_VERSION" >&2
  echo "Xcode'u bir kez açıp ilk kurulumu tamamlayın / Open Xcode and complete first-time setup." >&2
  exit 1
fi
SWIFT_NUMBER="$(echo "$SWIFT_VERSION" | sed -nE 's/.*Swift version ([0-9]+\.[0-9]+).*/\1/p' | head -1)"
SWIFT_MAJOR="${SWIFT_NUMBER%%.*}"
SWIFT_MINOR="${SWIFT_NUMBER#*.}"
if [[ -z "$SWIFT_NUMBER" ]] || (( SWIFT_MAJOR < 5 || (SWIFT_MAJOR == 5 && SWIFT_MINOR < 9) )); then
  echo "Swift 5.9+ gerekli. Apple geliştirme araçlarını güncelleyin / Update Apple's developer tools (Swift 5.9+)." >&2
  exit 1
fi
if ! /usr/bin/perl -MDynaLoader -e 'exit 0' 2>/dev/null; then
  echo "Sistem Perl bileşeni bulunamadı / The system Perl runtime is unavailable." >&2
  exit 1
fi
echo "Gereksinimler hazır / Requirements OK ($(uname -m), macOS $(sw_vers -productVersion))."
