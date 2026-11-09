import SwiftUI
import AppModel

public struct AllVitalsView: View {
    @ObservedObject public var viewModel: MedicalViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // Filter / navigation state
    @State private var selectedMetric: Vital.VitalType = .weight
    @State private var timeRange: TimeRange = .week
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var weekOffset: Int = 0
    @State private var highlightedVitalID: UUID?

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel) {
        self.viewModel = viewModel
    }

    public enum TimeRange: String, CaseIterable, Identifiable {
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
        case all = "All"

        public var id: String { rawValue }

        var days: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            case .all: return nil
            }
        }

        var label: String {
            switch self {
            case .week: return "Last 7 Days"
            case .month: return "Last 30 Days"
            case .quarter: return "Last 90 Days"
            case .all: return "All Time"
            }
        }
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView

            calendarStrip

            ScrollView {
                VStack(spacing: 20.0) {
                    metricFilterSection
                    timeRangeSection
                    chartSection
                    selectedDateSection
                    allReadingsSection
                }
                .padding(.bottom, 16.0)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity)
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
        .ignoreTopSafeArea()
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 12.0) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4.0) {
                        AppIcon(name: "chevron.left", size: 18.0, tint: Theme.primary)
                        Text("Back")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Theme.primary)
                }

                Spacer()

                Text("All Vitals")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Spacer()

                // Invisible spacer to keep title centered
                AppIcon(name: "chevron.left", size: 18.0, tint: .clear)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16.0)
        #if SKIP
        .padding(.top, 16.0)
        #else
        .padding(.top, 60.0)
        #endif
        .padding(.bottom, 12.0)
        .background(
            (isDark ? Theme.backgroundDark : Theme.backgroundLight)
                .opacity(0.95)
        )
    }

    // MARK: - Filters

    private var metricFilterSection: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Metric")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                .tracking(1.2)
                .padding(.horizontal, 16.0)

            HStack(spacing: 0.0) {
                metricChip(title: "Weight", type: .weight)
                metricChip(title: "Pressure", type: .bloodPressure)
                metricChip(title: "Sugar", type: .bloodSugar)
            }
            .padding(4.0)
            .background(isDark ? Theme.slate800 : Theme.slate200)
            .cornerRadius(12.0)
            .padding(.horizontal, 16.0)
        }
    }

    private func metricChip(title: String, type: Vital.VitalType) -> some View {
        let isSelected = selectedMetric == type
        return Button(action: {
            selectedMetric = type
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? (isDark ? .white : Theme.primary) : (isDark ? Theme.slate400 : Theme.slate500))
                .padding(.vertical, 8.0)
                .frame(maxWidth: .infinity)
                .background(isSelected ? (isDark ? Theme.slate700 : Color.white) : Color.clear)
                .cornerRadius(8.0)
        }
    }

    private var timeRangeSection: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Text("Time range")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                    .tracking(1.2)

                Spacer()

                Text(timeRange.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primary)
            }
            .padding(.horizontal, 16.0)

            HStack(spacing: 8.0) {
                ForEach(TimeRange.allCases) { range in
                    rangeChip(range: range)
                }
            }
            .padding(.horizontal, 16.0)
        }
    }

    private func rangeChip(range: TimeRange) -> some View {
        let isSelected = timeRange == range
        return Button(action: { timeRange = range }) {
            Text(range.rawValue)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : (isDark ? Theme.slate300 : Theme.slate600))
                .padding(.vertical, 8.0)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Theme.primary : (isDark ? Theme.slate800 : Theme.slate100))
                .cornerRadius(8.0)
        }
    }

    // MARK: - Calendar Strip

    private var displayedMonthString: String {
        let baseDate = Calendar.current.date(byAdding: .day, value: weekOffset * 7, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: baseDate)
    }

    private var calendarStrip: some View {
        VStack(spacing: 12.0) {
            HStack {
                Text(displayedMonthString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Spacer()

                HStack(spacing: 12.0) {
                    Button(action: { weekOffset -= 1 }) {
                        AppIcon(name: "chevron.left", size: 18.0, tint: isDark ? Theme.slate400 : Theme.slate500)
                    }
                    Button(action: { weekOffset += 1 }) {
                        AppIcon(name: "chevron.right", size: 18.0, tint: isDark ? Theme.slate400 : Theme.slate500)
                    }
                }
            }
            .padding(.horizontal, 16.0)

            HStack(spacing: 8.0) {
                ForEach(-3..<4) { offset in
                    dayCell(offset: offset)
                }
            }
            .padding(.horizontal, 16.0)
        }
        .padding(.vertical, 12.0)
        .background(isDark ? Theme.slate900 : Color.white)
        .cornerRadius(16.0)
        .overlay {
            RoundedRectangle(cornerRadius: 16.0)
                .stroke(isDark ? Theme.slate800 : Theme.slate100, lineWidth: 1.0)
        }
        .padding(.horizontal, 16.0)
        .padding(.bottom, 8.0)
    }

    private func dayCell(offset: Int) -> some View {
        let baseDate = Calendar.current.date(byAdding: .day, value: weekOffset * 7, to: Date()) ?? Date()
        let date = Calendar.current.date(byAdding: .day, value: offset, to: baseDate) ?? Date()
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let hasReading = filteredVitals.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        let dayStr = dayFormatter.string(from: date)

        let numFormatter = DateFormatter()
        numFormatter.dateFormat = "d"
        let numStr = numFormatter.string(from: date)

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = Calendar.current.startOfDay(for: date)
            }
        }) {
            VStack(spacing: 4.0) {
                Text(dayStr.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white.opacity(0.85) : (isDark ? Theme.slate500 : Theme.slate400))

                Text(numStr)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : (isDark ? Theme.slate100 : Theme.slate900))

                Circle()
                    .fill(hasReading ? Theme.primary : Color.clear)
                    .frame(width: 5.0, height: 5.0)
            }
            .frame(width: 44.0, height: 64.0)
            .background(isSelected ? Theme.primary : Color.clear)
            .cornerRadius(12.0)
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(isSelected ? Color.clear : (isDark ? Theme.slate800 : Theme.slate200), lineWidth: 1.0)
            }
            .shadow(color: isSelected ? Theme.primary.opacity(0.3) : Color.clear, radius: 5.0, x: 0.0, y: 5.0)
        }
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            HStack {
                VStack(alignment: .leading, spacing: 4.0) {
                    Text(metricLabel.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                        .tracking(1.2)

                    HStack(alignment: .firstTextBaseline, spacing: 4.0) {
                        Text(latestSelectedValue)
                            .font(.system(size: 28.0, weight: .bold))
                            .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
                        Text(metricUnit)
                            .font(.subheadline)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                    }
                }

                Spacer()

                if let trend = trendPercentage {
                    HStack(spacing: 4.0) {
                        AppIcon(name: trend.icon, size: 12.0)
                        Text(trend.text)
                    }
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(trend.color)
                    .padding(.horizontal, 8.0)
                    .padding(.vertical, 4.0)
                    .background(trend.color.opacity(0.1))
                    .cornerRadius(4.0)
                }
            }

            if filteredVitals.isEmpty {
                VStack(spacing: 8.0) {
                    AppIcon(name: "chart.bar.fill", size: 32.0, tint: isDark ? Theme.slate700 : Theme.slate300)
                    Text("No readings yet for \(metricLabel)")
                        .font(.caption)
                        .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140.0)
            } else {
                ZStack(alignment: .topLeading) {
                    DynamicChartPath(closed: false, data: filteredVitals.map { chartValue(for: $0) })
                        .stroke(Theme.primary, style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                        .frame(height: 140.0)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Theme.primary.opacity(0.2), Theme.primary.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                                .mask { DynamicChartPath(closed: true, data: filteredVitals.map { chartValue(for: $0) }).fill(Color.black) }
                        )

                    // Min/Max labels
                    if let maxVal = chartMaxValue, let minVal = chartMinValue {
                        HStack {
                            Text(String(format: "%.0f", minVal))
                                .font(.caption2)
                                .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
                            Spacer()
                            Text(String(format: "%.0f", maxVal))
                                .font(.caption2)
                                .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
                        }
                        .padding(.horizontal, 4.0)
                        .offset(y: 145.0)
                    }
                }
                .frame(height: 170.0)
            }
        }
        .padding(20.0)
        .background(isDark ? Theme.surfaceDark : Color.white)
        .cornerRadius(20.0)
        .overlay {
            RoundedRectangle(cornerRadius: 16.0)
                .stroke(isDark ? Theme.slate800 : Theme.slate100, lineWidth: 1.0)
        }
        .padding(.horizontal, 16.0)
    }

    // MARK: - Selected Date Section

    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            HStack {
                VStack(alignment: .leading, spacing: 2.0) {
                    Text("Readings for")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                        .tracking(1.2)

                    Text(DateFormatter.localizedString(from: selectedDate, dateStyle: .full, timeStyle: .none))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
                }

                Spacer()

                Text("\(vitalsForSelectedDate.count) entries")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primary)
            }
            .padding(.horizontal, 16.0)

            if vitalsForSelectedDate.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6.0) {
                        AppIcon(name: "calendar", size: 24.0, tint: isDark ? Theme.slate600 : Theme.slate400)
                        Text("No readings on this day")
                            .font(.caption)
                            .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
                    }
                    .padding(.vertical, 24.0)
                    Spacer()
                }
                .background(isDark ? Theme.slate900 : Color.white)
                .cornerRadius(12.0)
                .overlay {
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(isDark ? Theme.slate800 : Theme.slate100, lineWidth: 1.0)
                }
                .padding(.horizontal, 16.0)
            } else {
                VStack(spacing: 10.0) {
                    ForEach(vitalsForSelectedDate) { vital in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                highlightedVitalID = vital.id
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                if highlightedVitalID == vital.id {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        highlightedVitalID = nil
                                    }
                                }
                            }
                        }) {
                            vitalRow(vital)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16.0)
            }
        }
    }

    // MARK: - All Readings Section

    private var allReadingsSection: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            HStack {
                Text("All readings")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                    .tracking(1.2)

                Spacer()

                Text("\(filteredVitals.count) total")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primary)
            }
            .padding(.horizontal, 16.0)

            if filteredVitals.isEmpty {
                HStack {
                    Spacer()
                    Text("Tap + to add your first reading")
                        .font(.caption)
                        .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
                        .padding(.vertical, 24.0)
                    Spacer()
                }
                .background(isDark ? Theme.slate900 : Color.white)
                .cornerRadius(12.0)
                .overlay {
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(isDark ? Theme.slate800 : Theme.slate100, lineWidth: 1.0)
                }
                .padding(.horizontal, 16.0)
            } else {
                VStack(spacing: 10.0) {
                    ForEach(filteredVitals.reversed()) { vital in
                        Button(action: {
                            // Tap a reading: jump the calendar + chart to its date and briefly highlight it.
                            selectedDate = Calendar.current.startOfDay(for: vital.date)
                            syncWeekOffsetToDate()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                highlightedVitalID = vital.id
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                if highlightedVitalID == vital.id {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        highlightedVitalID = nil
                                    }
                                }
                            }
                        }) {
                            vitalRow(vital)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16.0)
            }
        }
    }

    private func vitalRow(_ vital: Vital) -> some View {
        let isHighlighted = highlightedVitalID == vital.id
        return HStack(spacing: 14.0) {
            ZStack {
                Circle()
                    .fill(isDark ? Theme.slate800 : Theme.slate50)
                    .frame(width: 44.0, height: 44.0)

                AppIcon(name: iconForType(vital.type), size: 22.0, tint: Theme.primary)
            }

            VStack(alignment: .leading, spacing: 2.0) {
                Text(valueLabel(for: vital))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Text(DateFormatter.localizedString(from: vital.date, dateStyle: .short, timeStyle: .short))
                    .font(.caption2)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
            }

            Spacer()

            if let notes = vital.notes, !notes.isEmpty {
                AppIcon(name: "info.circle", size: 16.0, tint: isDark ? Theme.slate500 : Theme.slate400)
            }

            AppIcon(name: "chevron.right", size: 14.0, tint: isDark ? Theme.slate500 : Theme.slate400)
        }
        .padding(14.0)
        .background(
            isHighlighted
                ? Theme.primary.opacity(0.15)
                : (isDark ? Theme.slate900 : Color.white)
        )
        .cornerRadius(12.0)
        .overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(
                    isHighlighted
                        ? Theme.primary
                        : (isDark ? Theme.slate800 : Theme.slate100),
                    lineWidth: isHighlighted ? 1.5 : 1.0
                )
        }
    }

    /// Align the calendar's `weekOffset` so the strip includes `selectedDate`.
    private func syncWeekOffsetToDate() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        guard let daysDiff = calendar.dateComponents([.day], from: today, to: selected).day else { return }
        weekOffset = Int((Double(daysDiff) / 7.0).rounded())
    }

    // MARK: - Computed Properties

    /// Vitals filtered by selected metric and time range.
    private var filteredVitals: [Vital] {
        let cutoff: Date?
        if let days = timeRange.days {
            cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())
        } else {
            cutoff = nil
        }

        return viewModel.data.vitals
            .filter { $0.type == selectedMetric }
            .filter { vital in
                guard let cutoff else { return true }
                return vital.date >= cutoff
            }
            .sorted { $0.date < $1.date }
    }

    private var vitalsForSelectedDate: [Vital] {
        filteredVitals.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var metricLabel: String {
        switch selectedMetric {
        case .weight: return "Weight"
        case .bloodPressure: return "Blood Pressure"
        case .bloodSugar: return "Blood Sugar"
        }
    }

    private var metricUnit: String {
        switch selectedMetric {
        case .weight: return "kg"
        case .bloodPressure: return "mmHg"
        case .bloodSugar: return "mg/dL"
        }
    }

    private var latestSelectedValue: String {
        guard let last = filteredVitals.last else { return "--" }
        return valueLabel(for: last)
    }

    private func chartValue(for vital: Vital) -> Double {
        vital.value
    }

    private var chartMaxValue: Double? {
        let values = filteredVitals.map { chartValue(for: $0) }
        return values.max()
    }

    private var chartMinValue: Double? {
        let values = filteredVitals.map { chartValue(for: $0) }
        return values.min()
    }

    private var trendPercentage: (icon: String, text: String, color: Color)? {
        let vitals = filteredVitals
        guard vitals.count >= 2 else { return nil }
        let current = chartValue(for: vitals[vitals.count - 1])
        let previous = chartValue(for: vitals[vitals.count - 2])

        if previous == 0.0 { return nil }

        let diff = current - previous
        let percentage = (diff / previous) * 100.0
        let formatted = String(format: "%.1f%%", abs(percentage))

        if diff < 0 {
            return ("arrow.down.right", formatted, Theme.emerald500)
        } else if diff > 0 {
            return ("arrow.up.right", formatted, Theme.rose500)
        } else {
            return ("arrow.right", "0.0%", Theme.slate500)
        }
    }

    // MARK: - Helpers

    private func valueLabel(for vital: Vital) -> String {
        switch vital.type {
        case .weight:
            return String(format: "%.1f %@", vital.value, "kg")
        case .bloodPressure:
            let v2 = Int(vital.value2 ?? 0)
            return "\(Int(vital.value))/\(v2) mmHg"
        case .bloodSugar:
            return String(format: "%.0f %@", vital.value, "mg/dL")
        }
    }

    private func iconForType(_ type: Vital.VitalType) -> String {
        switch type {
        case .weight: return "scalemass"
        case .bloodPressure: return "heart.fill"
        case .bloodSugar: return "drop.fill"
        }
    }
}
