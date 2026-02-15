import Foundation
import SwiftData

@Model
final class MeditationSettings {
    var duration: TimeInterval = 600
    var warmupDuration: TimeInterval = 0
    var intermediateGongInterval: TimeInterval?
    var startEndSound: String = "bell"
    var intermediateSound: String = "bell"

    init(
        duration: TimeInterval = 600,
        warmupDuration: TimeInterval = 0,
        intermediateGongInterval: TimeInterval? = nil,
        startEndSound: String = "bell",
        intermediateSound: String = "bell"
    ) {
        self.duration = duration
        self.warmupDuration = warmupDuration
        self.intermediateGongInterval = intermediateGongInterval
        self.startEndSound = startEndSound
        self.intermediateSound = intermediateSound
    }
}
