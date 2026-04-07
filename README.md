# Melingo

[![Visibility](https://img.shields.io/badge/visibility-public-brightgreen)](https://github.com/WhiteHades/melingo)
[![Status](https://img.shields.io/badge/status-active--development-blue)](https://github.com/WhiteHades/melingo)
[![Offline First](https://img.shields.io/badge/offline--first-yes-success)](https://github.com/WhiteHades/melingo)
[![Flutter](https://img.shields.io/badge/flutter-multi--platform-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/backend-fastapi-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Supabase](https://img.shields.io/badge/database-supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Issues](https://img.shields.io/github/issues/WhiteHades/melingo)](https://github.com/WhiteHades/melingo/issues)
[![Stars](https://img.shields.io/github/stars/WhiteHades/melingo?style=social)](https://github.com/WhiteHades/melingo)

Melingo is an offline-first, speaking-first AI language tutor built as a Flutter-first monorepo.

## Project tags

`offline-first` `flutter` `dart` `fastapi` `python` `supabase` `asr` `tts` `language-learning` `privacy-first` `mobile` `desktop` `web`

## What this repo is for

- One shared product UI across Android, iOS, web, Windows, macOS, and Linux.
- Privacy-first local inference and storage defaults.
- Modular AI pipeline: ASR -> tutor -> TTS.
- Event-first analytics with offline-first sync.

## Tech stack

- Frontend: Flutter + Riverpod + GoRouter
- Backend: FastAPI + Python
- Data: Postgres/Supabase
- Local security: encrypted local state + secure secret material store
- AI path (target): Voxtral Mini ASR + Qwen tutor + Qwen3-TTS

## Monorepo layout

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

## Current implementation status

- [x] Planning complete (PRD + phased plan + vertical-slice issues)
- [x] Phase 1 baseline scaffold ([#2](https://github.com/WhiteHades/melingo/issues/2))
- [x] Onboarding local-first writes ([#3](https://github.com/WhiteHades/melingo/issues/3))
- [x] Model manager + integrity verification ([#4](https://github.com/WhiteHades/melingo/issues/4))
- [ ] Audio engine + ASR first slice in progress ([#5](https://github.com/WhiteHades/melingo/issues/5))

## Development

Root checks:

```bash
/home/efaz/.volta/bin/npm run lint
/home/efaz/.volta/bin/npm run typecheck
/home/efaz/.volta/bin/npm test
```

Flutter app checks (from `apps/learner_app` once Flutter SDK is installed):

```bash
flutter pub get
flutter analyze
flutter test
```

## Security baseline

- TLS for all remote traffic.
- Encrypted local storage for sensitive app data.
- Model artifact integrity verification before activation.
- Secrets loaded from environment or secure stores only.

## Notes

- Repository visibility: public.
- License file is not set yet.
