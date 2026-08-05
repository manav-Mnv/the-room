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
