# Plan: Melingo - Offline-First Flutter AI Language Tutor

> Source PRD: `docs/prd-melingo-offline-flutter-language-tutor.md`

## Architectural decisions

Durable decisions that apply across all phases:

- **Monorepo shape**:
  - `apps/learner_app` for Flutter shell and feature modules.
  - `packages/design_system`, `packages/domain`, `packages/data`, `packages/ai_bridge`, `packages/analytics` for shared logic.
  - `backend/api`, `backend/migrations`, `backend/workers` for sync and aggregates.
- **Core runtime pipeline**: Mic -> ASR -> Tutor LLM -> TTS -> Speaker.
- **Data model strategy**: immutable event log + derived daily/weekly aggregates.
- **Sync strategy**: local-first writes, background replay queue, conflict resolution by timestamp/server version.
- **Security baseline**: TLS in transit, encrypted local persistence for sensitive artifacts, secrets in secure OS storage, integrity checks for model bundles.
- **Navigation model**: phone bottom nav, tablet rail/sidebar, desktop/web sidebar + command bar.
- **Language strategy**: modular LanguagePack abstraction with directionality, prompts, grammar taxonomy, and model preferences.

---

## Phase 1: App Shell, Design Tokens, and Secure Local Baseline

**User stories**: 1, 2, 18, 19, 20, 26, 32, 34

### What to build

Create the Flutter monorepo shell with adaptive app navigation, token-driven Luma-inspired design system primitives, baseline settings screen, and secure local storage primitives for sensitive app metadata. Deliver a working app skeleton that runs on at least one mobile and one desktop target with accessibility-ready components.

### Acceptance criteria

- [ ] App boots with adaptive navigation pattern by device class.
- [ ] Design tokens (color, radius, elevation, spacing, type) are consumed by core UI primitives.
- [ ] Sensitive settings/profile metadata path uses encrypted local persistence.
- [ ] Baseline accessibility checks pass for key shell screens.

---

## Phase 2: Onboarding, Profile, Goals, and Offline-First Local Writes

**User stories**: 1, 3, 12, 23, 24

### What to build

Implement onboarding and profile/goal setup as an end-to-end flow that always writes locally first. Include language/level selection and weekly goals, with pending sync markers ready for backend replay.

### Acceptance criteria

- [ ] Onboarding captures language, level, and weekly goal settings.
- [ ] User/profile/goals persist locally when offline.
- [ ] Pending-sync markers are created for unsynced records.
- [ ] User can revisit and update goals in settings/profile.

---

## Phase 3: Model Manifest + Bundle Manager (Lite/Balanced/Quality)

**User stories**: 4, 17, 22, 25, 36

### What to build

Deliver model setup flow with manifest retrieval/caching, bundle selection UI (Lite/Balanced/Quality), and secure model download/install pipeline with size/RAM/language metadata and integrity validation.

### Acceptance criteria

- [ ] Model manager screen displays bundle metadata (size, RAM, languages, offline support).
- [ ] Users can download/install/resume model bundle operations.
- [ ] Installed model artifacts are verified with integrity checks before activation.
- [ ] Model health/debug screen reports install and runtime readiness.

---

## Phase 4: Voice Input Slice (Audio Engine + ASR)

**User stories**: 5, 6, 33

### What to build

Implement first working voice turn from microphone capture to ASR transcript display via the native inference bridge and audio state machine. Include latency and confidence telemetry emission as events.

### Acceptance criteria

- [ ] User can record a turn and receive ASR transcript in-session.
- [ ] Audio state machine handles record start/stop/cancel safely.
- [ ] ASR confidence and latency are recorded as immutable events.
- [ ] Core flow works offline when required models are installed.

---

## Phase 5: Tutor Reasoning Slice (Local Qwen Text Tutor)

**User stories**: 7, 10, 30

### What to build

Add local tutor inference that consumes ASR transcript and returns structured tutoring output (corrected text, explanation, encouragement, next prompt, tags). Render correction cards in practice session.

### Acceptance criteria

- [ ] Tutor responses conform to structured response schema.
- [ ] Corrected text and explanation are shown per turn.
- [ ] Mistake tags are attached to turn output for later analytics.
- [ ] Tutor flow handles model errors with user-safe retry states.

