"""Thin wrapper around the Supabase service-role client, used only to insert
already-moderated posts. Reads happen directly from iOS via the anon key —
this server never serves GET requests for the feed.
"""
from __future__ import annotations

import os

from supabase import Client, create_client

_client: Client | None = None


def get_client() -> Client:
    global _client
    if _client is None:
        url = os.environ["SUPABASE_URL"]
        key = os.environ["SUPABASE_SERVICE_KEY"]
        _client = create_client(url, key)
    return _client


def insert_post(text: str) -> dict:
    """Inserts an approved post. Schema has no device ID / IP / user column —
    anonymity is enforced by schema, not just policy (see schema.sql)."""
    client = get_client()
    result = client.table("posts").insert({"text": text}).execute()
    return result.data[0]
