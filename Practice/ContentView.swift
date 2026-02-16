import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MeditationView()
                .tabItem {
                    Label("Sit", systemImage: "figure.mind.and.body")
                }

            ActivityView()
                .tabItem {
                    Label("Move", systemImage: "figure.yoga")
                }

            LifeTimerView()
                .tabItem {
                    Label("Live", systemImage: "sparkles")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            MeditationSettings.self,
            ActivityTemplate.self,
            ActivityInterval.self,
            LifeTimerSettings.self,
            AppSettings.self,
        ], inMemory: true)
}