---

## Phase 6: Full Conversation Slice (Qwen3-TTS + Turn-Taking)

**User stories**: 8, 15, 33

### What to build

Complete conversational loop by integrating TTS playback, interruption-safe turn-taking, and replay controls. Maintain low-latency interactions and emit timing events for TTS and playback reliability.

### Acceptance criteria

- [ ] AI replies are spoken through TTS with visible playback state.
- [ ] User can interrupt and continue conversation without broken state.
- [ ] Replay control works for AI turn audio.
- [ ] TTS latency/retry/interruption events are captured.

---

## Phase 7: Session Review + Mistake Taxonomy Slice

**User stories**: 9, 14, 15

### What to build

Implement post-session review with transcript timeline, corrections, mistake tags, and turn-level detail cards. Persist session, turn, feedback, and mistake entities locally and prepare sync payloads.

### Acceptance criteria

- [ ] Session review shows ordered transcript and correction details.
- [ ] Mistake categories/subcategories are visible and queryable.
- [ ] Turn-level replay and explanation access works from review.
- [ ] Session/turn/mistake entities persist with offline-first semantics.

---

## Phase 8: Stats v1 Slice (KPIs, Trends, and Aggregates)

**User stories**: 11, 12, 13, 28, 29

### What to build

Create stats overview using event-derived local aggregates for activity, performance, and system metrics with 7/30/90-day views, streak cards, and key trend charts.

### Acceptance criteria

- [ ] KPI cards show practice minutes, streak, session count, and average session length.
- [ ] Trend views support at least 7/30/90-day windows.
- [ ] Learning and system metrics (pronunciation/grammar/latency) render from event aggregates.
- [ ] Empty/error states are usable and consistent with design system.

---

## Phase 9: Sync + Auth Slice (Thin FastAPI + Supabase/Postgres)

**User stories**: 23, 24, 38

### What to build

Deliver minimal backend endpoints for auth, profile/goals sync, event upload, and aggregate pull. Wire background replay queue from app to backend with idempotent semantics.

### Acceptance criteria

- [ ] User auth and session identity flow works end-to-end.
- [ ] Unsynced local events replay in background when online.
- [ ] Conflicts resolve deterministically with timestamp/server-version policy.
- [ ] Backend exposes aggregate/stat and manifest endpoints required by app.

---

## Phase 10: Language Pack Slice (German + Arabic, RTL/LTR)

**User stories**: 16, 17, 21

### What to build

Implement LanguagePack infrastructure with German and Arabic pack definitions, localized UI content wiring, directionality support, and language-specific prompt/grammar taxonomy routing.

### Acceptance criteria

- [ ] German and Arabic packs can be selected and loaded.
- [ ] Arabic flows render correctly with RTL-aware layouts and text handling.
- [ ] Localized strings and content assets are versioned and swappable.
- [ ] Language-specific tutor metadata and mistake taxonomy are applied.

---

## Phase 11: Privacy, Encryption Hardening, and Donation Slice

**User stories**: 2, 34, 37, 41, 42

### What to build

Harden privacy/security surfaces and deliver non-gating donation UX. Add diagnostics opt-in controls, data retention/privacy settings, and explicit encryption/license transparency sections.

### Acceptance criteria

- [ ] Sensitive local paths are encrypted and key management uses secure OS storage.
- [ ] Transport security is enforced for all backend/model calls.
- [ ] Diagnostics are opt-in and off by default.
- [ ] Donation UI exists in settings/profile and does not gate core features.

---

## Phase 12: Release and Operations Slice (CI/CD + Admin Tools)

**User stories**: 35, 36, 38, 40

### What to build

Finalize shipping pipeline with CI checks for Flutter/backend/model manifests, release packaging workflow, and minimal admin/ops surfaces for content and aggregate monitoring.

### Acceptance criteria

- [ ] CI runs analyze/test/build for app and lint/test/migration checks for backend.
- [ ] Model manifest validation is part of release gating.
- [ ] Android-first release packaging and signing pipeline is reproducible.
- [ ] Minimal admin tools support manifest/content/stats operational workflows.
