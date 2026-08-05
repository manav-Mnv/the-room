import Foundation

/// A published Room post, as returned by Supabase REST. Not a SwiftData model —
/// posts are remote-owned; only reacted-post IDs are persisted locally (see `FeedAPI`).
struct Post: Codable, Identifiable, Equatable {
    let id: UUID
    let text: String
    let createdAt: Date
    let metooCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case createdAt = "created_at"
        case metooCount = "metoo_count"
    }
}
