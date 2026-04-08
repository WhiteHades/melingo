# Melangua Firebase Production Checklist

## Project

- Firebase project: `melangua-efaz`
- FlutterFire output: `apps/learner_app/lib/firebase_options.dart`
- Root Firebase config: `.firebaserc`, `firebase.json`

## Products In Use

- Authentication
- Firestore
- Storage
- Hosting
- App Check scaffold

## Required Console Steps

### Authentication

- Enable Anonymous sign-in if you want the current sync path to work as implemented.
- If you later add Google or email sign-in, link anonymous accounts instead of replacing them.

### Firestore

- Create the Firestore database in production mode.
- Deploy checked-in rules and indexes.

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest deploy --only firestore:rules,firestore:indexes
```

### Storage

- Create the default bucket if it has not already been provisioned.
- Deploy checked-in Storage rules.

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest deploy --only storage
```

### App Check

Android:

- register the Android app with Play Integrity
- ship one internal build first
- review App Check metrics
- enforce only after the app has been exercised in internal testing

Web:

- create a reCAPTCHA v3 site key
- add the site key as `FIREBASE_APP_CHECK_WEB_KEY` in your runtime or build system
- enable `ENABLE_FIREBASE_APP_CHECK=true`
- if web is public, turn on App Check enforcement after metrics look healthy

## Important Runtime Flags

- `USE_FIREBASE_EMULATORS=true`
- `ENABLE_FIREBASE_APP_CHECK=true`
- `ENABLE_FIREBASE_ANON_AUTH=true`
- `FIREBASE_APP_CHECK_WEB_KEY=<site-key>`

## Current Limitations

- Web builds are intentionally JS-only for now. `flutter_secure_storage_web` is not wasm-ready upstream, so use `flutter build web --no-wasm-dry-run`.
- The app has Firebase sync foundations, not a full serverless admin platform.

## Recommended Validation Order

1. Emulator Suite
2. Internal Android build
3. Closed test group
4. Production App Check enforcement
5. Production Play rollout
