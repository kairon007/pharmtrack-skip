import SwiftUI
import AppModel

public struct MainTabView: View {
    @ObservedObject private var viewModel: MedicalViewModel
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var selection = 0
    @State private var showOnboardingOverlay = false
    @State private var selectedAppointmentDate: Date = Date()

    private var isDark: Bool { colorScheme == .dark }
    private var isOnboarding: Bool { !hasCompletedOnboarding }

    public init(viewModel: MedicalViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            TabView(selection: $selection) {
                DashboardView(viewModel: viewModel, selectedTab: $selection, selectedAppointmentDate: $selectedAppointmentDate, isOnboarding: isOnboarding && selection == 0)
                    .tabItem {
                        Label {
                            Text("Home")
                        } icon: {
                            AppIcon(name: "house.fill", size: 24.0)
                        }
                    }
                    .tag(0)

                ConsultationsView(viewModel: viewModel, isOnboarding: isOnboarding && selection == 1)
                    .tabItem {
                        Label {
                            Text("Consults")
                        } icon: {
                            AppIcon(name: "cross.case.fill", size: 24.0)
                        }
                    }
                    .tag(1)

                MedicationTrackerView(viewModel: viewModel, isOnboarding: isOnboarding && selection == 2)
                    .tabItem {
                        Label {
                            Text("Meds")
                        } icon: {
                            AppIcon(name: "pills.fill", size: 24.0)
                        }
                    }
                    .tag(2)

                AppointmentsView(viewModel: viewModel, selectedDate: selectedAppointmentDate, isOnboarding: isOnboarding && selection == 3)
                    .tabItem {
                        Label {
                            Text("Calendar")
                        } icon: {
                            AppIcon(name: "calendar", size: 24.0)
                        }
                    }
                    .tag(3)

                VitalsView(viewModel: viewModel, isOnboarding: isOnboarding && selection == 4)
                    .tabItem {
                        Label {
                            Text("Vitals")
                        } icon: {
                            AppIcon(name: "heart.text.square.fill", size: 24.0)
                        }
                    }
                    .tag(4)
            }
            .platformAccentColor()

            if isOnboarding && showOnboardingOverlay {
                OnboardingOverlay(
                    text: selection < 4 ? "Ready for the next one?" : "Ready to use the app?",
                    buttonText: selection < 4 ? "Next" : "Get Started",
                    action: {
                        if selection < 4 {
                            withAnimation {
                                selection += 1
                            }
                        } else {
                            Task {
                                await viewModel.clearData()
                                // Small delay to ensure data is cleared before setting flag
                                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                                hasCompletedOnboarding = true
                            }
                        }
                    }
                )
            }
        }
        .onAppear {
            Task {
                await viewModel.load()
                if isOnboarding {
                    // Delay showing the overlay to let the scroll animation happen/start
                    try? await Task.sleep(nanoseconds: 3_500_000_000) // 3.5 seconds
                    withAnimation {
                        showOnboardingOverlay = true
                    }
                }
            }
        }
        .onChange(of: selection) { oldSelection, newSelection in
            if isOnboarding {
                showOnboardingOverlay = false
                Task {
                    // Wait for scroll animation
                    try? await Task.sleep(nanoseconds: 3_500_000_000)
                    withAnimation {
                        showOnboardingOverlay = true
                    }
                }
            }
        }
    }
}

struct OnboardingOverlay: View {
    let text: String
    let buttonText: String
    let action: () -> Void

    var body: some View {
        ZStack {
            // Blurred background overlay
            Rectangle()
                .fill(Color.black.opacity(0.6))
                .ultraThinBackground()
                .ignoresSafeArea()
            
            // Content card
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24.0) {
                    // Icon/indicator at top
                    ZStack {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 72, height: 72)
                        
                        AppIcon(name: "sparkles", size: 32, tint: .white)
                    }
                    .padding(.bottom, 8)
                    
                    // Text content
                    Text(text)
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    
                    Text("Swipe or tap below to explore")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    // Action button
                    Button(action: action) {
                        Text(buttonText)
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .background(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.98))
                .cornerRadius(24)
                .padding(.horizontal, 20)
                .padding(.bottom, 120) // Position above tab bar
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}
