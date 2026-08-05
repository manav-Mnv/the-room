# Software Requirements Specification (SRS)
## The Room — iOS Mental Wellness Application

**Version:** 1.0 · **Date:** August 2026 · **Author:** M.A.N (Manav)
**Standard:** Adapted from IEEE 830
**Event context:** The IndeHub Hackathon 2026

---

## 1. Introduction

### 1.1 Purpose
This document specifies the functional and non-functional requirements for The Room, a native iOS mental wellness application for Indian students. It is the reference for development, testing, and hackathon submission evidence.

### 1.2 Scope
The Room provides four capabilities: (1) daily mood tracking with habit reinforcement, (2) a private journal with on-device AI reflection, (3) a moderated anonymous peer-support feed, and (4) solo and multi-device synchronized guided breathing. The app is free, English-language, and iOS-only in v1.

### 1.3 Definitions and Abbreviations
- **FM** — Apple Foundation Models framework (on-device LLM, iOS 26+)
- **MPC** — MultipeerConnectivity framework
- **Check-in** — a single daily mood log event
- **Session** — one guided breathing run (solo or group)
- **Host** — the device that creates a group breathing session
- **Post** — an anonymous text entry submitted to The Room feed
- **Moderation service** — server-side FastAPI service running dual toxicity models

### 1.4 References
- Apple Foundation Models documentation (developer.apple.com)
- MultipeerConnectivity documentation
- IndeHub Hackathon 2026 Hacker Guide (indehub.org/hackathon/2026/guide)
- Tele-MANAS (14416), KIRAN (1800-599-0019) national helplines

### 1.5 Overview
Section 2 describes the product context; Section 3 lists detailed requirements; Section 4 covers non-functional requirements; Section 5 covers external interfaces; Section 6 covers constraints and assumptions.

---

## 2. Overall Description

### 2.1 Product Perspective
Standalone iOS application. Features F1, F2, F4 (solo), and F5 operate fully offline with on-device storage. Feature F3 depends on a hosted backend (FastAPI + Supabase). Feature F4 (group) uses peer-to-peer local networking with no server.

### 2.2 User Classes
- **Primary user:** student aged 16–25, iPhone owner, seeking low-friction emotional self-care
- **Group participant:** friend/peer of primary user joining a breathing session
- **Judge/evaluator:** hackathon reviewer assessing via TestFlight or screen recording

### 2.3 Operating Environment
- iOS 26 or later (target SDK: iOS 27 beta where available)
- Foundation Models features require an Apple Intelligence-capable device (iPhone 15 Pro or newer); the app must degrade gracefully on older devices
- Group sessions require Bluetooth/local WiFi permission
- Feed requires internet connectivity

### 2.4 Design Constraints
- Native SwiftUI only (hackathon eligibility: no cross-platform frameworks)
- Journal and mood data must never leave the device (product principle)
- No user accounts for local features; no personal identity attached to feed posts
- AI output must never contain medical advice, diagnosis, or therapeutic claims

### 2.5 Assumptions and Dependencies
- The moderation backend remains deployed and reachable during the judging window
- At least two physical iPhones are available for group-session demonstration
- Apple Foundation Models APIs behave as documented in the installed SDK

---

## 3. Functional Requirements

### FR-1: Mood Check-in
- **FR-1.1** The system shall allow the user to record one mood check-in per calendar day on a 5-level scale.
- **FR-1.2** The system shall allow an optional text note (≤140 characters) per check-in.
- **FR-1.3** The system shall persist check-ins locally using SwiftData.
- **FR-1.4** The system shall display a calendar view with each day color-coded by recorded mood.
- **FR-1.5** The system shall compute and display the current streak and the longest streak of consecutive check-in days.
- **FR-1.6** The system shall allow the user to schedule one daily local reminder notification at a chosen time.
- **FR-1.7** The system shall provide a home screen widget displaying the current streak.
- **FR-1.8** The widget shall allow a mood check-in with a single tap, without launching the full app, via an interactive widget intent.
- **FR-1.9** If a check-in already exists for today, the system shall show today's mood instead of prompting again.

