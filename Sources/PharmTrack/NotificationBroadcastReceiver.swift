import Foundation

#if SKIP
public class NotificationBroadcastReceiver: android.content.BroadcastReceiver {
    public init() {
    }
    
    override public func onReceive(_ context: android.content.Context?, _ intent: android.content.Intent?) {
        guard let context = context, let intent = intent else { return }
        
        let title = intent.getStringExtra("title") ?? "PharmTrack"
        let body = intent.getStringExtra("body") ?? ""
        let id = intent.getStringExtra("id") ?? "notification"
        
        let channelId = "scheduled_notifications"
        NotificationManager.shared.createAndroidNotificationChannel(context, channelId, "Scheduled Notifications")
        
        let builder = androidx.core.app.NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
        
        let notification = builder.build()
        let notificationManager = context.getSystemService(android.content.Context.NOTIFICATION_SERVICE) as? android.app.NotificationManager
        notificationManager?.notify(id.hashCode(), notification)
        
        print("Notification delivered: \(title)")
    }
}
#endif
