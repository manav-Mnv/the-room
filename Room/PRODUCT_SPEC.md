# THE ROOM — Product Specification

**Version:** 1.0 · **Date:** August 2026 · **Author:** M.A.N (Manav)
**Event:** The IndeHub Hackathon 2026 · Tracks: Wellness Loop (primary), Pocket Brain (on-device AI)

---

## 1. Product Overview

**Name:** The Room
**Platform:** iOS (native, SwiftUI)
**Price:** Free. No ads, no subscriptions, no in-app purchases.
**Target user:** Indian students, ages 16–25, dealing with academic stress, loneliness, and everyday emotional struggles.
**Positioning statement:** A private space for your mind, a safe room with others, and a way to breathe together.

**Core thesis:** The hardest part of a student's bad night is facing it alone. The Room combines private self-reflection that never leaves the device with lightweight, anonymous, and physical forms of "you're not alone."

**The problem:** India loses 40 students to suicide every day (14,488 in 2024, up 80% in a decade). Over 80% of Indians struggling with mental health receive no treatment. The barriers for students are stigma, cost, and loneliness.

**What The Room is NOT:** Not a therapy app. Not an AI companion or chatbot. Not a diagnosis tool. Not a social network.

---

## 2. Feature Specification

### F1 — Mood Check-in
- Daily mood log via emoji/slider scale (5 levels)
- Optional one-line note attached to a check-in
- Calendar view of mood history, color-coded by day
- Streak tracking: current streak and longest streak
- All data stored locally on device (SwiftData)
- Daily reminder notification at a user-chosen time
- Home screen widget: shows streak and allows one-tap mood check-in without opening the app (WidgetKit)

### F2 — Private AI Journal
- Free-text journal entries, unlimited length, saved locally
- On submitting an entry, on-device AI (Apple Foundation Models) generates a gentle two-line reflection in a supportive, non-clinical tone (never advice, diagnosis, or therapy language) and two to three emotion tags (e.g., "anxious," "hopeful")
- Works fully offline; journal content is never transmitted anywhere
- Entries browsable by date and linked to that day's mood
- Graceful fallback message on devices without Apple Intelligence support

### F3 — The Room (Anonymous Feed)
- Users post short anonymous confessions or thoughts (text only, character-capped)
- Every post passes through server-side dual-model AI toxicity screening BEFORE publishing; rejected posts never appear
- Crisis-language detection: a post signaling self-harm is not published — the user is gently shown the crisis support screen instead
- Feed is read-and-react only: users can tap "🫂 me too" on posts (anonymous count)
- No comments, no replies, no DMs, no profiles, no usernames, no follower counts, no virality mechanics; chronological feed
- Backend: FastAPI moderation service + Supabase storage (only feature requiring internet)

### F4 — Breathe Together (hero feature)
**Solo mode:**
- Guided breathing session: animated circle expanding/contracting on a 4s inhale / 4s hold / 6s exhale rhythm
- Core Haptics pulses synced to the animation
- Approximately 2-minute sessions; works offline; always available

**Group mode:**
- Up to 8 iPhones join one session over MultipeerConnectivity (Bluetooth/local WiFi; no internet needed)
- One phone hosts; nearby phones discover and join a lobby
- Host starts the session; one sync message (start timestamp + breathing pattern + duration) is sent; every phone runs an identical local timer from the shared start time
- All screens animate and all phones pulse haptics in unison
- Resilient by design: the session continues even if the connection drops mid-session, because no continuous streaming is required

**Completion screen:** synced across all devices — "You breathed together for 2 minutes 🫂"

### F5 — Crisis Support
- Dedicated help screen reachable from anywhere in the app
- One-tap call buttons: Tele-MANAS (14416) and KIRAN (1800-599-0019)
- Surfaced automatically by crisis-word detection in F3
- Non-judgmental, calm copy; no gatekeeping; no sign-in required

### F6 — Accessibility & Quality Baseline
- Full Dynamic Type support
- VoiceOver labels on all interactive elements
- Dark mode support
- No account required for any local feature (F1, F2, F4 solo)

---

## 3. Technical Architecture

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Local persistence | SwiftData |
| On-device AI | Apple Foundation Models framework |
| Haptics | Core Haptics |
| Device-to-device sync | MultipeerConnectivity |
| Widget | WidgetKit |
| Notifications | UserNotifications |
| Feed backend | FastAPI (moderation) + Supabase (storage) |
| Moderation models | Dual-model toxicity screening (toxic-bert + martin-ha) |

**Privacy architecture:** Mood data, journal entries, and AI processing are 100% on-device. The only data that ever leaves the phone is an anonymous feed post, and only after the user explicitly submits it.

---

## 4. Design Principles
1. **Private by architecture, not by policy** — the sensitive data physically cannot leave the device
2. **Co-presence without words** — support should not require explaining yourself
3. **Calm over engagement** — no infinite-scroll hooks, no gamified dopamine beyond gentle streaks
4. **Safety is a feature** — moderation and crisis routing ship in v1, not v2
5. **Reflection, not therapy** — AI observes and reflects; it never advises, diagnoses, or role-plays

---

## 5. Demo Narrative (5-minute arc)
1. Open on the money shot: three to four iPhones on a table, Breathe Together running, all circles and haptics in unison
2. Daily mood check-in from the home screen widget
3. Write a journal entry; on-device AI reflects, shown working offline (airplane mode)
4. Open The Room feed; read posts; tap 🫂
5. Attempt to post something toxic; moderation blocks it on camera
6. Crisis screen walkthrough
7. Close on the completion screen: "You breathed together"

---

## 6. Out of Scope (v1) — Roadmap
Hindi/vernacular support · voice journaling · ElevenLabs narration · Apple Watch app · HealthKit correlations · Siri App Intents · weekly AI summaries · exam mode · post comments · Silent SOS buddy alerts · Tap to Share session start · campus B2B dashboards · therapist referrals
