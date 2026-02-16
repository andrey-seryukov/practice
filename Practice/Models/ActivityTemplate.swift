import Foundation
import SwiftData

@Model
final class ActivityTemplate {
    var name: String = ""
    @Relationship(deleteRule: .cascade)
    var intervals: [ActivityInterval] = []
    var isPreset: Bool = false

    var sortedIntervals: [ActivityInterval] {
        intervals.sorted { $0.order < $1.order }
    }

    init(name: String, intervals: [ActivityInterval] = [], isPreset: Bool = false) {
        self.name = name
        self.intervals = intervals
        self.isPreset = isPreset
    }
}
