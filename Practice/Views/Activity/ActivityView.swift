import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var templates: [ActivityTemplate]
    @State private var selectedTemplate: ActivityTemplate?
    @State private var timer = TimerEngine()
    @State private var currentIntervalIndex = 0
    @State private var showTemplateList = false

    private var sortedIntervals: [ActivityInterval] {
        selectedTemplate?.sortedIntervals ?? []
    }

    private var currentInterval: ActivityInterval? {
        guard currentIntervalIndex < sortedIntervals.count else { return nil }
        return sortedIntervals[currentIntervalIndex]
    }

    private var isTimerActive: Bool {
        timer.state != .idle
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if templates.isEmpty {
                    Spacer()
                    noTemplateSelected
                    Spacer()
                } else {
                    templatePicker
                    intervalList(highlight: false)
                    Spacer()
                    TimerButton(style: .start) { startActivity() }
                        .padding(.bottom, 32)
                }
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
            .onChange(of: templates) {
                if selectedTemplate == nil, let first = templates.first {
                    selectedTemplate = first
                }
            }
        }
        .fullScreenCover(isPresented: .constant(isTimerActive)) {
            activityTimerScreen
                .onChange(of: timer.state) { _, newState in
                    if newState == .finished {
                        advanceInterval()
                    }
                }
        }
    }

    // MARK: - Idle Components

    private var selectedTemplateID: Binding<PersistentIdentifier?> {
        Binding(
            get: { selectedTemplate?.persistentModelID },
            set: { newID in
                selectedTemplate = templates.first { $0.persistentModelID == newID }
            }
        )
    }

    private var templatePicker: some View {
        Picker("Template", selection: selectedTemplateID) {
            ForEach(templates) { template in
                Text(template.name).tag(Optional(template.persistentModelID))
            }
        }
        .pickerStyle(.menu)
        .padding(.horizontal)
        .padding(.vertical, 8)
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

    // MARK: - Timer Screen

    private var activityTimerScreen: some View {
        VStack(spacing: 0) {
            if let interval = currentInterval {
                Text(interval.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 32)
            }

            Text(formatTime(timer.remainingTime))
                .font(.system(size: 64, weight: .thin, design: .monospaced))
                .contentTransition(.numericText())
                .padding(.vertical, 24)

            intervalList(highlight: true)

            Spacer()

            activeControls
                .padding(.bottom, 32)
        }
    }

    // MARK: - Shared Interval List

    private func intervalList(highlight: Bool) -> some View {
        List {
            ForEach(sortedIntervals) { interval in
                intervalRow(interval: interval, isCurrent: highlight && interval.id == currentInterval?.id)
            }
        }
        .listStyle(.plain)
        .allowsHitTesting(!highlight)
    }

    private func intervalRow(interval: ActivityInterval, isCurrent: Bool) -> some View {
        HStack {
            Text(interval.name)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTime(interval.duration))
                    .monospacedDigit()
                Text(interval.sound)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(isCurrent ? Color.accentColor.opacity(0.2) : nil)
    }

    // MARK: - Controls

    @ViewBuilder
    private var activeControls: some View {
        switch timer.state {
        case .running:
            HStack(spacing: 40) {
                TimerButton(style: .pause) { timer.pause() }
                TimerButton(style: .stop) { stopActivity() }
            }

        case .paused:
            HStack(spacing: 40) {
                TimerButton(style: .resume) { timer.resume() }
                TimerButton(style: .stop) { stopActivity() }
            }

        case .finished, .idle:
            EmptyView()
        }
    }

    // MARK: - Actions

    private func startActivity() {
        guard let interval = currentInterval else { return }
        SoundManager.shared.playSound(interval.sound)
        timer.start(duration: interval.duration)
    }

    private func advanceInterval() {
        currentIntervalIndex += 1
        if currentIntervalIndex < sortedIntervals.count {
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
        guard templates.isEmpty else {
            if selectedTemplate == nil, let first = templates.first {
                selectedTemplate = first
            }
            return
        }

        let hiit = ActivityTemplate(name: "HIIT", intervals: [])
        for round in 0..<8 {
            hiit.intervals.append(ActivityInterval(name: "Work \(round + 1)", duration: 30, order: round * 2))
            hiit.intervals.append(ActivityInterval(name: "Rest \(round + 1)", duration: 15, order: round * 2 + 1))
        }

        let yoga = ActivityTemplate(name: "Yoga Flow", intervals: [
            ActivityInterval(name: "Warm-up", duration: 300, order: 0),
            ActivityInterval(name: "Flow", duration: 1200, order: 1),
            ActivityInterval(name: "Cool-down", duration: 300, order: 2),
        ])

        let chiGong = ActivityTemplate(name: "Chi Gong", intervals: [
            ActivityInterval(name: "Warm-up", duration: 600, order: 0),
            ActivityInterval(name: "Practice", duration: 1800, order: 1),
            ActivityInterval(name: "Cool-down", duration: 300, order: 2),
        ])

        modelContext.insert(hiit)
        modelContext.insert(yoga)
        modelContext.insert(chiGong)

        selectedTemplate = hiit
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(ceil(interval)))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
