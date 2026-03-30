import SwiftUI
import SwiftData

enum MeditationPhase {
    case idle
    case warmup
    case meditation
    case finished
}

struct MeditationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var settingsItems: [MeditationSettings]
    @State private var timer = TimerEngine()
    @State private var phase: MeditationPhase = .idle
    @State private var sessionStartDate: Date?
    @State private var nextGongThreshold: TimeInterval = 0

    private var settings: MeditationSettings {
        settingsItems.first ?? MeditationSettings()
    }

    private var isActive: Bool {
        phase != .idle
    }

    var body: some View {
        NavigationStack {
            MeditationSettingsForm(settings: settings) {
                startSession()
            }
            .navigationTitle("Sitting Practice")
            .onAppear {
                ensureSettings()
            }
        }
        .fullScreenCover(isPresented: .constant(isActive)) {
            MeditationTimerView(
                timer: timer,
                settings: settings,
                phase: phase
            ) {
                stopTimer()
            } onFinished: {
                onPhaseFinished()
            }
            .onChange(of: timer.remainingTime) { _, remaining in
                checkIntervalBell(remaining: remaining)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhase(newPhase)
        }
        .onChange(of: timer.state) { oldState, newState in
            if oldState == .running && newState == .paused {
                NotificationManager.shared.cancelIntervalBells()
                NotificationManager.shared.cancelTimerCompletion()
            } else if oldState == .paused && newState == .running && phase == .meditation {
                scheduleIntervalBellNotifications()
            }
        }
    }

    private func startSession() {
        sessionStartDate = Date()
        if settings.warmupDuration > 0 {
            phase = .warmup
            timer.start(duration: settings.warmupDuration)
        } else {
            startMeditation()
        }
    }

    private func startMeditation() {
        phase = .meditation
        timer.start(duration: settings.duration)
        SoundManager.shared.playSound(settings.startEndSound)

        let interval = settings.intermediateGongInterval
        if interval > 0 {
            nextGongThreshold = settings.duration - interval
        } else {
            nextGongThreshold = 0
        }

        scheduleIntervalBellNotifications()
    }

    private func onPhaseFinished() {
        switch phase {
        case .warmup:
            startMeditation()
        case .meditation:
            phase = .finished
            SoundManager.shared.playSound(settings.startEndSound)
        default:
            break
        }
    }

    private func checkIntervalBell(remaining: TimeInterval) {
        guard phase == .meditation, nextGongThreshold > 0, remaining <= nextGongThreshold else { return }
        SoundManager.shared.playSound(settings.intermediateSound)
        nextGongThreshold -= settings.intermediateGongInterval
        if nextGongThreshold <= 0 {
            nextGongThreshold = 0
        }
    }

    private func handleScenePhase(_ newPhase: ScenePhase) {
        guard timer.state == .running else { return }
        switch newPhase {
        case .background:
            if let target = timer.targetDate {
                NotificationManager.shared.scheduleTimerCompletion(
                    at: target,
                    title: phase == .warmup ? "Warm-up Complete" : "Meditation Complete",
                    sound: settings.startEndSound
                )
            }
        case .active:
            NotificationManager.shared.cancelTimerCompletion()
            timer.recalculateFromBackground()
            syncGongThreshold()
        default:
            break
        }
    }

    private func syncGongThreshold() {
        guard phase == .meditation else { return }
        let interval = settings.intermediateGongInterval
        guard interval > 0 else { return }
        while nextGongThreshold > 0 && timer.remainingTime <= nextGongThreshold {
            nextGongThreshold -= interval
        }
        if nextGongThreshold < 0 { nextGongThreshold = 0 }
    }

    private func scheduleIntervalBellNotifications() {
        guard let target = timer.targetDate else { return }
        NotificationManager.shared.scheduleIntervalBells(
            targetDate: target,
            duration: settings.duration,
            interval: settings.intermediateGongInterval,
            sound: settings.intermediateSound
        )
    }

    private func stopTimer() {
        timer.stop()
        phase = .idle
        sessionStartDate = nil
        NotificationManager.shared.cancelTimerCompletion()
        NotificationManager.shared.cancelIntervalBells()
    }

    private func ensureSettings() {
        if settingsItems.isEmpty {
            modelContext.insert(MeditationSettings())
        }
    }
}
