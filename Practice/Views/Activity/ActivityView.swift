import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var templates: [ActivityTemplate]
    @State private var selectedTemplate: ActivityTemplate?
    @State private var timer = TimerEngine()
    @State private var currentIntervalIndex = 0
    @State private var showTemplateList = false

    private var currentInterval: ActivityInterval? {
        guard let selectedTemplate,
              currentIntervalIndex < selectedTemplate.intervals.count
        else { return nil }
        return selectedTemplate.intervals[currentIntervalIndex]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                if let selectedTemplate {
                    templateHeader(selectedTemplate)
                    timerDisplay
                    controls
                } else {
                    noTemplateSelected
                }

                Spacer()
            }
            .navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showTemplateList = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showTemplateList) {
                TemplateListView(selectedTemplate: $selectedTemplate)
            }
            .onAppear {
                seedPresetsIfNeeded()
            }
        }
    }

    private func templateHeader(_ template: ActivityTemplate) -> some View {
        VStack(spacing: 8) {
            Text(template.name)
                .font(.headline)
            if let interval = currentInterval, timer.state != .idle {
                Text(interval.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timerDisplay: some View {
        Text(formatTime(timer.state == .idle
            ? (currentInterval?.duration ?? 0)
            : timer.remainingTime))
            .font(.system(size: 64, weight: .thin, design: .monospaced))
            .contentTransition(.numericText())
    }

    @ViewBuilder
    private var controls: some View {
        switch timer.state {
        case .idle:
            Button("Start") { startActivity() }
                .font(.title2)

        case .running:
            HStack(spacing: 40) {
                Button("Pause") { timer.pause() }
                Button("Stop", role: .destructive) { stopActivity() }
            }
            .font(.title2)

        case .paused:
            HStack(spacing: 40) {
                Button("Resume") { timer.resume() }
                Button("Stop", role: .destructive) { stopActivity() }
            }
            .font(.title2)

        case .finished:
            VStack(spacing: 16) {
                Text("Interval Complete")
                    .font(.title3)
                Button("Continue") { advanceInterval() }
                    .font(.title2)
            }
        }
    }

    private var noTemplateSelected: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Select a template to begin")
                .foregroundStyle(.secondary)
            Button("Browse Templates") { showTemplateList = true }
        }
    }

    private func startActivity() {
        guard let interval = currentInterval else { return }
        SoundManager.shared.playSound(interval.sound)
        timer.start(duration: interval.duration)
    }

    private func advanceInterval() {
        guard let selectedTemplate else { return }
        currentIntervalIndex += 1
        if currentIntervalIndex < selectedTemplate.intervals.count {
            startActivity()
        } else {
            currentIntervalIndex = 0
            timer.stop()
        }
    }

    private func stopActivity() {
        timer.stop()
        currentIntervalIndex = 0
    }

    private func seedPresetsIfNeeded() {
        guard templates.isEmpty else { return }

        let hiit = ActivityTemplate(name: "HIIT", intervals: [], isPreset: true)
        for round in 1...8 {
            hiit.intervals.append(ActivityInterval(name: "Work \(round)", duration: 30))
            hiit.intervals.append(ActivityInterval(name: "Rest \(round)", duration: 15))
        }

        let yoga = ActivityTemplate(name: "Yoga Flow", intervals: [
            ActivityInterval(name: "Warm-up", duration: 300),
            ActivityInterval(name: "Flow", duration: 1200),
            ActivityInterval(name: "Cool-down", duration: 300),
        ], isPreset: true)

        let chiGong = ActivityTemplate(name: "Chi Gong", intervals: [
            ActivityInterval(name: "Warm-up", duration: 600),
            ActivityInterval(name: "Practice", duration: 1800),
            ActivityInterval(name: "Cool-down", duration: 300),
        ], isPreset: true)

        modelContext.insert(hiit)
        modelContext.insert(yoga)
        modelContext.insert(chiGong)
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(ceil(interval)))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
