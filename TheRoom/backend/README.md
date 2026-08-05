# The Room — moderation backend

FastAPI service that gates writes to the `posts` table: every submission is
checked for crisis language and dual-model toxicity *before* it's inserted
into Supabase. Reads never touch this service — the iOS app reads `posts`
directly from Supabase with the anon key (SELECT-only via RLS, see
`schema.sql`).

## Setup

1. Create a Supabase project, run `schema.sql` in its SQL editor.
2. Get a Hugging Face Inference API token: https://huggingface.co/settings/tokens
3. Copy `.env.example` to `.env` and fill in real values.
4. `pip install -r requirements.txt`
5. `python -m uvicorn app.main:app --reload` (local) or deploy to Railway/Render
   (either just needs `uvicorn app.main:app --host 0.0.0.0 --port $PORT` as the
   start command and the same env vars set in their dashboard).
6. Seed the feed so it never demos empty: `python seed.py`

## Endpoint contract

```
POST /confession/submit
{ "text": "..." }

-> 200
{ "approved": bool, "crisis": bool, "reason": string | null }
```

- `approved: true` — post is now live in `posts`.
- `approved: false, crisis: true` — crisis language detected; iOS should
  present the Crisis Support screen and never show a "rejected" message.
- `approved: false, crisis: false, reason: "toxicity"` — rejected by the
  toxicity models; iOS shows the gentle rejection copy.
- `approved: false, reason: "moderation_unavailable" | "storage_unavailable"`
  — the service failed closed; iOS shows the same gentle rejection copy
  (a judge should never be able to tell "our server errored" from "toxic").

## Keeping it awake for judging week

Free-tier Railway/Render instances sleep. Set up a cron ping (e.g.
cron-job.org, every 10 minutes) hitting `GET /health` during the submission
window (1-7 Aug 2026, per HANDOFF §2).

## iOS-side config

Once deployed, drop the base URL into
`TheRoom/TheRoom/Services/RoomConfig.swift` (`moderationBaseURL`), and the
Supabase project URL + **anon** key (never the service key) into the same
file. Until then, Phase 3's iOS code is fully written against that config
file but has nothing live to talk to.
