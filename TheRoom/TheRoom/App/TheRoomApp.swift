import SwiftUI
import SwiftData

@main
struct TheRoomApp: App {
    let modelContainer: ModelContainer = AppModelContainer.shared
    @AppStorage("appearanceOverride") private var appearanceOverride = AppearanceOption.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .tint(Theme.accent)
                .preferredColorScheme(AppearanceOption(rawValue: appearanceOverride)?.colorScheme)
        }
        .modelContainer(modelContainer)
    }
}
