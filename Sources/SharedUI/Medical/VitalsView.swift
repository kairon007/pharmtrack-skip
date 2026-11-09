import SwiftUI
import AppModel

public struct VitalsView: View {
    @ObservedObject public var viewModel: MedicalViewModel
    @State private var selectedMetric = "Weight"
    @State private var showingAddVital = false
    @State private var showingAllVitals = false
    @Environment(\.colorScheme) var colorScheme
    private let isOnboarding: Bool

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, isOnboarding: Bool = false) {
        self.viewModel = viewModel
        self.isOnboarding = isOnboarding
    }

    private var filteredVitals: [Vital] {
        let sorted = viewModel.data.vitals.sorted(by: { $0.date < $1.date })
        return sorted.filter {
            switch selectedMetric {
            case "Weight": return $0.type == .weight
            case "Pressure": return $0.type == .bloodPressure
            case "Sugar": return $0.type == .bloodSugar
            default: return false
            }
        }
    }

    private var unit: String {
        switch selectedMetric {
        case "Weight": return "kg"
        case "Pressure": return "mmHg"
        case "Sugar": return "mg/dL"
        default: return ""
        }
    }

    private var latestValue: String {
        if let vital = filteredVitals.last {
            if vital.type == .bloodPressure {
                let v2 = vital.value2 ?? 0
                return "\(Int(vital.value))/\(Int(v2))"
            }
            return String(format: "%.1f", vital.value)
        }
        return "--"
    }

    private var trendPercentage: (icon: String, text: String, color: Color)? {
        let vitals = filteredVitals
        guard vitals.count >= 2 else { return nil }
        let current = vitals[vitals.count - 1].value
        let previous = vitals[vitals.count - 2].value

        if previous == 0.0 {
            return nil
        }

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

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView
                .id("top")

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24.0) {
                        metricCards

                        trendCard

                        recentEntriesSection

                        if isOnboarding {
                            Color.clear.frame(height: 1.0).id("bottom")
                        }
                    }
                    .padding(.horizontal, 16.0)
                    .padding(.top, 16.0)
                    .padding(.bottom, 80.0)
                }
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
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
        .ignoreTopSafeArea()
        .sheet(isPresented: $showingAddVital) {
            AddVitalView(viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showingAllVitals) {
            AllVitalsView(viewModel: viewModel)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Vitals")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

            Spacer()

            Button(action: { showingAddVital = true }) {
                AppIcon(name: "plus", size: 20.0, tint: Theme.primary)
                    .frame(width: 44.0, height: 44.0)
                    .background(Theme.primary.opacity(0.1))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Add reading")
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

    // MARK: - Metric cards (value first)

    private var metricCards: some View {
        HStack(spacing: 12.0) {
            metricCard(title: "Weight", type: .weight, unit: "kg")
            metricCard(title: "Pressure", type: .bloodPressure, unit: "mmHg")
            metricCard(title: "Sugar", type: .bloodSugar, unit: "mg/dL")
        }
    }

    private func metricCard(title: String, type: Vital.VitalType, unit: String) -> some View {
        let isSelected = selectedMetric == title
        let vitals = viewModel.data.vitals.filter { $0.type == type }.sorted { $0.date < $1.date }
        let value: String
        if let last = vitals.last {
            value = type == .bloodPressure ? "\(Int(last.value))/\(Int(last.value2 ?? 0))" : String(format: "%.1f", last.value)
        } else {
            value = "--"
        }

        return Button(action: { selectedMetric = title }) {
            VStack(alignment: .leading, spacing: 4.0) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(unit)
                    .font(.caption)
                    .foregroundColor(isDark ? Theme.slate500 : Theme.slate400)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16.0)
            .background(isDark ? Theme.surfaceDark : Color.white)
            .cornerRadius(16.0)
            .overlay {
                RoundedRectangle(cornerRadius: 16.0)
                    .stroke(isSelected ? Theme.primary : (isDark ? Theme.borderDark : Theme.borderLight), lineWidth: isSelected ? 2.0 : 1.0)
            }
        }
    }

    // MARK: - Trend

    private var trendCard: some View {
        CardSurface(isDark: isDark) {
            VStack(alignment: .leading, spacing: 16.0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text("\(selectedMetric) trend")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                        HStack(alignment: .firstTextBaseline, spacing: 4.0) {
                            Text(latestValue)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                            Text(unit)
                                .font(.subheadline)
                                .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                        }
                    }

                    Spacer()

                    if let trend = trendPercentage {
                        HStack(spacing: 4.0) {
                            AppIcon(name: trend.icon, size: 14.0, tint: trend.color)
                            Text(trend.text)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(trend.color)
                        }
                        .padding(.horizontal, 8.0)
                        .padding(.vertical, 4.0)
                        .background(trend.color.opacity(0.1))
                        .cornerRadius(8.0)
                    }
                }

                if filteredVitals.count > 1 {
                    DynamicChartPath(closed: false, data: filteredVitals.map { $0.value })
                        .stroke(Theme.primary, style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                        .frame(height: 120.0)
                } else {
                    Text(filteredVitals.isEmpty ? "Add a reading to see your trend" : "Add another reading to see your trend")
                        .font(.subheadline)
                        .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 120.0)
                }
            }
        }
    }

    // MARK: - Recent entries

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            SectionHeader(
                title: "Recent readings",
                actionTitle: "View all",
                action: { showingAllVitals = true },
                isDark: isDark
            )

            if filteredVitals.isEmpty {
                EmptyStateCard(
                    icon: "heart.text.square.fill",
                    title: "No readings yet",
                    message: "Log your first \(selectedMetric.lowercased()) reading to start tracking.",
                    isDark: isDark
                )
            } else {
                VStack(spacing: 12.0) {
                    ForEach(Array(filteredVitals.reversed().prefix(5))) { vital in
                        vitalRow(vital)
                    }
                }
            }
        }
    }

    private func vitalRow(_ vital: Vital) -> some View {
        HStack(spacing: 16.0) {
            AppIcon(name: "scalemass", size: 20.0, tint: Theme.primary)
                .frame(width: 44.0, height: 44.0)
                .background(isDark ? Theme.backgroundDark : Theme.slate50)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2.0) {
                Text(valueLabel(for: vital))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Text(DateFormatter.localizedString(from: vital.date, dateStyle: .short, timeStyle: .short))
                    .font(.caption)
                    .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)
            }

            Spacer()

            if let notes = vital.notes, !notes.isEmpty {
                AppIcon(name: "info.circle", size: 16.0, tint: isDark ? Theme.slate500 : Theme.slate400)
            }

            IconCircleButton(icon: "trash", tint: Theme.error, label: "Delete reading") {
                viewModel.deleteVital(vital)
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

    private func valueLabel(for vital: Vital) -> String {
        switch vital.type {
        case .bloodPressure:
            return "\(Int(vital.value))/\(Int(vital.value2 ?? 0)) \(unit)"
        default:
            return String(format: "%.1f %@", vital.value, unit)
        }
    }
}

