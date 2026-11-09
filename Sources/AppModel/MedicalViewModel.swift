import Foundation
import Combine

public protocol NotificationManagerProtocol: Sendable {
    func updateNotifications(with data: MedicalData)
    func scheduleTestNotification()
}

@MainActor
public class MedicalViewModel: ObservableObject {
    @Published public var data: MedicalData
    private let repository: MedicalRepository
    public var notificationManager: NotificationManagerProtocol?

    public init(repository: MedicalRepository = LocalMedicalRepository(), notificationManager: NotificationManagerProtocol? = nil) {
        self.repository = repository
        self.data = MedicalData()
        self.notificationManager = notificationManager
    }

    public func load() async {
        do {
            if let loadedData = try await repository.load() {
                self.data = loadedData
                self.notificationManager?.updateNotifications(with: self.data)
            } else {
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                if !hasCompletedOnboarding {
                    self.populateMockData()
                } else {
                    self.data = MedicalData()
                }
            }
        } catch {
            print("Error loading data: \(error)")
            // Fallback to empty data instead of wiping user data with mocks if a parsing error occurs after onboarding
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            if !hasCompletedOnboarding {
                self.populateMockData()
            } else {
                self.data = MedicalData()
            }
        }
    }

    public func save() async {
        do {
            try await repository.save(data: data)
            self.notificationManager?.updateNotifications(with: self.data)
        } catch {
            print("Error saving data: \(error)")
        }
    }

    private func populateMockData() {
        // Mock data from designs
        let today = Date()

        // Appointments - use platform-specific date construction
        #if !SKIP
        let appointmentDate = Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: today) ?? today
        #else
        let appointmentDate = today
        #endif

        let appt1 = Appointment(
            id: UUID(),
            doctorName: "Dr. Michael Smith",
            specialty: "Cardiology",
            type: "General Checkup",
            date: appointmentDate,
            location: "City Clinic",
            notes: "Bring previous reports",
            notify: true
        )

        // Medications
        #if !SKIP
        let med1NextDose = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today)
        #else
        let med1NextDose: Date? = today
        #endif

        let med1 = Medication(
            id: UUID(),
            name: "Vitamin D3",
            dosage: "1000IU",
            instructions: "With Food",
            schedule: "Morning",
            stock: 24,
            active: true,
            nextDose: med1NextDose
        )

        let med2 = Medication(
             id: UUID(),
             name: "Atorvastatin",
             dosage: "10mg",
             instructions: "After breakfast",
             schedule: "Morning",
             stock: 24,
             active: true
        )

        let med3 = Medication(
             id: UUID(),
             name: "Ibuprofen",
             dosage: "400mg",
             instructions: "Every 6 hours",
             schedule: "Afternoon",
             stock: 3,
             active: true
        )

        // Consultations
        let consult1 = Consultation(
            id: UUID(),
            doctorName: "Dr. Sarah Jenkins",
            specialty: "Cardiologist",
            date: Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today,
            notes: "Continue 5mg Lisinopril daily; follow-up in 3 months."
        )

        // Vitals
        let vital1 = Vital(
            id: UUID(),
            type: .weight,
            value: 75.5,
            date: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today,
            notes: "Morning weigh-in"
        )

        // Logs
        let log1 = Log(
            id: UUID(),
            type: "Medication Taken",
            description: "Omega-3 Dose Taken",
            date: Calendar.current.date(byAdding: .hour, value: -4, to: today) ?? today,
            source: "Manual Log"
        )

        self.data.appointments = [appt1]
        self.data.medications = [med1, med2, med3]
        self.data.consultations = [consult1]
        self.data.vitals = [vital1]
        self.data.logs = [log1]

        Task { await save() }
    }

    // MARK: - CRUD Helpers

    public func addVital(_ vital: Vital) {
        data.vitals.insert(vital, at: 0)
        Task { await save() }
    }

    public func addConsultation(_ consultation: Consultation) {
        data.consultations.insert(consultation, at: 0)
        Task { await save() }
    }

    public func addMedication(_ medication: Medication) {
        data.medications.append(medication)
        Task { await save() }
    }

    public func addAppointment(_ appointment: Appointment) {
        data.appointments.append(appointment)
        // Sort by date
        data.appointments.sort { $0.date < $1.date }
        Task { await save() }
    }

    public func clearData() async {
        do {
            try await repository.clear()
            self.data = MedicalData()
        } catch {
            print("Error clearing data: \(error)")
        }
    }

    // MARK: - Update and Delete Helpers

    public func deleteVital(_ vital: Vital) {
        if let index = data.vitals.firstIndex(where: { $0.id == vital.id }) {
            data.vitals.remove(at: index)
            Task { await save() }
        }
    }

    public func deleteMedication(_ medication: Medication) {
        if let index = data.medications.firstIndex(where: { $0.id == medication.id }) {
            data.medications.remove(at: index)
            Task { await save() }
        }
    }

    public func deleteAppointment(_ appointment: Appointment) {
        if let index = data.appointments.firstIndex(where: { $0.id == appointment.id }) {
            data.appointments.remove(at: index)
            Task { await save() }
        }
    }

    public func deleteConsultation(_ consultation: Consultation) {
        if let index = data.consultations.firstIndex(where: { $0.id == consultation.id }) {
            data.consultations.remove(at: index)
            Task { await save() }
        }
    }

    public func updateVital(_ vital: Vital) {
        if let index = data.vitals.firstIndex(where: { $0.id == vital.id }) {
            data.vitals[index] = vital
            Task { await save() }
        }
    }

    public func updateMedication(_ medication: Medication) {
        if let index = data.medications.firstIndex(where: { $0.id == medication.id }) {
            data.medications[index] = medication
            Task { await save() }
        }
    }

    public func updateAppointment(_ appointment: Appointment) {
        if let index = data.appointments.firstIndex(where: { $0.id == appointment.id }) {
            data.appointments[index] = appointment
            data.appointments.sort { $0.date < $1.date }
            Task { await save() }
        }
    }

    public func updateConsultation(_ consultation: Consultation) {
        if let index = data.consultations.firstIndex(where: { $0.id == consultation.id }) {
            data.consultations[index] = consultation
            Task { await save() }
        }
    }

    public func markMedicationTaken(_ medication: Medication) {
        var updated = medication
        // Simple logic for next dose - 24 hours from now if morning, etc.
        // In a real app this would depend on schedule
        updated.stock = max(0, updated.stock - 1)

        // Next dose is roughly 24 hours from now for daily
        updated.nextDose = Date().addingTimeInterval(86400)

        if let index = data.medications.firstIndex(where: { $0.id == updated.id }) {
            data.medications[index] = updated
        }

        // Also add a log
        let log = Log(
            id: UUID(),
            type: "Medication Taken",
            description: "\(medication.name) Dose Taken",
            date: Date(),
            source: "Manual Log"
        )
        data.logs.insert(log, at: 0)
        Task { await save() }
    }

    // MARK: - Notification Settings
    public func updateNotificationSettings(_ settings: NotificationSettings) {
        self.data.notificationSettings = settings
        Task { await save() }
    }

}
