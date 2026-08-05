# CLAUDE_CODE_MASTER_PROMPT.md
## Paste this ENTIRE file as your first message to Claude Code.

---

You are the lead iOS engineer building **The Room**, a native SwiftUI app for the IndeHub Hackathon 2026. Read this prompt fully, then read `HANDOFF.md`, `BUILD_PROMPT.md`, `PRODUCT_SPEC.md`, and `SRS.md` in this repo before writing any code. Those files are the source of truth; this prompt is how you execute.

### Context you must respect
- **Solo developer, Windows machine.** You write correct Swift; compilation happens on a Mac later. Do not run build commands that need macOS — just produce clean, compilable Swift.
- **Foundation Models hardware is NOT available on this dev machine.** Any on-device AI must be written with a `SystemLanguageModel.default.availability` check and a graceful fallback path. Never assume the model runs locally.
- **Native only:** SwiftUI, iOS 26 minimum. No cross-platform anything (hackathon eligibility depends on it).
- **This is a wellness app for students who may be in distress.** Tone is calm, warm, non-clinical, never guilt-based. No dark patterns. Safety features are real, not decorative.

### The product in one line
A free, privacy-first mental wellness app: daily mood check-ins, a private on-device AI journal, a moderated anonymous peer-support feed, and "Breathe Together" — multiple iPhones syncing one guided breathing session. English only. No accounts for local features. No ads, no subscriptions.

---

## DESIGN IS NOT OPTIONAL — MATCH THE FIGMA EXACTLY

There is a complete Figma with all 13 screens designed. You must reproduce these screens faithfully in SwiftUI — same layout, same spacing, same hierarchy, same components. Do not invent your own layouts. Do not use default/stock SwiftUI styling. The visual quality bar is "indistinguishable from the Figma."

**Figma reference:** https://www.figma.com/design/pScdCmhdgC5aP0K7MWcV8Y
(If you cannot open it, the screen descriptions below plus HANDOFF §4 are authoritative — build to those precisely.)

### Design system — implement `DesignSystem/Theme.swift` FIRST, before any screen

Colors (define as Color assets or a Theme enum, with light + dark variants):
```
TOKEN            LIGHT      DARK       USE
bgBase           #FAF6F1    #1E1A17    app background
bgCard           #F3ECE4    #2A2420    cards / surfaces
bgElevated       #EDE3D7    #362E28    sheets, pressed states
bgBreathe        #2C2420    #14100D    breathing screens (stay dark in BOTH modes)
textPrimary      #3E3A36    #EDE6DD    never pure black
textSecondary    #8A8178    #A99E92
textMuted        #B5AB9F    #7A7166
accent           #C97B5D    #C97B5D    terracotta — THE ONLY ACCENT (buttons, breathing circle, selection, streak)
claySoft         #E5C3B3    #8A5540    accent-tinted fills, reflection cards
olive            #7D8A5C    #8FA06A    success / streak positive
ochre            #D9A45B    #D9A45B    gentle warnings — NEVER use red anywhere in this app
```

Non-negotiable style rules (these are what make it look like the Figma, not a template):
- Typography: system font, `.fontDesign(.rounded)` on ALL headings, mood numbers, and streak counts. Body stays default SF Pro. Use Dynamic Type text styles — never hardcoded point sizes for body text.
- Corner radius: **24** on cards, **capsule** on all buttons and pills, **28–36** on bottom sheets.
- **No drop shadows anywhere.** Create depth with layered surface tints (bgBase → bgCard → bgElevated), exactly like Headspace.
- Primary action buttons are **bottom-anchored** and full-width-with-margins (24pt side padding).
- All text input happens in **bottom sheets**, not pushed screens (thumb-reachable — 2026 pattern).
- Generous whitespace, calm low-stimulus layout. When unsure, add space, remove elements.
- Build reusable components in `DesignSystem/Components/`: `RoomCard`, `PrimaryButton`, `SecondaryButton`, `Pill`, `MoodEmojiButton`, `BottomSheet`, `SectionHeader`, `BreathingCircle`. Every screen composes these — no ad-hoc styling per screen.
- Micro-interactions: gentle spring animations on selection, tap, and transitions. Nothing flashy — calm motion.
- Full dark mode as a first-class designed surface, not an inverted afterthought. Onboarding and the entire Breathe flow are dark in both modes.
- Use native iOS 26 materials (`.glassEffect` / Liquid Glass) on the tab bar and sheet surfaces where appropriate, but sparingly — content-first, never at the cost of contrast/readability.

