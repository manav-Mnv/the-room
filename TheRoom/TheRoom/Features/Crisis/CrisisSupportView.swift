import SwiftUI

/// Screen 12 — Crisis Support. Calm, light, NO red anywhere. Reachable from the
/// toolbar on every tab and auto-presented when a post is crisis-flagged (FR-5.3).
struct CrisisSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showBreathe = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    VStack(spacing: Theme.Spacing.md) {
                        Text("🫶")
                            .font(.system(size: 48))
                        Text("You don't have to carry this alone")
                            .font(Theme.rounded(.title2, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                        Text("Talking to someone can help. These lines are free, confidential, and always open.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.Spacing.lg)

                    VStack(spacing: Theme.Spacing.md) {
                        CallButton(title: "Tele-MANAS", detail: "14416 · Govt of India 24×7", phoneNumber: "14416")
                        CallButton(title: "KIRAN", detail: "1800-599-0019 · toll-free", phoneNumber: "18005990019")
                    }

                    Button { showBreathe = true } label: {
                        Text("Or breathe with me for a minute →")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: Theme.Spacing.xxl)

                    Text("The Room is not a substitute for professional care.")
                        .font(.caption)
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(Theme.Spacing.screenMargin)
            }
            .background(Theme.bgBase)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showBreathe) {
                NavigationStack {
                    BreatheSessionView(startAt: .now.addingTimeInterval(1), pattern: .standard, duration: 120, peers: [], sessionManager: nil)
                }
            }
        }
    }
}

private struct CallButton: View {
    let title: String
    let detail: String
    let phoneNumber: String

    var body: some View {
        Link(destination: URL(string: "tel:\(phoneNumber)")!) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: "phone.fill")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Call \(title)")
                        .font(Theme.rounded(.headline))
                    Text(detail)
                        .font(.caption)
                        .opacity(0.85)
                }
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .foregroundStyle(Theme.bgBase)
            .frame(maxWidth: .infinity)
            .background(Theme.accent)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
        }
        .accessibilityLabel("Call \(title), \(detail)")
    }
}

#Preview {
    CrisisSupportView()
}
