import SwiftUI

/// Root navigation: 4 tabs (Today · Journal · The Room · Breathe) plus a
/// crisis-support affordance reachable from every tab.
struct RootTabView: View {
    @State private var showCrisis = false

    var body: some View {
        TabView {
            Tab("Today", systemImage: "sun.max") {
                NavigationStack {
                    TodayView()
                        .crisisToolbarButton(isPresented: $showCrisis)
                }
            }
            Tab("Journal", systemImage: "book") {
                NavigationStack {
                    JournalListView()
                        .crisisToolbarButton(isPresented: $showCrisis)
                }
            }
            Tab("The Room", systemImage: "person.2") {
                NavigationStack {
                    RoomFeedView()
                        .crisisToolbarButton(isPresented: $showCrisis)
                }
            }
            Tab("Breathe", systemImage: "wind") {
                NavigationStack {
                    BreatheHomeView()
                        .crisisToolbarButton(isPresented: $showCrisis)
                }
            }
        }
    }
}

/// Persistent crisis-support entry point, visible on every tab's toolbar.
/// Calm, never alarming — a lifebuoy rather than a red flag.
private struct CrisisToolbarModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = true
                    } label: {
                        Image(systemName: "figure.mind.and.body")
                            .foregroundStyle(Theme.accent)
                    }
                    .accessibilityLabel("Crisis support")
                    .accessibilityHint("Opens Tele-MANAS and KIRAN helpline numbers")
                }
            }
            .sheet(isPresented: $isPresented) {
                CrisisSupportView()
            }
    }
}

extension View {
    func crisisToolbarButton(isPresented: Binding<Bool>) -> some View {
        modifier(CrisisToolbarModifier(isPresented: isPresented))
    }
}

#Preview {
    RootTabView()
}
