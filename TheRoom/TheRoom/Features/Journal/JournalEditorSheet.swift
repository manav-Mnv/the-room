import SwiftUI
import SwiftData

/// Screen 5 — Journal editor bottom sheet. Text input lives in a sheet, not a
/// pushed screen (thumb-reachable, 2026 pattern).
struct JournalEditorSheet: View {
    let mostRecentEntry: JournalEntry?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isSaving = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            BottomSheetHeader(title: "New entry", onCancel: { dismiss() }) {
                EmptyView()
            }

            if let prompt = aiPromptChip {
                PromptChip(text: prompt)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("What's on your mind?")
                        .font(.body)
                        .foregroundStyle(Theme.textMuted)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                TextEditor(text: $text)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)
                    .tint(Theme.accent)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
            }
            .frame(minHeight: 160)

            HStack {
                Text("\(text.count) / no limit · saved on device")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                Spacer()
            }

            PrimaryButton(
                title: "Save & reflect ✦",
                isEnabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                isLoading: isSaving,
                action: save
            )
        }
        .padding(Theme.Spacing.lg)
        .bottomSheetSurface()
        .background(Theme.bgBase)
        .onAppear { isFocused = true }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    /// References the most recent entry's first emotion tag, if any — a light nudge,
    /// never a question the user has to answer.
    private var aiPromptChip: String? {
        guard let recent = mostRecentEntry, let topEmotion = recent.emotions.first else {
            return nil
        }
        return "Still thinking about feeling \(topEmotion)?"
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let entry = JournalEntry(text: trimmed)
        modelContext.insert(entry)
        try? modelContext.save()

        isSaving = true
        Task {
            let outcome = await AIReflectionService.reflect(on: trimmed)
            await MainActor.run {
                switch outcome {
                case .reflected(let reflection, let emotions):
                    entry.reflection = reflection
                    entry.emotions = emotions
                case .unavailable:
                    entry.reflectionUnavailable = true
                case .failed:
                    entry.reflectionUnavailable = true
                }
                entry.reflectionAttempted = true
                try? modelContext.save()
                isSaving = false
                dismiss()
            }
        }
    }
}

private struct PromptChip: View {
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Text("✦ PROMPT FOR YOU")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.accent)
                .tracking(0.5)
            Text(text)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.claySoft.opacity(0.5))
        .clipShape(Capsule())
    }
}

#Preview {
    JournalEditorSheet(mostRecentEntry: nil)
        .modelContainer(for: [MoodEntry.self, JournalEntry.self], inMemory: true)
}
