import SwiftUI
import AppModel

public struct MedicationTrackerView: View {
    @ObservedObject public var viewModel: MedicalViewModel
    @State private var selectedTab = "Today"
    @State private var searchText = ""
    @State private var showingAddMedication = false
    @State private var editingMedication: Medication?
    @Environment(\.colorScheme) var colorScheme
    private let isOnboarding: Bool

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, isOnboarding: Bool = false) {
        self.viewModel = viewModel
        self.isOnboarding = isOnboarding
    }

    private var takenTodayCount: Int {
        viewModel.data.logs.filter {
            $0.type == "Medication Taken" && Calendar.current.isDateInToday($0.date)
        }.count
    }

    private var filteredMedications: [Medication] {
        if searchText.isEmpty {
            return viewModel.data.medications
        } else {
            let searchLower = searchText.lowercased()
            return viewModel.data.medications.filter {
                $0.name.lowercased().contains(searchLower) ||
                $0.instructions.lowercased().contains(searchLower)
            }
        }
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24.0) {
                        if selectedTab == "Today" {
                            planSummaryCard
                            routineSection(title: "Morning", meds: filteredMedications.filter { $0.schedule == "Morning" })
                            routineSection(title: "Afternoon", meds: filteredMedications.filter { $0.schedule == "Afternoon" })
                            routineSection(title: "Evening", meds: filteredMedications.filter { $0.schedule == "Evening" })
                        } else if selectedTab == "Inventory" {
                            inventorySection()
                        } else {
                            historySection()
                        }

                        if isOnboarding {
                            Color.clear.frame(height: 1.0).id("bottom")
                        }
                    }
                    .padding(.horizontal, 16.0)
                    .padding(.top, 16.0)
                    .padding(.bottom, 100.0)
                }
                .onAppear {
                    if isOnboarding {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    proxy.scrollTo("Morning", anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
        .ignoreTopSafeArea()
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView(viewModel: viewModel)
        }
        .sheet(item: $editingMedication) { medication in
            AddMedicationView(viewModel: viewModel, editingMedication: medication)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 16.0) {
            HStack {
                Text("Medications")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Spacer()

                Button(action: {
                    showingAddMedication = true
                }) {
                    AppIcon(name: "plus", size: 20.0, tint: Theme.primary)
                        .frame(width: 44.0, height: 44.0)
                        .background(Theme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add medication")
            }

            HStack {
                AppIcon(name: "magnifyingglass", size: 20.0, tint: Theme.slate400)
                TextField("Search medications", text: $searchText)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
            }
            .padding(12.0)
            .background(isDark ? Theme.surfaceDark : Color.white)
            .cornerRadius(12.0)
            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0) }

            HStack(spacing: 12.0) {
                FilterChip(title: "Today", isSelected: selectedTab == "Today", isDark: isDark) {
                    selectedTab = "Today"
                }
                FilterChip(title: "Inventory", isSelected: selectedTab == "Inventory", isDark: isDark) {
                    selectedTab = "Inventory"
                }
                FilterChip(title: "History", isSelected: selectedTab == "History", isDark: isDark) {
                    selectedTab = "History"
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16.0)
        #if SKIP
        .padding(.top, 16.0)
        #else
        .padding(.top, 60.0)
        #endif
        .padding(.bottom, 16.0)
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    // MARK: - Today's plan summary

    private var planSummaryCard: some View {
        let total = filteredMedications.count
        let taken = min(takenTodayCount, total)
        let fraction = total == 0 ? 0.0 : Double(taken) / Double(total)

        return CardSurface(isDark: isDark) {
            VStack(alignment: .leading, spacing: 12.0) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(taken)")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                    Text("of \(total) taken today")
                        .font(.subheadline)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                    Spacer()

                    if taken == total && total > 0 {
                        AppIcon(name: "checkmark.circle.fill", size: 20.0, tint: Theme.success)
                    }
                }

                ProgressBar(fraction: fraction, isDark: isDark)
            }
        }
    }

    // MARK: - Routine sections

    private func routineSection(title: String, meds: [Medication]) -> some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                .padding(.horizontal, 4.0)

            if meds.isEmpty {
                Text("Nothing scheduled")
                    .font(.caption)
                    .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
                    .padding(.horizontal, 4.0)
            } else {
                VStack(spacing: 12.0) {
                    ForEach(meds) { med in
                        medicationRow(med)
                    }
                }
            }
        }
        .id(title)
    }

    /// Whole row is the tap target for "taken" — the primary action of this screen.
    private func medicationRow(_ med: Medication) -> some View {
        let isTaken = viewModel.data.logs.contains {
            $0.type == "Medication Taken" && $0.description.contains(med.name) && Calendar.current.isDateInToday($0.date)
        }

        return Button(action: {
            if !isTaken {
                viewModel.markMedicationTaken(med)
            }
        }) {
            HStack(spacing: 16.0) {
                ZStack {
                    Circle()
                        .stroke(isTaken ? Theme.primary : (isDark ? Theme.borderDark : Theme.borderLight), lineWidth: 2.0)
                        .frame(width: 28.0, height: 28.0)

                    if isTaken {
                        AppIcon(name: "checkmark", size: 14.0, tint: Theme.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 2.0) {
                    Text(med.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                    Text("\(med.dosage) · \(med.instructions)")
                        .font(.caption)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                }

                Spacer()

                if med.stock < 5 {
                    Text("Low stock")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.amber500)
                }

                IconCircleButton(icon: "pencil", tint: Theme.primary, label: "Edit \(med.name)") {
                    editingMedication = med
                }
            }
            .padding(16.0)
            .background(isDark ? Theme.surfaceDark : Color.white)
            .cornerRadius(16.0)
            .overlay {
                RoundedRectangle(cornerRadius: 16.0)
                    .stroke(isTaken ? Theme.primary.opacity(0.4) : (isDark ? Theme.borderDark : Theme.borderLight), lineWidth: 1.0)
            }
        }
    }

    // MARK: - Inventory

    private func inventorySection() -> some View {
        VStack(spacing: 12.0) {
            if filteredMedications.isEmpty {
                EmptyStateCard(
                    icon: "pills.fill",
                    title: "No medications yet",
                    message: "Add a medication to start tracking your supply.",
                    isDark: isDark
                )
            } else {
                ForEach(filteredMedications) { med in
                    medicationInventoryRow(med)
                }
            }
        }
    }

    private func medicationInventoryRow(_ med: Medication) -> some View {
        HStack(spacing: 16.0) {
            VStack(alignment: .leading, spacing: 4.0) {
                Text(med.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Text(med.dosage)
                    .font(.caption)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
            }

            Spacer()

            HStack(spacing: 8.0) {
                IconCircleButton(icon: "minus", tint: Theme.slate500, label: "Reduce stock of \(med.name)") {
                    if med.stock > 0 {
                        var updated = med
                        updated.stock = med.stock - 1
                        viewModel.updateMedication(updated)
                    }
                }

                Text("\(med.stock)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(med.stock < 5 ? Theme.amber500 : (isDark ? Theme.slate100 : Theme.slate900))
                    .frame(minWidth: 32.0)

                IconCircleButton(icon: "plus", tint: Theme.primary, label: "Add stock of \(med.name)") {
                    var updated = med
                    updated.stock = med.stock + 1
                    viewModel.updateMedication(updated)
                }
            }
        }
        .padding(16.0)
        .background(isDark ? Theme.surfaceDark : Color.white)
        .cornerRadius(16.0)
        .overlay {
            RoundedRectangle(cornerRadius: 16.0)
                .stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0)
        }
    }

    // MARK: - History

    private func historySection() -> some View {
        let medLogs = viewModel.data.logs.filter { $0.type == "Medication Taken" }

        return VStack(spacing: 12.0) {
            if medLogs.isEmpty {
                EmptyStateCard(
                    icon: "clock",
                    title: "No history yet",
                    message: "Doses you mark as taken will appear here.",
                    isDark: isDark
                )
            } else {
                ForEach(medLogs) { log in
                    logRow(log)
                }
            }
        }
    }

    private func logRow(_ log: Log) -> some View {
        HStack(spacing: 16.0) {
            AppIcon(name: "checkmark.circle.fill", size: 22.0, tint: Theme.success)

            VStack(alignment: .leading, spacing: 2.0) {
                Text(log.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
                    .lineLimit(1)

                Text(DateFormatter.localizedString(from: log.date, dateStyle: .none, timeStyle: .short))
                    .font(.caption)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
            }

            Spacer()
        }
        .padding(16.0)
        .background(isDark ? Theme.surfaceDark : Color.white)
        .cornerRadius(16.0)
        .overlay {
            RoundedRectangle(cornerRadius: 16.0)
                .stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0)
        }
    }
}
