import SwiftUI
import SwiftData

struct LifeTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsItems: [LifeTimerSettings]
    @State private var timer = TimerEngine()
    @State private var reminderDates: [Date] = []
    @State private var nextReminderIn: TimeInterval = 0

    private var settings: LifeTimerSettings {
        settingsItems.first ?? LifeTimerSettings()
    }

    private var isTimerActive: Bool {
        timer.state != .idle
    }

    var body: some View {
        NavigationStack {
            LifeTimerSettingsForm(settings: settings) {
                startLifeTimer()
            }
            .navigationTitle("Living Practice")
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

            if timer.state == .running, nextReminderIn > 0 {
                Text("Next reminder in \(formatTime(nextReminderIn))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            activeControls

            Spacer()
        }
        .onChange(of: timer.remainingTime) { _, _ in
            updateNextReminderCountdown()
        }
    }

    @ViewBuilder
    private var activeControls: some View {
        switch timer.state {
        case .running:
            HStack(spacing: 40) {
                TimerButton(style: .pause) { timer.pause() }
                TimerButton(style: .stop) { stopLifeTimer() }
            }

        case .paused:
            HStack(spacing: 40) {
                TimerButton(style: .resume) { timer.resume() }
                TimerButton(style: .stop) { stopLifeTimer() }
            }

        case .finished:
            VStack(spacing: 16) {
                Text("Time's Up")
                    .font(.title3)
                TimerButton(style: .done) {
                    SoundManager.shared.playSound(settings.startStopSound)
                    timer.stop()
                }
            }
            .onAppear {
                SoundManager.shared.playSound(settings.startStopSound)
            }

        case .idle:
            EmptyView()
        }
    }

    private func startLifeTimer() {
        SoundManager.shared.playSound(settings.startStopSound)
        timer.start(duration: settings.totalDuration)
        scheduleRandomReminders()
    }

    private func stopLifeTimer() {
        SoundManager.shared.playSound(settings.startStopSound)
        timer.stop()
        reminderDates = []
        nextReminderIn = 0
        NotificationManager.shared.cancelAll()
    }

    private func scheduleRandomReminders() {
        NotificationManager.shared.cancelAll()
        var dates: [Date] = []
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
            dates.append(fireDate)
        }

        reminderDates = dates
        updateNextReminderCountdown()
    }

    private func updateNextReminderCountdown() {
        let now = Date()
        let passed = reminderDates.filter { $0 <= now }
        if !passed.isEmpty {
            reminderDates.removeAll { $0 <= now }
            SoundManager.shared.playSound(settings.reminderSound)
        }
        if let next = reminderDates.first {
            nextReminderIn = next.timeIntervalSince(now)
        } else {
            nextReminderIn = 0
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
