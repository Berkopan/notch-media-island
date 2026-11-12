# Publishing the repository and app

Preparation does not create a GitHub repo, remote, tag or release.

## First push

1. Create an **empty public repository** on GitHub. Do not generate a README, gitignore or license there; they already exist here.
2. Copy its URL. In the project terminal run `git remote add origin YOUR_REPOSITORY_URL` (replace the placeholder), then `git push -u origin main`.
3. Check **Actions → Build and test**. CI tests and packages on `macos-15` (Apple Silicon) and `macos-15-intel`. It needs no secrets and has read-only repository permissions.
4. Wait for both jobs. A workflow file alone is not evidence that CI ran; hardware/media testing is separate.

## Downloadable packages

Run `bash scripts/package.sh` to produce `dist/MacBook-Island-VERSION-ARCH.zip` and a SHA-256 file for the current architecture. Packages include the app, both licenses, third-party notices and install instructions. Signatures are checked during the build.

For both architectures, download the two artifacts from a successful Actions run on the exact release commit. Extract the outer Actions ZIP and use the inner app ZIP/checksum. Artifacts expire after 14 days; publish durable downloads as Release assets.

## Draft release

1. Complete docs/TESTING.md on a real Mac, including installation from a freshly extracted ZIP. CI has no real music session/notch.
2. In **Releases → Draft a new release**, create a version tag such as `v0.1.0` targeting the tested commit. Match `CFBundleShortVersionString` in Resources/Info.plist.
3. Attach the inner app ZIPs and checksums. Include requirements, architecture labels, Turkish UI, player limitations and private API dependency.
4. Clearly disclose that packages are ad-hoc signed and **not notarized**. Do not label them Apple verified or App Store ready.
5. Save a draft, review it, then publish when ready.

For a new version, update both version keys in Resources/Info.plist, commit and repeat. Never add dist/ or app bundles to Git.

## Public binary signing

Developer ID signing and notarization are separate follow-up work requiring the maintainer’s Apple Developer setup. They are not configured here. Do not commit certificates or credentials. Compatibility of notarization with this helper/private API architecture must be verified before promising warning-free downloads.

Sources: [Apple app safety](https://support.apple.com/en-us/102445), [GitHub runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [artifacts](https://docs.github.com/en/actions/tutorials/store-and-share-data).
