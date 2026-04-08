<h1 align="center">Melangua</h1>

<p align="center">Offline-first, speaking-first AI language tutor for Arabic and German.</p>

<p align="center">
  <a href="https://github.com/WhiteHades/melangua"><img src="https://img.shields.io/badge/status-active--development-blue" alt="Status active development"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/flutter-multi--platform-02569B?logo=flutter&logoColor=white" alt="Flutter multi platform"></a>
  <a href="https://fastapi.tiangolo.com"><img src="https://img.shields.io/badge/backend-fastapi-009688?logo=fastapi&logoColor=white" alt="FastAPI backend"></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/cloud-firebase-FFCA28?logo=firebase&logoColor=black" alt="Firebase cloud"></a>
</p>

<p align="center">
  <code>offline-first</code>
  <code>speech-first</code>
  <code>flutter</code>
  <code>firebase</code>
  <code>privacy-first</code>
  <code>arabic</code>
  <code>german</code>
</p>

## What Melangua Is

Melangua is a language tutor built around one idea: if speaking is the goal, the speaking loop should be the product.

That changes what matters. You care less about endless lesson trees and more about whether the app can hear you, respond quickly, explain your mistakes, and still work when the network is weak. Melangua is built around that constraint.

## What It Does

- Implements the speaking-loop UI and state machine around ASR, tutoring, and TTS contracts.
- Keeps learner state local first, then syncs when cloud services are available.
- Supports Arabic and German with direction-aware UI and language-pack routing.
- Uses one Flutter codebase across phone, tablet, desktop, and web.
- Treats privacy as a default, not a premium setting.

## Current Repo Status

- Backend checks, Flutter analysis/tests, web build, Linux build, and Android debug build pass on the current Linux machine.
- The current repository uses a simulated AI bridge for ASR, tutor, and TTS during local runs and tests.
- Real on-device model inference is not wired into this tree yet, so voice-loop UX can be exercised end to end, but the responses are still stubbed.

## Core Features

### Speaking Practice

- Start a turn, stop it, cancel it, or replay the tutor response.
- Surface transcript confidence and latency so the voice loop is inspectable.
- Keep interruption-safe turn taking instead of fragile record/playback state.

### Structured Tutor Feedback

- Show corrected text, short explanations, encouragement, and next prompts.
- Normalize mistake tags by language pack so analytics stay useful.
- Preserve the path for local inference without coupling the UI to one model stack.

### Progress And Review

- Aggregate event-derived stats such as latency, confidence, replays, and interruptions.
- Expose top mistake tags and quality signals from real practice data.
- Keep the architecture ready for deeper session review and history sync.

### Privacy And Reliability

- Encrypt sensitive local state with secure key storage.
- Keep diagnostics opt-in.
- Keep raw audio retention off by default.
- Enforce secure remote endpoints before cloud calls are allowed.

## Why It Is Different

Most language apps are comfortable as long as you stay inside their happy path. Melangua is being built for the less convenient cases too: weak connectivity, cross-device use, language-specific UI, and a learner who wants the product to be clear about what it stores and why.

## Platform Direction

Melangua is being built as a multi-platform Flutter app with Firebase-backed cloud services and a thin custom backend where it still earns its keep.

## More Docs

- Product architecture: `docs/architecture.md`
- Product requirements: `docs/prd-melangua-offline-flutter-language-tutor.md`
- Delivery plan: `plans/melangua-offline-flutter-language-tutor.md`
- Development and setup: `docs/development.md`
- Manual verification guide: `docs/manual-testing.md`
