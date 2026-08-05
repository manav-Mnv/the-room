# BUILD_PROMPT.md — The Room (iOS)

> Paste this into Claude Code at the start of the project. Work phase by phase, in order. Do not skip ahead. After each phase, build, run, and verify the acceptance checks before moving on.

---

## What you are building

**The Room** — a free, privacy-first mental wellness iOS app for Indian students (16–25). Native SwiftUI. English only. No accounts for local features. No ads, no subscriptions, no paywall.

Four pillars:
1. **Mood Core** — daily mood check-in, streaks, calendar, home-screen widget
2. **Private AI Journal** — on-device reflections via Apple Foundation Models (never leaves the phone)
3. **The Room feed** — anonymous posts, server-side AI toxicity moderation BEFORE publish, "🫂 me too" reactions
4. **Breathe Together** — solo haptic breathing + up to 8 iPhones in one synced session via MultipeerConnectivity (**hero feature**)

Plus: crisis support screen (Tele-MANAS 14416, KIRAN 1800-599-0019), accessibility baseline.

**Not building:** AI chat companion, comments/replies, HealthKit, Siri intents, voice journaling, Hindi, Watch app, payments. These are roadmap. Do not add them.

Reference docs in repo root: `PRODUCT_SPEC.md` (what/why) and `SRS.md` (numbered requirements FR-1.1…FR-6.3, NFRs, acceptance criteria). When in doubt, SRS wins.

---

## Project setup

- Xcode project: `TheRoom`, iOS 26 minimum deployment, SwiftUI lifecycle, SwiftData enabled
- Targets: main app + widget extension (`TheRoomWidget`)
- Bundle structure:
```
TheRoom/
  App/            TheRoomApp.swift, RootTabView.swift
  Models/         MoodEntry.swift, JournalEntry.swift, Post.swift
  Features/
    Today/        (mood check-in, streaks, calendar)
    Journal/      (entries, AI reflection)
    Room/         (feed, composer)
    Breathe/      (solo + group session)
    Crisis/       (help screen)
    Onboarding/
  Services/       AIReflectionService.swift, ModerationAPI.swift, BreatheSessionManager.swift, HapticEngine.swift, StreakCalculator.swift
  DesignSystem/   Theme.swift, Components/
TheRoomWidget/    (widget + AppIntent for one-tap check-in)
```
- Navigation: `TabView` with 4 tabs — Today, Journal, The Room, Breathe. Crisis support: heart/lifebuoy toolbar button visible on every tab.

---

## Design system (implement first — Theme.swift)

Warm nude palette, ONE accent. Figma reference: https://www.figma.com/design/pScdCmhdgC5aP0K7MWcV8Y

```swift
// Light mode
bgBase        #FAF6F1   // app background
bgCard        #F3ECE4   // cards
bgElevated    #EDE3D7   // sheets, pressed states
bgBreathe     #2C2420   // breathing screen background (both modes stay dark)
textPrimary   #3E3A36   // never pure black
textSecondary #8A8178
textMuted     #B5AB9F
accent        #C97B5D   // terracotta — buttons, breathing circle, selection, streak. THE ONLY ACCENT.
claySoft      #E5C3B3   // accent-tinted fills
olive         #7D8A5C   // success/streak positive
ochre         #D9A45B   // gentle warnings (NEVER red anywhere in this app)

// Dark mode
bgBase #1E1A17 · bgCard #2A2420 · bgElevated #362E28 · textPrimary #EDE6DD · textSecondary #A99E92 · textMuted #7A7166 · accent stays #C97B5D
```

Rules:
- Define as Color assets with light/dark variants; expose via `Theme` enum
- Typography: system SF Pro; use `.fontDesign(.rounded)` on headings, mood numbers, streak counts
- Corner radius: 24 on cards, capsule on buttons/pills
- No drop shadows — depth via surface tint layers (Headspace-style)
- All text uses Dynamic Type text styles (`.title2`, `.body`, etc.) — never fixed point sizes
- Every interactive element gets an `accessibilityLabel`

---

## PHASE 1 — Mood Core

**Build:** SRS FR-1.1 → FR-1.9

