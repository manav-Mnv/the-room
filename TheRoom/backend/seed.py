"""One-off script: seeds ~28 curated posts so the feed never demos empty.

These are pre-written and trusted, so they're inserted directly via the
service-role client — they intentionally skip the moderation gate (that gate
exists for user-submitted text at request time, not for vetted seed content).

Usage:
    cd backend
    python -m pip install -r requirements.txt
    export SUPABASE_URL=...        (or set in .env and use python-dotenv)
    export SUPABASE_SERVICE_KEY=...
    python seed.py
"""
from __future__ import annotations

import os

from dotenv import load_dotenv

load_dotenv()

from app.supabase_client import get_client  # noqa: E402

SEED_POSTS = [
    # Exam fear
    "Three exams in four days and I genuinely don't know which one to be more scared of.",
    "Sat in the library till 2am and still feel like I know nothing. Anyone else?",
    "I keep rereading the same page because my brain won't hold onto anything before finals.",
    "Failed a mock test today and spiraled for an hour before I could breathe again.",
    "The night before results is somehow worse than the exam itself.",
    "I studied so hard for this one and I'm still terrified I'll blank out.",
    "Pretty sure my professor doesn't remember assigning this much reading in one week.",
    "Every time I open my notes I just close the laptop again. Send help.",
    # Homesickness
    "First Diwali away from home and the hostel mess food is not the same as amma's.",
    "Video called home for two hours today just to hear normal background noise from my house.",
    "Nobody warns you how loud a quiet dorm room can feel at 11pm.",
    "I miss my dog more than I thought was possible for a 19 year old to miss a dog.",
    "Made my mother's rajma today from a blurry photo of her handwriting. It wasn't the same but it helped.",
    "Three months into college and I still set two plates out of habit sometimes.",
    "The smell of rain hit different today and suddenly I just wanted to be home.",
    # Family pressure
    "My parents keep comparing my marks to my cousin's and I'm so tired of being a comparison.",
    "Told my dad I want to switch majors and the silence on the call said everything.",
    "Everyone in my family already has my whole life planned out except me.",
    "I got a B+ and somehow that felt like I'd let the whole family down.",
    "Sometimes I think they love the idea of me more than who I actually am.",
    "Family dinner turned into a career lecture again. I just wanted to eat in peace.",
    "It's exhausting being the 'responsible one' who's never allowed to have an off day.",
    # Loneliness / everyday struggle
    "Ate lunch alone in the library again today. Trying to tell myself that's okay.",
    "Group project where I did most of the work and nobody even said thanks. Just needed to vent.",
    "It's been a weirdly heavy week and I can't point to any one reason why.",
    "Sometimes college feels like everyone else got a manual I never received.",
    "Rejected from the internship I really wanted. Trying to remind myself it's one no, not the only one.",
    # Small wins
    "Finally submitted the assignment I'd been avoiding for two weeks. Small win but I'll take it.",
    "Talked to a stranger in my tutorial today and we're getting coffee tomorrow. Baby steps.",
    "Went for a walk instead of doom-scrolling tonight. Felt like a tiny victory.",
    "Actually asked my professor a question in front of the whole class today. Proud of past-me for pushing through.",
]


def main() -> None:
    client = get_client()
    inserted = 0
    for text in SEED_POSTS:
        client.table("posts").insert({"text": text}).execute()
        inserted += 1
    print(f"Seeded {inserted} posts.")


if __name__ == "__main__":
    main()
