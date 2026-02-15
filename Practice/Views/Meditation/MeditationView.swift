import SwiftUI
import SwiftData

struct MeditationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsItems: [MeditationSettings]
    @State private var timer = TimerEngine()
    @State private var showSettings = false
    @State private var sessionStartDate: Date?

    private var settings: MeditationSettings {
        settingsItems.first ?? MeditationSettings()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                timerDisplay

                controls

                Spacer()
            }
            .navigationTitle("Meditation")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                MeditationSettingsSheet(settings: settings)
            }
            .onAppear {
                ensureSettings()
            }
        }
    }

    private var timerDisplay: some View {
        Text(formatTime(timer.state == .idle ? settings.duration : timer.remainingTime))
            .font(.system(size: 64, weight: .thin, design: .monospaced))
            .contentTransition(.numericText())
    }

    @ViewBuilder
    private var controls: some View {
        switch timer.state {
        case .idle:
            Button("Start") {
                sessionStartDate = Date()
                timer.start(duration: settings.duration)
                SoundManager.shared.playSound(settings.startEndSound)
            }
            .font(.title2)

        case .running:
            HStack(spacing: 40) {
                Button("Pause") { timer.pause() }
                Button("Stop", role: .destructive) { stopTimer() }
            }
            .font(.title2)

        case .paused:
            HStack(spacing: 40) {
                Button("Resume") { timer.resume() }
                Button("Stop", role: .destructive) { stopTimer() }
            }
            .font(.title2)

        case .finished:
            VStack(spacing: 16) {
                Text("Session Complete")
                    .font(.title3)
                Button("Done") { timer.stop() }
                    .font(.title2)
            }
            .onAppear { onSessionFinished() }
        }
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

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(ceil(interval)))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
