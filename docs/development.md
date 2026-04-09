# Melangua Development

## Repo Checks

From the repo root:

```bash
/home/efaz/.volta/bin/npm run melangua:verify

# or run the underlying checks directly:
/home/efaz/.volta/bin/npm run lint
/home/efaz/.volta/bin/npm run typecheck
/home/efaz/.volta/bin/npm test
```

## One-Command Shortcuts

The repo now includes a cross-platform helper at `tool/melangua.dart` and npm shortcuts in `package.json`.

Use these from the repo root:

```bash
/home/efaz/.volta/bin/npm run melangua:backend
/home/efaz/.volta/bin/npm run melangua:health
/home/efaz/.volta/bin/npm run melangua:run:web
/home/efaz/.volta/bin/npm run melangua:run:web:chrome
/home/efaz/.volta/bin/npm run melangua:run:android
/home/efaz/.volta/bin/npm run melangua:run:ios
/home/efaz/.volta/bin/npm run melangua:run:linux
/home/efaz/.volta/bin/npm run melangua:run:macos
/home/efaz/.volta/bin/npm run melangua:run:windows
/home/efaz/.volta/bin/npm run melangua:build:web
/home/efaz/.volta/bin/npm run melangua:build:android:debug
/home/efaz/.volta/bin/npm run melangua:build:android:release
/home/efaz/.volta/bin/npm run melangua:build:ios
/home/efaz/.volta/bin/npm run melangua:build:linux
/home/efaz/.volta/bin/npm run melangua:build:macos
/home/efaz/.volta/bin/npm run melangua:build:windows
```

If you do not want npm as the wrapper, call the helper directly:

```bash
dart tool/melangua.dart run linux
dart tool/melangua.dart run web --config emulators
dart tool/melangua.dart build android-debug
```

## Flutter App

From `apps/learner_app`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
```

Additional local verification commands:

```bash
flutter build linux
flutter build apk --debug
```

Committed runtime define profiles:

- `apps/learner_app/config/runtime.local.json`
- `apps/learner_app/config/runtime.emulators.json`
- `apps/learner_app/config/runtime.appcheck.example.json`

The helper script forwards these through `--dart-define-from-file`, so the same runtime profile can be reused across web, Android, iOS, Linux, macOS, and Windows commands.

## Firebase Project

Default Firebase project:

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest use melangua-efaz
```

## Firebase Emulator Suite

From the repo root:

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest emulators:start
```

## Optional Runtime Flags

- `USE_FIREBASE_EMULATORS=true` routes Firebase SDKs to the local Emulator Suite.
- `ENABLE_FIREBASE_APP_CHECK=true` enables App Check bootstrap.
- `ENABLE_FIREBASE_ANON_AUTH=true` signs in anonymously during startup.
- `FIREBASE_APP_CHECK_WEB_KEY=<site-key>` supplies the reCAPTCHA v3 site key for web App Check.

## Web Build Note

The current web target is treated as a JavaScript web build, not a wasm target. `flutter_secure_storage_web` is still not wasm-ready upstream, so local and CI web builds use:

```bash
flutter build web --no-wasm-dry-run
```

If Chrome is not installed on your Linux machine, use `flutter run -d web-server` or serve `build/web` with a local HTTP server instead of `flutter run -d chrome`.

## Manual Testing

See `docs/manual-testing.md` for:

- one-command repo shortcuts for all major targets
- step-by-step Linux, web, backend, and Android run commands
- a user-story smoke-test checklist
- the exact verified outputs from this machine
- current limitations around the simulated AI bridge

## Firebase Files In Repo

- Root Firebase project config: `.firebaserc`, `firebase.json`
- Firestore rules and indexes: `firestore.rules`, `firestore.indexes.json`
- Storage rules: `storage.rules`
- FlutterFire output: `apps/learner_app/lib/firebase_options.dart`

## Current Cloud Shape

- Firebase handles project registration, app config, rules, hosting, and future auth/sync surfaces.
- FastAPI remains available for thin custom APIs and operational endpoints while the Firebase-backed path is completed.

## Current Runtime Truth

- The current repository passes automated backend and Flutter verification.
- The current ASR, tutor, and TTS path is still simulated in local development and tests.
- Manual testing today validates product flow and integration scaffolding, not real on-device inference quality.
- FlutterFire generated Firebase config for Android, iOS, macOS, web, and Windows in this environment, but it did not generate Linux Firebase options.