### FR-2: Private AI Journal
- **FR-2.1** The system shall allow creation of free-text journal entries of unlimited length, stored locally.
- **FR-2.2** Upon entry submission, the system shall generate, on-device via Foundation Models: (a) a reflection of at most two sentences in a warm, non-clinical tone, and (b) two to three emotion tags.
- **FR-2.3** AI generation shall function with no network connectivity.
- **FR-2.4** Journal content shall never be transmitted off-device.
- **FR-2.5** The system shall link each entry to the same-day mood check-in when one exists.
- **FR-2.6** The system shall present entries in a browsable, date-sorted list.
- **FR-2.7** On devices without Apple Intelligence support, the system shall save entries normally and display a friendly notice that AI reflections are unavailable on this device.
- **FR-2.8** AI prompts shall constrain output to reflection only: no advice, no diagnosis, no treatment suggestions, no role-play.

### FR-3: The Room (Anonymous Feed)
- **FR-3.1** The system shall allow submission of anonymous text posts (≤500 characters).
- **FR-3.2** Every post shall be evaluated by the server-side moderation service BEFORE publication.
- **FR-3.3** Posts classified as toxic by either moderation model shall be rejected and never displayed publicly.
- **FR-3.4** On rejection, the system shall show the author a non-punitive message without publishing the content.
- **FR-3.5** Posts containing crisis/self-harm language shall not be published; the system shall instead present the crisis support screen (FR-5) to the author.
- **FR-3.6** The feed shall display approved posts in reverse-chronological order.
- **FR-3.7** Users shall be able to tap a "me too" reaction on any post; the system shall display an anonymous aggregate count.
- **FR-3.8** The system shall NOT support comments, replies, direct messages, usernames, profiles, or follower mechanics.
- **FR-3.9** Posts shall carry no device identifier or personal information in the published record.
- **FR-3.10** When the feed is unreachable, the system shall show cached posts (if any) and an offline notice; composing shall be disabled offline.

### FR-4: Breathe Together
**Solo mode:**
- **FR-4.1** The system shall provide a guided breathing session with an animated circle following a 4s inhale / 4s hold / 6s exhale cycle.
- **FR-4.2** Core Haptics feedback shall be synchronized to each breathing phase (ramp on inhale, tick on hold, fade on exhale).
- **FR-4.3** Default session length shall be 2 minutes; the session shall be cancellable at any time.
- **FR-4.4** Solo mode shall function fully offline.

**Group mode:**
- **FR-4.5** The system shall allow a user to host a group session discoverable by nearby devices via MultipeerConnectivity.
- **FR-4.6** The system shall support 2 to 8 connected devices per session.
- **FR-4.7** The host lobby shall display the count and names (device-chosen display names) of joined peers.
- **FR-4.8** On start, the host shall broadcast exactly one sync message containing: session start timestamp, breathing pattern, and duration.
- **FR-4.9** Each device shall run its own local timer from the shared start timestamp; no continuous network traffic shall be required during the session.
- **FR-4.10** A session in progress shall continue to completion on each device even if peer connectivity is lost.
- **FR-4.11** On completion, all devices shall display a synchronized completion screen ("You breathed together for 2 minutes").
- **FR-4.12** If no peers join within a reasonable time, the host shall be able to start solo seamlessly.

### FR-5: Crisis Support
- **FR-5.1** The system shall provide a crisis support screen accessible from the main navigation at all times.
- **FR-5.2** The screen shall provide one-tap call actions for Tele-MANAS (14416) and KIRAN (1800-599-0019).
- **FR-5.3** The crisis screen shall be presented automatically when FR-3.5 triggers.
- **FR-5.4** The crisis screen shall require no sign-in, no data entry, and no confirmation steps before enabling the call action.

### FR-6: Onboarding & Settings
- **FR-6.1** First launch shall present a brief (≤3 screens) onboarding explaining privacy ("your journal never leaves your iPhone") and the app's non-therapeutic nature.
- **FR-6.2** Settings shall allow: reminder time change, display name for group sessions, and data erasure (delete all local data).
- **FR-6.3** The app shall include a visible disclaimer that it is not a substitute for professional mental health care.

