import SwiftUI

/// Screen 8 — the gentle rejection outcome. Ochre-bordered, never red, never punitive.
struct RejectedOutcomeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            RoomCard {
                VStack(spacing: Theme.Spacing.md) {
                    Text("💛")
                        .font(.system(size: 40))
                    Text("This one can't be posted")
                        .font(Theme.rounded(.title3, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("The Room stays gentle for everyone. Try rephrasing, or just let it go — this isn't a strike against you.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                    .stroke(Theme.ochre, lineWidth: 1.5)
            }

            Spacer()

            PrimaryButton(title: "Okay") { dismiss() }
        }
        .padding(Theme.Spacing.screenMargin)
        .background(Theme.bgBase)
        .presentationDetents([.medium])
    }
}

#Preview {
    RejectedOutcomeView()
}
