import SwiftUI

/// Entry point for the Breathe tab — always dark (`bgBreathe`), in both light and
/// dark system appearance. Routes into solo session or the group lobby (screens 9-11).
struct BreatheHomeView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            BreathingCircle(progress: 0.7, diameter: 160)

            VStack(spacing: Theme.Spacing.sm) {
                Text("Breathe together")
                    .font(Theme.rounded(.largeTitle, weight: .bold))
                    .foregroundStyle(Theme.onBreathePrimary)
                Text("A slow, shared breath — with friends nearby, or just yourself.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreatheSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: Theme.Spacing.md) {
                NavigationLink {
                    BreatheLobbyView(role: .host)
                } label: {
                    PrimaryButtonLabel(title: "Breathe together")
                }

                NavigationLink {
                    BreatheLobbyView(role: .joiner)
                } label: {
                    Text("Join a nearby session")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.onBreatheSecondary)
                }

                NavigationLink {
                    BreatheSessionView(startAt: .now.addingTimeInterval(1), pattern: .standard, duration: 120, peers: [], sessionManager: nil)
                } label: {
                    Text("or start alone")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.accent)
                }
            }
        }
        .padding(Theme.Spacing.screenMargin)
        .padding(.bottom, Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bgBreathe)
        .preferredColorScheme(.dark)
    }
}

/// A `PrimaryButton`-styled label for use inside a `NavigationLink` (which needs
/// its own tap target, so this skips `PrimaryButton`'s own `Button` wrapper).
struct PrimaryButtonLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(Theme.rounded(.body, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(Theme.bgBase)
            .background(Theme.accent)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack { BreatheHomeView() }
}
