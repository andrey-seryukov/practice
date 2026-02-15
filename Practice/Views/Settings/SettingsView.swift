import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsItems: [AppSettings]

    private var settings: AppSettings {
        settingsItems.first ?? AppSettings()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Sound") {
                    SoundPicker(title: "Default Sound", selection: Binding(
                        get: { settings.selectedSound },
                        set: { settings.selectedSound = $0 }
                    ))

                    Button("Preview") {
                        SoundManager.shared.playSound(settings.selectedSound)
                    }
                }

                Section("Health") {
                    Toggle("Report Mindful Minutes", isOn: Binding(
                        get: { settings.reportMindfulMinutes },
                        set: { newValue in
                            settings.reportMindfulMinutes = newValue
                            if newValue {
                                Task {
                                    _ = await HealthKitManager.shared.requestAuthorization()
                                }
                            }
                        }
                    ))
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                ensureSettings()
            }
        }
    }

    private func ensureSettings() {
        if settingsItems.isEmpty {
            modelContext.insert(AppSettings())
        }
    }
}
