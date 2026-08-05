import SwiftUI

/// Screen 8 — Composer. Submits through `ModerationAPI` only; never writes to
/// Supabase directly. Routes to one of three outcomes via the callbacks.
struct ComposerSheet: View {
    var onApproved: () -> Void
    var onRejected: () -> Void
    var onCrisis: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isSubmitting = false
    @FocusState private var isFocused: Bool

    private let charLimit = 500

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            BottomSheetHeader(title: "Share with The Room", onCancel: { dismiss() }) {
                EmptyView()
            }

            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("Anonymous · checked for safety before it appears")
                    .font(.caption)
            }
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)

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
                    .onChange(of: text) { _, newValue in
                        if newValue.count > charLimit {
                            text = String(newValue.prefix(charLimit))
                        }
                    }
            }
            .frame(minHeight: 140)

            HStack {
                Text("\(text.count) / \(charLimit)")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                Spacer()
            }

            PrimaryButton(
                title: "Post anonymously",
                isEnabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                isLoading: isSubmitting,
                action: submit
            )
        }
        .padding(Theme.Spacing.lg)
        .bottomSheetSurface()
        .background(Theme.bgBase)
        .onAppear { isFocused = true }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSubmitting = true
        Task {
            let result = await ModerationAPI.submit(text: trimmed)
            await MainActor.run {
                isSubmitting = false
                switch result {
                case .success(let response) where response.approved:
                    dismiss()
                    onApproved()
                case .success(let response) where response.crisis:
                    dismiss()
                    onCrisis()
                case .success:
                    dismiss()
                    onRejected()
                case .failure:
                    // Fail-closed: treat any client/network error the same as a
                    // gentle rejection — never silently "succeed".
                    dismiss()
                    onRejected()
                }
            }
        }
    }
}

#Preview {
    ComposerSheet(onApproved: {}, onRejected: {}, onCrisis: {})
}
