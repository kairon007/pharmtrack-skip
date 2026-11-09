import SwiftUI
import AppModel

public struct AddMedicationView: View {
    @ObservedObject var viewModel: MedicalViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var name = ""
    @State private var dosage = ""
    @State private var instructions = ""
    @State private var schedule = "Morning"
    @State private var stockStr = ""

    let schedules = ["Morning", "Afternoon", "Evening"]
    private let editingMedication: Medication?

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, editingMedication: Medication? = nil) {
        self.viewModel = viewModel
        self.editingMedication = editingMedication
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView

            ScrollView {
                VStack(spacing: 24.0) {
                    
                    // Details Section
                    VStack(alignment: .leading, spacing: 12.0) {
                        sectionHeader(title: "Medication details", icon: "pills.fill")
                        
                        #if SKIP
                        TextField("Name", text: $name)
                            .padding(12.0)
                            .background(isDark ? Theme.slate900 : Theme.slate50)
                        
                        TextField("Dosage (e.g., 10mg)", text: $dosage)
                            .padding(12.0)
                            .background(isDark ? Theme.slate900 : Theme.slate50)
                        
                        TextField("Instructions (e.g., With Food)", text: $instructions)
                            .padding(12.0)
                            .background(isDark ? Theme.slate900 : Theme.slate50)
                        #else
                        TextField("Name", text: $name)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }

                        TextField("Dosage (e.g., 10mg)", text: $dosage)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }

                        TextField("Instructions (e.g., With Food)", text: $instructions)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }
                        #endif
                    }
                    .padding(.top, 16.0)
                    .padding(.horizontal, 16.0)

                    // Schedule Section
                    VStack(alignment: .leading, spacing: 12.0) {
                        sectionHeader(title: "Schedule", icon: "clock")
                        
                        Picker("Time of Day", selection: $schedule) {
                            ForEach(schedules, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(4.0)
                        .background(isDark ? Theme.slate800 : Theme.slate100)
                        .cornerRadius(12.0)
                    }
                    .padding(.horizontal, 16.0)

                    // Inventory Section
                    VStack(alignment: .leading, spacing: 12.0) {
                        sectionHeader(title: "Inventory", icon: "shippingbox.fill")
                        
                        #if SKIP
                        TextField("Current Stock (pill count)", text: $stockStr)
                            .padding(12.0)
                            .background(isDark ? Theme.slate900 : Theme.slate50)
                        #else
                        TextField("Current Stock (pill count)", text: $stockStr)
                            .padding(16.0)
                            .background(isDark ? Theme.slate800 : Color.white)
                            .cornerRadius(12.0)
                            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.slate700 : Theme.slate200, lineWidth: 1.0) }
                        #endif
                    }
                    .padding(.horizontal, 16.0)
                }
                .padding(.bottom, 100.0)
            }

            saveButton
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
        .onAppear {
            if let med = editingMedication {
                name = med.name
                dosage = med.dosage
                instructions = med.instructions
                schedule = med.schedule
                stockStr = String(med.stock)
            }
        }
        .hideKeyboardOnTap()
    }

    private var headerView: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .frame(minWidth: 44.0, minHeight: 44.0, alignment: .leading)
                .foregroundColor(Theme.primary)

            Spacer()

            Text(editingMedication == nil ? "Add Medication" : "Edit Medication")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

            Spacer()

            Button("Done") { save() }
                .frame(minWidth: 44.0, minHeight: 44.0, alignment: .trailing)
                .fontWeight(.semibold)
                .foregroundColor(Theme.primary)
                .disabled(name.isEmpty || dosage.isEmpty)
        }
        .padding(16.0)
        .background(
            (isDark ? Theme.backgroundDark : Theme.backgroundLight)
                .opacity(0.95)
        )
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
                    Text(editingMedication == nil ? "Save Medication" : "Update Medication")
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.0)
                .background(Theme.primary)
                .cornerRadius(16.0)
            }
            .disabled(name.isEmpty || dosage.isEmpty)
            .padding(16.0)
            .padding(.bottom, 16.0)
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private func save() {
        let stock = Int(stockStr) ?? 0
        if let editing = editingMedication {
            var updated = editing
            updated.name = name
            updated.dosage = dosage
            updated.instructions = instructions
            updated.schedule = schedule
            updated.stock = stock
            viewModel.updateMedication(updated)
        } else {
            let newMed = Medication(name: name, dosage: dosage, instructions: instructions, schedule: schedule, stock: stock, active: true, nextDose: Date())
            viewModel.addMedication(newMed)
        }
        dismiss()
    }
}
