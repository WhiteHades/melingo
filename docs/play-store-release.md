# Melangua Play Store Release Plan

## Goal

Ship the Android build of Melangua through the Play Console with a reproducible signing path, Firebase production configuration, and a clear checklist for internal, closed, and production rollout.

## What Is Already Done In Repo

- Android project exists and builds from Flutter.
- Android package ID is `dev.melangua.learner_app`.
- Firebase Android app is registered under `melangua-efaz`.
- `google-services.json` is checked in for the registered Android app.
- GitHub Actions includes `.github/workflows/android-release.yml`.
- The release workflow expects signing secrets and fails fast if they are missing.

## What You Still Need To Do Outside The Repo

### 1. Create A Release Keystore

Run this once on a secure machine:

```bash
keytool -genkeypair \
  -v \
  -storetype JKS \
  -keystore melangua-release.jks \
  -alias melangua \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Write down these four values and keep them safe:

- keystore file
- store password
- key alias
- key password

### 2. Add GitHub Secrets

Base64 encode the keystore:

```bash
base64 -w 0 melangua-release.jks > melangua-release.jks.base64
```

Add these repository secrets in GitHub:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

### 3. Create The Play Console App

In Google Play Console:

- create the app named `Melangua`
- choose default language and app category
- enroll in Play App Signing
- upload the first release bundle from the GitHub workflow or local `flutter build appbundle --release`

### 4. Fill Required Store Listing Assets

Prepare these before submission:

- app icon
- feature graphic
- phone screenshots
- tablet screenshots if you want tablet distribution presented well
- short description
- full description
- privacy policy URL

### 5. Complete Policy Surfaces

Before production review:

- add a public privacy policy URL
- define whether the app collects diagnostics or crash data in production
- define whether user audio ever leaves device or Firebase storage
- complete the Data safety form in Play Console accordingly

## Recommended Rollout Order

### Phase 1. Internal Testing

- trigger `.github/workflows/android-release.yml`
- upload the generated `.aab`
- install through internal testing
- verify sign-in, speaking loop, review, stats, and sync on a physical Android device

### Phase 2. Closed Testing

- add a small tester group
- validate Firebase auth behavior, sync replay, and App Check
- validate crash-free startup and background resume

### Phase 3. Production Launch

- upload final signed `.aab`
- release with staged rollout
- monitor Firebase auth errors, Firestore rule denials, and crash reports

## Firebase Production Checklist

### App Check

In Firebase console:

1. open App Check
2. register the Android app with Play Integrity
3. register the web app with reCAPTCHA v3 if web is public
4. copy the web site key
5. pass it into the app with `FIREBASE_APP_CHECK_WEB_KEY`
6. enable `ENABLE_FIREBASE_APP_CHECK=true`
7. observe metrics before enforcing
8. enforce on Firestore, Storage, and any other public surfaces only after successful monitoring

### Auth

- enable Anonymous auth if you want the current local-first identity bootstrap to work as implemented
- if you plan to move to Google/email auth later, keep Anonymous linking in mind so learner progress is preserved

### Firestore And Storage

- deploy `firestore.rules`, `firestore.indexes.json`, and `storage.rules`
- test rule-denied paths in Emulator Suite before production enforcement

## Local Release Smoke Test

With `key.properties` present in `apps/learner_app/android/`:

```bash
cd apps/learner_app
flutter pub get
flutter build appbundle --release
```

Expected output:

```text
build/app/outputs/bundle/release/app-release.aab
```

## What Is Still A Product Decision

- whether Anonymous auth remains the production identity path
- whether App Check is enforced on day one or after a short observation period
- whether web is treated as production-facing now or remains secondary behind Android
- whether raw audio ever leaves the device in future releases
