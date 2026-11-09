import SwiftUI
import AppModel

public struct SettingsView: View {
    @ObservedObject public var viewModel: MedicalViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    // Local state for editing
    @State private var settings: NotificationSettings

    public init(viewModel: MedicalViewModel) {
        self.viewModel = viewModel
        // Initialize state with current settings
        _settings = State(initialValue: viewModel.data.notificationSettings)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Global Notifications")) {
                    Toggle("Enable All Notifications", isOn: $settings.allNotificationsEnabled)
                        .tint(Theme.primary)
                }

                if settings.allNotificationsEnabled {
                    Section(header: Text("Medications")) {
                        Toggle("Medication Reminders", isOn: $settings.medicationsEnabled)
                            .tint(Theme.primary)

                        if settings.medicationsEnabled {
                            Picker("Reminder Time", selection: $settings.medicationReminderTime) {
                                ForEach(NotificationSettings.ReminderTime.allCases, id: \.self) { time in
                                    Text(time.rawValue).tag(time)
                                }
                            }
                        }

                        Toggle("Low Stock Alerts", isOn: $settings.lowStockEnabled)
                            .tint(Theme.primary)

                        if settings.lowStockEnabled {
                            Picker("Alert Threshold", selection: $settings.lowStockThreshold) {
                                Text("3 doses left").tag(3)
                                Text("5 doses left").tag(5)
                                Text("10 doses left").tag(10)
                            }
                        }
                    }

                    Section(header: Text("Appointments")) {
                        Toggle("Appointment Alerts", isOn: $settings.appointmentsEnabled)
                            .tint(Theme.primary)

                        if settings.appointmentsEnabled {
                            Picker("Alert Time", selection: $settings.appointmentReminderTime) {
                                ForEach(NotificationSettings.ReminderTime.allCases, id: \.self) { time in
                                    Text(time.rawValue).tag(time)
                                }
                            }
                        }
                    }

                    Section(header: Text("Consultations")) {
                        Toggle("Consultation Alerts", isOn: $settings.consultationsEnabled)
                            .tint(Theme.primary)
                    }
                }
            }
            .onAppear {
                settings = viewModel.data.notificationSettings
            }
            .onChange(of: viewModel.data.notificationSettings) { newValue in
                settings = newValue
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateNotificationSettings(settings)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
