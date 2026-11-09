import SwiftUI
import AppModel

public struct AppointmentsView: View {
    @ObservedObject public var viewModel: MedicalViewModel
    @State private var showingAddAppointment = false
    @State private var editingAppointment: Appointment?
    @State private var selectedDate: Date
    @State private var weekOffset = 0
    @Environment(\.colorScheme) var colorScheme
    private let isOnboarding: Bool

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, selectedDate: Date = Date(), isOnboarding: Bool = false) {
        self.viewModel = viewModel
        self._selectedDate = State(initialValue: selectedDate)
        self.isOnboarding = isOnboarding
    }

    private var appointmentsHeaderText: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)

        if calendar.isDateInToday(selectedDate) {
            return "Today's Appointments"
        } else if selected > today {
            let days = calendar.dateComponents([.day], from: today, to: selected).day ?? 0
            return "In \(days) day\(days == 1 ? "" : "s")"
        } else {
            let days = calendar.dateComponents([.day], from: selected, to: today).day ?? 0
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView

            calendarStrip

            ScrollView {
                VStack(spacing: 20.0) {
                    HStack {
                        Text(appointmentsHeaderText)
                            .font(.headline)
                            .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
                        Spacer()
                    }
                    .padding(.horizontal, 16.0)

                    if appointmentsForSelectedDate.isEmpty {
                        Text("No appointments for \(DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .none))")
                            .font(.subheadline)
                            .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
                            .padding(.top, 40.0)
                    } else {
                        ForEach(appointmentsForSelectedDate) { appt in
                            appointmentCard(appt)
                        }
                    }
                }
                .padding(.top, 24.0)
                .padding(.bottom, 100.0)
            }
        }
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
        .ignoreTopSafeArea()
        .sheet(isPresented: $showingAddAppointment) {
            AddAppointmentView(viewModel: viewModel, selectedDate: selectedDate)
        }
        .sheet(item: $editingAppointment) { appointment in
            AddAppointmentView(viewModel: viewModel, selectedDate: appointment.date, editingAppointment: appointment)
        }
    }

    private var headerView: some View {
        VStack(spacing: 16.0) {
            HStack {
                Text("Appointments")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Spacer()

                Button(action: {
                    showingAddAppointment = true
                }) {
                    AppIcon(name: "plus", size: 24.0, tint: Theme.primary)
                        .frame(width: 44.0, height: 44.0)
                        .background(Theme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add appointment")
            }
        }
        .padding(.horizontal, 16.0)
        #if SKIP
        .padding(.top, 16.0)
        #else
        .padding(.top, 60.0)
        #endif
        .padding(.bottom, 16.0)
        .background(
            (isDark ? Theme.backgroundDark : Theme.backgroundLight)
                .opacity(0.95)
        )
    }

    private var appointmentsForSelectedDate: [Appointment] {
        viewModel.data.appointments.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var displayedMonthString: String {
        let displayedMonth = Calendar.current.date(byAdding: .day, value: weekOffset * 7, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private var calendarStrip: some View {
        VStack(spacing: 12.0) {
            HStack {
                Text(displayedMonthString)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Spacer()

                HStack(spacing: 16.0) {
                    Button(action: { weekOffset -= 1 }) {
                        AppIcon(name: "chevron.left", size: 20.0, tint: isDark ? Theme.slate400 : Theme.slate500)
                    }
                    Button(action: { weekOffset += 1 }) {
                        AppIcon(name: "chevron.right", size: 20.0, tint: isDark ? Theme.slate400 : Theme.slate500)
                    }
                }
            }
            .padding(.horizontal, 16.0)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.0) {
                    ForEach(-3..<4) { offset in
                        dayCell(offset: offset)
                    }
                }
                .padding(.horizontal, 16.0)
            }
        }
        .padding(.bottom, 16.0)
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private func dayCell(offset: Int) -> some View {
        let baseDate = Calendar.current.date(byAdding: .day, value: weekOffset * 7, to: Date()) ?? Date()
        let date = Calendar.current.date(byAdding: .day, value: offset, to: baseDate) ?? Date()
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        let dayStr = dayFormatter.string(from: date)

        let numFormatter = DateFormatter()
        numFormatter.dateFormat = "d"
        let numStr = numFormatter.string(from: date)

        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4.0) {
                Text(dayStr.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : (isDark ? Theme.slate500 : Theme.slate400))

                Text(numStr)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : (isDark ? Theme.slate100 : Theme.slate900))
            }
            .frame(width: 48.0, height: 64.0)
            .background(isSelected ? Theme.primary : (isDark ? Theme.surfaceDark : Color.white))
            .cornerRadius(12.0)
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(isSelected ? Color.clear : (isDark ? Theme.borderDark : Theme.borderLight), lineWidth: 1.0)
            }
        }
    }

    private func appointmentCard(_ appt: Appointment) -> some View {
        HStack(alignment: .top, spacing: 16.0) {
            VStack(spacing: 4.0) {
                Text(DateFormatter.localizedString(from: appt.date, dateStyle: .none, timeStyle: .short))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primary)
                    .lineLimit(1)

                Rectangle()
                    .fill(isDark ? Theme.borderDark : Theme.borderLight)
                    .frame(width: 2.0)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 56.0)

            VStack(alignment: .leading, spacing: 6.0) {
                Text(appt.doctorName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Text(appt.specialty)
                    .font(.subheadline)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                HStack(spacing: 4.0) {
                    AppIcon(name: "mappin.and.ellipse", size: 14.0)
                    Text(appt.location)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
            }

            Spacer()

            VStack(spacing: 8.0) {
                IconCircleButton(icon: "pencil", tint: Theme.primary, label: "Edit appointment") {
                    editingAppointment = appt
                }

                IconCircleButton(icon: "trash", tint: Theme.error, label: "Delete appointment") {
                    viewModel.deleteAppointment(appt)
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
        .padding(.horizontal, 16.0)
    }
}
