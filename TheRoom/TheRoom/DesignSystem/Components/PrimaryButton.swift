import SwiftUI

/// Bottom-anchored, full-width-with-margins primary action button.
/// Capsule shape, terracotta fill, gentle spring press feedback.
struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(Theme.bgBase)
                } else {
                    Text(title)
                        .font(Theme.rounded(.body, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(Theme.bgBase)
            .background(isEnabled ? Theme.accent : Theme.accent.opacity(0.4))
            .clipShape(Capsule())
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .animation(Theme.Motion.gentle, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
    }
}

/// Secondary / low-emphasis action — text-only or outline, used for "or start alone",
/// "Done", cancel-style actions.
struct SecondaryButton: View {
    let title: String
    var style: Style = .text
    let action: () -> Void

    enum Style {
        case text
        case outline
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.rounded(.body, weight: .medium))
                .frame(maxWidth: style == .outline ? .infinity : nil)
                .padding(.vertical, style == .outline ? 16 : 8)
                .foregroundStyle(style == .outline ? Theme.onBreathePrimary : Theme.textSecondary)
                .background {
                    if style == .outline {
                        Capsule().stroke(Theme.onBreathePrimary.opacity(0.4), lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Save & reflect ✦") {}
        SecondaryButton(title: "or start alone") {}
        SecondaryButton(title: "End session", style: .outline) {}
    }
    .padding()
    .background(Theme.bgBreathe)
}
