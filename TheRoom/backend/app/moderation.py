"""Moderation gate: crisis-language detection + dual-model toxicity screening.

Fail-closed by design (NFR-3.2): any error from either check means the post
does NOT publish. This module has no knowledge of Supabase — it only decides
approved / rejected / crisis for a piece of text.
"""
from __future__ import annotations

import os
import re
from dataclasses import dataclass

import httpx

TOXICITY_THRESHOLD = float(os.getenv("TOXICITY_THRESHOLD", "0.6"))
HF_API_TOKEN = os.getenv("HF_API_TOKEN", "")

TOXIC_BERT_MODEL = "unitary/toxic-bert"
MARTIN_HA_MODEL = "martin-ha/toxic-comment-model"
# HF retired the legacy api-inference.huggingface.co host in 2025 — serverless
# inference now goes through the router, with the hf-inference provider path
# preserving the same classic text-classification response shape.
HF_INFERENCE_URL = "https://router.huggingface.co/hf-inference/models/{model}"

# Curated, deliberately not exhaustive: catches direct, unambiguous crisis
# language. False negatives are acceptable (the composer isn't the only
# safety net); false positives just route a post to the crisis screen instead
# of publishing it, which is always the safe failure mode here.
CRISIS_PATTERNS = [
    r"\bkill myself\b",
    r"\bkilling myself\b",
    r"\bend my life\b",
    r"\bending my life\b",
    r"\bsuicid\w*\b",
    r"\bwant to die\b",
    r"\bdon'?t want to (be alive|live anymore|exist)\b",
    r"\bself[\s-]?harm\b",
    r"\bcutting myself\b",
    r"\bno reason to (live|go on)\b",
    r"\bbetter off dead\b",
    r"\bcan'?t (go on|do this anymore)\b",
]
_CRISIS_REGEX = re.compile("|".join(CRISIS_PATTERNS), re.IGNORECASE)


@dataclass
class ModerationResult:
    approved: bool
    crisis: bool
    reason: str | None = None


def check_crisis_language(text: str) -> bool:
    return bool(_CRISIS_REGEX.search(text))


async def _toxicity_score(client: httpx.AsyncClient, model: str, text: str) -> float:
    """Returns the highest-confidence toxic-label score from an HF text-classification model."""
    response = await client.post(
        HF_INFERENCE_URL.format(model=model),
        headers={"Authorization": f"Bearer {HF_API_TOKEN}"},
        json={"inputs": text, "options": {"wait_for_model": True}},
        timeout=8.0,
    )
    response.raise_for_status()
    data = response.json()

    # HF text-classification responses are [[{label, score}, ...]] or [{label, score}, ...]
    scores = data[0] if data and isinstance(data[0], list) else data
    toxic_scores = [
        item["score"]
        for item in scores
        if item.get("label", "").lower() not in {"neutral", "non-toxic", "not_toxic", "label_0"}
    ]
    return max(toxic_scores) if toxic_scores else 0.0


async def check_toxicity(text: str) -> float:
    """Highest toxicity score across both models — either model flagging it is enough to reject."""
    async with httpx.AsyncClient() as client:
        toxic_bert_score = await _toxicity_score(client, TOXIC_BERT_MODEL, text)
        martin_ha_score = await _toxicity_score(client, MARTIN_HA_MODEL, text)
    return max(toxic_bert_score, martin_ha_score)


async def moderate(text: str) -> ModerationResult:
    """Fail-closed: any exception here must surface as a non-approval to the caller."""
    if check_crisis_language(text):
        return ModerationResult(approved=False, crisis=True)

    score = await check_toxicity(text)
    if score >= TOXICITY_THRESHOLD:
        return ModerationResult(approved=False, crisis=False, reason="toxicity")

    return ModerationResult(approved=True, crisis=False)
