import SwiftUI

enum LifeDurationPickerKind: Identifiable {
    case total, minInterval, maxInterval

    var id: Self { self }

    var title: String {
        switch self {
        case .total: "Total Duration"
        case .minInterval: "Minimum Interval"
        case .maxInterval: "Maximum Interval"
        }
    }

    var format: DurationFormat {
        switch self {
        case .total: .hoursMinutes
        case .minInterval, .maxInterval: .minutesSeconds
        }
    }
}

struct LifeTimerSettingsForm: View {
    @Bindable var settings: LifeTimerSettings
    var onStart: () -> Void
    @State private var activePicker: LifeDurationPickerKind?

    var body: some View {
        Form {
            Section("Total Duration") {
                DurationRow(title: "Duration", duration: settings.totalDuration, format: .hoursMinutes) {
                    activePicker = .total
                }
            }

            Section("Reminder Interval") {
                DurationRow(title: "Minimum", duration: settings.minInterval, format: .minutesSeconds) {
                    activePicker = .minInterval
                }
                DurationRow(title: "Maximum", duration: settings.maxInterval, format: .minutesSeconds) {
                    activePicker = .maxInterval
                }
            }

            Section("Sound") {
                SoundPicker(title: "Start / Stop", selection: $settings.startStopSound)
                SoundPicker(title: "Reminder", selection: $settings.reminderSound)
            }

            Section {
                Button {
                    onStart()
                } label: {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                }
                .font(.title2)
            }
        }
        .sheet(item: $activePicker) { kind in
            LifeDurationPickerSheet(kind: kind, settings: settings)
                .presentationDetents([.fraction(1.0 / 3.0)])
        }
    }
}

private struct LifeDurationPickerSheet: View {
    let kind: LifeDurationPickerKind
    @Bindable var settings: LifeTimerSettings
    @Environment(\.dismiss) private var dismiss

    private var duration: Binding<TimeInterval> {
        switch kind {
        case .total: $settings.totalDuration
        case .minInterval: $settings.minInterval
        case .maxInterval: $settings.maxInterval
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Text(kind.title)
                        .font(.headline)
                    Spacer()
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
                .padding()

                Spacer()

                Group {
                    switch kind.format {
                    case .hoursMinutes:
                        HoursMinutesWheel(duration: duration)
                    case .minutesSeconds:
                        MinutesSecondsWheel(duration: duration)
                    }
                }
                .frame(width: geometry.size.width * 0.67)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
