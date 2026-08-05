import SwiftUI

/// Standard bottom-sheet chrome: grab handle + top row (Cancel / title / trailing action).
/// All text input in The Room happens inside sheets built on this — never pushed screens.
struct BottomSheetHeader<Trailing: View>: View {
    let title: String
    let onCancel: () -> Void
    @ViewBuilder var trailing: Trailing

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Capsule()
                .fill(Theme.textMuted.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, Theme.Spacing.sm)

            HStack {
                Button("Cancel", action: onCancel)
                    .foregroundStyle(Theme.textSecondary)

                Spacer()

                Text(title)
                    .font(Theme.rounded(.headline))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                trailing
            }
        }
    }
}

/// View modifier applying the sheet's rounded-top, elevated-surface presentation style.
struct BottomSheetSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.bgElevated)
            .clipShape(.rect(topLeadingRadius: Theme.Radius.sheet, topTrailingRadius: Theme.Radius.sheet))
    }
}

extension View {
    func bottomSheetSurface() -> some View {
        modifier(BottomSheetSurface())
    }
}

#Preview {
    VStack {
        BottomSheetHeader(title: "New entry", onCancel: {}) {
            Button("Save") {}
        }
        Spacer()
    }
    .padding(.horizontal, Theme.Spacing.lg)
    .frame(maxHeight: .infinity)
    .bottomSheetSurface()
    .background(Theme.bgBase)
}
