import Foundation
import SwiftData

/// One daily mood check-in. `date` is always normalized to the start of its
/// calendar day so "one check-in per day" can be enforced by a unique lookup
/// rather than a range query.
@Model
final class MoodEntry {
    /// Start-of-day timestamp (device calendar/timezone) — the natural key for "today".
    var date: Date
    /// 1 (very low) ... 5 (great). See `MoodLevel`.
    var level: Int
    /// Optional note, ≤140 characters (enforced by the editor UI, not here).
    var note: String?

    init(date: Date, level: Int, note: String? = nil) {
        self.date = Calendar.current.startOfDay(for: date)
        self.level = level
        self.note = note
    }
}
