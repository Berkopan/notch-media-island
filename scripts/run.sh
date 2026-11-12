#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash scripts/build.sh
open "build/MacBook Island.app"
