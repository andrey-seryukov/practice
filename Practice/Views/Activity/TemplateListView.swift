import SwiftUI
import SwiftData

struct TemplateListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var templates: [ActivityTemplate]
    @Binding var selectedTemplate: ActivityTemplate?
    @State private var showEditor = false
    @State private var editingTemplate: ActivityTemplate?

    var body: some View {
        NavigationStack {
            List {
                ForEach(templates) { template in
                    Button {
                        selectedTemplate = template
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.headline)
                            Text("\(template.intervals.count) intervals")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if selectedTemplate == template {
                                selectedTemplate = nil
                            }
                            modelContext.delete(template)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            editingTemplate = template
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        let newTemplate = ActivityTemplate(name: "New Template")
                        modelContext.insert(newTemplate)
                        editingTemplate = newTemplate
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingTemplate) { template in
                TemplateEditorView(template: template)
            }
        }
    }
}
