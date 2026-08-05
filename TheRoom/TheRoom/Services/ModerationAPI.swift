import Foundation

/// Client for the FastAPI moderation gate. All Room writes go through here —
/// never directly to Supabase — so every post is screened before publish.
enum ModerationAPI {
    struct SubmitResponse: Decodable {
        let approved: Bool
        let crisis: Bool
        let reason: String?
    }

    enum SubmitError: Error {
        case notConfigured
        case network
    }

    static func submit(text: String) async -> Result<SubmitResponse, SubmitError> {
        guard RoomConfig.isConfigured else { return .failure(.notConfigured) }

        var request = URLRequest(url: RoomConfig.moderationBaseURL.appending(path: "confession/submit"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["text": text])
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return .failure(.network)
            }
            let decoded = try JSONDecoder().decode(SubmitResponse.self, from: data)
            return .success(decoded)
        } catch {
            // Fail-closed on the client too: a network error is never treated as approval.
            return .failure(.network)
        }
    }
}
