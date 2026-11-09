# PharmTrack — the Skip implementation (v0.0.19)

This is the **"before"** half of a cross-platform migration study.

PharmTrack is a medication, appointment, consultation and vital-sign tracker for iOS
and Android. This repository holds the shipping **v0.0.19** app, built with
[Skip](https://skip.dev): one Swift codebase, transpiled to Kotlin by
`skipstone`, so both platforms share their source.

That shared runtime is exactly what the successor rewrite removes. The rewrite —
two independent implementations (Swift and Kotlin) with no shared code, held
together by a frozen behavior contract and a CI parity gate — lives in a
separate repository:
[`kairon007/pharmtrack-reflex`](https://github.com/kairon007/pharmtrack-reflex).

```
this repo (skip)            successor repo (reflex)
────────────────────         ───────────────────────────
Sources/                    specs/     the frozen behavior contract
Tests/                      ios/       Swift core + SwiftUI app
Package.swift               android/   Kotlin core + Compose app
Darwin/                     tools/     parity gate + validators
Android/                    .github/   the CI parity gate
Skip.env
```

The full migration plan — every decision, every preserved quirk, the evidence
behind each behavior — is in **[REFLEX_MIGRATION_PLAN.md](REFLEX_MIGRATION_PLAN.md)**.
Read it alongside this code: each Phase 0–4 section names the legacy files that
the rewrite was extracted from.

## Why it was rewritten

Skip transpiles Swift to Kotlin, which means:

- business logic can only be written in the subset that transpiles cleanly;
- `#if SKIP` blocks duplicate logic between the two platforms by hand;
- the two platforms drift silently — nobody diffs their runtime behavior.

The rewrite keeps the **observable behavior identical** (it is pinned by 180
behavior cases) while giving each platform a native implementation, a real
persistence contract, and a CI gate that fails when the two disagree.

## Architecture here

| Target | What it is |
|---|---|
| `AppModel` | Domain models, `MedicalViewModel`, `LocalMedicalRepository` — the data layer |
| `SharedUI` | SwiftUI views, transpiled to Kotlin for Android |
| `AppCore` | App entry point and root view |

The views own a lot of state directly, and the business rules live in computed
properties inside the views (`takenTodayCount`, trend percentages, calendar
math, filters). The rewrite moved all of that into pure reducers and selectors
so it could be tested — which is what the behavior contract in the successor
repo pins down.

## Data on device

`medical_data.json` in the app's documents (iOS) / files (Android) directory.
ISO8601 dates, uppercase UUIDs, optional fields omitted rather than null. The
rewrite reads and writes the **same file at the same path**, so upgrading from
v0.0.19 to 1.0 keeps every medication, appointment and reading.

## Building

This project needs [Skip](https://skip.dev) and its prerequisites:

```bash
brew install skiptools/skip/skip
skip checkup      # verify Kotlin, Gradle and the Android build tools
skip verify       # validate the project
```

Then:

```bash
just setup          # swift package resolve
just build          # both platforms
just ios-build      # iOS app for the simulator
just android-build  # Android debug APK
just test           # both platforms
```

Open `Project.xcworkspace` in Xcode for iOS development. Copy `.env.example` to
`.env` for the release scripts (signing, App Store Connect, Google Play).

## Store

The app is published as **PharmTrack** (`com.tunnxo.medtrack`) on the App Store
and Google Play. The successor rewrite ships as 1.0.

## Note on this repository

This is a sanitized snapshot: release credentials, signing keys, the marketing
site, the backend, device screenshots and the original private history are not
included. `.env.example` contains placeholders only.

## License

MIT — see [LICENSE](LICENSE).
