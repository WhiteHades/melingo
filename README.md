# Melingo

Melingo is an offline-first, speaking-first AI language tutor built as a Flutter-first monorepo.

## Goals

- One shared product UI across Android, iOS, web, Windows, macOS, and Linux.
- Privacy-first local inference and storage defaults.
- Modular AI pipeline: ASR -> tutor -> TTS.
- Event-first analytics with offline-first sync.

## Monorepo Layout

```text
melingo/
  apps/
    learner_app/
  packages/
    design_system/
    domain/
    data/
    ai_bridge/
    analytics/
  backend/
    api/
    migrations/
    workers/
  infra/
    ci/
    scripts/
  docs/
  plans/
```

## Current Status

- Planning complete (PRD + phased plan + vertical-slice issues).
- Phase 1 scaffold in progress.

## Development (Current Environment)

This workspace currently does not have Flutter SDK available in PATH.

When Flutter is installed, typical commands from `apps/learner_app` are:

```bash
flutter pub get
flutter analyze
flutter test
```

Backend checks from `backend/api`:

```bash
python3 -m pytest
```

## Security Baseline

- TLS for all remote traffic.
- Encrypted local storage for sensitive app data.
- Secrets loaded from environment / secure stores only.
