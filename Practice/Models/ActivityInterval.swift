import Foundation
import SwiftData

@Model
final class ActivityInterval {
    var name: String = ""
    var duration: TimeInterval = 30
    var sound: String = "bell-1"
    @Relationship(inverse: \ActivityTemplate.intervals)
    var template: ActivityTemplate?

    init(name: String, duration: TimeInterval, sound: String = "bell-1") {
        self.name = name
        self.duration = duration
        self.sound = sound
    }
}
