import Foundation
import FoundationModels

/// Generates the private, on-device journal reflection. Never sends anything
/// off-device, and works fully in airplane mode when the model is available.
///
/// LOCKED PROMPT CONTRACT (BUILD_PROMPT Phase 2 — do not loosen):
/// "You are a gentle, quiet companion reading a student's private journal entry.
/// Reply with a two-sentence warm reflection that acknowledges what they felt.
/// Never give advice, never diagnose, never mention therapy or treatment, never
/// role-play, never ask questions. Also return 2-3 single-word emotion tags."
/// If output ever contains advice ("you should...") that's a prompt bug — fix the
/// contract, don't patch around it downstream.
enum AIReflectionService {

    enum Outcome {
        case reflected(reflection: String, emotions: [String])
        /// Foundation Models isn't available on this device/OS (no Apple Intelligence
        /// hardware, not enabled, or still downloading). Save the entry, show a friendly notice.
        case unavailable
        /// Available but generation itself failed (rare) — same friendly fallback as unavailable.
        case failed
    }

    private static let instructions = """
    You are a gentle, quiet companion reading a student's private journal entry. \
    Reply with a two-sentence warm reflection that acknowledges what they felt. \
    Never give advice, never diagnose, never mention therapy or treatment, never \
    role-play, never ask questions. Also return 2-3 single-word emotion tags.
    """

    /// Checks on-device model availability before attempting anything.
    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    /// Generates a reflection for the given entry text. Budget: ~10s (UI shows a
    /// progress indicator while this runs — see `JournalEditorSheet`).
    static func reflect(on entryText: String) async -> Outcome {
        guard isAvailable else { return .unavailable }

        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(
                to: "Journal entry:\n\(entryText)",
                generating: ReflectionResult.self
            )
            let emotions = Array(response.content.emotions.prefix(3))
            return .reflected(reflection: response.content.reflection, emotions: emotions)
        } catch {
            return .failed
        }
    }
}

@Generable
struct ReflectionResult {
    @Guide(description: "A warm, two-sentence reflection. No advice, no diagnosis, no questions.")
    var reflection: String

    @Guide(description: "2 to 3 single-word emotion tags, lowercase, e.g. 'anxious', 'hopeful'.")
    var emotions: [String]
}
