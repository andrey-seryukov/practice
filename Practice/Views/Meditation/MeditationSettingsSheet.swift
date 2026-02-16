import SwiftUI

struct MeditationSettingsForm: View {
    @Bindable var settings: MeditationSettings
    var onStart: () -> Void
    @State private var activePicker: DurationPickerKind?

    var body: some View {
        Form {
            Section("Duration") {
                DurationRow(title: "Meditation", duration: settings.duration, format: .hoursMinutes) {
                    activePicker = .meditation
                }
                DurationRow(title: "Warm-up", duration: settings.warmupDuration, format: .minutesSeconds) {
                    activePicker = .warmup
                }
            }

            Section("Sound") {
                SoundPicker(title: "Start / End", selection: $settings.startEndSound)
            }

            Section("Intermediate Gong") {
                Toggle("Enable", isOn: hasIntermediateGong)
                if settings.intermediateGongInterval != nil {
                    DurationRow(title: "Interval", duration: settings.intermediateGongInterval ?? 300, format: .minutesSeconds) {
                        activePicker = .intermediateGong
                    }
                    SoundPicker(title: "Sound", selection: $settings.intermediateSound)
                }
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
            DurationPickerSheet(kind: kind, settings: settings)
                .presentationDetents([.fraction(1.0 / 3.0)])
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

// MARK: - Duration picker components

enum DurationPickerKind: Identifiable {
    case meditation, warmup, intermediateGong

    var id: Self { self }

    var title: String {
        switch self {
        case .meditation: "Meditation"
        case .warmup: "Warm-up"
        case .intermediateGong: "Interval"
        }
    }
}

enum DurationFormat {
    case hoursMinutes
    case minutesSeconds
}

struct DurationRow: View {
    let title: String
    let duration: TimeInterval
    let format: DurationFormat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Text(formatted)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var formatted: String {
        let total = Int(duration)
        switch format {
        case .hoursMinutes:
            let h = total / 3600
            let m = (total % 3600) / 60
            return h > 0 ? "\(h)h \(m)m" : "\(m) min"
        case .minutesSeconds:
            let m = total / 60
            let s = total % 60
            return s > 0 ? "\(m)m \(s)s" : "\(m) min"
        }
    }
}

struct DurationPickerSheet: View {
    let kind: DurationPickerKind
    @Bindable var settings: MeditationSettings
    @Environment(\.dismiss) private var dismiss

    private var duration: Binding<TimeInterval> {
        switch kind {
        case .meditation:
            $settings.duration
        case .warmup:
            $settings.warmupDuration
        case .intermediateGong:
            Binding(
                get: { settings.intermediateGongInterval ?? 300 },
                set: { settings.intermediateGongInterval = $0 }
            )
        }
    }

    private var format: DurationFormat {
        switch kind {
        case .meditation: .hoursMinutes
        case .warmup, .intermediateGong: .minutesSeconds
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(kind.title)
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
            }
            .padding()

            switch format {
            case .hoursMinutes:
                HoursMinutesWheel(duration: duration)
            case .minutesSeconds:
                MinutesSecondsWheel(duration: duration)
            }
        }
    }
}

struct HoursMinutesWheel: View {
    @Binding var duration: TimeInterval

    private var hours: Binding<Int> {
        Binding(
            get: { Int(duration) / 3600 },
            set: { duration = TimeInterval($0 * 3600 + (Int(duration) % 3600)) }
        )
    }

    private var minutes: Binding<Int> {
        Binding(
            get: { (Int(duration) % 3600) / 60 },
            set: { duration = TimeInterval(Int(duration) / 3600 * 3600 + $0 * 60) }
        )
    }

    var body: some View {
        HStack(spacing: 0) {
            Picker("Hours", selection: hours) {
                ForEach(0...23, id: \.self) { h in
                    Text("\(h)").tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()

            Text("h")
                .foregroundStyle(.secondary)

            Picker("Minutes", selection: minutes) {
                ForEach(0..<60, id: \.self) { m in
                    Text("\(m)").tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()

            Text("m")
                .foregroundStyle(.secondary)
        }
    }
}

struct MinutesSecondsWheel: View {
    @Binding var duration: TimeInterval

    private var minutes: Binding<Int> {
        Binding(
            get: { Int(duration) / 60 },
            set: { duration = TimeInterval($0 * 60 + Int(duration) % 60) }
        )
    }

    private var seconds: Binding<Int> {
        Binding(
            get: { Int(duration) % 60 },
            set: { duration = TimeInterval(Int(duration) / 60 * 60 + $0) }
        )
    }

    var body: some View {
        HStack(spacing: 0) {
            Picker("Minutes", selection: minutes) {
                ForEach(0..<60, id: \.self) { m in
                    Text("\(m)").tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()

            Text("m")
                .foregroundStyle(.secondary)

            Picker("Seconds", selection: seconds) {
                ForEach(0..<60, id: \.self) { s in
                    Text("\(s)").tag(s)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()

            Text("s")
                .foregroundStyle(.secondary)
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
