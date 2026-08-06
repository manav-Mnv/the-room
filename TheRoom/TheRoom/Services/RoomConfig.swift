import Foundation

/// Backend configuration for The Room feed (Phase 3). These are placeholder
/// values — the feed will not function until real ones are dropped in here.
/// See `backend/README.md` for the deploy steps that produce them.
///
/// Safe to commit: the Supabase key here must always be the **anon** key
/// (SELECT-only via RLS, see `backend/schema.sql`), never the service key.
enum RoomConfig {
    static let moderationBaseURL = URL(string: "https://the-room-backend.onrender.com")!

    /// e.g. "https://your-project.supabase.co"
    static let supabaseURL = URL(string: "https://piihnnffmfyyslkwsgvo.supabase.co")!

    /// The anon/public key from Supabase Settings -> API. Never the service role key.
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpaWhubmZmbWZ5eXNsa3dzZ3ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5NTI1MzYsImV4cCI6MjEwMTUyODUzNn0._w-CWqxqvQ9hZTzj79emicZZK4rbZeQRiHE3JNMrtUs"

    /// True once real Supabase values are set — gates feed reads + reactions,
    /// which don't need the moderation backend to be deployed.
    static var isSupabaseConfigured: Bool {
        !supabaseURL.absoluteString.contains("REPLACE-ME") && supabaseAnonKey != "REPLACE-ME"
    }

    /// True once the moderation backend is deployed and its URL is set — gates
    /// posting, since writes must never bypass the moderation gate.
    static var isModerationConfigured: Bool {
        !moderationBaseURL.absoluteString.contains("REPLACE-ME")
    }

    /// True only once everything is wired up (reads + writes both possible).
    static var isConfigured: Bool {
        isSupabaseConfigured && isModerationConfigured
    }
}
