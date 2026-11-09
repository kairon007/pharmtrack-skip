import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif
import AppModel

public class NotificationManager: NSObject, NotificationManagerProtocol, @unchecked Sendable {
    public static let shared = NotificationManager()
    
    #if SKIP
    public static var androidContext: android.content.Context?
    #endif

    private override init() {
        super.init()
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().delegate = self
        #endif
    }

    public func requestAuthorization() {
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
        #endif
    }

    public func scheduleTestNotification() {
        #if canImport(UserNotifications)
        print("Scheduling test notification in 10 seconds...")
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from PharmTrack!"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notif-\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled successfully.")
            }
        }
        #else
        #if SKIP
        scheduleAndroidTestNotification()
        #endif
        #endif
    }
    
    #if SKIP
    private func scheduleAndroidTestNotification() {
        guard let context = Self.androidContext else {
            print("Android context not set - cannot schedule notifications")
            return
        }
        
        print("Scheduling Android test notification...")
        let channelId = "test_notifications"
        createAndroidNotificationChannel(context, channelId, "Test Notifications")
        
        let builder = androidx.core.app.NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Test Notification")
            .setContentText("This is a test notification from PharmTrack!")
            .setAutoCancel(true)
        
        let notification = builder.build()
        let notificationManager = context.getSystemService(android.content.Context.NOTIFICATION_SERVICE) as? android.app.NotificationManager
        notificationManager?.notify(UUID().uuidString.hashCode(), notification)
        print("Android test notification scheduled successfully.")
    }
    
    public func createAndroidNotificationChannel(_ context: android.content.Context, _ channelId: String, _ channelName: String) {
        if #available(android 8.0) {
            let importance = android.app.NotificationManager.IMPORTANCE_DEFAULT
            let channel = android.app.NotificationChannel(channelId, channelName, importance)
            let notificationManager = context.getSystemService(android.content.Context.NOTIFICATION_SERVICE) as? android.app.NotificationManager
            notificationManager?.createNotificationChannel(channel)
        }
    }
    #endif

    public func updateNotifications(with data: MedicalData) {
        #if canImport(UserNotifications)
        let settings = data.notificationSettings
        let center = UNUserNotificationCenter.current()

        center.removeAllPendingNotificationRequests()

        guard settings.allNotificationsEnabled else { return }

        if settings.medicationsEnabled {
            for medication in data.medications where medication.active {
                scheduleMedicationReminder(for: medication, settings: settings)
            }
        }

        if settings.lowStockEnabled {
            for medication in data.medications where medication.active {
                if medication.stock <= settings.lowStockThreshold {
                    scheduleLowStockAlert(for: medication)
                }
            }
        }

        if settings.appointmentsEnabled {
            for appointment in data.appointments where appointment.date > Date() && appointment.notify {
                scheduleAppointmentAlert(for: appointment, settings: settings)
            }
        }

        if settings.consultationsEnabled {
            for consultation in data.consultations where consultation.date > Date() {
                scheduleConsultationAlert(for: consultation)
            }
        }
        #else
        #if SKIP
        updateAndroidNotifications(with: data)
        #endif
        #endif
    }
    
    #if SKIP
    private func updateAndroidNotifications(with data: MedicalData) {
        guard let context = Self.androidContext else {
            print("Android context not set - cannot update notifications")
            return
        }
        
        let settings = data.notificationSettings
        guard settings.allNotificationsEnabled else { return }
        
        if settings.medicationsEnabled {
            for medication in data.medications where medication.active {
                scheduleAndroidMedicationReminder(context, medication, settings)
            }
        }
        
        if settings.lowStockEnabled {
            for medication in data.medications where medication.active {
                if medication.stock <= settings.lowStockThreshold {
                    scheduleAndroidLowStockAlert(context, medication)
                }
            }
        }
        
        if settings.appointmentsEnabled {
            for appointment in data.appointments where appointment.date > Date() && appointment.notify {
                scheduleAndroidAppointmentAlert(context, appointment, settings)
            }
        }
        
        if settings.consultationsEnabled {
            for consultation in data.consultations where consultation.date > Date() {
                scheduleAndroidConsultationAlert(context, consultation)
            }
        }
    }
    
    private func scheduleAndroidMedicationReminder(_ context: android.content.Context, _ medication: Medication, _ settings: NotificationSettings) {
        guard let nextDose = medication.nextDose, nextDose > Date() else { return }
        
        var triggerDate = nextDose
        switch settings.medicationReminderTime {
        case .atTime:
            break
        case .fiveMinutes:
            triggerDate = triggerDate.addingTimeInterval(-5 * 60)
        case .oneHour:
            triggerDate = triggerDate.addingTimeInterval(-60 * 60)
        case .oneDay:
            triggerDate = triggerDate.addingTimeInterval(-24 * 60 * 60)
        }
        
        guard triggerDate > Date() else { return }
        
        let channelId = "medication_reminders"
        createAndroidNotificationChannel(context, channelId, "Medication Reminders")
        
        scheduleAndroidNotificationWithAlarm(context, triggerDate, "med-\(medication.id)", "Medication Reminder", "Time to take \(medication.name) (\(medication.dosage)). \(medication.instructions)")
    }
    
    private func scheduleAndroidLowStockAlert(_ context: android.content.Context, _ medication: Medication) {
        let channelId = "low_stock_alerts"
        createAndroidNotificationChannel(context, channelId, "Low Stock Alerts")
        
        let builder = androidx.core.app.NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("Low Medication Stock")
            .setContentText("You only have \(medication.stock) doses left of \(medication.name).")
            .setAutoCancel(true)
        
        let notification = builder.build()
        let notificationManager = context.getSystemService(android.content.Context.NOTIFICATION_SERVICE) as? android.app.NotificationManager
        notificationManager?.notify("lowstock-\(medication.id)".hashCode(), notification)
    }
    
    private func scheduleAndroidAppointmentAlert(_ context: android.content.Context, _ appointment: Appointment, _ settings: NotificationSettings) {
        var triggerDate = appointment.date
        switch settings.appointmentReminderTime {
        case .atTime:
            break
        case .fiveMinutes:
            triggerDate = triggerDate.addingTimeInterval(-5 * 60)
        case .oneHour:
            triggerDate = triggerDate.addingTimeInterval(-60 * 60)
        case .oneDay:
            triggerDate = triggerDate.addingTimeInterval(-24 * 60 * 60)
        }
        
        guard triggerDate > Date() else { return }
        
        let channelId = "appointment_reminders"
        createAndroidNotificationChannel(context, channelId, "Appointment Reminders")
        
        scheduleAndroidNotificationWithAlarm(context, triggerDate, "appt-\(appointment.id)", "Upcoming Appointment", "You have an appointment with \(appointment.doctorName) at \(appointment.location).")
    }
    
    private func scheduleAndroidConsultationAlert(_ context: android.content.Context, _ consultation: Consultation) {
        let triggerDate = consultation.date.addingTimeInterval(-24 * 60 * 60)
        guard triggerDate > Date() else { return }
        
        let channelId = "consultation_reminders"
        createAndroidNotificationChannel(context, channelId, "Consultation Reminders")
        
        scheduleAndroidNotificationWithAlarm(context, triggerDate, "consult-\(consultation.id)", "Upcoming Consultation", "You have a consultation with \(consultation.doctorName).")
    }
    
    private func scheduleAndroidNotificationWithAlarm(_ context: android.content.Context, _ triggerDate: Date, _ identifier: String, _ title: String, _ body: String) {
        let intent = android.content.Intent("pharm.track.NOTIFICATION_ALARM")
        intent.setPackage(context.getPackageName())
        intent.putExtra("title", title)
        intent.putExtra("body", body)
        intent.putExtra("id", identifier)
        
        let pendingIntent = android.app.PendingIntent.getBroadcast(
            context,
            identifier.hashCode(),
            intent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT | android.app.PendingIntent.FLAG_IMMUTABLE
        )
        
        let alarmManager = context.getSystemService(android.content.Context.ALARM_SERVICE) as? android.app.AlarmManager
        let triggerTimeMillis = Int64(triggerDate.timeIntervalSince1970) * 1000
        alarmManager?.setAndAllowWhileIdle(android.app.AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
    }
    #endif

    #if canImport(UserNotifications)
    private func scheduleMedicationReminder(for medication: Medication, settings: NotificationSettings) {
        guard let nextDose = medication.nextDose, nextDose > Date() else { return }

        var triggerDate = nextDose
        switch settings.medicationReminderTime {
        case .atTime:
            break
        case .fiveMinutes:
            triggerDate = triggerDate.addingTimeInterval(-5 * 60)
        case .oneHour:
            triggerDate = triggerDate.addingTimeInterval(-60 * 60)
        case .oneDay:
            triggerDate = triggerDate.addingTimeInterval(-24 * 60 * 60)
        }

        // Don't schedule if the reminder time is already past
        if triggerDate <= Date() { return }

        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name) (\(medication.dosage)). \(medication.instructions)"
        content.sound = UNNotificationSound.default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "med-\(medication.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleLowStockAlert(for medication: Medication) {
        let content = UNMutableNotificationContent()
        content.title = "Low Medication Stock"
        content.body = "You only have \(medication.stock) doses left of \(medication.name)."
        content.sound = UNNotificationSound.default

        // Schedule for next morning at 9 AM or immediately if after 9 AM
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0
        var triggerDate = Calendar.current.date(from: components)!
        if triggerDate <= Date() {
            triggerDate = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate)!
        }

        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        let request = UNNotificationRequest(identifier: "lowstock-\(medication.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleAppointmentAlert(for appointment: Appointment, settings: NotificationSettings) {
        var triggerDate = appointment.date
        switch settings.appointmentReminderTime {
        case .atTime:
            break
        case .fiveMinutes:
            triggerDate = triggerDate.addingTimeInterval(-5 * 60)
        case .oneHour:
            triggerDate = triggerDate.addingTimeInterval(-60 * 60)
        case .oneDay:
            triggerDate = triggerDate.addingTimeInterval(-24 * 60 * 60)
        }

        if triggerDate <= Date() { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "You have an appointment with \(appointment.doctorName) at \(appointment.location)."
        content.sound = UNNotificationSound.default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "appt-\(appointment.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleConsultationAlert(for consultation: Consultation) {
        // Default to 1 day before for consultations
        let triggerDate = consultation.date.addingTimeInterval(-24 * 60 * 60)

        if triggerDate <= Date() { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Consultation"
        content.body = "You have a consultation with \(consultation.doctorName)."
        content.sound = UNNotificationSound.default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "consult-\(consultation.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    #endif
}

#if canImport(UserNotifications)
extension NotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        #if SKIP
        completionHandler([.banner, .sound])
        #else
        completionHandler([.banner, .list, .sound])
        #endif
    }
}
#endif
