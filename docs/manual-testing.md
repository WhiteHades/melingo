# Melangua Manual Testing Guide

## Verified Snapshot

The following checks were run successfully on this Linux machine on 2026-04-08:

```bash
/home/efaz/.volta/bin/npm run lint
/home/efaz/.volta/bin/npm run typecheck
/home/efaz/.volta/bin/npm test
python3 infra/scripts/validate_model_manifest.py apps/learner_app/web/model-manifest.json

cd apps/learner_app
flutter pub get
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
flutter build linux
flutter build apk --debug
```

Verified outputs:

- backend tests pass
- web build succeeds at `apps/learner_app/build/web`
- Linux desktop bundle builds at `apps/learner_app/build/linux/x64/release/bundle/melangua`
- Android debug APK builds at `apps/learner_app/build/app/outputs/flutter-apk/app-debug.apk`

## Important Truths Before You Test

- The current app shell, onboarding flow, review flow, stats flow, sync queue, Firebase bootstrap, and model-manager UI are real.
- The current ASR, tutor, and TTS path is simulated through `UnimplementedAiBridgePlatform` in `apps/learner_app/lib/src/native/ai_bridge_platform.dart`.
- That means the speaking loop is testable as product flow, but it is not yet exercising real local voice models.
- The model manifest and bundle install flow are also scaffolded. The app validates bundle metadata and integrity hashes, but it is not yet downloading and running real inference models.

## Linux Prerequisites

Required tools:

- Flutter `3.41.6`
- Dart `3.11.4`
- Python `3.14+`
- Android SDK with accepted licenses if you want Android builds
- Volta-managed `npm` and `npx` at `/home/efaz/.volta/bin/`

Recommended checks:

```bash
flutter --version
flutter doctor -v
python3 --version
/home/efaz/.volta/bin/npm --version
```

Notes from this machine:

- Android toolchain is healthy.
- Linux desktop toolchain is healthy.
- Chrome is not installed, so `flutter run -d chrome` will fail until you install Chrome or point `CHROME_EXECUTABLE` at a Chromium-compatible browser.

## Backend Local Run

From the repo root:

```bash
python3 -m uvicorn backend.api.main:app --host 127.0.0.1 --port 8000 --reload
```

Health check:

```bash
curl http://127.0.0.1:8000/v1/health
```

Expected response:

```json
{ "status": "ok", "service": "melangua-api" }
```

## Run The App Locally

### Linux Desktop

From `apps/learner_app`:

```bash
flutter pub get
flutter run -d linux
```

If you only want to launch the previously built release bundle:

```bash
./build/linux/x64/release/bundle/melangua
```

### Web

If Chrome is available:

```bash
flutter run -d chrome --web-renderer canvaskit
```

If Chrome is not available, use the Flutter web server device:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
```

Or serve the built web output:

```bash
cd build/web
python3 -m http.server 8081
```

Then open `http://127.0.0.1:8081` in your browser.

Use `--dart-define` flags when you want Firebase emulator routing or App Check:

```bash
flutter run -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port 8081 \
  --dart-define=USE_FIREBASE_EMULATORS=true \
  --dart-define=ENABLE_FIREBASE_ANON_AUTH=true
```

### Android

Start an emulator from Android Studio or connect a device, then from `apps/learner_app`:

```bash
flutter devices
flutter run -d android
```

For a debug artifact only:

```bash
flutter build apk --debug
```

Debug APK path:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Release bundle generation still needs signing setup. See `docs/play-store-release.md`.

## Optional Firebase Emulator Testing

From the repo root:

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest emulators:start
```

Then run the Flutter app with:

```bash
--dart-define=USE_FIREBASE_EMULATORS=true
--dart-define=ENABLE_FIREBASE_ANON_AUTH=true
```

Only enable App Check locally if you are explicitly testing it and you have a valid web key where needed.

## Manual User Story Smoke Test

### 1. Onboarding

- Launch the app.
- Confirm you can enter a learner name.
- Select Arabic or German.
- Select a level and weekly goal.
- Save and confirm the profile is visible from the profile screen.

### 2. Adaptive Shell

- On desktop or resized web, confirm navigation stays usable.
- Confirm Arabic selection flips the app into RTL.
- Confirm major screens remain readable at narrow and wide widths.

### 3. Model Manager

- Open the model manager screen.
- Tap refresh manifest.
- Confirm manifest version appears.
- Tap download on a bundle.
- Tap mark ready.
- Confirm model health reports `ready: true` and lists the installed bundle.

### 4. Practice Flow

- Open practice.
- Confirm `offline ready` reflects whether you marked a bundle ready.
- Tap start.
- Tap stop.
- Confirm a transcript appears.
- Confirm correction, explanation, assistant text, next prompt, mistake tags, and latency values appear.
- Tap replay and confirm playback state changes.
- Tap review and confirm the turn is visible.

Expected current behavior:

- transcript is simulated
- tutor feedback is simulated
- TTS bytes are simulated

This is expected until the native AI bridge is implemented.

### 5. Review Flow

- Open review after completing a practice turn.
- Confirm the timeline shows the new turn.
- Filter by mistake category and confirm the list updates.
- Replay from review and confirm the replay path still works.

### 6. Stats Flow

- Open stats after creating a few practice turns.
- Confirm KPI cards render.
- Confirm trend windows switch across 7, 30, and 90 days.

### 7. Settings And Profile

- Open settings.
- Confirm diagnostics and privacy-related options render.
- Reopen profile and confirm onboarding values persist.

### 8. Backend And Sync Foundation

- Start the backend.
- If using Firebase emulators, run the app with emulator flags.
- Complete onboarding and a practice session.
- Confirm no startup errors occur.
- Use the automated tests as the primary verification for sync replay correctness until a live Firebase console test is performed.

## What Is Verified Versus Not Yet Verified

Verified here:

- backend routes and tests
- Flutter widget and repository tests
- model manifest validation
- web compile
- Linux desktop compile
- Android debug compile
- Firebase bootstrap code compiles cleanly

Not verified here:

- real microphone capture on device
- real ASR inference
- real tutor model inference
- real TTS playback backed by shipped models
- release-signed Android bundle generation
- live Firebase production rules and App Check behavior in console
- Play Console rollout

## Remaining External Work

- Play Console identity verification
- Android signing keystore and GitHub secrets
- Firebase App Check production setup
- real on-device AI runtime implementation behind `AiBridgePlatform`
- real-device smoke testing on Android hardware

## Recommended Next Order

1. Run the Linux desktop app and complete the smoke test above.
2. Run the web app through `web-server` or a local static server and repeat the smoke test.
3. Run the Android app on an emulator or device and repeat the smoke test.
4. Decide whether to wire real ASR/Tutor/TTS next or to finish Firebase/Play external setup first.
5. After Play Console verification lands, finish signing and internal-track rollout.
