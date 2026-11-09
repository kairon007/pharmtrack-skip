import SwiftUI
import AppModel

public struct AddVitalView: View {
    @ObservedObject var viewModel: MedicalViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var type: Vital.VitalType = .weight
    @State private var value = ""
    @State private var value2 = ""
    @State private var date = Date()
    @State private var note = ""

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView

            ScrollView {
                VStack(spacing: 24.0) {
                    
                    // Metric Selector
                    VStack(alignment: .leading, spacing: 12.0) {
                        Text("Vital type")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                        HStack(spacing: 12.0) {
                            metricTab(title: "Weight", type: .weight, icon: "scalemass")
                            metricTab(title: "Pressure", type: .bloodPressure, icon: "heart.fill")
                            metricTab(title: "Sugar", type: .bloodSugar, icon: "drop.fill")
                        }
                    }
                    .padding(.top, 16.0)
                    .padding(Edge.Set.horizontal, 16.0)

                    // Value Input
                    VStack(alignment: .leading, spacing: 12.0) {
                        Text("Value")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                        HStack {
                            if type == .bloodPressure {
                                TextField("120", text: $value)
                                    .font(.system(size: 24.0, weight: .bold))

                                Text("/")
                                    .font(.system(size: 24.0, weight: .light))
                                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                                TextField("80", text: $value2)
                                    .font(.system(size: 24.0, weight: .bold))
                            } else {
                                TextField("0.0", text: $value)
                                    .font(.system(size: 24.0, weight: .bold))
                            }
                            
                            Text(unit)
                                .font(.headline)
                                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                        }
                         .padding(16.0)
                         .background(isDark ? Theme.slate800 : Theme.slate50)
                         .cornerRadius(12.0)
                         .platformOverlayStrokeDark(isDark: isDark)
                    }
                    .padding(Edge.Set.horizontal, 16.0)

                    // Date
                    VStack(alignment: .leading, spacing: 12.0) {
                        Text("Date and time")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                        DatePicker("Select Date", selection: $date)
                             .labelsHidden()
                             .padding(12.0)
                             .frame(maxWidth: .infinity, alignment: .leading)
                             .background(isDark ? Theme.slate800 : Theme.slate50)
                             .cornerRadius(12.0)
                             .platformOverlayStrokeDark(isDark: isDark)
                    }
                    .padding(Edge.Set.horizontal, 16.0)

                    // Notes
                    VStack(alignment: .leading, spacing: 12.0) {
                        Text("Notes (optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                        TextField("Any specific conditions?", text: $note)
                             .padding(16.0)
                             .background(isDark ? Theme.slate800 : Theme.slate50)
                             .cornerRadius(12.0)
                             .platformOverlayStrokeDark(isDark: isDark)
                    }
                    .padding(Edge.Set.horizontal, 16.0)
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

            Text("Add vital")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

            Spacer()

            Button("Done") { save() }
                .frame(minWidth: 44.0, minHeight: 44.0, alignment: .trailing)
                .fontWeight(.semibold)
                .foregroundColor(Theme.primary)
                .disabled(value.isEmpty)
        }
        .padding(16.0)
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private func metricTab(title: String, type: Vital.VitalType, icon: String) -> some View {
        let isSelected = self.type == type
        return Button(action: { self.type = type }) {
            VStack(spacing: 8.0) {
                AppIcon(name: icon, size: 24.0, tint: isSelected ? .white : Theme.primary)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
             .padding(.vertical, 12.0)
             .background(isSelected ? Theme.primary : (isDark ? Theme.slate800 : Color.white))
             .foregroundColor(isSelected ? .white : (isDark ? Theme.slate300 : Theme.slate700))
             .cornerRadius(12.0)
             .platformOverlayStrokeSelected(isSelected: isSelected, isDark: isDark)
        }
    }

    private var unit: String {
        switch type {
        case .weight: return "kg"
        case .bloodPressure: return "mmHg"
        case .bloodSugar: return "mg/dL"
        }
    }

    private var saveButton: some View {
        VStack(spacing: 0.0) {
            Divider()
                .background(isDark ? Theme.slate800 : Theme.slate200)
            
            Button(action: save) {
                HStack {
                    AppIcon(name: "checkmark", size: 20.0, tint: .white)
                    Text("Save entry")
                }
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16.0)
                .background(Theme.primary)
                .cornerRadius(16.0)
            }
            .disabled(value.isEmpty)
            .padding(16.0)
            .padding(.bottom, 16.0)
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private func save() {
        if let numericValue = Double(value) {
            let numericValue2 = type == .bloodPressure ? Double(value2) : nil
            let newVital = Vital(type: type, value: numericValue, value2: numericValue2, date: date, notes: note.isEmpty ? nil : note)
            viewModel.addVital(newVital)
            dismiss()
        }
    }
}
