import SwiftUI
import SwiftData

@main
struct PracticeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    _ = await NotificationManager.shared.requestAuthorization()
                }
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
