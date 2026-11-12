# MacBook Island

A quiet, black Now Playing panel that expands from your MacBook's notch when you hover over it. Built with SwiftUI and AppKit; designed for a 16-inch MacBook Pro and sized using the display's actual notch geometry.

## First version

- Hover to expand; move away to collapse after a short delay.
- Artwork, title, artist, play/pause, previous and next.
- Seekable progress bar with elapsed and remaining time.
- System-wide active Now Playing session, including apps and browsers that publish media metadata to macOS.
- Empty state, connection errors, reconnect action, display changes and sleep/wake handling.
- Menu bar controls to hide/show the island or quit. No Dock icon.
- Respects Reduce Motion. Controls have accessibility labels. The initial interface is Turkish.

## Build and run

Requires macOS 14 or newer and Xcode 15 or newer (or matching Swift/Apple command line tools). No Homebrew packages, network downloads, API keys, or third-party Swift dependencies are required.

```sh
bash scripts/run.sh
```

This builds and opens `build/MacBook Island.app`. To build without launching:

```sh
bash scripts/build.sh
```

You can copy the resulting app into Applications yourself. The app is signed locally with an ad-hoc signature, not notarized for public binary distribution. The build targets the current Mac's architecture. Open `Package.swift` in Xcode for editing; use the build script for a runnable app bundle, since the media helper must be bundled alongside the executable.

```sh
swift test --disable-sandbox
```

## How media integration works

The app observes macOS's **active Now Playing session** via the private MediaRemote framework, using the bundled [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter). Starting with macOS 15.4, direct access from ordinary applications is restricted. The adapter runs inside the system Perl process and streams JSON updates to this app. Playback commands and seeks use that same adapter; there are no Spotify/Apple Music-specific integrations or AppleScript automation permissions.

This is not a system audio recorder. It cannot identify audio that the originating app does not publish to Now Playing. It shows the system-selected active session, **not a list of every simultaneously playing app**. Metadata and command support depend on the player. A known duration and position enable seeking; some players may still ignore seek or skip requests. Live/unknown-duration media has no seek control. Apple's private API can change with macOS updates, so this app is intended for local use and is not an App Store build.

The app makes no network requests and does not log listening history. Artwork and media metadata stay in memory. No microphone, screen-recording or Accessibility permission is requested.

## Layout and behavior

The notched display is preferred; when unavailable, a compact island sits at the top center of the main display. Content stays below the physical camera housing. The overlay joins Spaces and full-screen apps. Transparent margins pass clicks through. The app does not launch at login automatically.

## Source layout

- `Sources/IslandCore`: metadata decoding, timeline math and streaming buffer.
- `Sources/MacBookIsland`: menu bar lifecycle, overlay, playback UI and helper management.
- `Vendor/MediaRemoteAdapter`: pinned upstream Objective-C/Perl source and BSD license.
- `scripts`: offline build and launch scripts.
- `Tests`: timing, streaming and metadata regression checks.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the dependency provenance and [docs/TESTING.md](docs/TESTING.md) for manual checks.
