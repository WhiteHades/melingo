# PRD: Melangua - Offline-First Flutter AI Language Tutor

## Problem Statement

Learners who want practical speaking practice in Arabic and German are forced into apps that are either cloud-dependent, inconsistent across platforms, expensive to run, weak on privacy, or thin on actionable learning analytics. The target product needs to run across mobile, desktop, and web with one consistent UX, support offline-capable on-device AI (ASR, tutoring, TTS), keep user trust through privacy-first defaults and full encryption, and provide deep progress/system stats without introducing backend-heavy complexity.

## Solution

Build a Flutter-first monorepo delivering a speaking-first language tutor with a custom token-driven design system inspired by shadcn Luma. The runtime loop is Mic -> ASR -> Tutor LLM -> TTS -> Speaker, backed by an offline-first local data model and a thin FastAPI + Firebase backend for sync, auth, manifests, and aggregated analytics. AI runtimes are modular and replaceable behind interfaces, model artifacts are downloaded post-install via model bundles, and all sensitive data paths are encrypted in transit and at rest.

## User Stories

1. As a new learner, I want a clear onboarding flow, so that I can choose language, level, and goals quickly.
2. As a privacy-conscious learner, I want explicit local-first data handling, so that my raw voice data stays on device by default.
3. As a learner on weak connectivity, I want core speaking sessions to work offline, so that network outages never block practice.
4. As a learner on low-storage devices, I want model bundle choices with size and RAM estimates, so that I can install what my device supports.
5. As a learner, I want to start a session in one tap, so that I can practice with minimal friction.
6. As a learner, I want low-latency speech transcription, so that conversation feels natural.
7. As a learner, I want correction feedback with short explanations, so that I understand mistakes immediately.
8. As a learner, I want the AI to respond with natural TTS playback, so that I can practice listening and speaking turn-taking.
9. As a learner, I want session review with transcripts and corrections, so that I can revisit what I learned.
10. As a learner, I want pronunciation, grammar, and vocabulary indicators, so that I can focus where I need improvement.
11. As a learner, I want trend dashboards (7/30/90 days), so that I can track progress over time.
12. As a learner, I want streaks and weekly goals, so that I maintain consistency.
13. As a learner, I want per-language and per-topic breakdowns, so that I can prioritize weak areas.
14. As a learner, I want to inspect frequent mistake categories, so that I can target repeated errors.
15. As a learner, I want to replay important turns, so that I can compare my output against corrections.
16. As a learner, I want the app to support RTL correctly for Arabic, so that the interface feels native.
17. As a learner, I want language packs to be modular, so that future languages can be added without a full rewrite.
18. As a learner, I want consistent UI across phone, tablet, desktop, and web, so that switching devices is seamless.
19. As a learner, I want responsive navigation patterns per device class, so that controls feel native on each form factor.
20. As a learner, I want robust accessibility support, so that screen readers, larger text, and contrast settings work correctly.
21. As a learner, I want localized UI text and content, so that app instructions are easy to understand.
22. As a learner, I want model health/debug visibility, so that I can troubleshoot inference problems.
23. As a learner, I want secure account sync, so that my progress follows me across devices.
24. As a learner, I want conflict-safe offline sync, so that offline usage does not cause data loss.
25. As a learner, I want transparent model license information, so that I trust how the AI stack is used.
26. As an open-source contributor, I want a clear monorepo module structure, so that I can add features without touching unrelated areas.
27. As an open-source contributor, I want deterministic APIs and schemas, so that integration points are predictable.
28. As an engineer, I want event-based analytics, so that new metrics can be added without schema rewrites.
29. As an engineer, I want immutable event logging and derived aggregates, so that analytics remain auditable and scalable.
30. As an engineer, I want AI runtimes abstracted behind interfaces, so that models can be swapped later.
31. As an engineer, I want a stable native inference bridge for audio/model IO, so that Flutter UI remains decoupled from inference details.
32. As an engineer, I want feature-first Riverpod state boundaries, so that state remains maintainable.
33. As an engineer, I want a strict audio state machine, so that recording and playback edge cases are reliable.
34. As an engineer, I want encrypted local persistence and encrypted sync transport, so that security is enforceable by default.
35. As an engineer, I want CI pipelines for analyze/test/build across app and backend, so that regressions are caught early.
36. As an engineer, I want model manifest validation in CI, so that broken model metadata never reaches users.
37. As a maintainer, I want donation flows that never gate core learning, so that the free-for-everyone promise is preserved.
38. As a maintainer, I want admin tooling for aggregate stats and content updates, so that operations remain lightweight.
39. As a maintainer, I want content delivered as versioned structured assets, so that learning material can evolve without forced app updates.
40. As a maintainer, I want release automation for Android first and cross-platform artifacts later, so that shipping is repeatable.
41. As a maintainer, I want telemetry that is opt-in for diagnostics, so that trust is retained while improving quality.
42. As a maintainer, I want full encryption coverage and clear key management rules, so that security posture is explicit and testable.

