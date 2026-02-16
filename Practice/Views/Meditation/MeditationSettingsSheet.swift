import SwiftUI

struct MeditationSettingsForm: View {
    @Bindable var settings: MeditationSettings
    var onStart: () -> Void

    var body: some View {
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

// MARK: - Timer View

struct MeditationTimerView: View {
    var timer: TimerEngine
    var settings: MeditationSettings
    var onStop: () -> Void
    var onFinished: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text(formatTime(timer.remainingTime))
                .font(.system(size: 64, weight: .thin, design: .monospaced))
                .contentTransition(.numericText())

            controls

            Spacer()
        }
    }

    @ViewBuilder
    private var controls: some View {
        switch timer.state {
        case .running:
            HStack(spacing: 40) {
                Button("Pause") { timer.pause() }
                Button("Stop", role: .destructive) { onStop() }
            }
            .font(.title2)

        case .paused:
            HStack(spacing: 40) {
                Button("Resume") { timer.resume() }
                Button("Stop", role: .destructive) { onStop() }
            }
            .font(.title2)

        case .finished:
            VStack(spacing: 16) {
                Text("Session Complete")
                    .font(.title3)
                Button("Done") { onStop() }
                    .font(.title2)
            }
            .onAppear { onFinished() }

        case .idle:
            EmptyView()
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(ceil(interval)))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
