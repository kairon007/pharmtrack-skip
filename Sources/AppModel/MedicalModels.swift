import Foundation

public struct MedicalData: Codable, Sendable {
    public var appointments: [Appointment] = []
    public var medications: [Medication] = []
    public var consultations: [Consultation] = []
    public var vitals: [Vital] = []
    public var logs: [Log] = []
    public var notificationSettings: NotificationSettings = NotificationSettings()

    public init() {}

    enum CodingKeys: String, CodingKey {
        case appointments
        case medications
        case consultations
        case vitals
        case logs
        case notificationSettings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appointments = try container.decodeIfPresent([Appointment].self, forKey: .appointments) ?? []
        self.medications = try container.decodeIfPresent([Medication].self, forKey: .medications) ?? []
        self.consultations = try container.decodeIfPresent([Consultation].self, forKey: .consultations) ?? []
        self.vitals = try container.decodeIfPresent([Vital].self, forKey: .vitals) ?? []
        self.logs = try container.decodeIfPresent([Log].self, forKey: .logs) ?? []
        self.notificationSettings = try container.decodeIfPresent(NotificationSettings.self, forKey: .notificationSettings) ?? NotificationSettings()
    }
}

public struct NotificationSettings: Codable, Sendable, Equatable {
    public var allNotificationsEnabled: Bool
    public var medicationsEnabled: Bool
    public var appointmentsEnabled: Bool
    public var consultationsEnabled: Bool
    public var lowStockEnabled: Bool

    public var lowStockThreshold: Int

    public var medicationReminderTime: ReminderTime // e.g., "At time of event", "5 minutes before"
    public var appointmentReminderTime: ReminderTime // e.g., "1 day before", "1 hour before"

    public enum ReminderTime: String, Codable, Sendable, CaseIterable, Equatable {
        case atTime = "At time of event"
        case fiveMinutes = "5 minutes before"
        case oneHour = "1 hour before"
        case oneDay = "1 day before"
    }

    public init(allNotificationsEnabled: Bool = true, medicationsEnabled: Bool = true, appointmentsEnabled: Bool = true, consultationsEnabled: Bool = true, lowStockEnabled: Bool = true, lowStockThreshold: Int = 5, medicationReminderTime: ReminderTime = .atTime, appointmentReminderTime: ReminderTime = .oneDay) {
        self.allNotificationsEnabled = allNotificationsEnabled
        self.medicationsEnabled = medicationsEnabled
        self.appointmentsEnabled = appointmentsEnabled
        self.consultationsEnabled = consultationsEnabled
        self.lowStockEnabled = lowStockEnabled
        self.medicationReminderTime = medicationReminderTime
        self.appointmentReminderTime = appointmentReminderTime
        self.lowStockThreshold = lowStockThreshold
    }
}

public struct Appointment: Identifiable, Codable, Sendable {
    public let id: UUID
    public var doctorName: String
    public var specialty: String
    public var type: String // "General Checkup", "Follow-up", etc.
    public var date: Date
    public var location: String
    public var notes: String?
    public var notify: Bool

    public init(id: UUID = UUID(), doctorName: String, specialty: String, type: String, date: Date, location: String, notes: String? = nil, notify: Bool = true) {
        self.id = id
        self.doctorName = doctorName
        self.specialty = specialty
        self.type = type
        self.date = date
        self.location = location
        self.notes = notes
        self.notify = notify
    }
}

public struct Medication: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var dosage: String
    public var instructions: String // "With Food", "After breakfast", etc.
    public var schedule: String // "Morning", "Afternoon", "Evening"
    public var stock: Int
    public var active: Bool
    public var nextDose: Date?

    public init(id: UUID = UUID(), name: String, dosage: String, instructions: String, schedule: String, stock: Int, active: Bool = true, nextDose: Date? = nil) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.instructions = instructions
        self.schedule = schedule
        self.stock = stock
        self.active = active
        self.nextDose = nextDose
    }
}

public struct Consultation: Identifiable, Codable, Sendable {
    public let id: UUID
    public var doctorName: String
    public var specialty: String
    public var date: Date
    public var notes: String
    public var linkedMedications: [UUID] // IDs of linked meds

    public init(id: UUID = UUID(), doctorName: String, specialty: String, date: Date, notes: String, linkedMedications: [UUID] = []) {
        self.id = id
        self.doctorName = doctorName
        self.specialty = specialty
        self.date = date
        self.notes = notes
        self.linkedMedications = linkedMedications
    }
}

public struct Vital: Identifiable, Codable, Sendable {
    public let id: UUID
    public var type: VitalType
    public var value: Double // e.g., weight in kg, or systolic for BP (needs special handling for BP composite)
    public var value2: Double? // e.g., diastolic for BP
    public var date: Date
    public var notes: String?

    public enum VitalType: String, Codable, Sendable {
        case weight
        case bloodPressure
        case bloodSugar
    }

    public init(id: UUID = UUID(), type: VitalType, value: Double, value2: Double? = nil, date: Date, notes: String? = nil) {
        self.id = id
        self.type = type
        self.value = value
        self.value2 = value2
        self.date = date
        self.notes = notes
    }
}

public struct Log: Identifiable, Codable, Sendable {
    public let id: UUID
    public var type: String // "Medication Taken", "Vital Updated", etc.
    public var description: String
    public var date: Date
    public var source: String // "Manual Log", "Device Sync"

    public init(id: UUID = UUID(), type: String, description: String, date: Date, source: String) {
        self.id = id
        self.type = type
        self.description = description
        self.date = date
        self.source = source
    }
}
