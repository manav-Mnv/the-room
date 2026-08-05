import SwiftUI
import SwiftData

/// Screen 3 — Journal list (bento grid): large today/most-recent card, two smaller
/// tiles, a "This week" insight card, and a bottom "Write today's entry" button.
struct JournalListView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var showEditor = false
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                SectionHeader(title: "Journal", subtitle: "On this device only 🔒")

                if entries.isEmpty {
                    EmptyJournalState()
                } else {
                    bentoGrid
                    if let weekSummary {
                        WeekInsightCard(text: weekSummary)
                    }
                }
            }
            .padding(Theme.Spacing.screenMargin)
            .padding(.bottom, 90) // room for the floating primary button
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "Write today's entry") { showEditor = true }
                .padding(.horizontal, Theme.Spacing.screenMargin)
                .padding(.bottom, Theme.Spacing.sm)
                .background(Theme.bgBase.opacity(0.001)) // keeps tap area, no visual seam
        }
        .sheet(isPresented: $showEditor) {
            JournalEditorSheet(mostRecentEntry: entries.first)
        }
        .navigationDestination(item: $selectedEntry) { entry in
            JournalEntryDetailView(entry: entry, onNewEntry: { showEditor = true })
        }
    }

    private var bentoGrid: some View {
        VStack(spacing: Theme.Spacing.md) {
            if let latest = entries.first {
                Button { selectedEntry = latest } label: {
                    JournalEntryTile(entry: latest, style: .large)
                }
                .buttonStyle(.plain)
            }

            if entries.count > 1 {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(entries.dropFirst().prefix(2), id: \.persistentModelID) { entry in
                        Button { selectedEntry = entry } label: {
                            JournalEntryTile(entry: entry, style: .small)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    /// Most frequent emotion tags from entries in the last 7 days — a lightweight,
    /// locally-computed summary (not a fresh AI call) of what the on-device AI has
    /// already tagged this week.
    private var weekSummary: String? {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let recentEmotions = entries
            .filter { $0.date >= weekAgo }
            .flatMap(\.emotions)
        guard !recentEmotions.isEmpty else { return nil }

        let counts = Dictionary(grouping: recentEmotions, by: { $0 }).mapValues(\.count)
        let top = counts.sorted { $0.value > $1.value }.prefix(2).map(\.key)
        guard !top.isEmpty else { return nil }
        return "This week you've mostly felt " + top.joined(separator: " and ") + "."
    }
}

private struct EmptyJournalState: View {
    var body: some View {
        RoomCard {
            VStack(spacing: Theme.Spacing.sm) {
                Text("✦")
                    .font(.title)
                    .foregroundStyle(Theme.accent)
                Text("Your first entry is a good place to start")
                    .font(Theme.rounded(.headline))
                    .foregroundStyle(Theme.textPrimary)
                Text("Whatever's on your mind — it stays right here on your phone.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct WeekInsightCard: View {
    let text: String

    var body: some View {
        RoomCard(background: Theme.bgBreathe) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("This week")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.accent)
                    .tracking(1)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreathePrimary)
            }
        }
    }
}

/// One tile in the bento grid — large (today/most recent) or small (side-by-side).
struct JournalEntryTile: View {
    enum Style { case large, small }
    let entry: JournalEntry
    let style: Style

    var body: some View {
        RoomCard(background: Theme.claySoft) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(entry.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Text(entry.text)
                    .font(style == .large ? .body : .subheadline)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(style == .large ? 4 : 3)
                if !entry.emotions.isEmpty {
                    Text(entry.emotions.prefix(2).joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: style == .large ? 140 : 110, alignment: .topLeading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { JournalListView() }
        .modelContainer(for: [MoodEntry.self, JournalEntry.self], inMemory: true)
}
