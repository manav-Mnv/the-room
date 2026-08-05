import SwiftUI
import SwiftData
import UserNotifications

/// Screen 13 — Settings. Uses native grouped List styling (matches the master
/// prompt's explicit "grouped iOS-style sections" direction) rather than the
/// custom card system used elsewhere.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage("reminderEnabled") private var reminderEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("groupSessionDisplayName") private var groupSessionDisplayName = ""
    @AppStorage("appearanceOverride") private var appearanceOverride = AppearanceOption.system.rawValue

    @State private var showDeleteConfirmation = false
    @State private var didDeleteData = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? .now
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = components.hour ?? 20
                reminderMinute = components.minute ?? 0
                Task { await ReminderScheduler.schedule(at: components) }
            }
        )
    }

    var body: some View {
        List {
            Section("Daily reminder") {
                Toggle("Remind me to check in", isOn: $reminderEnabled)
                    .onChange(of: reminderEnabled) { _, enabled in
                        if enabled {
                            Task {
                                _ = await ReminderScheduler.requestAuthorizationIfNeeded()
                                await ReminderScheduler.schedule(at: DateComponents(hour: reminderHour, minute: reminderMinute))
                            }
                        } else {
                            ReminderScheduler.cancel()
                        }
                    }
                if reminderEnabled {
                    DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                }
            }

            Section("Group sessions") {
                TextField("Your name for Breathe Together", text: $groupSessionDisplayName)
                    .accessibilityLabel("Display name shown to nearby friends during group breathing sessions")
            }

            Section("Appearance") {
                Picker("Appearance", selection: $appearanceOverride) {
                    ForEach(AppearanceOption.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Privacy") {
                Label("Journal & moods stay on this iPhone · No account · no cloud · works offline", systemImage: "lock.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete all my data", systemImage: "trash")
                }
            }

            Section("About") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tele-MANAS · 14416 · Govt of India 24×7")
                    Text("KIRAN · 1800-599-0019 · toll-free")
                }
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

                Text("The Room is not a substitute for professional mental health care.")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
            }

            Section {
                Text("The Room · v1.0 · made with 🫀 in India")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Settings")
        .tint(Theme.accent)
        .confirmationDialog(
            "Delete all your data?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete everything", role: .destructive, action: deleteAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes every mood check-in and journal entry from this iPhone. It can't be undone.")
        }
        .alert("Data deleted", isPresented: $didDeleteData) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A fresh start today, whenever you're ready.")
        }
    }

    private func deleteAllData() {
        try? modelContext.delete(model: MoodEntry.self)
        try? modelContext.delete(model: JournalEntry.self)
        try? modelContext.save()
        ReactionStore.clearAll()
        didDeleteData = true
    }
}

enum AppearanceOption: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .modelContainer(for: [MoodEntry.self, JournalEntry.self], inMemory: true)
}
