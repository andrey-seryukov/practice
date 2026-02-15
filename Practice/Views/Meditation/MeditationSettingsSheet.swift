import SwiftUI

struct MeditationSettingsSheet: View {
    @Bindable var settings: MeditationSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Duration") {
                    DurationPicker(title: "Meditation", duration: $settings.duration, range: 60...7200)
                    DurationPicker(title: "Warm-up", duration: $settings.warmupDuration, range: 0...300)
                }

                Section("Intermediate Gong") {
                    Toggle("Enable", isOn: hasIntermediateGong)
                    if settings.intermediateGongInterval != nil {
                        DurationPicker(
                            title: "Interval",
                            duration: intermediateGongBinding,
                            range: 60...3600
                        )
                        SoundPicker(title: "Sound", selection: $settings.intermediateSound)
                    }
                }

                Section("Sounds") {
                    SoundPicker(title: "Start / End", selection: $settings.startEndSound)
                }
            }
            .navigationTitle("Meditation Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var hasIntermediateGong: Binding<Bool> {
        Binding(
            get: { settings.intermediateGongInterval != nil },
            set: { enabled in
                settings.intermediateGongInterval = enabled ? 300 : nil
            }
        )
    }

    private var intermediateGongBinding: Binding<TimeInterval> {
        Binding(
            get: { settings.intermediateGongInterval ?? 300 },
            set: { settings.intermediateGongInterval = $0 }
        )
    }
}

// MARK: - Reusable pickers

struct DurationPicker: View {
    let title: String
    @Binding var duration: TimeInterval
    var range: ClosedRange<TimeInterval> = 0...7200

    var body: some View {
        let minutes = Binding<Double>(
            get: { duration / 60 },
            set: { duration = $0 * 60 }
        )

        HStack {
            Text(title)
            Spacer()
            Text("\(Int(minutes.wrappedValue)) min")
                .foregroundStyle(.secondary)
            Stepper("", value: minutes, in: (range.lowerBound / 60)...(range.upperBound / 60), step: 1)
                .labelsHidden()
        }
    }
}

struct SoundPicker: View {
    let title: String
    @Binding var selection: String

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(SoundManager.availableSounds, id: \.self) { sound in
                Text(sound.capitalized).tag(sound)
            }
        }
    }
}
