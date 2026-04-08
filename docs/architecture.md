# Melangua Architecture (Phase 1 Baseline)

## Overview

Melangua follows a Flutter-first monorepo architecture with clear boundaries between UI, domain, data, AI runtime bridge, and backend sync services.

Core runtime path:

`Mic -> ASR -> Tutor -> TTS -> Speaker`

## Layers

- UI: Flutter widgets and feature modules in `apps/learner_app`.
- Logic/Domain: Domain models and use-case rules in `packages/domain`.
- Data: Repositories, local persistence, and sync orchestration in `packages/data`.
- AI bridge: Native bindings/contracts for on-device inference in `packages/ai_bridge`.
- Analytics: Event schemas and local aggregate calculators in `packages/analytics`.
- Backend: Thin FastAPI API with Firebase-backed sync, manifests, and aggregate reads.

## Non-Negotiables

- Offline-first writes.
- Event-first analytics.
- Replaceable AI runtimes behind interfaces.
- Full encryption posture for sensitive data.

## Phase 1 Delivered Boundaries

- App shell and adaptive navigation scaffold.
- Token-driven theme baseline.
- Encrypted settings repository contract.
- Backend API skeleton with health/manifests/sync placeholders.
