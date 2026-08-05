import Foundation

/// Backend configuration for The Room feed (Phase 3). These are placeholder
/// values — the feed will not function until real ones are dropped in here.
/// See `backend/README.md` for the deploy steps that produce them.
///
/// Safe to commit: the Supabase key here must always be the **anon** key
/// (SELECT-only via RLS, see `backend/schema.sql`), never the service key.
enum RoomConfig {
    /// e.g. "https://the-room-moderation.up.railway.app"
    static let moderationBaseURL = URL(string: "https://REPLACE-ME.example.com")!

    /// e.g. "https://your-project.supabase.co"
    static let supabaseURL = URL(string: "https://REPLACE-ME.supabase.co")!

    /// The anon/public key from Supabase Settings -> API. Never the service role key.
    static let supabaseAnonKey = "REPLACE-ME"

    /// True while `moderationBaseURL`/`supabaseURL` are still placeholders — used to
    /// short-circuit network calls with a friendly "not configured yet" state instead
    /// of spamming failed requests against a fake URL.
    static var isConfigured: Bool {
        !moderationBaseURL.absoluteString.contains("REPLACE-ME")
            && !supabaseURL.absoluteString.contains("REPLACE-ME")
            && supabaseAnonKey != "REPLACE-ME"
    }
}
