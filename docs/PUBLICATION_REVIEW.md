# Publication review

Review date: 2026-11-12. Scope: original source, vendored dependency, package contents, reachable Git history and locally stored Git objects. This is a source/provenance and disclosure review, not a guarantee of legal clearance or a comprehensive secret-detection service.

## License findings

| Component | License/status | Action |
| --- | --- | --- |
| Original app, tests, scripts and docs | MIT | Root LICENSE is included in source and app packages. |
| Vendored MediaRemote Adapter | BSD-3-Clause, pinned revision in THIRD_PARTY_NOTICES.md | Copyright, conditions and disclaimer retained. Full license shipped in source, app Resources and release ZIP. No endorsement claimed. |
| Apple system frameworks and SF Symbols | Used through system APIs; framework binaries and symbol assets are not copied into the repo | Do not add extracted Apple assets or framework binaries. |
| Music, album covers and credentials | Not distributed | Runtime metadata stays in memory; no recordings or real artwork in fixtures. |

No incompatible third-party license or source-distribution prohibition was identified in the included dependency. BSD-3-Clause permits source/binary redistribution subject to its retained notices and non-endorsement condition. Original MIT licensing does not replace the vendor's BSD license.

MediaRemote is a private Apple API. The vendored private API declarations are covered by the upstream repository's license; this review does not independently prove the provenance of every upstream declaration or resolve all Apple contractual/IP questions. App Store rule 2.5.1 requires public APIs, so this implementation is not App Store ready. That policy and macOS Gatekeeper/notarization are distinct from the open-source redistribution license review.

Sources: [upstream license at pinned revision](https://github.com/ungive/mediaremote-adapter/blob/14eed9389241d06e29f7326c19e9ebc6ec8a5f36/LICENSE), [BSD-3-Clause](https://opensource.org/license/bsd-3-clause), [App Store guidelines](https://developer.apple.com/app-store/review/guidelines/), [Apple distribution guidance](https://support.apple.com/en-us/102445).

## Privacy and Git history

The pre-preparation repository contained 10 commits, 54 blob objects and 47 tree objects. Every locally stored blob, commit and tag was inspected with targeted patterns, including objects beyond the latest checkout. No local account/host identifiers, absolute home paths, private keys, common GitHub/AWS token patterns, credential assignments or private IPv4 addresses were found. The only email was the generic project author placeholder; commit authors were not a personal identity. No credentials/certificates/environment files were tracked. No history rewrite was needed for those commits.

New publication files should be checked again before the initial push. Generic home-directory references such as `~/Applications` are portable instructions, not an actual account name. Public upstream copyright names are required attribution, not information about the maintainer's Mac.

Build folders, release ZIPs, logs, environment files and signing keys are ignored. Release builds remap project debug paths and strip executable debug information before signing. Local `.git/config`, reflogs and the filesystem path of the checkout are not sent by an ordinary push. Never share the entire working folder or `.git` directory as a public ZIP; publish tracked source or the packaged release artifacts.

Pattern scans cannot prove that arbitrary secrets never exist. Before future pushes, inspect new files and commit diffs; use a dedicated secret scanner for larger contributions. If a real secret is ever committed, revoke/rotate it and remove it from history before publishing, rather than only deleting it in a later commit.
