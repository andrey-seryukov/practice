import SwiftUI
import SwiftData

@main
struct PracticeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            MeditationSettings.self,
            ActivityTemplate.self,
            ActivityInterval.self,
            LifeTimerSettings.self,
            AppSettings.self,
        ])
    }
}
