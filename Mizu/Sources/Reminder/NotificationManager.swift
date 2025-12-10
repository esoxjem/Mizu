import Foundation
import os.log
import UserNotifications

final class NotificationManager: NSObject {

    static let shared = NotificationManager()

    private let preferences = Preferences()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.esoxjem.mizu", category: "NotificationManager")

    private override init() {
        super.init()
        notificationCenter.delegate = self
        logger.info("NotificationManager initialized, delegate set")
    }

    // MARK: - Permission Request

    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        guard !preferences.hasRequestedNotificationPermission() else {
            logger.info("Permission already requested previously, checking current status")
            checkCurrentAuthorization(completion: completion)
            return
        }

        logger.info("First launch - requesting notification permission")
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                self.logger.error("Permission request failed: \(error.localizedDescription)")
            } else {
                self.logger.info("Permission request completed - granted: \(granted)")
            }
            DispatchQueue.main.async {
                self.preferences.markNotificationPermissionRequested()
                completion(granted)
            }
        }
    }

    private func checkCurrentAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            let authorized = settings.authorizationStatus == .authorized
            self.logger.info("Current authorization status: \(settings.authorizationStatus.rawValue) (authorized: \(authorized))")
            DispatchQueue.main.async {
                completion(authorized)
            }
        }
    }

    // MARK: - Notification Delivery

    func deliverNotification(title: String, body: String, withSound: Bool) {
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

        notificationCenter.add(request) { error in
            if let error = error {
                self.logger.error("Failed to deliver notification: \(error.localizedDescription)")
            } else {
                self.logger.info("Notification delivered successfully")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
