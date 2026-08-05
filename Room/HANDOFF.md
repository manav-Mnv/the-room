# HANDOFF — The Room

> **Purpose:** single source of truth for any session (Claude Code, new chat, or future me) picking up this project. Read this first. Update it at the end of every work session.

**Last updated:** 2 August 2026
**Owner:** Manav (PIERC) · solo · team **M.A.N** · Student Developer
**Event:** The IndeHub Hackathon 2026 · registered ✅ (app name submitted as "The Room")

---

## 1. What we're building (one paragraph)

**The Room** — a free, privacy-first mental wellness **native iOS app (SwiftUI)** for Indian students (16–25). English only. No accounts for local features, no ads, no subscriptions. Four pillars: (1) daily **mood check-in** with streaks + home widget, (2) private **AI journal** with on-device reflections via Apple Foundation Models (never leaves the phone), (3) **The Room** anonymous feed with server-side AI toxicity moderation before publish, (4) **Breathe Together** — the hero: up to 8 iPhones sync one guided breathing session over MultipeerConnectivity, haptics in unison. Plus a crisis screen (Tele-MANAS 14416, KIRAN 1800-599-0019).

**Positioning:** "A private space for your mind, a safe room with others, and a way to breathe together."
**Tracks entered:** Wellness Loop (primary) + Pocket Brain (on-device AI).

---

**6 Aug 2026 — Supabase live, moderation backend not yet deployed.** User provided real Supabase project URL + anon key (service key and HF token also given, stored only in gitignored `backend/.env`, never committed — a real secret-leak near-miss happened here: user first pasted them into the *tracked* `.env.example`, caught before commit, `backend/.env` added to `.gitignore`). Wired `supabaseURL`/`supabaseAnonKey` into `RoomConfig.swift`. Split `RoomConfig.isConfigured` into `isSupabaseConfigured` (gates feed reads + reactions) and `isModerationConfigured` (gates posting, still false — `moderationBaseURL` is still a placeholder) so the feed can read live Supabase data now, with posting disabled and a "reading is live, posting opens once deployed" notice, rather than gating everything on the one field that isn't set yet. **Next:** deploy `backend/` (Railway/Render, see `backend/README.md`) using the `.env` values already sitting there, run `python seed.py`, then drop the deployed URL into `RoomConfig.moderationBaseURL`.

## 2. 🚨 OPEN BLOCKERS (resolve before/while building)

1. **MAC ACCESS — critical, unresolved.** Dev machine is **Windows** (`M:\indehub`). iOS apps cannot be built/run/recorded on Windows — Xcode is macOS-only. Need a Mac (own / friend / college lab / cloud Mac like MacinCloud ~$20/mo) before the Aug 7 deadline for compile + demo recording. Claude Code can write Swift on Windows; the .swift files transfer to a Mac to build. **This must be solved.**
2. **Foundation Models hardware — confirmed NOT available on dev machine.** So `AIReflectionService` must ship with an availability check + graceful fallback ("Reflections aren't available on this device"). AI reflections only demo on an Apple-Intelligence-capable iPhone (15 Pro / 16+). Arrange one borrowed such device for demo recording.
3. **Backend deployment** — needed for Phase 3 (feed) only. Deploy trimmed FastAPI + Supabase before that phase; keep it awake during judging week with a cron ping.

---

## 3. Locked decisions (do NOT relitigate)

- **Free app.** No paywall, no subscriptions. (Killed the MRR Machine track on purpose — "a student in crisis shouldn't hit a paywall" is a stronger wellness-track line.)
- **English only.** Hindi = roadmap line in submission, not built.
- **Nude palette + single terracotta accent.** Confirmed by market research (Headspace uses near-identical cream; distress-UX research recommends muted earthy tones). Dark-first for onboarding + all Breathe screens.
- **Confession feed = build it** (moderated, on existing backend), but **no comments/replies** in v1 (doubles moderation risk). Seed 25–30 curated posts so it never demos empty.
- **Breathe Together = hero feature.** Solo + group (up to 8 via MultipeerConnectivity) + synced completion screen. One-message sync design (start timestamp + pattern), each device runs local timer, survives connection drop. This is the demo money-shot: 3–4 phones pulsing in unison.
- **Crisis routing** ships in v1, not v2. NO red anywhere in the app.
- **AI = reflection only**, never advice/diagnosis/therapy/companion (dodges the 2025–26 AI-companion regulatory backlash). Prompt contract locked in BUILD_PROMPT.md Phase 2.

