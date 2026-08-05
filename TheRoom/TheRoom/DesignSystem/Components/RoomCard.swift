import SwiftUI

/// The base surface for content grouping. Depth comes from tint layering
/// (bgBase → bgCard → bgElevated), never from drop shadows.
struct RoomCard<Content: View>: View {
    var background: Color = Theme.bgCard
    var padding: CGFloat = Theme.Spacing.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
    }
}

#Preview {
    RoomCard {
        Text("Card content")
            .foregroundStyle(Theme.textPrimary)
    }
    .padding()
    .background(Theme.bgBase)
}
