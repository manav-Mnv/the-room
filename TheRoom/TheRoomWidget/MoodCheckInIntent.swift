import AppIntents
import WidgetKit
import SwiftData
import Foundation

/// One-tap mood check-in from the widget. Only 3 of the 5 levels fit the widget's
/// space, mapped to low/okay/great (1/3/5) per BUILD_PROMPT Phase 1.
struct LogMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Check in"
    static var description = IntentDescription("Log today's mood without opening The Room.")

    @Parameter(title: "Mood level")
    var level: Int

    init() {
        level = 3
    }

    init(level: Int) {
        self.level = level
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let context = ModelContext(AppModelContainer.shared)
        let startOfToday = Calendar.current.startOfDay(for: .now)

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date == startOfToday }
        )
        if let existing = try? context.fetch(descriptor), existing.isEmpty {
            let entry = MoodEntry(date: .now, level: level)
            context.insert(entry)
            try? context.save()
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
        return .result()
    }
}
