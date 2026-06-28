import SwiftUI

@main
struct LexoraApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var repository = WordRepository()
    @StateObject private var favorites = FavoritesManager()
    @StateObject private var notifications = NotificationManager()
    @StateObject private var premium = PremiumManager()
    @StateObject private var practice = PracticeSessionManager()
    @StateObject private var reviewPrompts = ReviewPromptManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
                .environmentObject(repository)
                .environmentObject(favorites)
                .environmentObject(notifications)
                .environmentObject(premium)
                .environmentObject(practice)
                .environmentObject(reviewPrompts)
                .font(.lexoraBody)
                .tint(LexoraColors.accent)
                .preferredColorScheme(.light)
                .onAppear {
                    reviewPrompts.registerAppLaunch()
                }
                .task {
                    premium.configure()
                    await practice.loadPracticeIfNeeded()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    Task {
                        await premium.refreshCustomerInfo(silent: true)
                        await practice.loadPracticeIfNeeded()
                    }
                }
        }
    }
}

private struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(LexoraColors.accent)
        .toolbarBackground(LexoraColors.cardBackground, for: .tabBar)
        .toolbarColorScheme(.light, for: .tabBar)
    }
}
