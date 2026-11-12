# Contributing

Use macOS 14+ and Swift 5.9+. Open Package.swift in Xcode for editing; use the scripts to build an app bundle with its media helper.

```sh
bash scripts/check-requirements.sh
swift test --disable-sandbox
bash -n Start.command
for script in scripts/*.sh; do bash -n "$script"; done
bash scripts/build.sh
git diff --check
```

Follow [the manual checklist](docs/TESTING.md) for UI/media changes. Keep PRs focused and describe behavior and validation. Never commit credentials, certificates, build products or personal listening data. Use fictional media in fixtures and screenshots.

Preserve vendor licenses and update THIRD_PARTY_NOTICES.md when updating the dependency. Original-code contributions use the project’s MIT license; vendor code retains BSD-3-Clause.
