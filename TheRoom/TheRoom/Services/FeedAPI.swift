import Foundation

/// Reads go straight to Supabase (anon key, SELECT-only via RLS) — writes are
/// never performed here, only through `ModerationAPI`. Also owns the small bit
/// of local state that makes reactions "once per post per device" without any
/// server-side identity.
enum FeedAPI {
    enum FeedError: Error {
        case notConfigured
        case network
    }

    static func fetchPosts() async -> Result<[Post], FeedError> {
        guard RoomConfig.isConfigured else { return .failure(.notConfigured) }

        var components = URLComponents(url: RoomConfig.supabaseURL.appending(path: "rest/v1/posts"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "select", value: "id,text,created_at,metoo_count"),
            URLQueryItem(name: "order", value: "created_at.desc"),
        ]

        var request = URLRequest(url: components.url!)
        request.setValue(RoomConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(RoomConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return .failure(.network)
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
            let posts = try decoder.decode([Post].self, from: data)
            PostCache.save(posts)
            return .success(posts)
        } catch {
            return .failure(.network)
        }
    }

    /// Increments the me-too counter via the `increment_metoo` RPC. The caller is
    /// responsible for checking `ReactionStore` first so this only fires once per post.
    static func react(to postID: UUID) async {
        guard RoomConfig.isConfigured else { return }
        var request = URLRequest(url: RoomConfig.supabaseURL.appending(path: "rest/v1/rpc/increment_metoo"))
        request.httpMethod = "POST"
        request.setValue(RoomConfig.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(RoomConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["post_id": postID])
        _ = try? await URLSession.shared.data(for: request)
    }
}

private extension JSONDecoder.DateDecodingStrategy {
    static var iso8601WithFractionalSeconds: JSONDecoder.DateDecodingStrategy {
        .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: string) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
    }
}

/// Locally cached posts so the feed shows something (with an offline notice)
/// when the network is unreachable — FR-3.10.
enum PostCache {
    private static let key = "cachedPosts"

    static func save(_ posts: [Post]) {
        guard let data = try? JSONEncoder().encode(posts) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> [Post] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let posts = try? JSONDecoder().decode([Post].self, from: data)
        else { return [] }
        return posts
    }
}

/// Tracks which post IDs this device has already reacted to — "🫂 me too" is
/// one tap per post per device, enforced purely client-side.
enum ReactionStore {
    private static let key = "reactedPostIDs"

    static func hasReacted(to id: UUID) -> Bool {
        reactedIDs.contains(id.uuidString)
    }

    static func markReacted(_ id: UUID) {
        var ids = reactedIDs
        ids.insert(id.uuidString)
        UserDefaults.standard.set(Array(ids), forKey: key)
    }

    private static var reactedIDs: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }
}
