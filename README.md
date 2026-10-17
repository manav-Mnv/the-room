<div align="center">

# The Room

**A free, privacy-first mental wellness app for Indian students.**
*A private space for your mind, a safe room with others, and a way to breathe together.*

![Status](https://img.shields.io/badge/status-hackathon%20submission-8250df?style=flat-square)
![Backend](https://img.shields.io/badge/backend-live-2ea44f?style=flat-square)
![iOS 26+](https://img.shields.io/badge/iOS-26%2B-000000?style=flat-square&logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-0A84FF?style=flat-square&logo=swift&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?style=flat-square&logo=supabase&logoColor=white)

Built for **The IndeHub Hackathon 2026** · Tracks: *Wellness Loop* and *Pocket Brain (on-device AI)*

</div>

---

## Why

India loses around 40 students to suicide every day, and more than 80% of Indians who struggle with their mental health get no treatment. For students the barriers are stigma, cost and loneliness. The Room is built around one idea: the hardest part of a bad night is facing it alone.

It is **not** a therapy app, a chatbot, a diagnosis tool or a social network. No accounts for local features, no ads, no subscriptions, no paywall.

## Features

| | Feature | How it works |
| --- | --- | --- |
| 🙂 | **Mood check-in** | Daily 5-level mood log with an optional note, streaks, a colour-coded calendar, a gentle daily reminder, and a home-screen widget with one-tap check-in. All data stays on the device (SwiftData). |
| 📓 | **Private AI journal** | Write freely; Apple Foundation Models writes a two-line, non-clinical reflection and emotion tags **on the device**. Nothing is ever sent anywhere. Falls back gracefully on phones without Apple Intelligence. |
| 🫂 | **The Room feed** | Anonymous, text-only posts. Every post is screened by two toxicity models *before* it is published; posts with crisis language are never shown, and the writer is taken to the support screen instead. Read and react ("me too") only: no comments, profiles or follower counts. |
| 🌬️ | **Breathe Together** | Guided breathing with breath-synced haptics, solo or with up to 8 iPhones nearby over MultipeerConnectivity. One sync message starts the session; each phone then runs its own clock, so it keeps going even if Bluetooth drops. |
| 🆘 | **Crisis support** | One tap from every screen: Tele-MANAS **14416** and KIRAN **1800-599-0019**. |

## Tech stack

| Layer | Tools |
| --- | --- |
| iOS app | SwiftUI · SwiftData · Apple Foundation Models · WidgetKit + App Intents · Core Haptics · MultipeerConnectivity · UserNotifications |
| Moderation backend | Python 3.11 · FastAPI · Hugging Face Inference API (`unitary/toxic-bert` + `martin-ha/toxic-comment-model`) |
| Feed storage | Supabase (Postgres + Row Level Security) |
| Hosting | Render (backend) |
| Project generation | XcodeGen (`project.yml`) |

## How the feed stays safe

```
iOS app ──POST /confession/submit──▶ FastAPI gate ──▶ crisis-language check
                                          │                 │ crisis → app shows support screen
                                          ▼
                              2 toxicity models (either can reject)
                                          │ approved
                                          ▼
                             Supabase `posts` (service key, server only)
iOS app ◀──────── reads `posts` directly with the anon key (SELECT-only via RLS)
```

The gate **fails closed**: if a model or the database is unavailable, the post is rejected rather than published unmoderated.

## Getting started

### iOS app (needs a Mac)

```sh
brew install xcodegen
cd TheRoom
xcodegen generate
open TheRoom.xcodeproj
```

In Xcode, set your signing team and confirm the App Group `group.com.man.theroom` is enabled for both the app and widget targets. Group breathing and haptics need **physical iPhones**; the simulator can't exercise them.

### Moderation backend

```sh
cd TheRoom/backend
cp .env.example .env        # SUPABASE_URL, SUPABASE_SERVICE_KEY, HF_API_TOKEN, TOXICITY_THRESHOLD
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
python seed.py              # optional: seed the feed
```

Run `schema.sql` in your Supabase project's SQL editor first. More detail in [`TheRoom/backend/README.md`](TheRoom/backend/README.md).

## Project structure

```
Room/                   Product spec, SRS, build plan and hackathon submission notes
TheRoom/
├── project.yml         XcodeGen project definition
├── TheRoom/
│   ├── App/            App entry and tab navigation
│   ├── DesignSystem/   Theme tokens and shared components
│   ├── Features/       Today · Journal · Room · Breathe · Crisis · Onboarding · Settings
│   ├── Models/         MoodEntry, JournalEntry, Post
│   └── Services/       AI reflection, feed + moderation APIs, breathing clock, haptics, streaks
├── TheRoomWidget/      Streak widget + one-tap mood intent
├── TheRoomTests/       BreathingClock and StreakCalculator tests
└── backend/            FastAPI moderation gate, schema.sql, seed script
```

## Documentation

- [Product specification](Room/PRODUCT_SPEC.md)
- [Software requirements (SRS)](Room/SRS.md)
- [Hackathon submission](Room/SUBMISSION.md)

## Author

Built solo by **[Manav](https://github.com/manav-Mnv)** (team M.A.N) for The IndeHub Hackathon 2026.
