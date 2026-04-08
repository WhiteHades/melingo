# Melangua Handoff For A Fresh ChatGPT Session

## Project Snapshot

- Product name: `Melangua`
- GitHub repo: `WhiteHades/melangua`
- Local repo path at the time of this handoff: `/home/efaz/Codes/melangua`
- Main app: `apps/learner_app`
- Cloud project: Firebase `melangua-efaz`

## What Has Been Completed

### Product And Branding

- Renamed the product from Melingo to Melangua in repo metadata, app copy, docs, and GitHub description/topics.
- Root README is now product-facing, not developer-facing.

### Flutter App

- Adaptive shell across phone/tablet/desktop/web.
- Speaking-loop UX and state machine for ASR -> tutor -> TTS.
- Replay and interruption support.
- Session review timeline with category filters and replay from review.
- Stats with 7/30/90-day windows, streak, session length, practice minutes, and tag rollups.
- Arabic and German language packs with RTL support.
- Current local/dev runtime still uses a simulated AI bridge rather than real on-device inference.

### Security And Local Persistence

- Sensitive local values are encrypted.
- Diagnostics are opt-in.
- Raw audio retention remains off by default.

### Firebase

- Firebase project exists: `melangua-efaz`
- FlutterFire is configured.
- `apps/learner_app/lib/firebase_options.dart` exists.
- Root Firebase config exists: `.firebaserc`, `firebase.json`
- Firestore and Storage rules are checked in.
- App Check bootstrap exists in code.

### Sync Foundation

- Anonymous Firebase identity gateway exists.
- Encrypted local queue exists.
- Onboarding profile writes include timestamps.
- Deterministic conflict handling prefers newer `updatedAtIso`.
- Practice events queue and replay through the Firebase sync service.

### CI And Release

- CI workflow exists.
- Android release workflow exists.
- Model manifest validation is checked in and used by CI.
- GitHub Actions are opted into Node 24.

### Dependency State

Flutter app dependencies were upgraded to current resolvable majors, including:

- `flutter_riverpod` `3.3.1`
- `flutter_secure_storage` `10.0.0`
- `go_router` `17.2.0`

Compatibility fixes were added so the app still compiles and tests pass.

## Current Verification Snapshot

Verified successfully on 2026-04-08:

- `/home/efaz/.volta/bin/npm run lint`
- `/home/efaz/.volta/bin/npm run typecheck`
- `/home/efaz/.volta/bin/npm test`
- `python3 infra/scripts/validate_model_manifest.py apps/learner_app/web/model-manifest.json`
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build web --no-wasm-dry-run`
- `flutter build linux`
- `flutter build apk --debug`

Build outputs verified:

- web: `apps/learner_app/build/web`
- linux: `apps/learner_app/build/linux/x64/release/bundle/melangua`
- android debug: `apps/learner_app/build/app/outputs/flutter-apk/app-debug.apk`

Manual test guide:

- `docs/manual-testing.md`

## Repo Docs To Read First

- `README.md`
- `docs/architecture.md`
- `docs/development.md`
- `docs/operations.md`
- `docs/firebase-production.md`
- `docs/play-store-release.md`
- `docs/prd-melangua-offline-flutter-language-tutor.md`
- `plans/melangua-offline-flutter-language-tutor.md`

## Current Known External Steps Still Required

These are not code gaps. They require console or secret setup.

### Android Release Signing

You still need to create a release keystore and add these GitHub secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

The workflow now fails fast if they are missing.

### Firebase App Check Production Enforcement

You still need to configure App Check in Firebase console.

Android:

- register Play Integrity
- test with internal builds
- enforce after metrics look healthy

Web:

- create a real reCAPTCHA v3 site key
- pass it as `FIREBASE_APP_CHECK_WEB_KEY`
- set `ENABLE_FIREBASE_APP_CHECK=true`

### Web Wasm

This is intentionally treated as a future follow-up, not a release blocker.

- `flutter_secure_storage_web` is not wasm-ready upstream.
- Current web builds should use `flutter build web --no-wasm-dry-run`.
- The app still builds and runs as a JS web target.

## Play Store Readiness Summary

From a code/repo perspective, the Android app is close.

Still required before Play submission:

1. release keystore
2. GitHub signing secrets
3. Play Console app creation and Play App Signing
4. screenshots, icon, feature graphic, descriptions
5. privacy policy URL
6. Firebase production checks and App Check config
7. internal and closed testing on real Android devices

See `docs/play-store-release.md` for the full checklist.

## Validation Commands

Backend:

```bash
/home/efaz/.volta/bin/npm run lint
/home/efaz/.volta/bin/npm run typecheck
/home/efaz/.volta/bin/npm test
```

Flutter:

```bash
cd apps/learner_app
flutter pub get
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
```

Firebase config:

```bash
python3 infra/scripts/validate_model_manifest.py apps/learner_app/web/model-manifest.json
/home/efaz/.volta/bin/npx -y firebase-tools@latest use melangua-efaz
```

## Suggested Next Tasks For A New Session

1. Verify the local filesystem repo folder is `/home/efaz/Codes/melangua` so local path parity matches the product and GitHub repo rename.
2. Finalize Play Store release assets and policy copy.
3. Configure real Firebase App Check enforcement.
4. Add richer auth providers if anonymous-only auth is not enough for launch.
5. If web wasm matters, replace or isolate `flutter_secure_storage_web`.
6. Implement a real `AiBridgePlatform` so ASR, tutor, and TTS are backed by actual model runtimes instead of the current simulated bridge.

## Important Constraint

Do not assume external Firebase or Play Console configuration is done just because the repo is ready. The checked-in code and workflows are prepared, but production console setup still matters.
