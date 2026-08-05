import SwiftUI
import SwiftData

@main
struct TheRoomApp: App {
    let modelContainer: ModelContainer = AppModelContainer.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .tint(Theme.accent)
        }
        .modelContainer(modelContainer)
    }
}

/// Single shared SwiftData container, backed by the App Group so the widget
/// extension (TheRoomWidgetExtension) reads/writes the same local store.
enum AppModelContainer {
    static let appGroupID = "group.com.man.theroom"

    static let shared: ModelContainer = {
        let schema = Schema([
            MoodEntry.self,
            JournalEntry.self,
        ])

        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        else {
            // Falls back to the default local store if the App Group isn't
            // provisioned yet (e.g. before DEVELOPMENT_TEAM is set in Xcode).
            return (try? ModelContainer(for: schema)) ?? emptyFallbackContainer(schema: schema)
        }

        let storeURL = groupURL.appending(path: "TheRoom.sqlite")
        let configuration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            return (try? ModelContainer(for: schema)) ?? emptyFallbackContainer(schema: schema)
        }
    }()

    private static func emptyFallbackContainer(schema: Schema) -> ModelContainer {
        // swiftlint:disable:next force_try
        try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
}