1. `MoodEntry` SwiftData model: `date: Date` (startOfDay, unique), `level: Int` (1–5), `note: String?`
2. Today tab: greeting, "How are you feeling today?", 5-emoji row (😞😕😐🙂😄), selected emoji fills terracotta; optional note field (140 chars); save button. If today already logged → show today's mood + streak instead of the picker.
3. `StreakCalculator`: current streak (consecutive days ending today/yesterday), longest streak. Unit-test this — off-by-one date bugs are guaranteed otherwise. Handle timezone via `Calendar.current.startOfDay`.
4. Calendar month view: each day tinted by mood level (claySoft → terracotta scale), tap a day to see note.
5. Daily reminder: `UserNotifications`, one notification at user-chosen time (Settings), gentle copy: "A minute for yourself?" — never guilt-based.
6. Widget extension: small widget shows streak 🔥 + today's state; interactive `AppIntent` buttons for one-tap mood log (all 5 levels won't fit — use 3: 😞😐😄 mapping to 1/3/5). Shared SwiftData container via App Group `group.com.man.theroom`.

**Accept when:** check-in from widget updates streak in app without opening it; streak survives app relaunch; calendar shows history; VoiceOver can complete a check-in.

---

## PHASE 2 — Private AI Journal

**Build:** SRS FR-2.1 → FR-2.8

1. `JournalEntry` model: `date`, `text`, `reflection: String?`, `emotions: [String]`
2. Journal tab: date-sorted entry list → editor. On save, call `AIReflectionService`.
3. `AIReflectionService` using **Foundation Models framework**:
   - Check `SystemLanguageModel.default.availability` first; if unavailable → save entry normally, set a friendly flag ("Reflections aren't available on this device")
   - Use guided generation into a struct: `{ reflection: String, emotions: [String] }`
   - Prompt contract (critical): "You are a gentle, quiet companion reading a student's private journal entry. Reply with a two-sentence warm reflection that acknowledges what they felt. Never give advice, never diagnose, never mention therapy or treatment, never role-play, never ask questions. Also return 2–3 single-word emotion tags."
   - Show progress indicator during generation (≤10 s budget); generation must work in airplane mode
4. Entry detail view: text, reflection in a claySoft card, emotion tags as capsules, linked mood of that day.

**Accept when:** entry written in airplane mode gets a reflection + tags; older-device fallback path shows the notice and still saves; reflections never contain advice ("you should…" = prompt bug, fix it).

---

## PHASE 3 — The Room feed

**Build:** SRS FR-3.1 → FR-3.10. Backend already exists (FastAPI `/confession/submit` with toxic-bert + martin-ha, from the bloom-whispers-nexus repo) — adapt and deploy it, don't rewrite it.

1. Backend prep: deploy FastAPI service to Railway/Render; endpoint contract: `POST /confession/submit` → `{ approved: Bool, crisis: Bool, reason: String? }`. Add crisis-keyword pass (self-harm phrases list) alongside toxicity models. Approved posts write to Supabase table `posts (id, text, created_at, metoo_count)`. **Fail closed:** if moderation errors → not published.
2. iOS `ModerationAPI` + `FeedAPI` (Supabase REST, anon key, read + RPC increment for me-too).
3. Feed UI: chronological cards, relative time, 🫂 count button (one tap per post per device — store reacted IDs locally). Pull to refresh. Offline → cached posts + notice, composer disabled.
4. Composer: 500-char limit, "Posting anonymously" note, submit → spinner → outcomes: approved (appears in feed) / rejected (kind copy: "This one can't be posted — The Room stays gentle for everyone") / crisis (→ present Crisis screen, do not publish, extra-soft copy).
5. Seed script: insert 25–30 realistic student confessions into Supabase (exam fear, homesickness, family pressure, small wins). Feed must never demo empty.

**Accept when:** normal post round-trips to feed; toxic post visibly rejected; crisis phrasing routes to Crisis screen; me-too increments once; airplane mode shows cache + disabled composer.

---

## PHASE 4 — Breathe Together (hero — polish this hardest)

**Build:** SRS FR-4.1 → FR-4.12

