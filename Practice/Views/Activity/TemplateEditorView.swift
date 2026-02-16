import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Bindable var template: ActivityTemplate
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Template") {
                    TextField("Name", text: $template.name)
                }

                Section("Intervals") {
                    ForEach(template.sortedIntervals) { interval in
                        HStack {
                            TextField("Name", text: Binding(
                                get: { interval.name },
                                set: { interval.name = $0 }
                            ))
                            Spacer()
                            Text(formatDuration(interval.duration))
                                .foregroundStyle(.secondary)
                            Stepper("",
                                value: Binding(
                                    get: { interval.duration },
                                    set: { interval.duration = $0 }
                                ),
                                in: 5...3600,
                                step: 5
                            )
                            .labelsHidden()
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
        }
    }

    private func reorderIntervals() {
        for (index, interval) in template.sortedIntervals.enumerated() {
            interval.order = index
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        if total >= 60 {
            return "\(total / 60)m \(total % 60)s"
        }
        return "\(total)s"
    }
}
