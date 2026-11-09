import SwiftUI
import AppModel

public struct NewConsultationView: View {
    @ObservedObject var viewModel: MedicalViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var doctorName: String
    @State private var specialty: String
    @State private var date: Date
    @State private var notes: String
    @State private var linkedMedications: [UUID]
    @State private var showingMedicationPicker = false
    private var editingConsultation: Consultation?

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, consultation: Consultation? = nil) {
        self.viewModel = viewModel
        self.editingConsultation = consultation
        self._doctorName = State(initialValue: consultation?.doctorName ?? "")
        self._specialty = State(initialValue: consultation?.specialty ?? "")
        self._date = State(initialValue: consultation?.date ?? Date())
        self._notes = State(initialValue: consultation?.notes ?? "")
        self._linkedMedications = State(initialValue: consultation?.linkedMedications ?? [])
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView

            ScrollView {
                VStack(spacing: 24.0) {

                    // Doctor Info
                    sectionHeader(title: "Doctor information", icon: "cross.case.fill")
                    VStack(spacing: 12.0) {
                        #if SKIP
                        TextField("Doctor Name (e.g. Dr. Sarah Johnson)", text: $doctorName)
                            .padding(12.0)
                            .background(isDark ? Theme.slate900 : Theme.slate50)
                        
                        TextField("Specialty (e.g. Cardiologist)", text: $specialty)
                            .padding(12.0)
                            .background(isDark ? Theme.slate900 : Theme.slate50)
                        #else
                        TextField("Doctor Name (e.g. Dr. Sarah Johnson)", text: $doctorName)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }

                        TextField("Specialty (e.g. Cardiologist)", text: $specialty)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }
                        #endif
                    }

                    // Schedule
                    sectionHeader(title: "Consultation schedule", icon: "calendar")
                    HStack {
                        #if SKIP
                        DatePicker("Consultation Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .padding(12.0)
                            .background(isDark ? Theme.slate900 : Theme.slate50)
                        #else
                        DatePicker("Consultation Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .padding(12.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }
                        #endif
                        Spacer()
                    }

                    // Notes
                    sectionHeader(title: "Consultation notes", icon: "doc.text.fill")
                    notesTextField

                    // Linked Meds (Placeholder)
                    sectionHeader(title: "Prescribed medications", icon: "pills.fill")

                    if !linkedMedications.isEmpty {
                        VStack(spacing: 8.0) {
                            ForEach(linkedMedications, id: \.self) { medId in
                                if let med = viewModel.data.medications.first(where: { $0.id == medId }) {
                                    HStack {
                                        Text(med.name)
                                        Spacer()
                                        Button(action: {
                                            linkedMedications.removeAll { $0 == medId }
                                        }) {
                                            AppIcon(name: "minus.circle.fill", size: 20, tint: Theme.rose500)
                                        }
                                    }
                                    .padding()
                                    .background(isDark ? Theme.slate800 : Color.white)
                                    .cornerRadius(12.0)
                                }
                            }
                        }
                    }

                    Button(action: { showingMedicationPicker = true }) {
                        VStack(spacing: 8.0) {
                            AppIcon(name: "plus.circle", size: 32.0, tint: Theme.primary.opacity(0.5))
                            Text("Link medication")
                                .font(.subheadline)
                                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24.0)
                        .background(Theme.primary.opacity(0.05))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12.0)
                                .stroke(style: StrokeStyle(lineWidth: 1.0, dash: [5.0]))
                                .foregroundColor(Theme.primary.opacity(0.3))
                        }
                    }
                }
                .padding(16.0)
                .padding(.bottom, 100.0)
            }

            saveButton
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
        .hideKeyboardOnTap()
        .sheet(isPresented: $showingMedicationPicker) {
            MedicationPickerView(viewModel: viewModel, selectedMedications: $linkedMedications)
        }
    }

    private var headerView: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .frame(minWidth: 44.0, minHeight: 44.0, alignment: .leading)
                .foregroundColor(Theme.primary)

            Spacer()

            Text(editingConsultation == nil ? "New Consultation" : "Edit Consultation")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

            Spacer()

            Button("Done") { save() }
                .frame(minWidth: 44.0, minHeight: 44.0, alignment: .trailing)
                .fontWeight(.semibold)
                .foregroundColor(Theme.primary)
        }
        .padding(16.0)
        .background(
            (isDark ? Theme.backgroundDark : Theme.backgroundLight)
                .opacity(0.95)
        )
    }

    private var notesTextField: some View {
        Group {
            #if SKIP
            TextField("Describe symptoms, advice, etc...", text: $notes)
                .padding(12.0)
                .background(isDark ? Theme.slate900 : Theme.slate50)
            #else
            TextField("Describe symptoms, advice, etc...", text: $notes)
                .padding(16.0)
                .background(isDark ? Theme.slate800 : Color.white)
                .cornerRadius(12.0)
                .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }
            #endif
        }
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
                    Text(editingConsultation == nil ? "Save Consultation" : "Update Consultation")
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.0)
                .background(Theme.primary)
                .cornerRadius(16.0)
            }
            .padding(16.0)
            .padding(.bottom, 16.0)
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private func save() {
        if var existing = editingConsultation {
            existing.doctorName = doctorName
            existing.specialty = specialty
            existing.date = date
            existing.notes = notes
            existing.linkedMedications = linkedMedications
            viewModel.updateConsultation(existing)
        } else {
            let newConsult = Consultation(doctorName: doctorName, specialty: specialty, date: date, notes: notes, linkedMedications: linkedMedications)
            viewModel.addConsultation(newConsult)
        }
        dismiss()
    }
}

public struct MedicationPickerView: View {
    @ObservedObject var viewModel: MedicalViewModel
    @Binding var selectedMedications: [UUID]
    @Environment(\.dismiss) var dismiss

    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.data.medications) { med in
                    Button(action: {
                        if selectedMedications.contains(med.id) {
                            selectedMedications.removeAll { $0 == med.id }
                        } else {
                            selectedMedications.append(med.id)
                        }
                    }) {
                        HStack {
                            Text(med.name)
                            Spacer()
                            if selectedMedications.contains(med.id) {
                                AppIcon(name: "checkmark", size: 20, tint: Theme.primary)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
