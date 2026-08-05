import SwiftUI

/// Screen-level title + optional subtitle (e.g. "The Room" / "Anonymous · moderated · you're not alone here").
struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.rounded(.largeTitle, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SectionHeader(title: "The Room", subtitle: "Anonymous · moderated · you're not alone here")
        .padding()
        .background(Theme.bgBase)
}
