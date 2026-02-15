import SwiftUI

struct LifeTimerSettingsSheet: View {
    @Bindable var settings: LifeTimerSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Total Duration") {
                    HourMinutePicker(title: "Duration", duration: $settings.totalDuration, maxHours: 12)
                }

                Section("Reminder Interval") {
                    DurationPicker(title: "Minimum", duration: $settings.minInterval, range: 300...3600)
                    DurationPicker(title: "Maximum", duration: $settings.maxInterval, range: 300...7200)
                }
            }
            .navigationTitle("Life Timer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HourMinutePicker: View {
    let title: String
    @Binding var duration: TimeInterval
    var maxHours: Int = 12

    var body: some View {
        let hours = Binding<Int>(
            get: { Int(duration) / 3600 },
            set: { duration = TimeInterval($0 * 3600 + Int(duration) % 3600) }
        )
        let minutes = Binding<Int>(
            get: { (Int(duration) % 3600) / 60 },
            set: { duration = TimeInterval(Int(duration) / 3600 * 3600 + $0 * 60) }
        )

        HStack {
            Text(title)
            Spacer()
            Picker("Hours", selection: hours) {
                ForEach(0...maxHours, id: \.self) { h in
                    Text("\(h)h").tag(h)
                }
            }
            .pickerStyle(.menu)
            Picker("Minutes", selection: minutes) {
                ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                    Text("\(m)m").tag(m)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
