import SwiftUI
import SwiftData

/// Screen 4 — Journal entry with AI reflection.
struct JournalEntryDetailView: View {
    let entry: JournalEntry
    var onNewEntry: () -> Void

    @Query private var moodEntries: [MoodEntry]

    private var sameDayMood: MoodEntry? {
        moodEntries.first { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                header
                Text(entry.text)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)

                if let reflection = entry.reflection {
                    ReflectionCard(reflection: reflection, emotions: entry.emotions)
                } else if entry.reflectionUnavailable {
                    UnavailableReflectionNotice()
                } else if !entry.reflectionAttempted {
                    RoomCard {
                        HStack(spacing: Theme.Spacing.sm) {
                            ProgressView()
                            Text("Reflecting…")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.screenMargin)
            .padding(.bottom, 90)
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "New entry", action: onNewEntry)
                .padding(.horizontal, Theme.Spacing.screenMargin)
                .padding(.bottom, Theme.Spacing.sm)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: Theme.Spacing.sm) {
            if let mood = sameDayMood {
                Text(MoodLevel.emojis[mood.level - 1])
                    .font(.title2)
            }
            Text(entry.date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                .font(Theme.rounded(.headline))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

private struct ReflectionCard: View {
    let reflection: String
    let emotions: [String]

    var body: some View {
        RoomCard(background: Theme.claySoft) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text("✦ REFLECTION · ON THIS DEVICE ONLY")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)

                Text(reflection)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)

                if !emotions.isEmpty {
                    HStack(spacing: Theme.Spacing.xs) {
                        ForEach(emotions, id: \.self) { emotion in
                            Pill(text: emotion, background: Theme.bgElevated)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct UnavailableReflectionNotice: View {
    var body: some View {
        RoomCard(background: Theme.bgElevated) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.textMuted)
                Text("Reflections aren't available on this device")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

#Preview {
    let entry = JournalEntry(text: "Today felt like a lot, but I got through my presentation.")
    entry.reflection = "You carried something heavy today and still showed up. That took real courage."
    entry.emotions = ["anxious", "relieved"]
    return NavigationStack {
        JournalEntryDetailView(entry: entry, onNewEntry: {})
    }
    .modelContainer(for: [MoodEntry.self, JournalEntry.self], inMemory: true)
}
