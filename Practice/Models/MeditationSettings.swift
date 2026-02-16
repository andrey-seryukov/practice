import Foundation
import SwiftData

@Model
final class MeditationSettings {
    var duration: TimeInterval = 600
    var warmupDuration: TimeInterval = 0
    var intermediateGongInterval: TimeInterval = 0
    var startEndSound: String = "bell-1"
    var intermediateSound: String = "bell-2"

    init(
        duration: TimeInterval = 600,
        warmupDuration: TimeInterval = 0,
        intermediateGongInterval: TimeInterval = 0,
        startEndSound: String = "bell-1",
        intermediateSound: String = "bell-2"
    ) {
        self.duration = duration
        self.warmupDuration = warmupDuration
        self.intermediateGongInterval = intermediateGongInterval
        self.startEndSound = startEndSound
        self.intermediateSound = intermediateSound
    }
}
