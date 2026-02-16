import Foundation
import SwiftData

@Model
final class ActivityTemplate {
    var name: String = ""
    @Relationship(deleteRule: .cascade)
    var intervals: [ActivityInterval] = []
    var sortedIntervals: [ActivityInterval] {
        intervals.sorted { $0.order < $1.order }
    }

    init(name: String, intervals: [ActivityInterval] = []) {
        self.name = name
        self.intervals = intervals
    }
}
