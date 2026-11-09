import SwiftUI
import AppModel

public struct ConsultationsView: View {
    @ObservedObject public var viewModel: MedicalViewModel
    @State private var searchText = ""
    @State private var showingAddConsultation = false
    @State private var editingConsultation: Consultation?
    @Environment(\.colorScheme) var colorScheme
    private let isOnboarding: Bool

    private var isDark: Bool { colorScheme == .dark }

    public init(viewModel: MedicalViewModel, isOnboarding: Bool = false) {
        self.viewModel = viewModel
        self.isOnboarding = isOnboarding
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            headerView
                .id("top")

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16.0) {
                        HStack {
                        Text("Active treatments")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isDark ? Theme.slate400 : Theme.slate500)

                        Spacer()

                        Text("\(viewModel.data.consultations.count) active")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.primary)
                    }
                    .padding(.horizontal, 16.0)
                    .padding(.top, 16.0)

                        ForEach(filteredConsultations) { consult in
                            consultationCard(consult)
                        }

                        if filteredConsultations.isEmpty {
                            EmptyStateCard(
                                icon: "cross.case.fill",
                                title: "No consultations yet",
                                message: "Add a doctor to keep your treatments in one place.",
                                isDark: isDark
                            )
                            .padding(.horizontal, 0)
                        }
                        if isOnboarding {
                            Color.clear.frame(height: 1.0).id("bottom")
                        }
                    }
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
        .sheet(isPresented: $showingAddConsultation) {
            NewConsultationView(viewModel: viewModel)
        }
        .sheet(item: $editingConsultation) { consultation in
            NewConsultationView(viewModel: viewModel, consultation: consultation)
        }
    }

    private var headerView: some View {
        VStack(spacing: 16.0) {
            HStack {
                Text("Consultations")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)

                Spacer()

                Button(action: {
                    showingAddConsultation = true
                }) {
                    AppIcon(name: "plus", size: 20.0, tint: Theme.primary)
                        .frame(width: 44.0, height: 44.0)
                        .background(Theme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add consultation")
            }

            // Search Bar
            HStack {
                AppIcon(name: "magnifyingglass", size: 20.0, tint: Theme.slate400)
                TextField("Search by doctor or specialty...", text: $searchText)
                    .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
            }
            .padding(12.0)
            .background(isDark ? Theme.surfaceDark : Color.white)
            .cornerRadius(12.0)
            .overlay { RoundedRectangle(cornerRadius: 12.0).stroke(isDark ? Theme.borderDark : Theme.borderLight, lineWidth: 1.0) }
        }
        .padding(.horizontal, 16.0)
        #if SKIP
        .padding(.top, 16.0)
        #else
        .padding(.top, 60.0) // Safe area
        #endif
        .padding(.bottom, 16.0)
        .background(isDark ? Theme.backgroundDark : Theme.backgroundLight)
    }

    private var filteredConsultations: [Consultation] {
        if searchText.isEmpty {
            return viewModel.data.consultations
        } else {
            let searchLower = searchText.lowercased()
            return viewModel.data.consultations.filter {
                $0.doctorName.lowercased().contains(searchLower) ||
                $0.specialty.lowercased().contains(searchLower)
            }
        }
    }

    private func consultationCard(_ consult: Consultation) -> some View {
        Button(action: { editingConsultation = consult }) {
            HStack(spacing: 16.0) {
                // Initials avatar — photos > initials > generic icons
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.1))
                        .frame(width: 52.0, height: 52.0)

                    Text(initials(for: consult.doctorName))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.primary)
                }

                VStack(alignment: .leading, spacing: 2.0) {
                    Text(consult.doctorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isDark ? Theme.slate100 : Theme.slate900)
                        .lineLimit(1)

                    Text(consult.specialty)
                        .font(.caption)
                        .foregroundColor(Theme.primary)
                        .lineLimit(1)

                    Text("Last visit: \(DateFormatter.localizedString(from: consult.date, dateStyle: .medium, timeStyle: .none))")
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
        .padding(.horizontal, 16.0)
        .padding(.vertical, 4.0)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }
        let joined = letters.joined().uppercased()
        return joined.isEmpty ? "?" : joined
    }
}