### The 13 screens (reproduce each to match Figma)

1. **Onboarding — Privacy** (dark): centered glowing terracotta orb with 🔒, headline "Your journal never leaves your iPhone", subtitle about on-device/offline/no-account, 3-dot page indicator, bottom "Continue". 3 onboarding screens total (privacy → breathe intro → "not therapy" disclaimer + notification permission).
2. **Today — Mood Check-in** (light): greeting "Good evening, [name]", "How are you feeling today?", a card with 5 emoji mood buttons (😞😕😐🙂😄) where the selected one fills terracotta, optional note field, a 🔥 streak card (current + longest), a dark "Breathe together" CTA card, bottom tab bar.
3. **Journal — List (bento grid)** (light): title "Journal", "On this device only 🔒", a large today entry card (claySoft) + two smaller entry tiles side by side + a dark "This week" AI-insight card. Bottom "Write today's entry" button.
4. **Journal — Entry with AI Reflection** (light): back nav, date + mood emoji, the full entry text, then a claySoft reflection card labeled "✦ REFLECTION · ON THIS DEVICE ONLY" with a 2-sentence reflection and emotion tag pills (anxious/lonely/soothed), bottom "New entry".
5. **Journal — Editor (bottom sheet)**: dimmed background, sheet with grab handle, Cancel/title/save row, an AI prompt chip ("✦ PROMPT FOR YOU" referencing a recent entry), the text being typed with a terracotta caret, char count "N / no limit · saved on device", bottom "Save & reflect ✦".
6. **Mood History — Calendar** (light): month title + ‹ › nav, weekday headers, a heatmap grid where each day's cell is tinted by mood intensity (claySoft→terracotta scale, high-mood days show white bold numbers), a stats card (🔥 current / longest / avg mood in olive), a dark "✦ PATTERN" insight card ("weekends average 1.2 higher…").
7. **The Room — Feed** (light): title "The Room", subtitle "Anonymous · moderated · you're not alone here", chronological post cards (bgCard) each with the text, a "🫂 me too · N" claySoft pill and "Nh ago · anonymous". Bottom dark composer bar "Share something anonymously…".
8. **Composer + Moderation States** (bottom sheet): the compose sheet ("Share with The Room", "🔒 Anonymous · checked for safety before it appears", text field, char count, "Post anonymously"). PLUS design the two outcome cards: a gentle ochre-bordered REJECTED card ("💛 This one can't be posted… The Room stays gentle for everyone") and a claySoft CRISIS card ("🫶 It sounds really heavy right now… Open support →").
9. **Breathe — Session** (dark, `bgBreathe`): "The Room" small header, a "Breathing with N friends" pill with colored dots, a large terracotta breathing circle with 2 soft outer glow layers (opacity ~0.15 / 0.3), phase label ("Breathe in / Hold / Breathe out") in rounded font, countdown "1:24 remaining", bottom outline "End session".
10. **Breathe — Lobby (host)** (dark): "Breathe together", "Friends nearby can see this session", a dashed-ring discovery circle with "waiting…", a list of joined-peer pills (colored dot + "Name joined" + ✓), "N friends here · room for X more", bottom "Start breathing · 2 min" and "or start alone".
11. **Breathe — Completion** (dark): glowing terracotta orb with 🫂, "You breathed together for 2 minutes", "You, [names] slowed down on the same beat", a row of peer avatar circles, bottom "Breathe again" + "Done".
12. **Crisis Support** (light, calm — NO red): 🫶, "You don't have to carry this alone", supportive line, two big terracotta call buttons ("📞 Call Tele-MANAS · 14416 · Govt of India 24×7" and "📞 Call KIRAN · 1800-599-0019 · toll-free" via `tel:` links), a soft "Or breathe with me for a minute →" bridge into Breathe, and a bottom disclaimer "The Room is not a substitute for professional care."
13. **Settings** (light): grouped iOS-style sections — daily reminder time / group-session name / appearance; a PRIVACY section ("🔒 Journal & moods stay on this iPhone · No account · no cloud · works offline" + "🗑️ Delete all my data"); an ABOUT section (crisis lines + disclaimer); footer "The Room · v1.0 · made with 🫀 in India".

