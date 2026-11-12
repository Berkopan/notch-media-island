# Getting started

No coding required. macOS 14 Sonoma or newer is required.

## Ready-made app (when released)

1. Open this repository’s **Releases** section. If empty, use the source instructions below.
2. Check Apple menu → **About This Mac**: download `arm64` for Apple M-series, `x86_64` for Intel.
3. Unzip and drag **Notch Media Island.app** into Applications. Open it and hover over the notch.

No Xcode is needed for a prebuilt app. Current packages are ad-hoc signed and not notarized; see the security section.

## From a clone or source ZIP

1. Clone the repo, or choose **Code → Download ZIP** and unzip it.
2. Double-click **Start.command**. Terminal shows progress; you do not need to type commands.
3. If Apple’s free Command Line Tools are missing, type `y` and Return to open Apple’s installer. Finish installation, then reopen **Start.command**. Apple’s installer needs internet access, disk space and possibly administrator authorization.
4. Wait for the first build. The app installs into **Applications inside your home folder** and opens. Press Return to close the launcher after completion.

Next time use Finder → **Go → Home → Applications → Notch Media Island.app**. This personal Applications folder differs from the system folder; installing the app itself needs no administrator privileges. You do not need to rebuild each time.

## macOS security messages

A downloaded app or Start.command may be blocked because current packages are **not Developer ID signed or notarized**. Verify the source before deciding whether to open it, and follow [Apple’s official guidance](https://support.apple.com/en-us/102445). After attempting to open it, **System Settings → Privacy & Security → Open Anyway** may be available for the specific item. Managed Macs may restrict this. Do not override malware warnings.

Scripts do not disable Gatekeeper, remove quarantine attributes or change system security settings.

## Troubleshooting

- Launcher opens as text: right-click → Open With → Terminal.
- Execute permission missing: type `bash ` (including the space) in Terminal, drag Start.command onto the window, then press Return.
- Tools missing: finish Apple’s installation and reopen the launcher. If Xcode requests first-time setup or license acceptance, open Xcode and complete its instructions.
- Already running: choose **Çıkış** (Quit) from the waveform menu bar icon and retry.
- No track: check macOS Now Playing first; not all sources publish metadata.
- Disconnected: choose **Medya bağlantısını yenile** (Reconnect).
- Failure after a macOS update: the private API may have changed; report your macOS version in an issue.

The interface is Turkish. **Adayı gizle / göster** = Hide/show, **Oynat** = Play, **Duraklat** = Pause. No Dock icon or automatic launch at login is expected.

## Update/remove

Download/pull new source, quit and run Start.command again. For a binary update, quit and replace the app. To uninstall, quit and move the installed app to Trash. Remove the source folder separately if desired; music files are unaffected.
