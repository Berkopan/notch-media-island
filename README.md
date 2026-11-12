# MacBook Island

A compact black media player that expands from your MacBook’s notch on hover. Native SwiftUI/AppKit, with system Now Playing integration.

**[Türkçe kurulum](docs/GETTING_STARTED.tr.md)** · **[English setup](docs/GETTING_STARTED.md)**

## Start without writing code

1. Clone the repository, or choose **Code → Download ZIP** on GitHub and unzip it.
2. Double-click **Start.command** in the project folder.
3. If Apple’s developer tools are missing, the launcher offers to open Apple’s installer. Finish that installation, then reopen **Start.command**.
4. Wait for the first build. The app installs into **Applications inside your home folder** and opens. Hover over the notch.

For later launches, open **MacBook Island.app** from your home folder’s Applications folder. There is no need to rebuild each time. The launcher uses Terminal to show progress, but requires no code or commands. If macOS blocks it, see the setup guide.

Requires **macOS 14 Sonoma or newer**. Building from source requires Apple Command Line Tools with **Swift 5.9+**, or Xcode 15+. Apple Silicon has been tested locally; CI is configured for Apple Silicon and Intel, but Intel playback still needs on-device verification.

### Ready-made app

Once a release is published, use this repository’s **Releases** section: download `arm64` for Apple M-series or `x86_64` for Intel. Unzip, drag **MacBook Island.app** into Applications, then open. No developer tools needed. If Releases is empty, use the source setup above.

Current packages are **ad-hoc signed, not Developer ID signed or notarized**. macOS may block a downloaded app. Review [Apple’s safety guidance](https://support.apple.com/en-us/102445) and the setup guide before deciding whether to open it.

## Features

- Hover to expand; delayed collapse when the pointer leaves.
- Artwork, title, artist, native playback controls and draggable timeline.
- Immediate seek feedback and pause/resume synchronization.
- Follows macOS’s active Now Playing session across compatible apps and browsers.
- Menu bar hide/show, reconnect and quit; no Dock icon.
- Handles display changes and sleep/wake; respects Reduce Motion.

The interface is currently Turkish. This shows the **active system media session**, not every simultaneous audio source. Sources must publish Now Playing information; metadata, seek and skip support depend on the player. Live/unknown-duration media cannot be scrubbed. The app does not record audio, request microphone/screen-recording/Accessibility access, send telemetry or store listening history. It does not start at login automatically.

## Developer commands

```sh
bash scripts/check-requirements.sh
bash scripts/run.sh                 # Build and launch from build/
bash scripts/install.sh             # Install into ~/Applications and launch
swift test --disable-sandbox
bash scripts/package.sh             # ZIP + SHA-256 under dist/
```

Quit before installing an update. Open `Package.swift` in Xcode for editing; use the scripts for a runnable bundle with the media helper. No Homebrew, API keys or external Swift dependencies are needed. Local builds need no network downloads once Apple’s tools are installed.

## License and distribution

Original project code: [MIT](LICENSE). Bundled [MediaRemote Adapter](https://github.com/ungive/mediaremote-adapter): **BSD-3-Clause**, with notices preserved in source and app packages. See [third-party notices](THIRD_PARTY_NOTICES.md) and [publication review](docs/PUBLICATION_REVIEW.md).

The adapter uses Apple’s **private MediaRemote API** through the system Perl process to support macOS 15.4+. Apple may change it; this implementation is not suitable for the Mac App Store’s public-API requirement. This is an independent project, not affiliated with Apple or endorsed by the adapter’s authors. No Apple framework binaries, album artwork or recordings are redistributed.

[Testing](docs/TESTING.md) · [Contributing](CONTRIBUTING.md) · [Publishing](docs/RELEASING.md)
