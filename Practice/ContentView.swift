import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MeditationView()
                .tabItem {
                    Label("Meditation", systemImage: "bell")
                }

            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "figure.run")
                }

            LifeTimerView()
                .tabItem {
                    Label("Life", systemImage: "sparkles")
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
