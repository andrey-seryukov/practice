import Foundation
import SwiftData

@Model
final class ActivityInterval {
    var name: String = ""
    var duration: TimeInterval = 30
    var sound: String = "bell-1"
    var order: Int = 0
    @Relationship(inverse: \ActivityTemplate.intervals)
    var template: ActivityTemplate?

    init(name: String, duration: TimeInterval, sound: String = "bell-1", order: Int = 0) {
        self.name = name
        self.duration = duration
        self.sound = sound
        self.order = order
    }
}
