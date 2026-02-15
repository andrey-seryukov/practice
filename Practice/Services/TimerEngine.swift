import Foundation

enum TimerState {
    case idle
    case running
    case paused
    case finished
}

@MainActor
@Observable
final class TimerEngine {
    private(set) var remainingTime: TimeInterval = 0
    private(set) var state: TimerState = .idle

    private var targetDate: Date?
    private var timer: Timer?
    private var pausedRemaining: TimeInterval = 0

    var totalDuration: TimeInterval = 0

    func start(duration: TimeInterval) {
        totalDuration = duration
        remainingTime = duration
        targetDate = Date().addingTimeInterval(duration)
        state = .running
        startTicking()
    }

    func pause() {
        guard state == .running else { return }
        pausedRemaining = remainingTime
        timer?.invalidate()
        timer = nil
        targetDate = nil
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        targetDate = Date().addingTimeInterval(pausedRemaining)
        state = .running
        startTicking()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        targetDate = nil
        remainingTime = 0
        state = .idle
    }

    func recalculateFromBackground() {
        guard let targetDate, state == .running else { return }
        let remaining = targetDate.timeIntervalSinceNow
        if remaining <= 0 {
            finish()
        } else {
            remainingTime = remaining
        }
    }

    private func startTicking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
    }

    private func tick() {
        guard let targetDate, state == .running else { return }
        let remaining = targetDate.timeIntervalSinceNow
        if remaining <= 0 {
            finish()
        } else {
            remainingTime = remaining
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        targetDate = nil
        remainingTime = 0
        state = .finished
    }
}
