# Melangua Operations

## What This Covers

This is the minimal operator surface for the current repo. It focuses on the things that break first in practice:

- model manifest changes
- Firebase rules and emulator checks
- hosted web previews
- backend health visibility

## Model Manifest Workflow

Source file:

```text
apps/learner_app/web/model-manifest.json
```

Validation:

```bash
python3 infra/scripts/validate_model_manifest.py apps/learner_app/web/model-manifest.json
```

What it checks:

- non-empty version string
- non-empty bundle list
- supported bundle IDs only (`lite`, `balanced`, `quality`)

## Firebase Rules Workflow

Start emulators:

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest emulators:start
```

Deploy rules and indexes:

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest deploy --only firestore:rules,firestore:indexes,storage
```

Tracked files:

- `firestore.rules`
- `firestore.indexes.json`
- `storage.rules`
- `firebase.json`

## Hosting Preview Workflow

Create a preview channel:

```bash
/home/efaz/.volta/bin/npx -y firebase-tools@latest hosting:channel:deploy preview
```

The hosting config serves the built Flutter web output from:

```text
apps/learner_app/build/web
```

## Backend Health

The thin backend health route remains available at:

```text
/v1/health
```

Expected service name:

```json
{ "status": "ok", "service": "melangua-api" }
```

## Release Notes

- CI validates backend checks, Flutter checks, Firebase JSON syntax, and model-manifest shape.
- Android release builds require secret-based signing through `.github/workflows/android-release.yml`.
- The release workflow now fails fast with a clear message if signing secrets are missing.
- Web CI uses `flutter build web --no-wasm-dry-run` until the secure storage dependency becomes wasm-ready.
