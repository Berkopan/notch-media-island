# Third-party notices

Original Notch Media Island code is MIT licensed (see the root LICENSE). The dependency below retains its own BSD-3-Clause license; it is not relicensed under MIT.

## MediaRemote Adapter

- Source: https://github.com/ungive/mediaremote-adapter
- Pinned commit: `14eed9389241d06e29f7326c19e9ebc6ec8a5f36`
- Copyright (c) 2025 Jonas van den Berg and contributors
- License: BSD 3-Clause, reproduced in [Vendor/MediaRemoteAdapter/LICENSE](Vendor/MediaRemoteAdapter/LICENSE).

The `src`, `include`, and `bin` directories are vendored without modification. The application build script compiles the helper framework directly with Apple's Clang rather than requiring upstream's CMake build. The upstream test client source is retained but is not shipped in the application. The license is also included in the built app's Resources directory.
