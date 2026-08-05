import SwiftUI
import SwiftData

/// Screen 2 — Today: mood check-in, streak, "Breathe together" CTA.
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]
    @AppStorage("userDisplayName") private var displayName: String = ""

    @State private var selectedLevel: Int?
    @State private var note: String = ""
    @State private var showBreathe = false

    private var todayEntry: MoodEntry? {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: startOfToday) }
    }

    private var streak: StreakCalculator.Result {
        StreakCalculator.calculate(checkInDates: entries.map(\.date))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                header

                if let todayEntry {
                    LoggedTodayCard(entry: todayEntry)
                } else {
                    CheckInCard(
                        selectedLevel: $selectedLevel,
                        note: $note,
                        onSave: saveCheckIn
                    )
                }

                NavigationLink {
                    MoodCalendarView()
                } label: {
                    StreakCard(current: streak.current, longest: streak.longest)
                }
                .buttonStyle(.plain)

                BreatheCTACard { showBreathe = true }
            }
            .padding(Theme.Spacing.screenMargin)
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
        .navigationDestination(isPresented: $showBreathe) {
            BreatheHomeView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(greeting)
                .font(Theme.rounded(.title2, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
            if todayEntry == nil {
                Text("How are you feeling today?")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "morning"
        case 12..<17: timeOfDay = "afternoon"
        default: timeOfDay = "evening"
        }
        let name = displayName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Good \(timeOfDay)" : "Good \(timeOfDay), \(name)"
    }

    private func saveCheckIn() {
        guard let selectedLevel else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = MoodEntry(date: .now, level: selectedLevel, note: trimmedNote.isEmpty ? nil : trimmedNote)
        modelContext.insert(entry)
        try? modelContext.save()
    }
}

// MARK: - Check-in card

private struct CheckInCard: View {
    @Binding var selectedLevel: Int?
    @Binding var note: String
    let onSave: () -> Void

    private let noteLimit = 140

    var body: some View {
        RoomCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                HStack {
                    ForEach(1...5, id: \.self) { level in
                        MoodEmojiButton(
                            emoji: MoodLevel.emojis[level - 1],
                            level: level,
                            isSelected: selectedLevel == level
                        ) {
                            withAnimation(Theme.Motion.gentle) { selectedLevel = level }
                        }
                        if level < 5 { Spacer() }
                    }
                }

                TextField("Add a note (optional)", text: $note, axis: .vertical)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1...3)
                    .onChange(of: note) { _, newValue in
                        if newValue.count > noteLimit {
                            note = String(newValue.prefix(noteLimit))
                        }
                    }
                    .accessibilityLabel("Optional note about today")

                PrimaryButton(title: "Save check-in", isEnabled: selectedLevel != nil, action: onSave)
            }
        }
    }
}

private struct LoggedTodayCard: View {
    let entry: MoodEntry

    var body: some View {
        RoomCard(background: Theme.claySoft) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack(spacing: Theme.Spacing.sm) {
                    Text(MoodLevel.emojis[entry.level - 1])
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You checked in today")
                            .font(Theme.rounded(.headline))
                            .foregroundStyle(Theme.textPrimary)
                        Text(MoodLevel.label(for: entry.level))
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.top, Theme.Spacing.xs)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Streak card

private struct StreakCard: View {
    let current: Int
    let longest: Int

    var body: some View {
        RoomCard {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("🔥 \(current)")
                        .font(Theme.rounded(.title, weight: .bold))
                        .foregroundStyle(Theme.olive)
                    Text(current == 0 ? "Fresh start today" : "day streak")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(longest)")
                        .font(Theme.rounded(.title3, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("longest")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current streak \(current) days, longest streak \(longest) days")
    }
}

// MARK: - Breathe CTA

private struct BreatheCTACard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoomCard(background: Theme.bgBreathe) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Breathe together")
                            .font(Theme.rounded(.headline))
                            .foregroundStyle(Theme.onBreathePrimary)
                        Text("Start a session — friends nearby can join")
                            .font(.subheadline)
                            .foregroundStyle(Theme.accent)
                    }
                    Spacer()
                    Image(systemName: "wind")
                        .foregroundStyle(Theme.accent)
                        .font(.title2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Breathe together")
        .accessibilityHint("Start a guided breathing session, alone or with nearby friends")
    }
}

#Preview {
    NavigationStack { TodayView() }
        .modelContainer(for: [MoodEntry.self, JournalEntry.self], inMemory: true)
}
