# Melangua Development

## Repo Checks

From the repo root:

```bash
/home/efaz/.volta/bin/npm run lint
/home/efaz/.volta/bin/npm run typecheck
/home/efaz/.volta/bin/npm test
```

## Flutter App

From `apps/learner_app`:

```bash
flutter pub get
flutter analyze
flutter test
```

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

## Firebase Files In Repo

- Root Firebase project config: `.firebaserc`, `firebase.json`
- Firestore rules and indexes: `firestore.rules`, `firestore.indexes.json`
- Storage rules: `storage.rules`
- FlutterFire output: `apps/learner_app/lib/firebase_options.dart`

## Current Cloud Shape

- Firebase handles project registration, app config, rules, hosting, and future auth/sync surfaces.
- FastAPI remains available for thin custom APIs and operational endpoints while the Firebase-backed path is completed.