---

## HOW YOU WORK — PHASE GATING (strict)

Work in the phases defined in `BUILD_PROMPT.md`. **You must complete one phase, show me the result, and WAIT for my approval before starting the next.** Do not run ahead. Do not build Phase 2 while I'm reviewing Phase 1. After each phase: summarize what you built, list the acceptance checks from SRS §6.2 that now pass, note anything incomplete, and update `HANDOFF.md` §9 with a session-log line.

**PHASE 0 — Foundation (do this first, then STOP and show me):**
- Xcode project `TheRoom` (SwiftUI lifecycle, SwiftData enabled), folder layout per BUILD_PROMPT.md, widget extension target `TheRoomWidget`, App Group `group.com.man.theroom`.
- `DesignSystem/Theme.swift` (all tokens above, light+dark) + the reusable components in `DesignSystem/Components/`.
- Root 4-tab `TabView`: Today · Journal · The Room · Breathe, each a themed placeholder in the correct background color, plus a persistent crisis-support toolbar button on every tab.
- Goal: app would launch showing 4 correctly-themed empty tabs. **Stop and show me.**

**PHASE 1 — Mood Core:** mood check-in (5-emoji, terracotta selection, note), `StreakCalculator` (unit-tested date math), calendar heatmap (screen 6), daily reminder, WidgetKit one-tap check-in. Build screens 2 and 6. **Stop, show me.**

**PHASE 2 — Private AI Journal:** `JournalEntry` model, journal list (screen 3, bento), entry+reflection (screen 4), editor bottom sheet (screen 5). `AIReflectionService` on Foundation Models WITH availability check + fallback; locked prompt contract from BUILD_PROMPT.md Phase 2 (reflection only — never advice/diagnosis/therapy). **Stop, show me.**

**PHASE 3 — The Room feed:** deploy trimmed FastAPI + Supabase (design in HANDOFF §6, fail-closed, HF Inference for models, keyword crisis check). iOS feed (screen 7), composer + 3 moderation outcomes (screen 8), seed 25–30 curated posts. Reads → Supabase directly; writes → FastAPI gate only. **Stop, show me.**

**PHASE 4 — Breathe Together (polish hardest — this is the hero):** solo haptic breathing (screen 9) with `BreathingClock` (unit-tested pure function) + Core Haptics ramp/tick/fade on 4-4-6 rhythm; group mode via MultipeerConnectivity (screen 10 lobby, up to 8 peers, ONE sync message = start timestamp + pattern + duration, each device runs local clock, survives connection drop); synced completion (screen 11). **Stop, show me.**

**PHASE 5 — Crisis / Onboarding / Settings / Accessibility:** crisis screen (screen 12), 3 onboarding screens (screen 1), settings (screen 13), then a full Dynamic Type + VoiceOver sweep across every screen. **Stop, show me.**

**PHASE 6 — Ship prep:** app icon (terracotta circle on nude), empty states, demo seed/debug menu (inject 7-day streak + seeded feed), then help me assemble the submission text (problem/user/product, WWDC26 tech used, attributions, known limitations, judge instructions). **Stop, show me.**

### Rules for every phase
- Working beats complete. If a phase runs long, cut scope INSIDE the phase; never ship a half-broken flow. If catastrophic, cut order is: Phase 3 → Phase 2's AI (keep plain journal) → never Phase 4.
- Match the Figma. If something isn't specified, choose the option most consistent with the design system and note it.
- Commit after each working piece: `Phase N: <summary>`.
- Copy tone: warm, brief, non-clinical. Broken streak = "Fresh start today", never "You lost your streak".
- Unit-test the two fragile pure functions: `StreakCalculator` and `BreathingClock`.
- No `localStorage`-style hacks, no placeholder lorem ipsum in shipped screens, no stock styling.

### Start now
Read the four md files, then do **Phase 0 only**, then stop and show me the foundation before continuing.
