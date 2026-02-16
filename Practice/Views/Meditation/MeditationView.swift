import SwiftUI
import SwiftData

struct MeditationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsItems: [MeditationSettings]
    @State private var timer = TimerEngine()
    @State private var sessionStartDate: Date?

    private var settings: MeditationSettings {
        settingsItems.first ?? MeditationSettings()
    }

    private var isActive: Bool {
        timer.state == .running || timer.state == .paused || timer.state == .finished
    }

    var body: some View {
        NavigationStack {
            Group {
                if isActive {
                    MeditationTimerView(timer: timer, settings: settings) {
                        stopTimer()
                    } onFinished: {
                        onSessionFinished()
                    }
                } else {
                    MeditationSettingsForm(settings: settings) {
                        startTimer()
                    }
                }
            }
            .navigationTitle("Sitting Practice")
            .onAppear {
                ensureSettings()
            }
        }
    }

    private func startTimer() {
        sessionStartDate = Date()
        timer.start(duration: settings.duration)
        SoundManager.shared.playSound(settings.startEndSound)
    }

    private func stopTimer() {
        timer.stop()
        sessionStartDate = nil
    }

    private func onSessionFinished() {
        SoundManager.shared.playSound(settings.startEndSound)
    }

    private func ensureSettings() {
        if settingsItems.isEmpty {
            modelContext.insert(MeditationSettings())
        }
    }
}
