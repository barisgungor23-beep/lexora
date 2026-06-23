import SwiftUI

@main
struct LexoraApp: App {
    @StateObject private var repository = WordRepository()
    @StateObject private var favorites = FavoritesManager()
    @StateObject private var notifications = NotificationManager()
    @StateObject private var premium = PremiumManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(repository)
                .environmentObject(favorites)
                .environmentObject(notifications)
                .environmentObject(premium)
                .font(.lexoraBody)
                .tint(LexoraColors.accent)
                .task {
                    premium.configure()
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
    }
}
