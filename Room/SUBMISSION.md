# The Room — Hackathon Submission Draft

> Draft for The IndeHub Hackathon 2026. Fill in the ⚠️ placeholders once the
> Mac/build/demo-recording blockers (HANDOFF §2) are resolved.

## Problem / User / Product

**Problem.** India loses roughly 40 students to suicide every day — 14,488 in
2024, up 80% in a decade — and over 80% of Indians struggling with mental
health receive no treatment at all. For students specifically, the barriers
aren't awareness, they're stigma, cost, and loneliness: the hardest part of a
bad night is facing it alone, with no private, judgment-free place to put it.

**User.** Indian students aged 16–25 — in college, under academic and family
pressure, often away from home for the first time, carrying phones but not
therapists.

**Product.** The Room is a free, privacy-first iOS wellness app built around
four pillars: a daily mood check-in with streaks and a home-screen widget; a
private journal that reflects back on-device via Apple Foundation Models and
never transmits a word; The Room, a moderated anonymous peer feed where
"you're not alone" costs one tap, not a profile; and Breathe Together, the
hero feature — up to 8 iPhones syncing one guided breathing session over
MultipeerConnectivity, haptics and animation in unison, no internet required.
A crisis screen (Tele-MANAS 14416, KIRAN 1800-599-0019) is always one tap
away. No accounts for local features, no ads, no subscriptions, no paywall —
because a student in crisis shouldn't hit one.

## Platform + WWDC26 technologies used

- **SwiftUI** — 100% native UI, iOS 26 minimum deployment
- **SwiftData** — local mood/journal persistence, App-Group-shared with the widget
- **Apple Foundation Models** — on-device journal reflection + emotion tagging,
  guided generation into a typed `@Generable` struct, availability-checked
  with a graceful fallback on non-Apple-Intelligence hardware
- **WidgetKit + App Intents** — home-screen streak widget with an interactive
  one-tap check-in (`LogMoodIntent`), no app launch required
- **Core Haptics** — breath-synced haptic ramp (inhale) / tick (hold) / fade
  (exhale), prebuilt `CHHapticPattern`s
- **MultipeerConnectivity** — peer-to-peer group breathing sessions, one sync
  message per session, zero continuous network traffic
- **UserNotifications** — daily local reminder, gentle non-guilt copy

## Attributions

- **FastAPI** — moderation gate backend framework
- **Supabase** — Postgres + REST API for the anonymous feed
- **Hugging Face Inference API** — hosting for the toxicity models
- **`unitary/toxic-bert`** and **`martin-ha/toxic-comment-model`** — dual-model
  toxicity screening (either model flagging a post is enough to reject it)

## Known limitations (disclosed up front, not discovered by judges)

- English-only in v1 — Hindi/vernacular support is roadmap, not built.
- AI journal reflections require Apple Intelligence-capable hardware
  (iPhone 15 Pro or newer). On older devices/simulators the app still saves
  entries normally and shows a friendly "reflections aren't available on this
  device" notice — it never blocks journaling.
- The Room feed requires network connectivity; moderation adds roughly 1-3
  seconds of latency to each post submission (two model calls + a DB write).
- Group Breathe sessions require physical proximity (Bluetooth/local WiFi
  permission) — this is by design (privacy: no server involved), not a bug.

## Judge instructions: running a group Breathe session

1. Install the app on two (or more) physical iPhones — the simulator cannot
   exercise MultipeerConnectivity or Core Haptics.
2. On device A: Breathe tab → **Breathe together** (this device becomes the
   host and starts advertising over local WiFi/Bluetooth).
3. On device B (and any others): Breathe tab → **Join a nearby session** (this
   device browses and auto-connects to the first host it finds).
4. Once device B shows up in device A's lobby, tap **Start breathing · 2 min**
   on the host. All connected devices receive one sync message and begin an
   identical local countdown — you should see every circle expand/contract in
   step, with haptics in unison.
5. To verify resilience: toggle Bluetooth off on device B mid-session. The
   session keeps running to completion on both devices anyway — no
   reconnection is needed, because after the single start-of-session message
   each phone runs its own local clock (see `BreathingClock.swift` and its
   unit tests for the mechanism).
6. Both devices should reach the completion screen ("You breathed together
   for 2 minutes 🫂") at the same moment.

⚠️ **Still needed before this section is submission-ready:**
- ⚠️ Confirm on real hardware: cross-device drift is ≤200ms (SRS NFR-2.3).
- ⚠️ Deploy the backend (`TheRoom/backend/README.md`) and drop live
  Supabase/HF credentials into `RoomConfig.swift` — the feed is inert until
  then.
- ⚠️ Record the 5-minute demo per `PRODUCT_SPEC.md` §5 (open on multi-phone
  Breathe Together, widget check-in, airplane-mode journal reflection, feed +
  live moderation rejection, crisis screen, completion screen).
- ⚠️ Team/app name, screenshots, and any hackathon-portal-specific fields.