**Cut to roadmap (don't build):** Hindi, voice journaling, ElevenLabs, Apple Watch, HealthKit, Siri intents, exam mode, post comments, Silent SOS, Tap to Share, real payments, AI chat companion.

**Cut order if timeline collapses:** feed (Phase 3) first → journal AI (keep plain journal) second → **Breathe Together ships no matter what.**

---

## 4. The 13 screens (all designed in Figma)

**Figma file:** https://www.figma.com/design/pScdCmhdgC5aP0K7MWcV8Y (Parul student account — 2503031461401@paruluniversity.ac.in)
Page "01 · Design Tokens" = full palette as variables (light+dark). Page "02 · Screens" = all 13.

1. Onboarding (privacy, dark) 2. Today (mood + streak) 3. Journal list (bento) 4. Journal entry + AI reflection 5. Journal editor (bottom sheet + AI prompt) 6. Mood calendar (heatmap + stats + pattern) 7. The Room feed 8. Composer + moderation states (approved/rejected/crisis) 9. Breathe session (dark, glowing circle) 10. Breathe lobby (host + joined peers) 11. Breathe completion (peer avatars) 12. Crisis support 13. Settings (privacy + delete data)

---

## 5. Color tokens (Theme.swift)

```
LIGHT                                  DARK
bg/base        #FAF6F1                 #1E1A17
bg/card        #F3ECE4                 #2A2420
bg/elevated    #EDE3D7                 #362E28
bg/breathe     #2C2420 (both modes stay dark)   #14100D
text/primary   #3E3A36                 #EDE6DD
text/secondary #8A8178                 #A99E92
text/muted     #B5AB9F                 #7A7166
accent         #C97B5D (terracotta — ONLY accent, both modes)
clay-soft      #E5C3B3
olive          #7D8A5C (success/streak)
ochre          #D9A45B (gentle warning — never red)
```
Type: SF Pro, `.fontDesign(.rounded)` on headings/numbers. Cards radius 24, buttons capsule. No drop shadows (depth via surface tints). Dynamic Type everywhere. Bottom-anchored primary buttons. Bottom sheets for input.

---

## 6. Tech stack

| Layer | Tech |
|---|---|
| UI | SwiftUI (native, iOS 26 min) |
| Local data | SwiftData |
| On-device AI | Apple Foundation Models (+ availability fallback) |
| Haptics | Core Haptics |
| Device sync | MultipeerConnectivity |
| Widget | WidgetKit + App Intents |
| Notifications | UserNotifications |
| Feed backend | FastAPI (moderation gate) + Supabase (storage) |
| Moderation | dual-model toxicity (toxic-bert + martin-ha) + keyword crisis check |

**Backend design:** reads go straight to Supabase (anon key, SELECT-only RLS); writes go ONLY through FastAPI `/posts` which moderates then inserts with service key. Fail-closed (any error = not published). Recommend HF Inference API over self-hosting models (keeps server ~100MB, free-tier deployable). Crisis detection = curated keyword list, not ML, for v1. Schema has no device ID / IP / user column (anonymity by schema).

---

## 7. Build order (from BUILD_PROMPT.md)

0. Skeleton + Theme.swift + 4-tab TabView (Today · Journal · The Room · Breathe)
1. **Phase 1 — Mood Core:** check-in, StreakCalculator (unit-test date math), calendar, reminder, widget one-tap
2. **Phase 2 — Journal:** entries + on-device AI reflection (availability check + fallback), locked prompt contract
3. **Phase 3 — The Room:** deploy trimmed FastAPI+Supabase, feed, composer, 3 moderation outcomes, seed script
4. **Phase 4 — Breathe Together (polish hardest):** solo haptic → group MPC lobby → one-message sync → synced completion
5. **Phase 5 — Crisis, Onboarding (3 screens), Settings, accessibility sweep**
6. **Phase 6 — Ship:** icon, empty states, demo seed, record demo (open with multi-phone breathe shot), submission text

**Test the two fragile things:** `StreakCalculator` and `BreathingClock` (pure functions, unit tests).

---

## 8. Reference files in repo root
- `BUILD_PROMPT.md` — the driving instruction for Claude Code (phases, prompt contract, acceptance checks)
- `PRODUCT_SPEC.md` — what/why, pitch-facing
- `SRS.md` — numbered requirements FR-1.1…FR-6.3 + acceptance criteria (§6.2 = "am I done?" checklist)
- `HANDOFF.md` — this file

---

## 9. Session log (append each session)

**2 Aug 2026 — planning + design complete.** Registered for hackathon. Locked all decisions above. Built Figma file with 13 screens + design tokens. Wrote PRODUCT_SPEC, SRS, BUILD_PROMPT. Confirmed: Windows dev machine (Mac blocker OPEN), no Foundation Models hardware (fallback required). Moved repo off OneDrive to M:\indehub. Claude Code installed and pointed at repo. **Next:** resolve Mac access; then Claude Code → skeleton + Phase 1.

**6 Aug 2026 — Phase 0 (Foundation) complete.** User approved autonomous phase-by-phase build (no per-phase stop), asking only on true blockers. Decisions confirmed with user: bundle ID `com.man.TheRoom` (App Group `group.com.man.theroom` as already locked); Phase 3 backend will be built against stub config now, real Supabase/HF keys wired later. Since there's no Mac, project is authored via **XcodeGen** (`TheRoom/project.yml`) instead of a hand-edited `.pbxproj` — run `xcodegen generate` on first Mac session (see `TheRoom/README.md`). Built: `DesignSystem/Theme.swift` (all color tokens, light/dark, dynamic `Color`s, no asset catalog needed), reusable components (`RoomCard`, `PrimaryButton`/`SecondaryButton`, `Pill`/`PeerDot`, `MoodEmojiButton` + `MoodLevel` heatmap tint helper, `BottomSheetHeader`, `SectionHeader`, `BreathingCircle`/`DashedDiscoveryRing`), `TheRoomApp.swift` (App-Group-backed SwiftData container), `RootTabView.swift` (4 tabs + persistent crisis toolbar button), themed placeholder root views for all 4 tabs + Crisis sheet, minimal `TheRoomWidget` target (StreakWidget skeleton, real logic in Phase 1). **Broke/blocked:** none — proceeding straight into Phase 1 per user's continuous-build instruction. **Next:** Phase 1 (Mood Core).

**6 Aug 2026 — Phase 1 (Mood Core) complete.** Built: `MoodEntry` SwiftData model; `StreakCalculator` pure function + 9 unit tests (`TheRoomTests/StreakCalculatorTests.swift`) covering gaps, month/year boundaries, same-day duplicates, longest-vs-current divergence; full Today screen (screen 2 — 5-emoji check-in, note field, logged-today state, streak card, dark Breathe CTA); Mood Calendar screen (screen 6 — month heatmap, ‹› nav, day detail sheet, stats card, locally-computed weekend/weekday "✦ PATTERN" insight — no AI needed for this one, it's arithmetic); `ReminderScheduler` service (UserNotifications, gentle copy, no UI yet — picker lands in Phase 5 Settings); `TheRoomWidget` StreakWidget now reads real data from the App-Group SwiftData store and has 3 interactive one-tap check-in buttons via `LogMoodIntent` (AppIntents), mapped to levels 1/3/5. Moved `AppModelContainer` into `Services/` and added it + `Models/` + `StreakCalculator` to the widget target's sources in `project.yml` (files shared between app and widget targets, not duplicated). Created a minimal `JournalEntry` model early (needed by the shared SwiftData schema since Phase 0) — full Journal UI still lands in Phase 2. **Broke/blocked:** none. **Next:** Phase 2 (Private AI Journal).

**6 Aug 2026 — Phase 2 (Private AI Journal) complete.** Built: `AIReflectionService` on the `FoundationModels` framework (`SystemLanguageModel.default.availability` check first, `@Generable` `ReflectionResult` struct, locked prompt contract copied verbatim from BUILD_PROMPT — reflection-only, no advice/diagnosis/questions — 3-way `Outcome` enum: reflected / unavailable / failed, both fallback cases show the same friendly on-device notice); journal list screen 3 (bento: large latest-entry card + 2 side-by-side tiles + locally-computed "This week" emotion-frequency card, empty state, floating "Write today's entry" button); entry detail screen 4 (claySoft reflection card labeled exactly "✦ REFLECTION · ON THIS DEVICE ONLY", emotion pills, in-progress/unavailable states, linked same-day mood emoji); editor bottom sheet screen 5 (grab handle, "✦ PROMPT FOR YOU" chip referencing the most recent entry's top emotion tag, terracotta-tint `TextEditor` caret, live char count, "Save & reflect ✦" saves immediately then reflects async so the UI never blocks on generation). Added `FoundationModels.framework` to `project.yml`. **Note:** since Foundation Models hardware isn't on this dev machine (per HANDOFF §2 blocker), the reflection path is unverified end-to-end — it will only be exercisable on an Apple-Intelligence-capable device; the fallback path (`.unavailable`) is what will actually run in any simulator/non-AI-device testing. **Broke/blocked:** none. **Next:** Phase 3 (The Room feed).

**6 Aug 2026 — Phase 3 (The Room feed) complete, backend not yet deployed.** Per user's answer, built this against stub config rather than waiting on live credentials. Backend (`TheRoom/backend/`): FastAPI `app/main.py` (`POST /confession/submit`, `GET /health`, fail-closed on any exception), `app/moderation.py` (crisis-keyword regex checked first, then dual HF Inference toxicity check — toxic-bert + martin-ha, max score wins), `app/supabase_client.py` (service-key insert only, no reads), `schema.sql` (posts table + anon SELECT-only RLS + `increment_metoo` RPC — anonymity enforced by schema, no identity column exists at all), `seed.py` (30 curated posts: exam fear/homesickness/family pressure/loneliness/small wins), `.env.example`, `README.md` with Railway/Render deploy steps + cron-ping-to-stay-awake note. iOS: `RoomConfig.swift` (placeholder URLs/keys, `isConfigured` gate so nothing spams a fake endpoint), `Post` model, `ModerationAPI` (writes only, fail-closed on network error too), `FeedAPI` (Supabase REST reads + me-too RPC + `PostCache`/`ReactionStore` in UserDefaults for offline + once-per-device reactions), feed screen 7 (offline notice, not-configured notice, empty state, pull-to-refresh), composer screen 8 + the 3 outcomes (approved triggers a refetch; gentle ochre-bordered rejected card; claySoft crisis bridge card with "Open support →" into the real Crisis screen rather than slamming it open). **Decisions:** crisis outcome is a soft bridge card per the master prompt's screen-8 spec, not a direct jump to the crisis screen. **Broke/blocked:** none for the code itself — but the feed is inert until real Supabase/HF/deploy credentials are dropped into `RoomConfig.swift` and `backend/.env` (this is the still-open item from HANDOFF §2 blocker 3; user chose to defer it rather than provide keys now). **Next:** Phase 4 (Breathe Together).

**6 Aug 2026 — Phase 4 (Breathe Together, the hero) complete.** Built: `BreathingClock` pure function (`startAt`+pattern+duration+now → phase/circleProgress/remaining/isComplete) + 10 unit tests including the load-bearing one — two calls with identical inputs produce identical `BreathState`, which is the entire cross-device sync guarantee spelled out as a test, not just a comment; `HapticEngine` (Core Haptics, prebuilt ramp/tick/fade patterns, silently no-ops on unsupported hardware per NFR-3.3); `BreatheSessionManager` (MultipeerConnectivity, service type `theroom-breathe`, host auto-accepts invitations, joiner auto-invites the first discovered host, `broadcastStart` sends exactly one `BreatheSyncMessage` — start timestamp 2s in the future + pattern + duration — then applies it locally too); screen 9 `BreatheSessionView` (single view serves solo and group, `TimelineView` recomputes `BreathingClock.state` every tick so there's no per-device mutable phase to drift, peer pill only shows when `peers` is non-empty); screen 10 `BreatheLobbyView` (single view serves host and joiner via a `Role` enum, dashed discovery ring, peer pills with checkmarks, "N friends here · room for X more", host-only Start button); screen 11 `BreatheCompletionView` (glowing orb, peer avatar row, "Breathe again"/"Done"). **Decision (noted, not asked — internal flow simplification, not a visual spec question):** the master prompt's screen list has one lobby screen, not a separate "browse for hosts" screen, so joining auto-connects to the first discovered host rather than presenting a tap-to-select list; this can be revisited if multiple simultaneous sessions turn out to be a real scenario. **Broke/blocked:** none — but like Phase 3, this is unverified beyond code review: no physical iPhones to test the ≤200ms drift or Bluetooth-drop resilience acceptance criteria (SRS 6.2 #4) until it's on real hardware. **Next:** Phase 5 (Crisis, Onboarding, Settings, Accessibility).

**6 Aug 2026 — Phase 5 (Crisis, Onboarding, Settings, Accessibility) complete.** Built: full Crisis screen (screen 12 — two terracotta `tel:` call buttons for Tele-MANAS 14416 and KIRAN 1800-599-0019, "Or breathe with me for a minute →" bridge straight into a solo `BreatheSessionView`, disclaimer footer, no red anywhere); 3-screen onboarding (screen 1 — privacy/breathe-intro/not-therapy+reminder-opt-in, dark in both modes, `TabView(.page)` + 3-dot indicator, Skip on pages 1-2, gated behind `@AppStorage("hasCompletedOnboarding")` as a `fullScreenCover` on `RootTabView`); Settings (screen 13 — native grouped `List` per the master prompt's explicit "grouped iOS-style" direction rather than the custom card system used elsewhere; reminder toggle+time wired to `ReminderScheduler`, group-session display name, appearance override wired into `TheRoomApp`'s `.preferredColorScheme`, Privacy section, Delete-all-data with confirmation dialog that clears SwiftData + `ReactionStore`, About section, footer); reachable via a gear icon on the Today tab. Accessibility: added remaining `accessibilityLabel`s (settings gear, crisis call buttons compose title+detail into one label, onboarding page dots hidden from VoiceOver since the Continue button already conveys progress); typography audit confirmed no screen uses fixed point sizes for body/label text, only for emoji/icon glyphs which don't carry Dynamic Type semantics the same way. **Decision (noted, not asked):** reconciled a wording difference between CLAUDE_CODE_MASTER_PROMPT (screen 1 headline "Your journal never leaves your iPhone") and BUILD_PROMPT (screen 1 headline "A private space for your mind" + privacy line) by using both — title + subtitle — since they're complementary, not contradictory. **Broke/blocked:** none — full VoiceOver/Dynamic-Type-XL manual sweep still needs a real device/simulator (no Mac yet). **Next:** Phase 6 (Ship prep).

**6 Aug 2026 — Phase 6 (Ship prep) complete. All 7 phases (0-6) built in one continuous session.** Built: app icon (`scripts/generate_app_icon.py`, Pillow-generated flat terracotta circle on nude field, wired into `Assets.xcassets/AppIcon.appiconset` at 1024×1024, `ASSETSCATALOG_COMPILER_APPICON_NAME` already set in `project.yml`); empty states already existed for Journal and Room feed from Phases 2-3, verified Mood Calendar and Breathe lobby degrade gracefully with zero data too; debug-only "Inject 7-day streak" button in Settings (`#if DEBUG`, backfills 7 days of check-ins without duplicating existing ones) — feed seeding is `backend/seed.py` from Phase 3; `Room/SUBMISSION.md` drafted (problem/user/product, WWDC26 tech list, attributions, known limitations from SRS §6.3, judge instructions for running a 2-device group Breathe session) with explicit ⚠️ markers for the pieces that need a live device/backend to finish (drift measurement, demo recording, live credentials). Fixed a `project.yml` sources/resources overlap (excluded `Resources/**` from the app target's source glob so the asset catalog isn't double-referenced).

**Where this leaves the project:** all Swift code for all 13 screens + widget + backend is written, organized per `BUILD_PROMPT.md`'s target structure, and reviewed for internal consistency — but **none of it has been compiled**, because there is still no Mac (HANDOFF §2 blocker 1, still open). The two pure-logic units (`StreakCalculator`, `BreathingClock`) have real unit tests ready to run the moment `xcodegen generate` produces a project on a Mac. Three things remain genuinely blocked on resources only the user has: (1) a Mac, to build/run/test any of this at all; (2) an Apple-Intelligence-capable iPhone, to verify the Foundation Models reflection path actually produces the intended tone (the fallback path is what will run everywhere else); (3) real Supabase + Hugging Face + Railway/Render credentials, to bring the feed backend live (`TheRoom/backend/README.md` has the exact steps; `RoomConfig.swift` is the one file to edit once they exist). **Next:** get to a Mac, run `xcodegen generate`, fix whatever the compiler finds (expected — this was never compiled), run the two test targets, then work through the physical-device acceptance checks in SRS §6.2.

<!-- TEMPLATE for next entry:
**[date] — [what happened].** Done: ___. Broke/blocked: ___. Decisions: ___. Next: ___.
-->

---

## 10. Kickoff message for Claude Code (paste this)

> Read HANDOFF.md, BUILD_PROMPT.md, PRODUCT_SPEC.md, and SRS.md in this repo. We're building The Room, a native SwiftUI iOS app. Foundation Models hardware isn't on this dev machine — build AIReflectionService with an availability check and graceful fallback. Start with the Xcode project skeleton + Theme.swift (color tokens from HANDOFF §5), then the 4-tab TabView, then Phase 1 (Mood Core). Go phase by phase and commit after each working piece. At the end of the session, update HANDOFF.md §9 session log.