---

## 4. Non-Functional Requirements

### NFR-1: Privacy & Security
- **NFR-1.1** Mood and journal data shall be stored only in the app's local container.
- **NFR-1.2** No analytics SDK shall collect journal or mood content.
- **NFR-1.3** Feed submissions shall be transmitted over HTTPS only.
- **NFR-1.4** The published feed record shall contain only: post text, timestamp, reaction count.

### NFR-2: Performance
- **NFR-2.1** App cold launch to interactive: ≤2 seconds on target hardware.
- **NFR-2.2** On-device AI reflection generation: ≤10 seconds per entry; a progress indicator shall be shown.
- **NFR-2.3** Group session cross-device drift: ≤200 ms perceptible offset between devices.
- **NFR-2.4** Widget check-in round-trip: ≤1 second.

### NFR-3: Reliability
- **NFR-3.1** All local features shall function with zero network connectivity.
- **NFR-3.2** Moderation service unavailability shall never cause an unmoderated post to publish (fail-closed).
- **NFR-3.3** App shall not crash on denial of any permission (notifications, local network, Bluetooth); features shall degrade with explanatory messaging.

### NFR-4: Usability & Accessibility
- **NFR-4.1** All screens shall support Dynamic Type up to accessibility sizes.
- **NFR-4.2** All interactive elements shall have VoiceOver labels.
- **NFR-4.3** The app shall support light and dark mode.
- **NFR-4.4** Breathing guidance shall be followable without sound (visual + haptic).
- **NFR-4.5** Copy tone across the app shall be calm, non-judgmental, and free of clinical jargon.

### NFR-5: Safety & Ethics
- **NFR-5.1** AI-generated text shall never include diagnosis, medical advice, or therapeutic claims.
- **NFR-5.2** The app shall not use engagement-maximizing dark patterns (infinite scroll rewards, variable-ratio notifications, guilt messaging on broken streaks).
- **NFR-5.3** Crisis routing shall take precedence over all other flows when triggered.

---

## 5. External Interface Requirements

### 5.1 User Interface
SwiftUI throughout; TabView navigation with four tabs: Today (mood), Journal, The Room, Breathe. Crisis support reachable from a persistent toolbar affordance on every tab.

### 5.2 Software Interfaces
- **Foundation Models API** — on-device text generation (reflection, emotion tagging) via guided generation into typed structures
- **Moderation API** — `POST /confession/submit` (FastAPI): request {text}; response {approved: bool, reason?, crisis: bool}
- **Feed API** — Supabase REST: fetch approved posts, submit reaction increments
- **WidgetKit / App Intents** — interactive widget check-in intent
- **UserNotifications** — daily local reminder

### 5.3 Communication Interfaces
- HTTPS (TLS 1.2+) for all backend calls
- MultipeerConnectivity over Bluetooth/peer-to-peer WiFi for group sessions (local only, unencrypted content limited to session metadata)

---

## 6. Constraints, Assumptions, Acceptance

### 6.1 Constraints
- Hackathon submission window: 1–7 August 2026
- Solo developer; native Apple client mandatory
- Foundation Models hardware floor: iPhone 15 Pro or newer

### 6.2 Acceptance Criteria (submission-ready definition)
1. A new user can check in a mood from the widget and see the streak update.
2. A journal entry written in airplane mode receives an AI reflection.
3. A toxic post is demonstrably rejected; a normal post appears in the feed; a crisis-flagged post routes to the crisis screen.
4. Two or more physical iPhones run a visibly synchronized breathing session with haptics, surviving a mid-session Bluetooth interruption.
5. VoiceOver can complete a mood check-in end to end.
6. The demo recording captures criteria 1–4 on camera.

### 6.3 Known Limitations (to disclose in submission)
- English-only in v1
- AI reflections require Apple Intelligence-capable hardware
- Feed requires network; moderation latency adds 1–3 s to post submission
- Group sessions require physical proximity (local network permission)
