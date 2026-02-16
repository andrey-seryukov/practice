import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Bindable var template: ActivityTemplate
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var editingInterval: ActivityInterval?

    var body: some View {
        NavigationStack {
            Form {
                Section("Template") {
                    TextField("Name", text: $template.name)
                }

                Section("Intervals") {
                    ForEach(template.sortedIntervals) { interval in
                        TextField("Name", text: Binding(
                            get: { interval.name },
                            set: { interval.name = $0 }
                        ))
                        DurationRow(
                            title: "Duration",
                            duration: interval.duration,
                            format: .minutesSeconds
                        ) {
                            editingInterval = interval
                        }
                        Picker("Sound", selection: Binding(
                            get: { interval.sound },
                            set: { interval.sound = $0 }
                        )) {
                            ForEach(SoundManager.availableSounds, id: \.self) { sound in
                                Text(sound).tag(sound)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let sorted = template.sortedIntervals
                        for index in indexSet {
                            let interval = sorted[index]
                            template.intervals.removeAll { $0.id == interval.id }
                            modelContext.delete(interval)
                        }
                        reorderIntervals()
                    }

                    Button("Add Interval") {
                        let nextOrder = (template.intervals.map(\.order).max() ?? -1) + 1
                        let interval = ActivityInterval(name: "Interval", duration: 30, order: nextOrder)
                        template.intervals.append(interval)
                    }
                }
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $editingInterval) { interval in
                IntervalDurationPickerSheet(interval: interval)
                    .presentationDetents([.fraction(1.0 / 3.0)])
            }
        }
    }

    private func reorderIntervals() {
        for (index, interval) in template.sortedIntervals.enumerated() {
            interval.order = index
        }
    }
}

private struct IntervalDurationPickerSheet: View {
    @Bindable var interval: ActivityInterval
    @Environment(\.dismiss) private var dismiss

    private var duration: Binding<TimeInterval> {
        $interval.duration
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Text(interval.name)
                        .font(.headline)
                    Spacer()
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
                .padding()

                Spacer()

                MinutesSecondsWheel(duration: duration)
                    .frame(width: geometry.size.width * 0.67)

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
