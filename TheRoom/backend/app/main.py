"""FastAPI moderation gate for The Room feed.

Contract (SRS 5.2, BUILD_PROMPT Phase 3):
    POST /confession/submit  { text: str }
    -> { approved: bool, crisis: bool, reason: str | None }

Fail-closed: any unhandled error results in a 200 response with
approved=False rather than ever letting an unmoderated post through.
"""
from __future__ import annotations

import logging

from dotenv import load_dotenv

# Must run before the `moderation`/`supabase_client` imports below — both read
# their config from `os.environ`/`os.getenv` at import time. In production
# (Railway/Render) env vars are set in the host dashboard and this is a no-op.
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from . import moderation, supabase_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("theroom")

app = FastAPI(title="The Room — Moderation Gate")

# The iOS app talks to this over HTTPS only; CORS is irrelevant to native
# clients but harmless to leave permissive for local testing/curl.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


class SubmitRequest(BaseModel):
    text: str = Field(min_length=1, max_length=500)


class SubmitResponse(BaseModel):
    approved: bool
    crisis: bool
    reason: str | None = None


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}


@app.post("/confession/submit", response_model=SubmitResponse)
async def submit_confession(request: SubmitRequest) -> SubmitResponse:
    text = request.text.strip()
    if not text:
        return SubmitResponse(approved=False, crisis=False, reason="empty")

    try:
        result = await moderation.moderate(text)
    except Exception:
        # Fail-closed (NFR-3.2): moderation service errors never publish a post.
        logger.exception("Moderation check failed; failing closed.")
        return SubmitResponse(approved=False, crisis=False, reason="moderation_unavailable")

    if not result.approved:
        return SubmitResponse(approved=False, crisis=result.crisis, reason=result.reason)

    try:
        supabase_client.insert_post(text)
    except Exception:
        logger.exception("Supabase insert failed after approval; failing closed.")
        return SubmitResponse(approved=False, crisis=False, reason="storage_unavailable")

    return SubmitResponse(approved=True, crisis=False)
