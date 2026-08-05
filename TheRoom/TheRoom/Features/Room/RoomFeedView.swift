import SwiftUI

/// Screen 7 — The Room feed.
struct RoomFeedView: View {
    @State private var posts: [Post] = []
    @State private var isOffline = false
    @State private var isLoading = false
    @State private var showComposer = false
    @State private var route: Route?

    private enum Route: Identifiable {
        case rejected
        case crisis
        var id: Self { self }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                SectionHeader(title: "The Room", subtitle: "Anonymous · moderated · you're not alone here")

                if !RoomConfig.isSupabaseConfigured {
                    NotConfiguredNotice()
                } else if isOffline {
                    OfflineNotice()
                } else if !RoomConfig.isModerationConfigured {
                    PostingNotYetAvailableNotice()
                }

                if posts.isEmpty && !isLoading {
                    EmptyFeedState()
                } else {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(posts) { post in
                            PostCard(post: post)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.screenMargin)
            .padding(.bottom, 90)
        }
        .background(Theme.bgBase)
        .scrollContentBackground(.hidden)
        .refreshable { await load() }
        .task { await load() }
        .safeAreaInset(edge: .bottom) {
            ComposerBar(isEnabled: RoomConfig.isModerationConfigured && !isOffline) { showComposer = true }
        }
        .sheet(isPresented: $showComposer) {
            ComposerSheet(onApproved: {
                Task { await load() }
            }, onRejected: {
                route = .rejected
            }, onCrisis: {
                route = .crisis
            })
        }
        .sheet(item: $route) { route in
            switch route {
            case .rejected:
                RejectedOutcomeView()
            case .crisis:
                CrisisBridgeOutcomeView()
            }
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        let result = await FeedAPI.fetchPosts()
        switch result {
        case .success(let fetched):
            posts = fetched
            isOffline = false
        case .failure:
            posts = PostCache.load()
            isOffline = true
        }
    }
}

private struct PostCard: View {
    let post: Post
    @State private var hasReacted: Bool
    @State private var displayedCount: Int

    init(post: Post) {
        self.post = post
        _hasReacted = State(initialValue: ReactionStore.hasReacted(to: post.id))
        _displayedCount = State(initialValue: post.metooCount)
    }

    var body: some View {
        RoomCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text(post.text)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)

                HStack {
                    Button(action: react) {
                        Pill(text: "🫂 me too · \(displayedCount)", background: hasReacted ? Theme.accent.opacity(0.25) : Theme.claySoft)
                    }
                    .buttonStyle(.plain)
                    .disabled(hasReacted)
                    .accessibilityLabel(hasReacted ? "You said me too" : "Say me too")

                    Spacer()

                    Text("\(post.createdAt.formatted(.relative(presentation: .named))) · anonymous")
                        .font(.caption)
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
    }

    private func react() {
        guard !hasReacted else { return }
        hasReacted = true
        displayedCount += 1
        ReactionStore.markReacted(post.id)
        Task { await FeedAPI.react(to: post.id) }
    }
}

private struct ComposerBar: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text("Share something anonymously…")
                    .font(.subheadline)
                    .foregroundStyle(Theme.onBreatheSecondary)
                Spacer()
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(Theme.accent)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, 14)
            .background(Theme.bgBreathe)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
        .padding(.horizontal, Theme.Spacing.screenMargin)
        .padding(.bottom, Theme.Spacing.sm)
        .accessibilityLabel("Share something anonymously")
    }
}

private struct EmptyFeedState: View {
    var body: some View {
        RoomCard {
            Text("The Room is quiet right now. Be the first to share something today.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct OfflineNotice: View {
    var body: some View {
        RoomCard(background: Theme.bgElevated) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(Theme.textMuted)
                Text("You're offline — showing saved posts. Sharing is paused until you're back online.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

private struct NotConfiguredNotice: View {
    var body: some View {
        RoomCard(background: Theme.bgElevated) {
            Text("The Room feed isn't connected to a server yet.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

private struct PostingNotYetAvailableNotice: View {
    var body: some View {
        RoomCard(background: Theme.bgElevated) {
            Text("Reading is live — posting opens once the moderation service is deployed.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview {
    NavigationStack { RoomFeedView() }
}
