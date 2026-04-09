# Melangua V1 Production Plan

## Goal

Ship a real Melangua v1 that is:

- on-device first
- low-latency enough for speaking practice
- high-quality enough to feel like a real tutor, not a demo
- production-ready across Android first, then desktop platforms
- honest about what is local, what is synced, and what still falls back by platform

This plan is based on:

- the current Melangua repo state
- `/home/efaz/Codes/parlor`
- `/home/efaz/Codes/gallery`
- official Google AI Edge runtime direction via LiteRT-LM and Gallery patterns

## Hard Truths

The current Melangua repository has the app shell, state machine, review, stats, sync scaffolding, and model-manager UX. It does not yet have a real on-device voice stack.

Current missing pieces:

- microphone capture plugin and permissions
- real ASR runtime
- real tutor runtime
- real TTS runtime
- real model download/install/verify lifecycle for production assets
- platform-specific runtime selection and benchmarking

So the correct plan is not a one-line switch. It is a runtime program.

## Decision Summary

### 1. Do not use Piper as the primary v1 TTS

Piper is good as a fallback, but not the best primary voice path for Melangua.

Why:

- quality is behind stronger modern neural options
- voice quality is inconsistent across languages and voices
- it is fine for utility speech, but Melangua needs tutor-grade listening quality

### 2. Do not copy `parlor` directly

`parlor` is useful as a reference, not as an application substrate.

What to borrow from `parlor`:

- sentence-level streaming TTS
- barge-in semantics
- platform-aware TTS backend abstraction
- first-run model bootstrap thinking

What not to borrow:

- browser plus WebSocket architecture
- server-first orchestration
- Kokoro-only TTS assumption

### 3. Do borrow heavily from `gallery`

`gallery` is the strongest reference for Android production patterns.

What to borrow from `gallery`:

- allowlisted model metadata structure
- runtime abstraction boundaries like `LlmModelHelper`
- WorkManager-based download and resume flow
- normalized on-device model paths and versioned storage
- explicit accelerator preferences
- benchmark-first model evaluation mentality

### 4. Best v1 architecture is platform-tiered, not one-model-everywhere

There is no single speech stack today that simultaneously wins on:

- Arabic quality
- German quality
- Android embeddability
- desktop embeddability
- latency
- offline support
- implementation maturity

So the best production v1 is a tiered runtime strategy.

## Recommended Runtime Stack

## Android Primary Stack

### Tutor runtime

Use LiteRT-LM task models and Google-style runtime management.

Primary choice:

- Gemma 3n E2B or E4B via LiteRT-LM on Android

Why:

- this is closest to Google’s official on-device path
- Gallery already proves the model-management and runtime shape
- it gives a stronger production story for mobile than a custom JNI-first llama.cpp stack as the only path

### ASR runtime

Use a dedicated ASR path instead of relying entirely on multimodal LLM audio understanding.

Primary choice:

- Whisper.cpp or Sherpa-ONNX streaming ASR on Android

Why:

- Melangua needs reliable transcript quality for correction and review
- language-learning products need explicit transcripts, confidence, timing, and replayable turn state
- using an LLM alone for transcription makes quality harder to tune and observe

### TTS runtime

Primary v1 choice:

- Android platform TTS as the mobile production default

Why this is better than Piper for v1:

- strongest integration story
- lowest implementation risk
- strong Arabic and German coverage on real Android devices
- very good latency
- fully on-device when offline voice packs are installed
- easiest to make robust under interruptions, audio focus changes, and lifecycle events

Do not read this as “most exciting model”. Read it as “best production mobile decision”.

Optional premium path later:

- Qwen3-TTS where an embeddable Android runtime becomes stable enough

### Android verdict

Best production Android v1:

- ASR: Whisper.cpp or Sherpa-ONNX
- Tutor: Gemma 3n via LiteRT-LM
- TTS: Android platform TTS

This is the best mix of quality, latency, maturity, and shippability.

