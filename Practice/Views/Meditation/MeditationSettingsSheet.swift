import SwiftUI

struct MeditationSettingsForm: View {
    @Bindable var settings: MeditationSettings
    var onStart: () -> Void
    @State private var activePicker: DurationPickerKind?

    var body: some View {
        Form {
            Section("Duration") {
                DurationRow(title: "Warm-up", duration: settings.warmupDuration, format: .minutesSeconds) {
                    activePicker = .warmup
                }
                DurationRow(title: "Meditation", duration: settings.duration, format: .hoursMinutes) {
                    activePicker = .meditation
                }
            }

            Section("Sound") {
                SoundPicker(title: "Start / End", selection: $settings.startEndSound)
            }

            Section("Interval Bell") {
                DurationRow(title: "Interval", duration: settings.intermediateGongInterval, format: .minutesSeconds) {
                    activePicker = .intermediateGong
                }
                SoundPicker(title: "Sound", selection: $settings.intermediateSound)
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

}

// MARK: - Timer View

struct MeditationTimerView: View {
    var timer: TimerEngine
    var settings: MeditationSettings
    var phase: MeditationPhase
    var onStop: () -> Void
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            // Fallback background color in case image doesn't load
            Color(.systemBackground)
                .ignoresSafeArea()

            // Background image
            Image("screen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.5)

            VStack(spacing: 40) {
                Spacer()

                if phase == .warmup {
                    Text("Warm-up")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Text(formatTime(timer.remainingTime))
                    .font(.system(size: 64, weight: .thin, design: .monospaced))
                    .contentTransition(.numericText())

                controls

                Spacer()
            }
            .onChange(of: timer.state) { _, newState in
                if newState == .finished {
                    onFinished()
                }
            }
        }
    }

    @ViewBuilder
    private var controls: some View {
        switch phase {
        case .warmup:
            TimerButton(style: .stop) { onStop() }

        case .meditation:
            switch timer.state {
            case .running:
                HStack(spacing: 40) {
                    TimerButton(style: .pause) { timer.pause() }
                    TimerButton(style: .stop) { onStop() }
                }

            case .paused:
                HStack(spacing: 40) {
                    TimerButton(style: .resume) { timer.resume() }
                    TimerButton(style: .stop) { onStop() }
                }

            case .finished, .idle:
                EmptyView()
            }

        case .finished:
            VStack(spacing: 16) {
                Text("Session Complete")
                    .font(.title3)
                TimerButton(style: .done) { onStop() }
            }

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
        if total == 0 { return "Off" }
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
            $settings.intermediateGongInterval
        }
    }

    private var format: DurationFormat {
        switch kind {
        case .meditation: .hoursMinutes
        case .warmup, .intermediateGong: .minutesSeconds
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
                    switch format {
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
