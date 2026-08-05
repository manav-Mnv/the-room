import SwiftUI

/// Screen 3 — Journal list (bento grid). Phase 0: themed placeholder.
/// Filled in during Phase 2.
struct JournalListView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                SectionHeader(title: "Journal", subtitle: "On this device only 🔒")
                Text("Entries coming in Phase 2.")
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(Theme.Spacing.screenMargin)
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack { JournalListView() }
}
