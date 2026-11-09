import SwiftUI
import AppModel

public struct DashboardView: View {
    @ObservedObject public var viewModel: MedicalViewModel
    @Binding public var selectedTab: Int
    @Binding public var selectedAppointmentDate: Date
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    private let isOnboarding: Bool

    @State private var showingAddConsultation = false
    @State private var showingAddMedication = false
    @State private var showingAddAppointment = false
    @State private var showingAddVital = false
    @State private var showingSettings = false

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, selectedTab: Binding<Int>, selectedAppointmentDate: Binding<Date>, isOnboarding: Bool = false) {
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self._selectedAppointmentDate = selectedAppointmentDate
        self.isOnboarding = isOnboarding
    }

    // MARK: - Computed data

    private var todaysMeds: [Medication] {
        viewModel.data.medications
    }

    private var takenTodayCount: Int {
        viewModel.data.logs.filter {
            $0.type == "Medication Taken" && Calendar.current.isDateInToday($0.date)
        }.count
    }

    private var nextMedication: Medication? {
        viewModel.data.medications.sorted { ($0.nextDose ?? .distantFuture) < ($1.nextDose ?? .distantFuture) }.first
    }

    private var upcomingAppointments: [Appointment] {
        viewModel.data.appointments
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    // MARK: - Body

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 32.0) {
                    headerView
                        .id("top")

                    todaySection

                    quickActionsSection

                    upcomingSection

                    historySection

                    if isOnboarding {
                        Color.clear.frame(height: 1.0).id("bottom")
                    }
                }
                .frame(maxWidth: .infinity)
                #if SKIP
                .padding(.bottom, 120.0)
                #else
                .padding(.bottom, 80.0)
                #endif
            }
            .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
            .ignoreAllSafeAreas()
            .sheet(isPresented: $showingAddConsultation) { NewConsultationView(viewModel: viewModel) }
            .sheet(isPresented: $showingAddMedication) { AddMedicationView(viewModel: viewModel) }
            .sheet(isPresented: $showingAddAppointment) { AddAppointmentView(viewModel: viewModel, selectedDate: Date()) }
            .sheet(isPresented: $showingAddVital) { AddVitalView(viewModel: viewModel) }
            .sheet(isPresented: $showingSettings) { SettingsView(viewModel: viewModel) }
            .onAppear {
                if isOnboarding {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2.0) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
            }

            Spacer()

            Button(action: { showingSettings = true }) {
                AppIcon(name: "bell.fill", size: 20.0, tint: isDark ? Theme.slate300 : Theme.slate600)
                    .frame(width: 44.0, height: 44.0)
                    .background(isDark ? Theme.surfaceDark : Color.white)
                    .clipShape(Circle())
            }
            .accessibilityLabel("Notification settings")
        }
        .padding(.horizontal, 16.0)
        #if SKIP
        .padding(.top, 20.0)
        #else
        .padding(.top, 56.0)
        #endif
    }

    // MARK: - Today (hero)

    @ViewBuilder
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            if !todaysMeds.isEmpty {
                todaysMedsCard
            } else if let appt = upcomingAppointments.first {
                todaysAppointmentCard(appt)
            } else {
                EmptyStateCard(
                    icon: "plus.circle",
                    title: "Start your health log",
                    message: "Add a medication or an appointment and your day shows up here.",
                    isDark: isDark
                )
            }
        }
        .padding(.horizontal, 16.0)
    }

    /// Hero card: today's plan with progress and the single next action.
    private var todaysMedsCard: some View {
        let taken = min(takenTodayCount, todaysMeds.count)
        let fraction = todaysMeds.isEmpty ? 0.0 : Double(taken) / Double(todaysMeds.count)

        return CardSurface(isDark: isDark) {
            VStack(alignment: .leading, spacing: 16.0) {
                HStack {
                    Text("Today's plan")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                    Spacer()

                    Text("\(taken) of \(todaysMeds.count) taken")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.primary)
                }

                ProgressBar(fraction: fraction, isDark: isDark)

                if let med = nextMedication {
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text("Next dose")
                            .font(.caption)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                        Text("\(med.name) · \(med.dosage)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                        Text(med.instructions)
                            .font(.caption)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                    }
                    .padding(.top, 8.0)

                    PrimaryButton(title: "Mark taken", icon: "checkmark") {
                        viewModel.markMedicationTaken(med)
                    }
                }
            }
        }
    }

    private func todaysAppointmentCard(_ appt: Appointment) -> some View {
        CardSurface(isDark: isDark) {
            VStack(alignment: .leading, spacing: 12.0) {
                Text("Next appointment")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                Text(appt.doctorName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                HStack(spacing: 16.0) {
                    Label(
                        title: { Text(DateFormatter.localizedString(from: appt.date, dateStyle: .short, timeStyle: .short)) },
                        icon: { AppIcon(name: "clock", size: 16.0) }
                    )

                    Label(
                        title: { Text(appt.location) },
                        icon: { AppIcon(name: "mappin.and.ellipse", size: 16.0) }
                    )
                }
                .font(.caption)
                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
            }
        }
        .onTapGesture {
            selectedAppointmentDate = appt.date
            selectedTab = 3
        }
    }

    // MARK: - Quick actions

    private var quickActionsSection: some View {
        HStack(spacing: 12.0) {
            quickActionTile(title: "Doctor", icon: "cross.case.fill") { showingAddConsultation = true }
            quickActionTile(title: "Meds", icon: "pills.fill") { showingAddMedication = true }
            quickActionTile(title: "Visit", icon: "calendar") { showingAddAppointment = true }
            quickActionTile(title: "Vitals", icon: "heart.text.square.fill") { showingAddVital = true }
        }
        .padding(.horizontal, 16.0)
    }

    private func quickActionTile(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8.0) {
                AppIcon(name: icon, size: 20.0, tint: Theme.primary)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isDark ? Theme.slate200 : Theme.slate700)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16.0)
            .background(isDark ? Theme.surfaceDark : Color.white)
            .cornerRadius(16.0)
            .overlay {
                RoundedRectangle(cornerRadius: 16.0)
                    .stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0)
            }
        }
    }

    // MARK: - Upcoming appointments

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            SectionHeader(
                title: "Upcoming",
                actionTitle: "Calendar",
                action: { selectedTab = 3 },
                isDark: isDark
            )
            .padding(.horizontal, 16.0)

            if upcomingAppointments.isEmpty {
                EmptyStateCard(
                    icon: "calendar",
                    title: "No upcoming appointments",
                    message: "Add a visit and it will appear here before the day comes.",
                    isDark: isDark
                )
                .padding(.horizontal, 16.0)
            } else {
                VStack(spacing: 12.0) {
                    ForEach(Array(upcomingAppointments.prefix(3))) { appt in
                        appointmentRow(appt)
                    }
                }
                .padding(.horizontal, 16.0)
            }
        }
    }

    private func appointmentRow(_ appt: Appointment) -> some View {
        Button(action: {
            selectedAppointmentDate = appt.date
            selectedTab = 3
        }) {
            HStack(spacing: 16.0) {
                VStack(alignment: .leading, spacing: 2.0) {
                    Text(DateFormatter.localizedString(from: appt.date, dateStyle: .none, timeStyle: .short))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.primary)

                    Text(DateFormatter.localizedString(from: appt.date, dateStyle: .short, timeStyle: .none))
                        .font(.caption)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                }
                .frame(width: 72.0, alignment: .leading)

                RoundedRectangle(cornerRadius: 1.0)
                    .fill(isDark ? Theme.borderDark : Theme.borderLight)
                    .frame(width: 2.0, height: 44.0)

                VStack(alignment: .leading, spacing: 2.0) {
                    Text(appt.doctorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
                        .lineLimit(1)

                    Text("\(appt.type) · \(appt.location)")
                        .font(.caption)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                        .lineLimit(1)
                }

                Spacer()

                AppIcon(name: "chevron.right", size: 14.0, tint: isDark ? Theme.slate500 : Theme.slate400)
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

    // MARK: - Recent history

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            SectionHeader(
                title: "Recent activity",
                actionTitle: "View all",
                action: { selectedTab = 4 },
                isDark: isDark
            )
            .padding(.horizontal, 16.0)

            if viewModel.data.logs.isEmpty {
                EmptyStateCard(
                    icon: "clock",
                    title: "Nothing logged yet",
                    message: "Taking a medication or adding a reading will show up here.",
                    isDark: isDark
                )
                .padding(.horizontal, 16.0)
            } else {
                VStack(spacing: 12.0) {
                    ForEach(Array(viewModel.data.logs.prefix(5))) { log in
                        logRow(log)
                    }
                }
                .padding(.horizontal, 16.0)
            }
        }
    }

    private func logRow(_ log: Log) -> some View {
        HStack(spacing: 16.0) {
            AppIcon(
                name: log.type == "Medication Taken" ? "checkmark.circle.fill" : "pencil.circle.fill",
                size: 22.0,
                tint: Theme.primary
            )

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

            Text(log.source)
                .font(.caption)
                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
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
