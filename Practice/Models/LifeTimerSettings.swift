import Foundation
import SwiftData

@Model
final class LifeTimerSettings {
    var totalDuration: TimeInterval = 14400
    var minInterval: TimeInterval = 900
    var maxInterval: TimeInterval = 2700
    var startStopSound: String = "bell-1"
    var reminderSound: String = "bell-1"

    init(
        totalDuration: TimeInterval = 14400,
        minInterval: TimeInterval = 900,
        maxInterval: TimeInterval = 2700,
        startStopSound: String = "bell-1",
        reminderSound: String = "bell-1"
    ) {
        self.totalDuration = totalDuration
        self.minInterval = minInterval
        self.maxInterval = maxInterval
        self.startStopSound = startStopSound
        self.reminderSound = reminderSound
    }
}
