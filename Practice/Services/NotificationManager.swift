import UserNotifications

final class NotificationManager: @unchecked Sendable {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func scheduleNotification(at date: Date, title: String, body: String = "", sound: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let sound {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(sound))
        } else {
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(date.timeIntervalSinceNow, 1),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleTimerCompletion(at date: Date, title: String, sound: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Your session is complete."
        if let sound {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(sound))
        } else {
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(date.timeIntervalSinceNow, 1),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "timer-completion",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelTimerCompletion() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["timer-completion"]
        )
    }

    // MARK: - Interval Bells

    private var intervalBellIdentifiers: [String] = []

    func scheduleIntervalBells(
        targetDate: Date,
        duration: TimeInterval,
        interval: TimeInterval,
        sound: String?
    ) {
        cancelIntervalBells()
        guard interval > 0 else { return }

        var identifiers: [String] = []
        var elapsed = interval
        var index = 0

        while elapsed < duration {
            let bellDate = targetDate.addingTimeInterval(-(duration - elapsed))
            guard bellDate.timeIntervalSinceNow > 1 else {
                elapsed += interval
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "Interval Bell"
            if let sound {
                content.sound = UNNotificationSound(named: UNNotificationSoundName(sound))
            } else {
                content.sound = .default
            }

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: bellDate.timeIntervalSinceNow,
                repeats: false
            )

            let id = "interval-bell-\(index)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            identifiers.append(id)

            elapsed += interval
            index += 1
        }

        intervalBellIdentifiers = identifiers
    }

    func cancelIntervalBells() {
        guard !intervalBellIdentifiers.isEmpty else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: intervalBellIdentifiers
        )
        intervalBellIdentifiers = []
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        intervalBellIdentifiers = []
    }
}
