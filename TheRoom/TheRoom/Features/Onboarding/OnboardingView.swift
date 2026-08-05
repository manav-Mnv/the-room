import SwiftUI

/// Screen 1 — Onboarding: 3 screens max (FR-6.1), dark in both light and dark
/// mode like the rest of the Breathe-adjacent surfaces. Skippable at any point.
struct OnboardingView: View {
    var onFinished: () -> Void

    @State private var page = 0
    private let pageCount = 3

    var body: some View {
        ZStack {
            Theme.bgBreathe.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if page < pageCount - 1 {
                        Button("Skip", action: onFinished)
                            .foregroundStyle(Theme.onBreatheSecondary)
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenMargin)
                .padding(.top, Theme.Spacing.sm)

                TabView(selection: $page) {
                    PrivacyPage().tag(0)
                    BreatheIntroPage().tag(1)
                    DisclaimerPage(onFinished: onFinished).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        Circle()
                            .fill(index == page ? Theme.accent : Theme.onBreatheSecondary.opacity(0.3))
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(.bottom, Theme.Spacing.lg)
                .accessibilityHidden(true)

                if page < pageCount - 1 {
                    PrimaryButton(title: "Continue") {
                        withAnimation(Theme.Motion.transition) { page += 1 }
                    }
                    .padding(.horizontal, Theme.Spacing.screenMargin)
                    .padding(.bottom, Theme.Spacing.lg)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct PrivacyPage: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            GlowingOrb(symbol: "🔒")
            VStack(spacing: Theme.Spacing.sm) {
                Text("A private space for your mind")
                    .font(Theme.rounded(.title, weight: .bold))
                    .foregroundStyle(Theme.onBreathePrimary)
                    .multilineTextAlignment(.center)
                Text("Your journal never leaves your iPhone. It works fully offline, with no account needed.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreatheSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Spacer()
        }
        .padding(Theme.Spacing.screenMargin)
    }
}

private struct BreatheIntroPage: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            GlowingOrb(symbol: "🫂")
            VStack(spacing: Theme.Spacing.sm) {
                Text("Breathe together")
                    .font(Theme.rounded(.title, weight: .bold))
                    .foregroundStyle(Theme.onBreathePrimary)
                    .multilineTextAlignment(.center)
                Text("Sync a guided breathing session with friends nearby — or just breathe on your own, anytime.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreatheSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Spacer()
        }
        .padding(Theme.Spacing.screenMargin)
    }
}

private struct DisclaimerPage: View {
    var onFinished: () -> Void
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            GlowingOrb(symbol: "✦")
            VStack(spacing: Theme.Spacing.sm) {
                Text("The Room is not therapy")
                    .font(Theme.rounded(.title, weight: .bold))
                    .foregroundStyle(Theme.onBreathePrimary)
                    .multilineTextAlignment(.center)
                Text("It's a private space to reflect and a gentle nudge toward connection — not a substitute for professional care. A daily reminder can help you build the habit, if you'd like one.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreatheSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()

            PrimaryButton(title: "Turn on daily reminders", isLoading: isRequesting) {
                isRequesting = true
                Task {
                    _ = await ReminderScheduler.requestAuthorizationIfNeeded()
                    await ReminderScheduler.schedule(at: DateComponents(hour: 20, minute: 0))
                    await MainActor.run { onFinished() }
                }
            }
            SecondaryButton(title: "Not now", action: onFinished)
        }
        .padding(Theme.Spacing.screenMargin)
        .padding(.bottom, Theme.Spacing.lg)
    }
}

private struct GlowingOrb: View {
    let symbol: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.accent.opacity(0.15))
                .frame(width: 160, height: 160)
            Circle()
                .fill(Theme.accent.opacity(0.3))
                .frame(width: 120, height: 120)
            Circle()
                .fill(Theme.accent)
                .frame(width: 84, height: 84)
            Text(symbol)
                .font(.system(size: 32))
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    OnboardingView(onFinished: {})
}
