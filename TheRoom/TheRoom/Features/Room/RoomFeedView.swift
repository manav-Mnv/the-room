import SwiftUI

/// Screen 7 — The Room feed. Phase 0: themed placeholder.
/// Filled in during Phase 3.
struct RoomFeedView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                SectionHeader(title: "The Room", subtitle: "Anonymous · moderated · you're not alone here")
                Text("Feed coming in Phase 3.")
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(Theme.Spacing.screenMargin)
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack { RoomFeedView() }
}
