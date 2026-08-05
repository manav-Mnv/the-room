import Foundation
import SwiftData

/// A free-text journal entry with an optional on-device AI reflection.
/// Never transmitted anywhere — see `AIReflectionService`.
@Model
final class JournalEntry {
    var date: Date
    var text: String
    /// Two-sentence warm reflection, filled in after `AIReflectionService` runs. Nil until then.
    var reflection: String?
    /// 2-3 single-word emotion tags returned alongside the reflection.
    var emotions: [String]
    /// True once reflection generation has been attempted (success or graceful fallback),
    /// so the UI can distinguish "still generating" from "never tried".
    var reflectionAttempted: Bool
    /// True if this device doesn't support on-device reflections (Foundation Models unavailable).
    var reflectionUnavailable: Bool

    init(date: Date = .now, text: String) {
        self.date = date
        self.text = text
        self.reflection = nil
        self.emotions = []
        self.reflectionAttempted = false
        self.reflectionUnavailable = false
    }
}
