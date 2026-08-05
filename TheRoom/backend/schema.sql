-- The Room feed schema. Run this in the Supabase SQL editor.
-- Anonymity is enforced by schema: no device ID, IP, or user column exists,
-- so there is nothing identifying to leak even if RLS were misconfigured.

create table if not exists posts (
    id uuid primary key default gen_random_uuid(),
    text text not null check (char_length(text) <= 500),
    created_at timestamptz not null default now(),
    metoo_count integer not null default 0
);

alter table posts enable row level security;

-- Reads: anyone with the anon key can SELECT. No INSERT/UPDATE/DELETE policy
-- exists for anon — writes only happen via the FastAPI service role key,
-- after moderation. This is what makes "reads go straight to Supabase,
-- writes go only through the moderation gate" actually true at the DB layer.
create policy "posts are publicly readable"
    on posts for select
    to anon
    using (true);

-- Anonymous "🫂 me too" reactions: a single RPC that increments the counter.
-- One-tap-per-post-per-device is enforced client-side (locally stored reacted
-- post IDs) — the RPC itself has no per-device state, keeping the schema
-- identity-free.
create or replace function increment_metoo(post_id uuid)
returns void
language sql
security definer
as $$
    update posts set metoo_count = metoo_count + 1 where id = post_id;
$$;

grant execute on function increment_metoo(uuid) to anon;