1. **Solo session:** full-screen `bgBreathe` dark view (always dark, both modes). Terracotta circle with 2 soft outer glow layers (opacity 0.15/0.3). Rhythm 4s in / 4s hold / 6s out, driven by one `BreathingClock` (start date + pattern → phase at any instant; pure function, testable). Phase label ("Breathe in / Hold / Breathe out"), countdown, End button. 2-minute default.
2. `HapticEngine` (Core Haptics): inhale = intensity ramp 0.3→0.8 over 4s; hold = single soft tick; exhale = fade 0.8→0.1 over 6s. Prebuild `CHHapticPattern`s; respect device support check.
3. **Group session** via `BreatheSessionManager` (MultipeerConnectivity, service type `theroom-breathe`):
   - Host: advertise + lobby view listing joined peers ("2 friends here"), Start button
   - Join: browse → tap host → land in lobby
   - On start, host broadcasts ONE message: `{ startAt: Date (2s in future), pattern: [4,4,6], duration: 120 }`. Every device (host included) runs its own `BreathingClock` from `startAt`. NO further network traffic during the session.
   - Connection drop mid-session → session continues locally to completion (this is free with the clock design — verify it)
   - No peers joined → "Start alone" path into solo
4. Completion screen, all devices (timer-driven, so it syncs automatically): "You breathed together for 2 minutes 🫂", peer count, Done.
5. Today-tab CTA card (dark card, terracotta subtitle: "Start a session — friends nearby can join").

**Accept when:** two physical iPhones visibly pulse in step (haptics + animation) with ≤200 ms drift; killing Bluetooth mid-session doesn't stop either device; solo works offline; completion screens appear together.

---

## PHASE 5 — Crisis, Onboarding, Accessibility

1. Crisis screen (FR-5): calm ivory background, terracotta call buttons — "Call Tele-MANAS · 14416" and "Call KIRAN · 1800-599-0019" via `tel:` links; line: "Talking to someone can help. These lines are free, confidential, and always open." Reachable from toolbar everywhere + auto-presented on crisis-flagged posts. NO red anywhere.
2. Onboarding (FR-6): 3 screens max — (1) "A private space for your mind" + privacy line "Your journal never leaves your iPhone", (2) "Breathe together" intro, (3) "The Room is not therapy" disclaimer + notification permission ask. Skippable.
3. Settings: reminder time, display name for group sessions, Delete All My Data (with confirm), About + disclaimer.
4. Accessibility sweep: Dynamic Type XL pass on every screen, VoiceOver labels audit, breathing screen usable without sound (it already is — verify phase label + haptics suffice).

---

## PHASE 6 — Ship prep

1. App icon: terracotta circle on nude field (simple, flat)
2. Empty states for every list (warm copy, never bleak)
3. Demo seed: ensure feed seeded, streak data present on demo device (debug menu to inject 7-day streak)
4. Record demo (5 min): OPEN with multi-phone Breathe Together shot → widget check-in → journal + airplane-mode reflection → feed + live moderation rejection → crisis screen → completion screen. 
5. Submission text: problem/user/product, platforms + WWDC26 tech used (Foundation Models, WidgetKit/App Intents, Core Haptics, MultipeerConnectivity, SwiftData), attributions (FastAPI, Supabase, toxic-bert, martin-ha, Hugging Face), known limitations (from SRS 6.3), judge instructions (how to run a group session with 2 devices).

---

## Ground rules for the AI pair (read carefully)

- **Working > complete.** If a phase runs long, cut scope inside the phase, never ship a half-broken flow. Cut order if catastrophic: Phase 3 → Phase 2 AI (keep plain journal) → never Phase 4.
- **Copy tone everywhere:** warm, brief, non-clinical, non-guilt. Broken streak = "Fresh start today" — never "You lost your streak."
- **No dark patterns:** no infinite scroll tricks, no push-notification pressure, no celebration walls blocking exit.
- **AI safety:** reflection prompts are locked to the contract in Phase 2. If output ever includes advice/diagnosis, treat as a bug.
- **Test the two fragile things:** `StreakCalculator` (unit tests, date edge cases) and `BreathingClock` (unit tests, phase math). Everything else can be manually verified.
- **Commit per phase** with message `Phase N: <summary>`.
