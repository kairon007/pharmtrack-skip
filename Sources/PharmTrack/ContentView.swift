import SwiftUI
import SharedUI
import AppModel

struct ContentView: View {
    @StateObject var viewModel: MedicalViewModel

    init() {
        _viewModel = StateObject(wrappedValue: MedicalViewModel(notificationManager: NotificationManager.shared))
    }

    var body: some View {
        MainTabView(viewModel: viewModel)
            .onAppear {
                NotificationManager.shared.requestAuthorization()
            }
    }
}