## Desktop Stack

### Linux and macOS

Primary desktop tutor choice:

- Gemma 4 E2B or Gemma 3n via LiteRT-LM if runtime support is smooth enough
- otherwise llama.cpp-compatible compact tutor model as a fallback

Primary desktop TTS choice:

- Kokoro on desktop where supported

Why:

- `parlor` already shows Kokoro ONNX on Linux and MLX on Apple Silicon as a practical path
- quality is materially better than Piper for supported languages
- sentence-level streaming is straightforward

Important constraint:

- Kokoro is not a safe single-source answer for Arabic today

So desktop TTS should be:

- Kokoro where voice and language quality are acceptable
- platform TTS fallback for Arabic
- Piper only as final fallback, not as primary

### Windows

Primary choice:

- tutor: same compact on-device LLM abstraction as other desktop targets
- TTS: Windows system TTS first, Kokoro ONNX second if validated well enough

## iOS Stack

Primary v1 choice:

- tutor: keep iOS behind Android until Android is stable
- TTS: AVSpeechSynthesizer as the first production path

Why:

- it gives a real, maintainable shipping story faster than trying to force the same experimental stack onto iOS immediately

## What Is Better Than Piper

If the question is pure voice-model quality, the answer is not Piper.

For Melangua, the better options are:

1. Android and iOS system neural TTS for mobile production
2. Kokoro for desktop where language support is validated
3. Qwen3-TTS as a future premium path, not the first production dependency

So the correct v1 decision is:

- do not use Piper as primary
- use platform TTS on mobile
- use Kokoro on desktop where it performs well
- keep Piper only as fallback

## What To Borrow From `parlor`

Borrow:

- TTS backend abstraction
- streaming sentences instead of waiting for the full paragraph
- interrupt-aware speech generation loop
- benchmark mentality for end-to-end latency

Do not borrow:

- browser frontend
- FastAPI as the main runtime orchestrator for Melangua
- multimodal server conversation loop as the app architecture

## What To Borrow From `gallery`

Borrow directly:

- model metadata richness similar to `model_allowlist.json`
- download repository patterns
- WorkManager download worker patterns
- runtime interface patterns from `LlmModelHelper.kt`
- accelerator and memory hints in model metadata
- local file path conventions and versioned model storage

Do not borrow blindly:

- HuggingFace OAuth complexity unless gated/private model workflows truly require it
- Android-only architectural assumptions in the shared Flutter layers

## Workstreams

## Workstream 1: Audio Capture And Playback Foundation

Deliverables:

- add microphone recording plugin to Flutter app
- add Android microphone permission
- add iOS microphone usage description
- define PCM frame format for all runtimes
- unify playback interruption and audio focus handling

Success criteria:

- record, interrupt, and replay work on Android and Linux
- audio sessions survive app pause/resume cleanly

## Workstream 2: Model Metadata And Install System

Deliverables:

- replace simplified `model-manifest.json` shape with a production schema
- include per-model:
  - runtime type
  - supported platforms
  - download URL
  - checksum
  - estimated RAM
  - accelerator hints
  - license and attribution
- add resumable download/install states
- add verification and corruption recovery

Borrow from:

- `gallery` model and download worker structure

Success criteria:

- models install, resume, verify, and recover after partial download

## Workstream 3: Android Tutor Runtime

Deliverables:

- native Android plugin layer for LiteRT-LM
- Gemma 3n-backed tutor runtime
- structured JSON tutor response contract
- streaming token support where useful

Success criteria:

- structured tutor output reaches Flutter reliably
- inference latency is measured on device
- fallback model sizes are available for weaker devices

## Workstream 4: ASR Runtime

Deliverables:

- Android ASR plugin using Whisper.cpp or Sherpa-ONNX
- transcript confidence and partial transcript streaming
- deterministic turn finalization for review and stats

Success criteria:

- Arabic and German transcription is stable enough for correction workflows
- partial and final transcript states do not race each other

