import SwiftUI

/// Screen 2 — Today: mood check-in, streak, "Breathe together" CTA.
/// Phase 0: themed placeholder. Filled in during Phase 1.
struct TodayView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                SectionHeader(title: "Today")
                Text("Mood check-in coming in Phase 1.")
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(Theme.Spacing.screenMargin)
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack { TodayView() }
}
