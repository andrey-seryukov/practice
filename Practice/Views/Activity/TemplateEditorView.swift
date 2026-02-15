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
                    ForEach(template.intervals) { interval in
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
                        for index in indexSet {
                            let interval = template.intervals[index]
                            template.intervals.remove(at: index)
                            modelContext.delete(interval)
                        }
                    }

                    Button("Add Interval") {
                        let interval = ActivityInterval(name: "Interval", duration: 30)
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

    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        if total >= 60 {
            return "\(total / 60)m \(total % 60)s"
        }
        return "\(total)s"
    }
}
