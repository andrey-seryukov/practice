import Foundation
import SwiftData

@Model
final class AppSettings {
    var selectedSound: String = "bell"
    var reportMindfulMinutes: Bool = false

    init(selectedSound: String = "bell", reportMindfulMinutes: Bool = false) {
        self.selectedSound = selectedSound
        self.reportMindfulMinutes = reportMindfulMinutes
    }
}
