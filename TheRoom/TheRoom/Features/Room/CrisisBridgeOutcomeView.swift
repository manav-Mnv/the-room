import SwiftUI

/// Screen 8 — the crisis outcome card. Never publishes the post; softly bridges
/// into the full Crisis Support screen (FR-3.5, FR-5.3) rather than presenting
/// it as a jarring interruption.
struct CrisisBridgeOutcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCrisisSupport = false

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            RoomCard(background: Theme.claySoft) {
                VStack(spacing: Theme.Spacing.md) {
                    Text("🫶")
                        .font(.system(size: 40))
                    Text("It sounds really heavy right now")
                        .font(Theme.rounded(.title3, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("We didn't post this — some things deserve more than a feed. Talking to someone can help, and it's free and confidential.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)

                    Button { showCrisisSupport = true } label: {
                        HStack(spacing: 4) {
                            Text("Open support")
                            Image(systemName: "arrow.right")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()

            SecondaryButton(title: "Not now") { dismiss() }
        }
        .padding(Theme.Spacing.screenMargin)
        .background(Theme.bgBase)
        .presentationDetents([.medium])
        .sheet(isPresented: $showCrisisSupport) {
            CrisisSupportView()
        }
    }
}

#Preview {
    CrisisBridgeOutcomeView()
}
