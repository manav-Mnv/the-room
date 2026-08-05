import SwiftUI

/// Screen 12 — Crisis Support. Phase 0: themed placeholder reachable from every tab.
/// Filled in during Phase 5.
struct CrisisSupportView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("🫶")
                .font(.system(size: 48))
            Text("You don't have to carry this alone")
                .font(Theme.rounded(.title2, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
            Text("Full crisis flow coming in Phase 5.")
                .foregroundStyle(Theme.textSecondary)
            SecondaryButton(title: "Close") { dismiss() }
        }
        .padding(Theme.Spacing.screenMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bgBase)
    }
}

#Preview {
    CrisisSupportView()
}
