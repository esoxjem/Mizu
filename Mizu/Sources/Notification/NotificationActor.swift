import Foundation
import os.log
import UserNotifications

/// Thread-safe actor for handling notification operations using Swift Concurrency.
/// Replaces the callback-based NotificationManager with async/await.
actor NotificationActor {
    static let shared = NotificationActor()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "NotificationActor")

    private init() {
        logger.info("NotificationActor initialized")
    }

    // MARK: - Permission Request

    /// Requests notification permission if not already determined.
    /// - Returns: `true` if notifications are authorized, `false` otherwise.
    func requestPermissionIfNeeded() async -> Bool {
        let settings = await notificationCenter.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
                logger.info("Permission request completed - granted: \(granted)")
                return granted
            } catch {
                logger.error("Permission request failed: \(error.localizedDescription)")
                return false
            }
        case .authorized, .provisional:
            logger.info("Notifications already authorized")
            return true
        case .denied, .ephemeral:
            logger.info("Notifications denied or ephemeral")
            return false
        @unknown default:
            logger.warning("Unknown authorization status")
            return false
        }
    }

    // MARK: - Notification Delivery

    /// Delivers a notification with the specified content.
    /// - Parameters:
    ///   - title: The notification title
    ///   - body: The notification body text
    ///   - withSound: Whether to play the default notification sound
    func deliverNotification(title: String, body: String, withSound: Bool) async {
        logger.info("Delivering notification: \(title)")

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if withSound {
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await notificationCenter.add(request)
            logger.info("Notification delivered successfully")
        } catch {
            logger.error("Failed to deliver notification: \(error.localizedDescription)")
        }
    }
}