struct ChartPath: Shape {
    var closed: Bool = false

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0.0, y: rect.height * 0.7))
        path.addCurve(to: CGPoint(x: rect.width * 0.3, y: rect.height * 0.8), control1: CGPoint(x: rect.width * 0.1, y: rect.height * 0.6), control2: CGPoint(x: rect.width * 0.2, y: rect.height * 0.9))
        path.addCurve(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.3), control1: CGPoint(x: rect.width * 0.4, y: rect.height * 0.7), control2: CGPoint(x: rect.width * 0.5, y: rect.height * 0.4))
        path.addCurve(to: CGPoint(x: rect.width, y: rect.height * 0.5), control1: CGPoint(x: rect.width * 0.8, y: rect.height * 0.2), control2: CGPoint(x: rect.width * 0.9, y: rect.height * 0.4))

        if closed {
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0.0, y: rect.height))
            path.closeSubpath()
        }

        return path
    }
}

struct DynamicChartPath: Shape {
    var closed: Bool = false
    var data: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        guard data.count > 1 else {
            // Fallback for empty or single data point
            path.move(to: CGPoint(x: 0.0, y: rect.height * 0.5))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.5))
            if closed {
                path.addLine(to: CGPoint(x: rect.width, y: rect.height))
                path.addLine(to: CGPoint(x: 0.0, y: rect.height))
                path.closeSubpath()
            }
            return path
        }

        let maxVal = data.max() ?? 100.0
        let minVal = data.min() ?? 0.0
        let range = maxVal - minVal
        let adjustedRange = range == 0.0 ? 1.0 : range

        let stepX = rect.width / CGFloat(data.count - 1)

        for (index, value) in data.enumerated() {
            let normalizedY: CGFloat
            if range == 0.0 {
                normalizedY = 0.5
            } else {
                normalizedY = 1.0 - CGFloat((value - minVal) / adjustedRange)
            }
            let y = normalizedY * (rect.height * 0.8) + (rect.height * 0.1)
            let x = CGFloat(index) * stepX

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        if closed {
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0.0, y: rect.height))
            path.closeSubpath()
        }

        return path
    }
}
