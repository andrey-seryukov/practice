import Foundation
import SwiftData

@Model
final class AppSettings {
    var selectedSound: String = "bell-1"
    var reportMindfulMinutes: Bool = false

    init(selectedSound: String = "bell-1", reportMindfulMinutes: Bool = false) {
        self.selectedSound = selectedSound
        self.reportMindfulMinutes = reportMindfulMinutes
    }
}