## Workstream 5: TTS Runtime

Deliverables:

- Android platform TTS adapter
- desktop Kokoro adapter
- fallback adapter ordering by platform
- voice profile mapping per language

Success criteria:

- German and Arabic playback both sound acceptable
- interruption works cleanly
- sentence-level streaming works on desktop

## Workstream 6: Cross-Platform Runtime Selection

Deliverables:

- runtime capability matrix in app config
- device capability checks
- model bundle recommendations by RAM and platform
- explicit diagnostics screen for active backends

Success criteria:

- app can explain which runtime is active and why
- users are not surprised by silent fallback behavior

## Workstream 7: Production Hardening

Deliverables:

- crash reporting policy and opt-in diagnostics
- App Check rollout plan
- background download recovery
- storage quota checks
- benchmark screen and support export
- release signing and internal testing automation

Success criteria:

- release candidates are benchmarked and logged per device class
- failures degrade visibly and safely

## Workstream 8: Real Device Matrix

Minimum matrix:

- Android mid-tier device
- Android flagship device
- Linux desktop
- macOS Apple Silicon desktop if supported

Test scenarios:

- onboarding
- model download
- speaking loop
- barge-in
- review replay
- sync replay
- low-storage path
- offline mode
- resume after backgrounding

## Runtime Abstractions To Introduce

Keep the current `AiBridgePlatform` idea, but split it into narrower production interfaces:

- `AsrRuntime`
- `TutorRuntime`
- `TtsRuntime`
- `AudioCaptureRuntime`
- `AudioPlaybackRuntime`

Then use a coordinator layer to compose them per platform.

Why:

- Melangua needs different best-in-class backends by platform
- one monolithic bridge becomes the wrong abstraction once real runtimes arrive

## Suggested V1 Bundle Strategy

Do not ship one giant all-platform bundle definition.

Define bundles by platform and capability tier.

Example:

- Android Lite
  - ASR: whisper base/small tier
  - Tutor: Gemma 3n E2B tier
  - TTS: system TTS
- Android Quality
  - stronger tutor model if device RAM allows
- Desktop Lite
  - smaller tutor model
  - system TTS fallback
- Desktop Quality
  - stronger tutor runtime
  - Kokoro primary TTS

## Production Readiness Checklist

Product:

- tutor output schema finalized
- correction tone finalized
- review and stats semantics frozen

Runtime:

- microphone and playback permissions handled
- all active runtimes benchmarked
- all bundles checksum-verified

Operations:

- release signing complete
- App Check staged rollout complete
- crash and analytics policy finalized

Store readiness:

- screenshots
- privacy policy
- support docs
- data safety disclosures

## Immediate Next Moves

1. Commit the repo helper commands and runtime config profiles already in the Melangua worktree.
2. Add microphone capture dependencies and permissions.
3. Rework `AiBridgePlatform` into separate runtime interfaces.
4. Implement Android ASR tracer bullet with Whisper.cpp or Sherpa-ONNX.
5. Implement Android tutor tracer bullet with LiteRT-LM and Gemma 3n.
6. Implement Android system TTS adapter.
7. Implement desktop Kokoro adapter.
8. Replace the simplified manifest with a production metadata schema.
9. Add benchmark and active-runtime diagnostics screens.
10. Run real device matrix testing before calling v1 complete.

## Final Recommendation

If the mandate is best production v1, not easiest demo, then the recommended Melangua architecture is:

- Android ASR: Whisper.cpp or Sherpa-ONNX
- Android tutor: Gemma 3n via LiteRT-LM
- Android TTS: system TTS
- Desktop tutor: LiteRT-LM or compact local LLM runtime
- Desktop TTS: Kokoro where validated, system fallback otherwise
- Piper: fallback only

That is the stack most likely to get you:

- high quality
- low latency
- Arabic and German coverage
- Android-first production readiness
- a path that aligns with Google’s official edge-model direction without overfitting Melangua to a demo app
