import SwiftUI
import SwiftData

struct LifeTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsItems: [LifeTimerSettings]
    @State private var timer = TimerEngine()
    @State private var showSettings = false
    @State private var nextReminderIn: TimeInterval = 0

    private var settings: LifeTimerSettings {
        settingsItems.first ?? LifeTimerSettings()
    }

    private var isTimerActive: Bool {
        timer.state != .idle
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                Text(formatTime(settings.totalDuration))
                    .font(.system(size: 64, weight: .thin, design: .monospaced))

                Button("Start") { startLifeTimer() }
                    .font(.title2)

                Spacer()
            }
            .navigationTitle("Life")
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
                LifeTimerSettingsSheet(settings: settings)
            }
            .onAppear {
                ensureSettings()
            }
        }
        .fullScreenCover(isPresented: .constant(isTimerActive)) {
            lifeTimerScreen
        }
    }

    private var lifeTimerScreen: some View {
        VStack(spacing: 40) {
            Spacer()

            Text(formatTime(timer.remainingTime))
                .font(.system(size: 64, weight: .thin, design: .monospaced))
                .contentTransition(.numericText())

            if timer.state == .running {
                Text("Next reminder in \(formatTime(nextReminderIn))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            activeControls

            Spacer()
        }
    }

    @ViewBuilder
    private var activeControls: some View {
        switch timer.state {
        case .running:
            HStack(spacing: 40) {
                Button("Pause") { timer.pause() }
                Button("Stop", role: .destructive) { stopLifeTimer() }
            }
            .font(.title2)

        case .paused:
            HStack(spacing: 40) {
                Button("Resume") { timer.resume() }
                Button("Stop", role: .destructive) { stopLifeTimer() }
            }
            .font(.title2)

        case .finished:
            VStack(spacing: 16) {
                Text("Time's Up")
                    .font(.title3)
                Button("Done") { timer.stop() }
                    .font(.title2)
            }

        case .idle:
            EmptyView()
        }
    }

    private func startLifeTimer() {
        timer.start(duration: settings.totalDuration)
        scheduleRandomReminders()
    }

    private func stopLifeTimer() {
        timer.stop()
        NotificationManager.shared.cancelAll()
    }

    private func scheduleRandomReminders() {
        NotificationManager.shared.cancelAll()
        var elapsed: TimeInterval = 0
        let total = settings.totalDuration

        while elapsed < total {
            let gap = TimeInterval.random(in: settings.minInterval...settings.maxInterval)
            elapsed += gap
            guard elapsed < total else { break }

            let fireDate = Date().addingTimeInterval(elapsed)
            NotificationManager.shared.scheduleNotification(
                at: fireDate,
                title: "Life Timer",
                body: "Take a moment to be present."
            )

            if nextReminderIn == 0 {
                nextReminderIn = gap
            }
        }
    }

    private func ensureSettings() {
        if settingsItems.isEmpty {
            modelContext.insert(LifeTimerSettings())
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(ceil(interval)))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
