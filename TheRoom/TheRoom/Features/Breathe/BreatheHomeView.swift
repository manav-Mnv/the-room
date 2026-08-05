import SwiftUI

/// Entry point for the Breathe tab — always dark (`bgBreathe`), in both light and
/// dark system appearance. Routes into solo session or the group lobby (screens 9-11).
/// Phase 0: themed placeholder. Filled in during Phase 4.
struct BreatheHomeView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("Breathe")
                .font(Theme.rounded(.largeTitle, weight: .bold))
                .foregroundStyle(Theme.onBreathePrimary)
            Text("Solo & group sessions coming in Phase 4.")
                .foregroundStyle(Theme.onBreatheSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.Spacing.screenMargin)
        .background(Theme.bgBreathe)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack { BreatheHomeView() }
}
