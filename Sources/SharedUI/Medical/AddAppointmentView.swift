import SwiftUI
import AppModel

public struct AddAppointmentView: View {
    @ObservedObject var viewModel: MedicalViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var doctorName = ""
    @State private var specialty = ""
    @State private var type = ""
    @State private var date: Date
    @State private var location = ""
    @State private var notes = ""

    private let editingAppointment: Appointment?
    private var isEditing: Bool { editingAppointment != nil }

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, selectedDate: Date = Date(), editingAppointment: Appointment? = nil) {
        self.viewModel = viewModel
        self.editingAppointment = editingAppointment
        if let appt = editingAppointment {
            self._doctorName = State(initialValue: appt.doctorName)
            self._specialty = State(initialValue: appt.specialty)
            self._type = State(initialValue: appt.type)
            self._date = State(initialValue: appt.date)
            self._location = State(initialValue: appt.location)
            self._notes = State(initialValue: appt.notes ?? "")
        } else {
            self._date = State(initialValue: selectedDate)
        }
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView

            ScrollView {
                VStack(spacing: 24.0) {
                    
                    // Doctor Section
                    VStack(alignment: .leading, spacing: 12.0) {
                        sectionHeader(title: "Doctor & Specialty", icon: "person.fill")
                        
                        TextField("Doctor's Name", text: $doctorName)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .platformOverlayStroke(isDark: isDark)

                        TextField("Specialty", text: $specialty)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .platformOverlayStroke(isDark: isDark)
                    }
                    .padding(.top, 16.0)
                    .padding(.horizontal, 16.0)

                    // Details Section
                    VStack(alignment: .leading, spacing: 12.0) {
                        sectionHeader(title: "Appointment details", icon: "calendar")
                        
                        TextField("Type (e.g., General Checkup)", text: $type)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .platformOverlayStroke(isDark: isDark)

                        DatePicker("Date & Time", selection: $date)
                            .labelsHidden()
                            .padding(12.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .platformOverlayStroke(isDark: isDark)

                        TextField("Location", text: $location)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .platformOverlayStroke(isDark: isDark)
                    }
                    .padding(.horizontal, 16.0)

                    // Notes Section
                    VStack(alignment: .leading, spacing: 12.0) {
                        sectionHeader(title: "Notes (optional)", icon: "doc.text.fill")
                        
                        TextField("Bring previous reports...", text: $notes)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .platformOverlayStroke(isDark: isDark)
                    }
                    .padding(.horizontal, 16.0)
                }
                .padding(.bottom, 100.0)
            }

            saveButton
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
        .hideKeyboardOnTap()
    }

    private var headerView: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .frame(minWidth: 44.0, minHeight: 44.0, alignment: .leading)
                .foregroundColor(Theme.primary)

            Spacer()

            Text(isEditing ? "Edit Appointment" : "New Appointment")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

            Spacer()

            Button("Done") { save() }
                .frame(minWidth: 44.0, minHeight: 44.0, alignment: .trailing)
                .fontWeight(.semibold)
                .foregroundColor(Theme.primary)
                .disabled(doctorName.isEmpty || specialty.isEmpty || type.isEmpty || location.isEmpty)
        }
        .padding(16.0)
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8.0) {
            AppIcon(name: icon, size: 16.0, tint: Theme.primary)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
            Spacer()
        }
    }

    private var saveButton: some View {
        VStack(spacing: 0.0) {
            Divider()
                .background(isDark ? Theme.slate800 : Theme.slate200)
            
            Button(action: save) {
                HStack {
                    AppIcon(name: "checkmark", size: 20.0, tint: .white)
                    Text("Save appointment")
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.0)
                .background(Theme.primary)
                .cornerRadius(16.0)
            }
            .disabled(doctorName.isEmpty || specialty.isEmpty || type.isEmpty || location.isEmpty)
            .padding(16.0)
            .padding(.bottom, 16.0)
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private func save() {
        if let existing = editingAppointment {
            let updated = Appointment(
                id: existing.id,
                doctorName: doctorName,
                specialty: specialty,
                type: type,
                date: date,
                location: location,
                notes: notes.isEmpty ? nil : notes,
                notify: existing.notify
            )
            viewModel.updateAppointment(updated)
        } else {
            let newAppt = Appointment(
                doctorName: doctorName,
                specialty: specialty,
                type: type,
                date: date,
                location: location,
                notes: notes.isEmpty ? nil : notes,
                notify: true
            )
            viewModel.addAppointment(newAppt)
        }
        dismiss()
    }
}