## Implementation Decisions

- Product shell is a Flutter-first monorepo with shared code for Android, iOS, web, Windows, macOS, and Linux.
- Visual system is a custom token-driven design system inspired by shadcn Luma (rounded geometry, soft elevation, breathable spacing), implemented natively in Flutter.
- State management uses Riverpod in feature-bounded contexts (auth, conversation, models, stats, settings).
- Domain/data/app boundaries are kept explicit via package modules: design_system, domain, data, ai_bridge, analytics.
- Conversation runtime is modular: ASR (Voxtral-Mini) -> Tutor (small local Qwen text model) -> TTS (Qwen3-TTS-0.6B).
- AI runtime adapters are replaceable behind interfaces so language/model changes do not affect feature UI.
- Native inference is handled through a bridge layer (Rust or C++), with platform adapters only for unavoidable OS surfaces.
- Audio orchestration is state-machine driven, not widget driven, to avoid race conditions and duplex bugs.
- Backend remains intentionally thin (FastAPI + Firebase) and does not serve core real-time inference.
- Sync model is offline-first: local write-through queue, background sync, conflict resolution by timestamp + server version semantics.
- Analytics model is immutable event-first with derived daily/weekly aggregates and materialized summaries.
- Session entities include session, turns, feedback, mistakes, and AI timing/confidence telemetry for deep drill-downs.
- Content is versioned structured assets (topics, roleplays, drills, hints, grammar notes, decks, achievements).
- Language support is modular via LanguagePack abstraction (prompts, grammar taxonomy, directionality, model preference, strings).
- Navigation adapts by device class: bottom nav (phone), rail/sidebar (tablet), sidebar + command bar (desktop/web).
- Initial MVP scope is speaking-only; reading/writing modules are deferred to later roadmap phases.
- Model artifacts are downloaded post-install as Lite/Balanced/Quality bundles with transparent device requirements.
- Model manifests are backend-delivered and validated in CI before release.
- Full encryption is mandatory:
  - TLS for all network calls.
  - Encrypted local persistence for sensitive records and optional encrypted raw audio cache.
  - Encrypted model/download artifact integrity checks.
  - Secrets/keys in OS secure storage; no plaintext credential persistence.
  - Optional diagnostics only with explicit user opt-in.
- Security posture favors minimal PII, explicit consent, and transparent model/license display in settings.
- Donation flows are non-blocking and never gate core features.
- CI/CD covers Flutter analyze/test/build, backend lint/test/migrations, and release packaging/signing workflows.

## Testing Decisions

- Good tests verify externally observable behavior and contracts, not implementation details.
- Module testing focus:
  - Design system components and theme tokens (render/semantics consistency).
  - Conversation orchestrator (turn lifecycle, retries, interruption handling).
  - Audio state machine (record/play/interrupt transitions).
  - AI adapter interfaces (ASR/Tutor/TTS happy and failure paths with fakes).
  - Model manager (bundle selection, download, resume, checksum/integrity validation).
  - Offline-first repository/sync queue (enqueue, replay, conflict resolution).
  - Event logging and aggregate calculators.
  - Backend API contracts (auth, profile/goal sync, manifest and aggregate endpoints).
  - Encryption boundaries (key retrieval paths, encrypted writes/reads, transport enforcement).
- Test types:
  - Unit tests for domain logic, repositories, aggregators, and adapter contracts.
  - Widget tests for key screens (onboarding, practice, review, stats, settings).
  - Integration tests for end-to-end speaking flow and sync flow.
  - API tests for backend endpoint contracts and migrations.
- Prior art:
  - No existing repository tests yet; baseline conventions will follow Flutter testing best practices (unit/widget/integration split) and FastAPI + pytest patterns.

## Out of Scope

- Remote cloud-first model inference as the default runtime.
- Payment-gated feature access, subscription paywalls, or ad-based gating.
- Full reading/writing curriculum in the initial speaking-first release.
- Broad language expansion beyond initial Arabic and German packs in MVP.
- Complex social/community mechanics (leaderboards, multiplayer, etc.) for v0.
- Enterprise admin features beyond minimal operator tools for manifests/stats/content.

## Further Notes

- Delivery priority follows: app shell -> design system -> audio -> ASR -> tutor -> TTS -> logging/review -> stats -> model manager -> sync backend -> donations/release.
- Architectural preference is simple, boring interfaces over clever abstractions.
- Performance and battery constraints are first-class acceptance criteria for voice loops.
- This PRD is intended as the parent issue for follow-on phased planning and vertical-slice implementation issues.
